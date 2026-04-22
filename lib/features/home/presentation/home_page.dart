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
import '../data/news_service.dart';
import '../../analysis/presentation/analysis_page.dart';
import 'widgets/home_search_delegate.dart';
import 'widgets/settings_drawer.dart';

import '../../../../../l10n/generated/app_localizations.dart';

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
    final c    = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final total = controller.recentMatches.length;
    final done  = controller.recentMatches
        .where((m) => m['status'] == AppConstants.statusDone).length;

    return SizedBox(
      height: 260,
      child: Stack(fit: StackFit.expand, children: [
        // Football background image
        Image.network(
          'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=900&q=80',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: c.heroTop),
        ),
        // Dark gradient overlay
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.55),
                Colors.black.withValues(alpha: 0.82),
              ],
            ),
          ),
        ),
        // Content
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Top bar
              Row(children: [
                Icon(Icons.sports_soccer_outlined, color: c.accent, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('PlayVision',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                ),
                GestureDetector(
                  onTap: () => showSearch(context: context, delegate: HomeSearchDelegate(controller)),
                  child: const Icon(Icons.search_rounded, color: Colors.white70, size: 22),
                ),
                const SizedBox(width: 8),
                Builder(builder: (ctx) => GestureDetector(
                  onTap: () => Scaffold.of(ctx).openEndDrawer(),
                  child: const Icon(Icons.settings_outlined, color: Colors.white70, size: 22),
                )),
              ]),

              const Spacer(),

              // Stats row
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l10n.totalMatches,
                      style: const TextStyle(color: Colors.white60, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text('$total',
                      style: const TextStyle(
                        color: Colors.white, fontSize: 52, fontWeight: FontWeight.w900,
                        letterSpacing: -2, height: 1,
                      )),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: c.accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: c.accent.withValues(alpha: 0.5)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.check_circle_rounded, color: c.accent, size: 12),
                      const SizedBox(width: 4),
                      Text('$done ${l10n.analysed}',
                          style: TextStyle(color: c.accent, fontSize: 11, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  _SparkLine(values: const [0.4, 0.6, 0.3, 0.8, 0.5, 0.9, 0.7], color: c.accent),
                  const SizedBox(height: 6),
                  Text(DateFormat('EEE d MMM').format(DateTime.now()),
                      style: const TextStyle(color: Colors.white54, fontSize: 11)),
                ]),
              ]),
            ]),
          ),
        ),
      ]),
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
    final l10n = AppLocalizations.of(context)!; // TRADUCCION

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l10n.selectOrCreateTeam, // TRADUCIDO
            style: TextStyle(color: c.text, fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(l10n.chooseTeamSubtitle, // TRADUCIDO
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
                Text(l10n.createTeam, // TRADUCIDO
                    style: TextStyle(color: c.text, fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(l10n.tapToAddTeam, // TRADUCIDO
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
                _TeamCircleItem(label: l10n.newTeam, initial: '+', isAdd: true, onTap: onAdd), // TRADUCIDO
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
    final l10n = AppLocalizations.of(context)!; // TRADUCCION
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
              child: Text(l10n.changeTeam, // TRADUCIDO
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
    final l10n = AppLocalizations.of(context)!; // TRADUCCION

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
              Text(l10n.analyseVideo, // TRADUCIDO
                  style: TextStyle(color: c.textHi, fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(l10n.uploadMatchVideo, // TRADUCIDO
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
    final l10n = AppLocalizations.of(context)!; // TRADUCCION

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
            Text(l10n.viewAnalysis, // TRADUCIDO
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
    final l10n = AppLocalizations.of(context)!; // TRADUCCION

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
          Text(l10n.teamMatches, // TRADUCIDO
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
            child: Center(child: Text(l10n.noAnalysedMatches, // TRADUCIDO
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
          Text(l10n.teamMatches, // TRADUCIDO
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
    final l10n = AppLocalizations.of(context)!; // TRADUCCION

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
          _TabPill(label: l10n.resultsTab, active: selected == 0, onTap: () => onSelect(0)), // TRADUCIDO
          _TabPill(label: l10n.newsTab,   active: selected == 1, onTap: () => onSelect(1)),  // TRADUCIDO
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
    final c    = context.colors;
    final l10n = AppLocalizations.of(context)!;

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
            Text(l10n.noRealMatchesToday, style: TextStyle(color: c.muted, fontSize: 13)),
          ])),
        ),
      );
    }

    final typedMatches = matches.cast<Map<String, dynamic>>();

    // Prefer a live match for the hero card
    final hero = typedMatches.firstWhere(
      (m) {
        final s = m['fixture']?['status']?['short'] as String? ?? '';
        return s == '1H' || s == '2H' || s == 'HT';
      },
      orElse: () => typedMatches.first,
    );

    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final m in typedMatches) {
      final key = m['league']?['name'] as String? ?? 'Others';
      grouped.putIfAbsent(key, () => []).add(m);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Hero featured match card
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: _FeaturedMatchCard(match: hero),
      ),

      // "Match Schedule" header
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Match Schedule',
                style: TextStyle(color: c.textHi, fontSize: 20, fontWeight: FontWeight.w800)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(color: c.accentLo, borderRadius: BorderRadius.circular(20)),
              child: Text('${matches.length} matches',
                  style: TextStyle(color: c.accent, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),

      ...grouped.entries.map((entry) => _LeagueGroup(
        leagueName: entry.key,
        leagueLogo: entry.value.first['league']?['logo'] as String? ?? '',
        matches: entry.value,
      )),
      const SizedBox(height: 8),
    ]);
  }
}

// ── Featured hero match card ──────────────────────────────────────────────────

class _FeaturedMatchCard extends StatelessWidget {
  final Map<String, dynamic> match;
  const _FeaturedMatchCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    final homeTeam    = match['teams']?['home']?['name']  as String? ?? 'Home';
    final awayTeam    = match['teams']?['away']?['name']  as String? ?? 'Away';
    final homeLogo    = match['teams']?['home']?['logo']  as String? ?? '';
    final awayLogo    = match['teams']?['away']?['logo']  as String? ?? '';
    final homeGoals   = match['goals']?['home'];
    final awayGoals   = match['goals']?['away'];
    final statusShort = match['fixture']?['status']?['short']   as String? ?? 'NS';
    final elapsed     = match['fixture']?['status']?['elapsed'];
    final dateStr     = match['fixture']?['date']  as String? ?? '';
    final leagueName  = match['league']?['name']   as String? ?? '';
    final leagueLogo  = match['league']?['logo']   as String? ?? '';

    final isLive     = statusShort == '1H' || statusShort == '2H' || statusShort == 'HT';
    final isFinished = statusShort == 'FT' || statusShort == 'AET' || statusShort == 'PEN';

    String timeText = '';
    if (!isFinished && !isLive && dateStr.isNotEmpty) {
      try {
        final dt = DateTime.parse(dateStr).toLocal();
        timeText = DateFormat('HH:mm · dd MMM').format(dt);
      } catch (_) {}
    }
    if (isLive && elapsed != null) timeText = "$elapsed'";

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 230,
        child: Stack(fit: StackFit.expand, children: [
          // Stadium background
          Image.network(
            'https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=800&q=80',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: c.surface),
          ),
          // Dark gradient
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.45),
                  Colors.black.withValues(alpha: 0.90),
                ],
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Top: league + status badge
              Row(children: [
                if (leagueLogo.isNotEmpty)
                  Image.network(leagueLogo, width: 20, height: 20,
                      errorBuilder: (_, __, ___) => const Icon(Icons.emoji_events, color: Colors.white70, size: 16))
                else
                  const Icon(Icons.emoji_events, color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(leagueName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600))),
                if (isLive)
                  _LiveBadge(time: timeText)
                else if (isFinished)
                  _StatusPill(label: 'FT')
                else if (timeText.isNotEmpty)
                  _StatusPill(label: timeText),
              ]),

              const Spacer(),

              // Teams + Score
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: Column(children: [
                  _HeroTeamLogo(logoUrl: homeLogo, name: homeTeam),
                  const SizedBox(height: 8),
                  Text(homeTeam,
                      maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                ])),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: isFinished || isLive
                      ? Row(mainAxisSize: MainAxisSize.min, children: [
                          Text('${homeGoals ?? 0}',
                              style: TextStyle(
                                color: isLive ? c.accent : Colors.white,
                                fontSize: 38, fontWeight: FontWeight.w900, letterSpacing: -1,
                              )),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text('–',
                                style: TextStyle(color: Colors.white38, fontSize: 26, fontWeight: FontWeight.w300)),
                          ),
                          Text('${awayGoals ?? 0}',
                              style: TextStyle(
                                color: isLive ? c.accent : Colors.white,
                                fontSize: 38, fontWeight: FontWeight.w900, letterSpacing: -1,
                              )),
                        ])
                      : const Text('VS',
                          style: TextStyle(
                              color: Colors.white54, fontSize: 22,
                              fontWeight: FontWeight.w800, letterSpacing: 3)),
                ),

                Expanded(child: Column(children: [
                  _HeroTeamLogo(logoUrl: awayLogo, name: awayTeam),
                  const SizedBox(height: 8),
                  Text(awayTeam,
                      maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                ])),
              ]),

              const SizedBox(height: 4),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  final String time;
  const _LiveBadge({required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE91E63),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 6, height: 6,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(time.isEmpty ? 'LIVE' : 'LIVE  $time',
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
      ]),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  const _StatusPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}

class _HeroTeamLogo extends StatelessWidget {
  final String logoUrl;
  final String name;
  const _HeroTeamLogo({required this.logoUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    if (logoUrl.isNotEmpty) {
      return Image.network(logoUrl, width: 52, height: 52,
          errorBuilder: (_, __, ___) => _placeholder());
    }
    return _placeholder();
  }

  Widget _placeholder() => Container(
    width: 52, height: 52,
    decoration: const BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
    child: Center(child: Text(
      name.isNotEmpty ? name[0].toUpperCase() : '?',
      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
    )),
  );
}

// ── League group + match rows ─────────────────────────────────────────────────

class _LeagueGroup extends StatelessWidget {
  final String leagueName;
  final String leagueLogo;
  final List<Map<String, dynamic>> matches;

  const _LeagueGroup({required this.leagueName, required this.leagueLogo, required this.matches});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
        child: Row(children: [
          if (leagueLogo.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(leagueLogo, width: 26, height: 26,
                  errorBuilder: (_, __, ___) => Icon(Icons.emoji_events, color: c.accent, size: 18)),
            )
          else
            Icon(Icons.emoji_events, color: c.accent, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(leagueName,
              style: TextStyle(color: c.text, fontSize: 13, fontWeight: FontWeight.w700))),
          Icon(Icons.chevron_right_rounded, color: c.dim, size: 18),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(children: matches.map((m) => _ResultRowAPI(match: m)).toList()),
      ),
    ]);
  }
}

class _ResultRowAPI extends StatelessWidget {
  final Map<String, dynamic> match;
  const _ResultRowAPI({required this.match});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    final homeTeam    = match['teams']?['home']?['name'] as String? ?? 'Local';
    final awayTeam    = match['teams']?['away']?['name'] as String? ?? 'Away';
    final homeLogo    = match['teams']?['home']?['logo'] as String? ?? '';
    final awayLogo    = match['teams']?['away']?['logo'] as String? ?? '';
    final homeGoals   = match['goals']?['home'];
    final awayGoals   = match['goals']?['away'];
    final statusShort = match['fixture']?['status']?['short'] as String? ?? 'NS';
    final elapsed     = match['fixture']?['status']?['elapsed'];
    final dateStr     = match['fixture']?['date'] as String? ?? '';

    final isLive     = statusShort == '1H' || statusShort == '2H' || statusShort == 'HT';
    final isFinished = statusShort == 'FT' || statusShort == 'AET' || statusShort == 'PEN';

    String centerTop;
    String centerBottom = '';
    Color  centerColor;

    if (isLive) {
      centerTop    = '${homeGoals ?? 0} – ${awayGoals ?? 0}';
      centerBottom = elapsed != null ? "$elapsed'" : 'LIVE';
      centerColor  = const Color(0xFFE91E63);
    } else if (isFinished) {
      centerTop    = '${homeGoals ?? 0} – ${awayGoals ?? 0}';
      centerBottom = 'FT';
      centerColor  = c.textHi;
    } else {
      if (dateStr.isNotEmpty) {
        try {
          final dt = DateTime.parse(dateStr).toLocal();
          centerTop    = DateFormat('HH:mm').format(dt);
          centerBottom = DateFormat('dd MMM').format(dt);
        } catch (_) { centerTop = '--:--'; }
      } else {
        centerTop = '--:--';
      }
      centerColor = c.accent;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLive ? const Color(0xFFE91E63).withValues(alpha: 0.35) : c.border,
        ),
      ),
      child: Row(children: [
        // Home team
        Expanded(child: Row(children: [
          _MatchTeamLogo(logoUrl: homeLogo, name: homeTeam, accentColor: c.accent),
          const SizedBox(width: 8),
          Expanded(child: Text(homeTeam,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(color: c.text, fontSize: 13, fontWeight: FontWeight.w600))),
        ])),

        // Center: score or time
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isLive
                ? const Color(0xFFE91E63).withValues(alpha: 0.12)
                : c.elevated,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(centerTop,
                style: TextStyle(color: centerColor, fontSize: 14, fontWeight: FontWeight.w800)),
            if (centerBottom.isNotEmpty)
              Text(centerBottom,
                  style: TextStyle(
                    color: isLive ? const Color(0xFFE91E63) : c.dim,
                    fontSize: 9, fontWeight: FontWeight.w700,
                  )),
          ]),
        ),

        // Away team
        Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Expanded(child: Text(awayTeam,
              maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.end,
              style: TextStyle(color: c.text, fontSize: 13, fontWeight: FontWeight.w600))),
          const SizedBox(width: 8),
          _MatchTeamLogo(logoUrl: awayLogo, name: awayTeam, accentColor: c.accent),
        ])),
      ]),
    );
  }
}

class _MatchTeamLogo extends StatelessWidget {
  final String logoUrl;
  final String name;
  final Color  accentColor;
  const _MatchTeamLogo({required this.logoUrl, required this.name, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (logoUrl.isNotEmpty) {
      return Image.network(logoUrl, width: 28, height: 28,
          errorBuilder: (_, __, ___) => _placeholder(c));
    }
    return _placeholder(c);
  }

  Widget _placeholder(AppColorTokens c) => Container(
    width: 28, height: 28,
    decoration: BoxDecoration(color: c.elevated, shape: BoxShape.circle),
    child: Center(child: Text(
      name.isNotEmpty ? name[0].toUpperCase() : '?',
      style: TextStyle(color: accentColor, fontSize: 11, fontWeight: FontWeight.w700),
    )),
  );
}

// ── Real news from RSS feeds (ESPN FC + BBC Sport) ────────────────────────────

class _NoticiasSection extends StatefulWidget {
  const _NoticiasSection();

  @override
  State<_NoticiasSection> createState() => _NoticiasSectionState();
}

class _NoticiasSectionState extends State<_NoticiasSection> {
  List<NewsArticle> _articles = [];
  bool _loading = true;
  bool _error   = false;

  // Fallback images when the RSS item has no thumbnail
  static const _fallbackImages = [
    'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=400&q=80',
    'https://images.unsplash.com/photo-1517466787929-bc90951d0974?w=400&q=80',
    'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=400&q=80',
    'https://images.unsplash.com/photo-1459865264687-595d652de67e?w=400&q=80',
    'https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=400&q=80',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = false; });
    try {
      final articles = await NewsService.instance.fetchNews(count: 8);
      if (mounted) setState(() { _articles = articles; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _loading = false; _error = true; });
    }
  }

  String _fallback(int index) => _fallbackImages[index % _fallbackImages.length];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    if (_loading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator(color: c.accent, strokeWidth: 1.5)),
      );
    }

    if (_error || _articles.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: _ErrorCard(onRetry: _load),
      );
    }

    final featured  = _articles.first;
    final rest      = _articles.skip(1).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(children: [
        // Featured big card
        _FeaturedArticleCard(
          article: featured,
          fallbackImage: _fallback(0),
        ),
        const SizedBox(height: 12),
        // Compact rows
        ...rest.asMap().entries.map((e) => _ArticleCard(
          article: e.value,
          fallbackImage: _fallback(e.key + 1),
        )),
        // Refresh row
        const SizedBox(height: 4),
        GestureDetector(
          onTap: _load,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.refresh_rounded, color: c.accent, size: 14),
              const SizedBox(width: 6),
              Text('Refresh news', style: TextStyle(color: c.accent, fontSize: 12, fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorCard({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Column(children: [
        Icon(Icons.wifi_off_rounded, color: c.dim, size: 32),
        const SizedBox(height: 10),
        Text('Could not load news', style: TextStyle(color: c.text, fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text('Check your connection', style: TextStyle(color: c.muted, fontSize: 12)),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: onRetry,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(color: c.accentLo, borderRadius: BorderRadius.circular(8)),
            child: Text('Retry', style: TextStyle(color: c.accent, fontSize: 13, fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }
}

class _FeaturedArticleCard extends StatelessWidget {
  final NewsArticle article;
  final String fallbackImage;
  const _FeaturedArticleCard({required this.article, required this.fallbackImage});

  @override
  Widget build(BuildContext context) {
    final c        = context.colors;
    final imageUrl = article.imageUrl ?? fallbackImage;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 200,
        child: Stack(fit: StackFit.expand, children: [
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Image.network(fallbackImage, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: c.elevated)),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.88)],
              ),
            ),
          ),
          Positioned(
            left: 16, right: 16, bottom: 16,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: c.accent, borderRadius: BorderRadius.circular(6)),
                child: Text(article.category,
                    style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 8),
              Text(article.title,
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700, height: 1.3)),
              const SizedBox(height: 6),
              Text(article.timeAgo,
                  style: const TextStyle(color: Colors.white60, fontSize: 11)),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final NewsArticle article;
  final String fallbackImage;
  const _ArticleCard({required this.article, required this.fallbackImage});

  @override
  Widget build(BuildContext context) {
    final c        = context.colors;
    final imageUrl = article.imageUrl ?? fallbackImage;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Row(children: [
        ClipRRect(
          borderRadius: const BorderRadius.horizontal(left: Radius.circular(13)),
          child: SizedBox(
            width: 90, height: 82,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.network(fallbackImage, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: c.elevated,
                    child: Icon(Icons.sports_soccer, color: c.accent, size: 28),
                  )),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(color: c.accentLo, borderRadius: BorderRadius.circular(5)),
              child: Text(article.category,
                  style: TextStyle(color: c.accent, fontSize: 9, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 5),
            Text(article.title,
                maxLines: 2, overflow: TextOverflow.ellipsis,
                style: TextStyle(color: c.text, fontSize: 12, fontWeight: FontWeight.w600, height: 1.3)),
            const SizedBox(height: 4),
            Text(article.timeAgo, style: TextStyle(color: c.muted, fontSize: 10)),
          ]),
        )),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Icon(Icons.arrow_forward_ios_rounded, color: c.dim, size: 12),
        ),
      ]),
    );
  }
}