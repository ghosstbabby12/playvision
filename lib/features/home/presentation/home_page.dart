import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_color_tokens.dart';
import '../../../../shared/widgets/form_text_field.dart';
import '../controller/home_controller.dart';
import '../../analysis/presentation/analysis_page.dart';
import 'widgets/home_search_delegate.dart';
import 'widgets/settings_drawer.dart';

class HomePage extends StatefulWidget {
  final void Function(int)? onTabChange;
  const HomePage({super.key, this.onTabChange});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController _controller;
  int _selectedTab = 0;

  List<dynamic> _liveMatches = [];
  bool _isLoadingLiveMatches = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = HomeController();
    _controller.loadTeams();
    _controller.loadRecentMatches();
    _fetchLiveMatches();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _fetchLiveMatches());
  }

  Future<void> _fetchLiveMatches() async {
    List<dynamic> matches = [];
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.apiBase}/api/live-matches'),
      );
      if (response.statusCode == 200) {
        matches = (json.decode(response.body) as Map)['data'] ?? [];
      }
    } catch (e) {
      debugPrint('Error API partidos: $e');
    } finally {
      if (mounted) {
        setState(() {
          _liveMatches = matches;
          _isLoadingLiveMatches = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _handleMessages() {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return;

    final error = _controller.errorMessage;
    final success = _controller.successMessage;

    if (error != null || success != null) {
      _controller.consumeMessages();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final c = context.colors;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error ?? success!),
          backgroundColor: error != null ? c.danger : c.accentMid,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        _handleMessages();
        final hasTeam = _controller.selectedTeam != null;

        return Scaffold(
          backgroundColor: c.bg,
          endDrawer: const SettingsDrawer(),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _HeroSection(controller: _controller)),

              if (!hasTeam)
                SliverToBoxAdapter(
                  child: _TeamSelectorSection(
                    controller: _controller,
                    onAdd: () => _openTeamDialog(),
                  ),
                ),

              if (hasTeam) ...[
                SliverToBoxAdapter(
                  child: _SelectedTeamHeader(
                    controller: _controller,
                    onEdit: () => _openTeamDialog(team: _controller.selectedTeam),
                    onDelete: () => _deleteTeam(_controller.selectedTeam!),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _AnalyseButton(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AnalysisPage()),
                    ),
                  ),
                ),
                if (_controller.hasResult)
                  SliverToBoxAdapter(
                    child: _ViewAnalysisButton(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AnalysisPage()),
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: _PreviousAnalysesSection(controller: _controller),
                ),
              ],

              SliverToBoxAdapter(
                child: _TabSelector(
                  selected: _selectedTab,
                  onSelect: (i) => setState(() => _selectedTab = i),
                ),
              ),

              if (_selectedTab == 0)
                SliverToBoxAdapter(
                  child: _ResultadosAPISection(
                    isLoading: _isLoadingLiveMatches,
                    matches: _liveMatches,
                  ),
                )
              else
                const SliverToBoxAdapter(child: _NoticiasSection()),

              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openTeamDialog({Map<String, dynamic>? team}) async {
    final nameCtrl     = TextEditingController(text: team?['name'] as String? ?? '');
    final categoryCtrl = TextEditingController(text: team?['category'] as String? ?? '');
    final clubCtrl     = TextEditingController(text: team?['club'] as String? ?? '');
    final isEdit = team != null;

    XFile? pickedLogo;
    Uint8List? logoBytes;
    bool isSaving = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) {
          final c = ctx.colors;
          return AlertDialog(
            backgroundColor: c.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(isEdit ? 'Edit team' : 'New team',
                style: TextStyle(color: c.text, fontWeight: FontWeight.w700)),
            content: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final file = await picker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 512,
                        maxHeight: 512,
                        imageQuality: 85);
                    if (file == null) return;
                    final bytes = await file.readAsBytes();
                    setDlg(() { pickedLogo = file; logoBytes = bytes; });
                  },
                  child: Stack(alignment: Alignment.bottomRight, children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: c.elevated,
                        shape: BoxShape.circle,
                        border: Border.all(color: c.borderGreen, width: 2),
                        image: logoBytes != null
                            ? DecorationImage(image: MemoryImage(logoBytes!), fit: BoxFit.cover)
                            : (team?['logo_url'] as String?)?.isNotEmpty == true
                                ? DecorationImage(
                                    image: NetworkImage(team!['logo_url'] as String),
                                    fit: BoxFit.cover)
                                : null,
                      ),
                      child: logoBytes == null && (team?['logo_url'] as String?) == null
                          ? Icon(Icons.groups_outlined, color: c.accent, size: 32)
                          : null,
                    ),
                    Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, color: Colors.black, size: 13),
                    ),
                  ]),
                ),
                const SizedBox(height: 6),
                Text(pickedLogo != null ? 'Logo selected' : 'Tap to add logo',
                    style: TextStyle(color: c.muted, fontSize: 11)),
                const SizedBox(height: 16),
                FormTextField(controller: nameCtrl, label: 'Name'),
                const SizedBox(height: 10),
                FormTextField(controller: categoryCtrl, label: 'Category'),
                const SizedBox(height: 10),
                FormTextField(controller: clubCtrl, label: 'Club'),
              ]),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(ctx),
                child: Text('Cancel', style: TextStyle(color: c.muted)),
              ),
              TextButton(
                onPressed: isSaving ? null : () async {
                  if (nameCtrl.text.trim().isEmpty) return;
                  setDlg(() => isSaving = true);

                  String? logoUrl;
                  if (pickedLogo != null && logoBytes != null) {
                    final tmpId = isEdit ? (team['id'] as int) : DateTime.now().millisecondsSinceEpoch;
                    final ext = pickedLogo!.name.split('.').last.toLowerCase();
                    logoUrl = await _controller.uploadLogo(
                        teamId: tmpId, bytes: logoBytes!, extension: ext);
                  }

                  if (isEdit) {
                    await _controller.updateTeam(
                      id: team['id'] as int,
                      name: nameCtrl.text.trim(),
                      category: categoryCtrl.text.trim().isEmpty ? null : categoryCtrl.text.trim(),
                      club: clubCtrl.text.trim().isEmpty ? null : clubCtrl.text.trim(),
                      logoUrl: logoUrl,
                    );
                  } else {
                    await _controller.createTeam(
                      name: nameCtrl.text.trim(),
                      category: categoryCtrl.text.trim().isEmpty ? null : categoryCtrl.text.trim(),
                      club: clubCtrl.text.trim().isEmpty ? null : clubCtrl.text.trim(),
                      logoUrl: logoUrl,
                    );
                  }
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                },
                child: isSaving
                    ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: c.accent))
                    : Text(isEdit ? 'Save' : 'Create',
                        style: TextStyle(color: c.accent, fontWeight: FontWeight.w700)),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteTeam(Map<String, dynamic> team) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final c = ctx.colors;
        return AlertDialog(
          backgroundColor: c.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Delete team',
              style: TextStyle(color: c.text, fontWeight: FontWeight.w700)),
          content: Text('Delete team "${team['name']}"? This cannot be undone.',
              style: TextStyle(color: c.muted, fontSize: 13, height: 1.5)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancel', style: TextStyle(color: c.muted))),
            TextButton(onPressed: () => Navigator.pop(ctx, true),
                child: Text('Delete', style: TextStyle(color: c.danger))),
          ],
        );
      },
    );

    if (confirm == true) await _controller.deleteTeam(team['id'] as int);
  }
}

// ── Section widgets ────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final HomeController controller;
  const _HeroSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final total = controller.recentMatches.length;
    final done  = controller.recentMatches
        .where((m) => m['status'] == AppConstants.statusDone).length;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.heroTop, c.heroBottom],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(Icons.sports_soccer_outlined, color: c.accent, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text('PlayVision',
                  style: TextStyle(color: c.text, fontSize: 18, fontWeight: FontWeight.w800)),
              ),
              GestureDetector(
                onTap: () => showSearch(
                  context: context,
                  delegate: HomeSearchDelegate(controller),
                ),
                child: Icon(Icons.search_rounded, color: c.muted, size: 22),
              ),
              const SizedBox(width: 8),
              Builder(builder: (ctx) => GestureDetector(
                onTap: () => Scaffold.of(ctx).openEndDrawer(),
                child: Icon(Icons.settings_outlined, color: c.muted, size: 22),
              )),
            ]),
            const SizedBox(height: 24),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Total matches', style: TextStyle(color: c.muted, fontSize: 13)),
                const SizedBox(height: 4),
                Text('$total',
                  style: TextStyle(
                    color: c.textHi, fontSize: 56, fontWeight: FontWeight.w900,
                    letterSpacing: -2, height: 1,
                  )),
                const SizedBox(height: 6),
                Row(children: [
                  Icon(Icons.check_circle_rounded, color: c.accent, size: 14),
                  const SizedBox(width: 4),
                  Text('$done analysed',
                    style: TextStyle(color: c.accent, fontSize: 12, fontWeight: FontWeight.w600)),
                ]),
              ])),
              _SparkLine(values: const [0.4, 0.6, 0.3, 0.8, 0.5, 0.9, 0.7], color: c.accent),
            ]),
            const SizedBox(height: 8),
            Text(DateFormat('EEE d MMMM').format(DateTime.now()),
                style: TextStyle(color: c.dim, fontSize: 11)),
          ]),
        ),
      ),
    );
  }
}

class _TeamSelectorSection extends StatelessWidget {
  final HomeController controller;
  final VoidCallback onAdd;

  const _TeamSelectorSection({required this.controller, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Select or create a team',
            style: TextStyle(color: c.text, fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Choose a team to start a new analysis',
            style: TextStyle(color: c.muted, fontSize: 13)),
        const SizedBox(height: 20),

        if (controller.isLoading)
          Center(child: CircularProgressIndicator(color: c.accent, strokeWidth: 1.5))
        else if (controller.teams.isEmpty)
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: c.borderGreen),
              ),
              child: Column(children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(color: c.accentLo, shape: BoxShape.circle),
                  child: Icon(Icons.groups_outlined, color: c.accent, size: 30),
                ),
                const SizedBox(height: 14),
                Text('Create a team',
                    style: TextStyle(color: c.text, fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text('Tap here to add your first team',
                    style: TextStyle(color: c.muted, fontSize: 12)),
              ]),
            ),
          )
        else ...[
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _TeamCircleItem(label: 'New', initial: '+', isAdd: true, onTap: onAdd),
                const SizedBox(width: 14),
                ...controller.teams.map((t) => Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: _TeamCircleItem(
                        label: t['name'] as String? ?? '',
                        initial: _initial(t['name'] as String?),
                        logoUrl: t['logo_url'] as String?,
                        isAdd: false,
                        onTap: () => controller.selectTeam(t),
                      ),
                    )),
              ],
            ),
          ),
        ]
      ]),
    );
  }

  String _initial(String? name) => name?.isNotEmpty == true ? name![0].toUpperCase() : '?';
}

class _TeamCircleItem extends StatelessWidget {
  final String label;
  final String initial;
  final String? logoUrl;
  final bool isAdd;
  final VoidCallback onTap;

  const _TeamCircleItem({
    required this.label,
    required this.initial,
    required this.isAdd,
    required this.onTap,
    this.logoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            color: isAdd ? c.accentLo : c.elevated,
            shape: BoxShape.circle,
            border: Border.all(color: isAdd ? c.borderGreen : c.border, width: 1.5),
            image: !isAdd && logoUrl != null && logoUrl!.isNotEmpty
                ? DecorationImage(image: NetworkImage(logoUrl!), fit: BoxFit.cover)
                : null,
          ),
          child: !isAdd && logoUrl != null && logoUrl!.isNotEmpty
              ? null
              : Center(child: Text(initial,
                  style: TextStyle(
                      color: isAdd ? c.accent : c.text, fontSize: 22, fontWeight: FontWeight.w700))),
        ),
        const SizedBox(height: 6),
        SizedBox(width: 64, child: Text(label,
            maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
            style: TextStyle(color: c.muted, fontSize: 11))),
      ]),
    );
  }
}

class _SelectedTeamHeader extends StatelessWidget {
  final HomeController controller;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SelectedTeamHeader({required this.controller, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final team    = controller.selectedTeam!;
    final initial = (team['name'] as String?)?.isNotEmpty == true ? (team['name'] as String)[0].toUpperCase() : '?';
    final logoUrl = team['logo_url'] as String?;
    final hasLogo = logoUrl != null && logoUrl.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: c.borderGreen),
        ),
        child: Row(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: c.accentLo,
              shape: BoxShape.circle,
              image: hasLogo ? DecorationImage(image: NetworkImage(logoUrl), fit: BoxFit.cover) : null,
            ),
            child: hasLogo ? null : Center(child: Text(initial,
                style: TextStyle(color: c.accent, fontSize: 22, fontWeight: FontWeight.w700))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(team['name'] ?? '',
                style: TextStyle(color: c.text, fontSize: 16, fontWeight: FontWeight.w700)),
            Text('${team['club'] ?? ''} ${team['category'] ?? ''}',
                style: TextStyle(color: c.muted, fontSize: 12)),
          ])),
          GestureDetector(
            onTap: controller.clearTeamSelection,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: c.accentLo, borderRadius: BorderRadius.circular(10)),
              child: Text('Change',
                  style: TextStyle(color: c.accent, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(onTap: onEdit,
              child: Icon(Icons.edit_outlined, color: c.muted, size: 18)),
          const SizedBox(width: 8),
          GestureDetector(onTap: onDelete,
              child: Icon(Icons.delete_outline, color: c.danger, size: 18)),
        ]),
      ),
    );
  }
}

class _AnalyseButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AnalyseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: c.borderGreen),
          ),
          child: Row(children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: c.accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.videocam_outlined, color: c.accent, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Analyse video',
                  style: TextStyle(color: c.textHi, fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Upload a match video and get AI stats',
                  style: TextStyle(color: c.muted, fontSize: 12)),
            ])),
            Icon(Icons.arrow_forward_ios_rounded, color: c.accent, size: 16),
          ]),
        ),
      ),
    );
  }
}

class _ViewAnalysisButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ViewAnalysisButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: c.accent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.analytics_outlined, color: c.bg, size: 20),
            const SizedBox(width: 8),
            Text('View analysis',
                style: TextStyle(color: c.bg, fontSize: 15, fontWeight: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }
}

class _PreviousAnalysesSection extends StatelessWidget {
  final HomeController controller;
  const _PreviousAnalysesSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final teamId = controller.selectedTeam?['id'] as int?;
    if (teamId == null) return const SizedBox.shrink();

    final isLoading = controller.isLoadingMatchesForTeam(teamId);
    final matches   = controller.selectedTeamMatches;

    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Center(child: CircularProgressIndicator(color: c.accent, strokeWidth: 1.5)),
      );
    }

    if (matches.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Team matches',
              style: TextStyle(color: c.text, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.border),
            ),
            child: Center(child: Text('No analysed matches yet',
                style: TextStyle(color: c.muted, fontSize: 13))),
          ),
        ]),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Team matches',
              style: TextStyle(color: c.text, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...matches.map((m) => _MatchItem(
                match: m,
                controller: controller,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AnalysisPage()),
                ),
              )),
        ],
      ),
    );
  }
}

class _MatchItem extends StatefulWidget {
  final Map<String, dynamic> match;
  final VoidCallback onTap;
  final HomeController controller;

  const _MatchItem({required this.match, required this.onTap, required this.controller});

  @override
  State<_MatchItem> createState() => _MatchItemState();
}

class _MatchItemState extends State<_MatchItem> {
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    final c          = context.colors;
    final controller = widget.controller;
    final opponent   = widget.match['opponent'] as String? ?? 'Unknown opponent';
    final dateStr    = widget.match['match_date'] as String? ?? '';
    final status     = widget.match['status'] as String? ?? 'uploaded';
    final matchId    = widget.match['id'] as int;

    DateTime? dt;
    if (dateStr.isNotEmpty) {
      try { dt = DateTime.parse(dateStr).toLocal(); } catch (_) {}
    }
    final formattedDate = dt != null ? DateFormat(AppConstants.dateFormat).format(dt) : '';

    Color statusColor;
    String statusLabel;
    if (status == AppConstants.statusDone) {
      statusColor = c.success;
      statusLabel = AppConstants.labelAnalysed;
    } else if (status == AppConstants.statusProcessing) {
      statusColor = c.warning;
      statusLabel = AppConstants.labelProcessing;
    } else {
      statusColor = c.dim;
      statusLabel = AppConstants.labelUploaded;
    }

    return GestureDetector(
      onTap: () async {
        if (_isDownloading) return;
        if (status == AppConstants.statusDone) {
          setState(() => _isDownloading = true);
          final success = await controller.loadAnalysisForMatch(matchId);
          if (!context.mounted) return;
          setState(() => _isDownloading = false);

          if (success) {
            widget.onTap();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text('Failed to load analysis for this match.'),
              backgroundColor: c.danger,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('This match is not analysed yet.'),
            backgroundColor: c.warning,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.border),
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: c.elevated,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.sports_soccer_outlined, color: c.dim, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('vs $opponent',
                  style: TextStyle(color: c.text, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Row(children: [
                Text(formattedDate, style: TextStyle(color: c.muted, fontSize: 11)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(statusLabel,
                      style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.w700)),
                ),
              ]),
            ]),
          ),
          if (_isDownloading)
            SizedBox(width: 16, height: 16,
                child: CircularProgressIndicator(color: c.accent, strokeWidth: 2))
          else
            Icon(Icons.arrow_forward_ios_rounded, color: c.dim, size: 13),
        ]),
      ),
    );
  }
}

class _SparkLine extends StatelessWidget {
  final List<double> values;
  final Color color;
  const _SparkLine({required this.values, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80, height: 36,
      child: CustomPaint(painter: _SparkPainter(values, color)),
    );
  }
}

class _SparkPainter extends CustomPainter {
  final List<double> values;
  final Color color;
  const _SparkPainter(this.values, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final x = size.width * (i / (values.length - 1));
      final y = size.height * (1 - values[i]);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparkPainter old) => old.color != color;
}

class _TabSelector extends StatelessWidget {
  final int selected;
  final void Function(int) onSelect;

  const _TabSelector({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.border),
        ),
        child: Row(children: [
          _TabPill(label: 'Resultados', active: selected == 0, onTap: () => onSelect(0)),
          _TabPill(label: 'Noticias',   active: selected == 1, onTap: () => onSelect(1)),
        ]),
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabPill({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? c.accentLo : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: active ? Border.all(color: c.borderGreen) : null,
          ),
          child: Text(label, textAlign: TextAlign.center,
              style: TextStyle(
                  color: active ? c.accent : c.muted,
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
        ),
      ),
    );
  }
}

class _ResultadosAPISection extends StatelessWidget {
  final bool isLoading;
  final List<dynamic> matches;

  const _ResultadosAPISection({required this.isLoading, required this.matches});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator(color: c.accent, strokeWidth: 1.5)),
      );
    }

    if (matches.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.border),
          ),
          child: Center(child: Column(children: [
            Icon(Icons.sports_soccer_outlined, color: c.dim, size: 28),
            const SizedBox(height: 8),
            Text('No real matches today', style: TextStyle(color: c.muted, fontSize: 13)),
          ])),
        ),
      );
    }

    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final m in matches) {
      final key = m['league']?['name'] as String? ?? 'Others';
      grouped.putIfAbsent(key, () => []).add(m);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
      child: Column(
        children: grouped.entries.map((entry) => _LeagueGroup(
          leagueName: entry.key,
          leagueLogo: entry.value.first['league']?['logo'] as String? ?? '',
          matches: entry.value,
        )).toList(),
      ),
    );
  }
}

class _LeagueGroup extends StatelessWidget {
  final String leagueName;
  final String leagueLogo;
  final List<Map<String, dynamic>> matches;

  const _LeagueGroup({required this.leagueName, required this.leagueLogo, required this.matches});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
          child: Row(children: [
            SizedBox(
              width: 24, height: 24,
              child: leagueLogo.isNotEmpty
                  ? Image.network(leagueLogo,
                      errorBuilder: (_, __, ___) => Icon(Icons.emoji_events, color: c.accent, size: 16))
                  : Icon(Icons.emoji_events, color: c.accent, size: 16),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(leagueName,
                style: TextStyle(color: c.text, fontSize: 13, fontWeight: FontWeight.w700))),
          ]),
        ),
        ...matches.map((m) => _ResultRowAPI(match: m)),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _ResultRowAPI extends StatelessWidget {
  final Map<String, dynamic> match;
  const _ResultRowAPI({required this.match});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    final homeTeam  = match['teams']?['home']?['name'] ?? 'Local';
    final awayTeam  = match['teams']?['away']?['name'] ?? 'Away';
    final homeLogo  = match['teams']?['home']?['logo'] ?? '';
    final awayLogo  = match['teams']?['away']?['logo'] ?? '';
    final homeGoals = match['goals']?['home'];
    final awayGoals = match['goals']?['away'];
    final statusShort = match['fixture']?['status']?['short'] ?? 'NS';
    final elapsed     = match['fixture']?['status']?['elapsed'] ?? 0;
    final dateStr     = match['fixture']?['date'] ?? '';

    String timeLabel = '';
    String dateLabel = '';
    if (dateStr.isNotEmpty) {
      try {
        final dt = DateTime.parse(dateStr).toLocal();
        timeLabel = DateFormat('HH:mm').format(dt);
        dateLabel = DateFormat('dd MMM').format(dt);
      } catch (_) {}
    }

    final isLive     = statusShort == '1H' || statusShort == '2H' || statusShort == 'HT';
    final isFinished = statusShort == 'FT' || statusShort == 'AET' || statusShort == 'PEN';

    Color statusColor;
    String statusLabel;
    String scoreText;

    if (isFinished) {
      statusColor = c.dim;
      statusLabel = 'Finalizado';
      scoreText   = '$homeGoals - $awayGoals';
    } else if (isLive) {
      statusColor = c.success;
      statusLabel = 'En Vivo';
      timeLabel   = "$elapsed'";
      scoreText   = '$homeGoals - $awayGoals';
    } else {
      statusColor = c.muted;
      statusLabel = 'Programado';
      scoreText   = '-';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.border)),
      ),
      child: Row(children: [
        SizedBox(
          width: 58,
          child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Text(statusLabel, textAlign: TextAlign.center,
                style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(timeLabel,
                style: TextStyle(color: isLive ? statusColor : c.muted, fontSize: 12, fontWeight: FontWeight.bold)),
            Text(dateLabel, style: TextStyle(color: c.dim, fontSize: 10)),
          ]),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: _TeamBadgeAPI(name: homeTeam, logoUrl: homeLogo)),
            const SizedBox(width: 8),
            Text('vs', style: TextStyle(color: c.dim, fontSize: 11)),
            const SizedBox(width: 8),
            Expanded(child: _TeamBadgeAPI(name: awayTeam, logoUrl: awayLogo)),
          ]),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isLive ? c.successBg : c.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(scoreText,
              style: TextStyle(
                  color: isLive ? c.success : (isFinished ? c.text : c.dim),
                  fontSize: 14, fontWeight: FontWeight.w800)),
        ),
      ]),
    );
  }
}

class _TeamBadgeAPI extends StatelessWidget {
  final String name;
  final String logoUrl;

  const _TeamBadgeAPI({required this.name, required this.logoUrl});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(children: [
      if (logoUrl.isNotEmpty)
        Image.network(logoUrl, width: 22, height: 22,
            errorBuilder: (_, __, ___) => const SizedBox(width: 22, height: 22))
      else
        Container(
          width: 22, height: 22,
          decoration: BoxDecoration(color: c.elevated, shape: BoxShape.circle),
          child: Center(child: Text(name.isNotEmpty ? name[0] : '?',
              style: TextStyle(color: c.accent, fontSize: 10, fontWeight: FontWeight.w700))),
        ),
      const SizedBox(width: 5),
      Expanded(child: Text(name, overflow: TextOverflow.ellipsis,
          style: TextStyle(color: c.text, fontSize: 12, fontWeight: FontWeight.w500))),
    ]);
  }
}

class _NoticiasSection extends StatelessWidget {
  const _NoticiasSection();

  static const _articles = [
    (category: 'Análisis',     title: 'Cómo el análisis de video está cambiando el fútbol moderno',             time: 'Hace 2 horas', icon: Icons.analytics_outlined),
    (category: 'Táctica',      title: 'Presión alta vs bloque bajo: ¿cuál funciona mejor según los datos?',     time: 'Hace 5 horas', icon: Icons.architecture_outlined),
    (category: 'Entrenamiento',title: '5 ejercicios para mejorar el recorrido total de tus jugadores',           time: 'Hace 1 día',   icon: Icons.fitness_center_outlined),
    (category: 'IA Fútbol',    title: 'YOLO y la detección de jugadores: el futuro del scouting',               time: 'Hace 2 días',  icon: Icons.smart_toy_outlined),
    (category: 'Posiciones',   title: 'Mapas de calor: cómo leer las zonas de dominio en cancha',               time: 'Hace 3 días',  icon: Icons.map_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(children: _articles.map((a) => _ArticleCard(
            category: a.category,
            title: a.title,
            time: a.time,
            icon: a.icon,
          )).toList()),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final String category;
  final String title;
  final String time;
  final IconData icon;

  const _ArticleCard({required this.category, required this.title, required this.time, required this.icon});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Row(children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(color: c.accentLo, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: c.accent, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: c.accentLo, borderRadius: BorderRadius.circular(6)),
            child: Text(category,
                style: TextStyle(color: c.accent, fontSize: 10, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 6),
          Text(title, maxLines: 2, overflow: TextOverflow.ellipsis,
              style: TextStyle(color: c.text, fontSize: 13, fontWeight: FontWeight.w600, height: 1.3)),
          const SizedBox(height: 4),
          Text(time, style: TextStyle(color: c.muted, fontSize: 11)),
        ])),
        const SizedBox(width: 8),
        Icon(Icons.arrow_forward_ios_rounded, color: c.dim, size: 13),
      ]),
    );
  }
}
