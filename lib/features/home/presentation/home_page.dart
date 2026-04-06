import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/form_text_field.dart';
import '../controller/home_controller.dart';
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
  int _selectedTab = 0; // 0 = Resultados, 1 = Noticias
  
  // Variables para la API de Partidos en Vivo
  List<dynamic> _liveMatches = [];
  bool _isLoadingLiveMatches = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = HomeController();
    _controller.loadTeams();
    _controller.loadRecentMatches();

    // Iniciar carga de partidos en vivo
    _fetchLiveMatches();
    // Actualizar cada 60 segundos
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _fetchLiveMatches();
    });
  }

  // --- FUNCIÓN CON LA IP DE TU COMPUTADORA ---
  Future<void> _fetchLiveMatches() async {
    try {
      String apiUrl = "http://127.0.0.1:8000/api/live-matches";
      
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        if (mounted) {
          setState(() {
            _liveMatches = decodedData['data'] ?? [];
            _isLoadingLiveMatches = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error API partidos: $e");
      if (mounted) {
        setState(() => _isLoadingLiveMatches = false);
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
    final error   = _controller.errorMessage;
    final success = _controller.successMessage;
    if (error != null || success != null) {
      _controller.consumeMessages();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error ?? success!),
          backgroundColor: error != null ? AppColors.danger : AppColors.accentMid,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        _handleMessages();
        final hasTeam = _controller.selectedTeam != null;

        return Scaffold(
          backgroundColor: AppColors.bg,
          endDrawer: const SettingsDrawer(),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _HeroSection(controller: _controller)),

              if (!hasTeam) ...[
                SliverToBoxAdapter(child: _TeamSelectorSection(
                  controller: _controller,
                  onAdd: () => _openTeamDialog(),
                )),
              ],

              if (hasTeam) ...[
                SliverToBoxAdapter(child: _SelectedTeamHeader(
                  controller: _controller,
                  onEdit: () => _openTeamDialog(team: _controller.selectedTeam),
                  onDelete: () => _deleteTeam(_controller.selectedTeam!),
                )),

                SliverToBoxAdapter(child: _AnalyseButton(
                  onTap: () => widget.onTabChange?.call(1),
                )),

                if (_controller.hasResult)
                  SliverToBoxAdapter(child: _ViewAnalysisButton(
                    onTap: () => widget.onTabChange?.call(1),
                  )),

                SliverToBoxAdapter(child: _PreviousAnalysesSection(
                  controller: _controller,
                  onTabChange: widget.onTabChange,
                )),
              ],

              SliverToBoxAdapter(child: _TabSelector(
                selected: _selectedTab,
                onSelect: (i) => setState(() => _selectedTab = i),
              )),
              
              if (_selectedTab == 0)
                SliverToBoxAdapter(child: _ResultadosAPISection(
                  isLoading: _isLoadingLiveMatches,
                  matches: _liveMatches,
                ))
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
    final nameCtrl     = TextEditingController(text: team?['name']     as String? ?? '');
    final categoryCtrl = TextEditingController(text: team?['category'] as String? ?? '');
    final clubCtrl     = TextEditingController(text: team?['club']     as String? ?? '');
    final isEdit       = team != null;

    XFile?     pickedLogo;
    Uint8List? logoBytes;
    bool       isSaving = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(isEdit ? 'Edit team' : 'New team',
              style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // ── Logo picker ──────────────────────────────────
              GestureDetector(
                onTap: () async {
                  final picker = ImagePicker();
                  final file   = await picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 512, maxHeight: 512, imageQuality: 85,
                  );
                  if (file == null) return;
                  final bytes = Uint8List.fromList(await file.readAsBytes());
                  setDlg(() { pickedLogo = file; logoBytes = bytes; });
                },
                child: Stack(alignment: Alignment.bottomRight, children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.elevated,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderGreen, width: 2),
                      image: logoBytes != null
                          ? DecorationImage(
                              image: MemoryImage(logoBytes!),
                              fit: BoxFit.cover)
                          : (team?['logo_url'] as String?)?.isNotEmpty == true
                              ? DecorationImage(
                                  image: NetworkImage(team!['logo_url'] as String),
                                  fit: BoxFit.cover)
                              : null,
                    ),
                    child: (logoBytes == null && (team?['logo_url'] as String?) == null)
                        ? const Icon(Icons.groups_outlined, color: AppColors.accent, size: 32)
                        : null,
                  ),
                  Container(
                    width: 24, height: 24,
                    decoration: const BoxDecoration(
                        color: AppColors.accent, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, color: Colors.black, size: 13),
                  ),
                ]),
              ),
              const SizedBox(height: 6),
              Text(pickedLogo != null ? 'Logo selected' : 'Tap to add logo',
                  style: const TextStyle(color: AppColors.muted, fontSize: 11)),
              const SizedBox(height: 16),
              FormTextField(controller: nameCtrl,     label: 'Name'),
              const SizedBox(height: 10),
              FormTextField(controller: categoryCtrl, label: 'Category'),
              const SizedBox(height: 10),
              FormTextField(controller: clubCtrl,     label: 'Club'),
            ]),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.muted)),
            ),
            TextButton(
              onPressed: isSaving ? null : () async {
                if (nameCtrl.text.trim().isEmpty) return;
                setDlg(() => isSaving = true);

                // Upload logo if a new one was picked
                String? logoUrl;
                if (pickedLogo != null && logoBytes != null) {
                  final tmpId = isEdit ? (team['id'] as int) : DateTime.now().millisecondsSinceEpoch;
                  final ext   = pickedLogo!.name.split('.').last.toLowerCase();
                  logoUrl = await _controller.uploadLogo(
                    teamId: tmpId, bytes: logoBytes!, extension: ext,
                  );
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
                  ? const SizedBox(width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent))
                  : Text(isEdit ? 'Save' : 'Create',
                      style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteTeam(Map<String, dynamic> team) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete team',
            style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w700)),
        content: Text('Delete "${team['name']}"? This cannot be undone.',
            style: const TextStyle(color: AppColors.muted, fontSize: 13, height: 1.5)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel', style: TextStyle(color: AppColors.muted))),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete', style: TextStyle(color: AppColors.danger))),
        ],
      ),
    );
    if (confirm == true) await _controller.deleteTeam(team['id'] as int);
  }
}

class _HeroSection extends StatelessWidget {
  final HomeController controller;
  const _HeroSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final total = controller.recentMatches.length;
    final done  = controller.recentMatches
        .where((m) => m['status'] == AppConstants.statusDone).length;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [AppColors.heroTop, AppColors.heroBottom],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.sports_soccer_outlined, color: AppColors.accent, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('PlayVision', style: TextStyle(
                    color: AppColors.text, fontSize: 18, fontWeight: FontWeight.w800)),
              ),
              GestureDetector(
                  onTap: () => showSearch(
                    context: context,
                    delegate: HomeSearchDelegate(controller),
                  ),
                  child: const Icon(Icons.search_rounded, color: AppColors.muted, size: 22)),
              const SizedBox(width: 8),
              Builder(builder: (ctx) => GestureDetector(
                onTap: () => Scaffold.of(ctx).openEndDrawer(),
                child: const Icon(Icons.settings_outlined, color: AppColors.muted, size: 22),
              )),
            ]),
            const SizedBox(height: 24),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Total matches', style: TextStyle(color: AppColors.muted, fontSize: 13)),
                const SizedBox(height: 4),
                Text('$total', style: const TextStyle(
                    color: AppColors.textHi, fontSize: 56,
                    fontWeight: FontWeight.w900, letterSpacing: -2, height: 1)),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 14),
                  const SizedBox(width: 4),
                  Text('$done analysed', style: const TextStyle(
                      color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w600)),
                ]),
              ])),
              const _SparkLine(values: [0.4, 0.6, 0.3, 0.8, 0.5, 0.9, 0.7]),
            ]),
            const SizedBox(height: 8),
            Text(DateFormat('EEE d MMMM').format(DateTime.now()),
                style: const TextStyle(color: AppColors.dim, fontSize: 11)),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Select or create a team',
            style: TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text('Choose a team to start a new analysis',
            style: TextStyle(color: AppColors.muted, fontSize: 13)),
        const SizedBox(height: 20),
        if (controller.isLoading)
          const Center(child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 1.5))
        else if (controller.teams.isEmpty)
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderGreen),
              ),
              child: Column(children: [
                Container(
                  width: 64, height: 64,
                  decoration: const BoxDecoration(color: AppColors.accentLo, shape: BoxShape.circle),
                  child: const Icon(Icons.groups_outlined, color: AppColors.accent, size: 30),
                ),
                const SizedBox(height: 14),
                const Text('Create a team', style: TextStyle(
                    color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                const Text('Tap here to add your first team',
                    style: TextStyle(color: AppColors.muted, fontSize: 12)),
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
                    label:   t['name']    as String? ?? '—',
                    initial: _initial(t['name'] as String?),
                    logoUrl: t['logo_url'] as String?,
                    isAdd:   false,
                    onTap:   () => controller.selectTeam(t),
                  ),
                )),
              ],
            ),
          ),
        ],
      ]),
    );
  }

  String _initial(String? name) =>
      (name?.isNotEmpty == true) ? name![0].toUpperCase() : '?';
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
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 60, height: 60,
        decoration: BoxDecoration(
          color: isAdd ? AppColors.accentLo : AppColors.elevated,
          shape: BoxShape.circle,
          border: Border.all(
            color: isAdd ? AppColors.borderGreen : AppColors.border, width: 1.5),
          image: (!isAdd && logoUrl != null && logoUrl!.isNotEmpty)
              ? DecorationImage(
                  image: NetworkImage(logoUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: (!isAdd && logoUrl != null && logoUrl!.isNotEmpty)
            ? null
            : Center(child: Text(initial, style: TextStyle(
                color: isAdd ? AppColors.accent : AppColors.text,
                fontSize: 22, fontWeight: FontWeight.w700))),
      ),
      const SizedBox(height: 6),
      SizedBox(width: 64, child: Text(label,
          maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.muted, fontSize: 11))),
    ]),
  );
}

class _SelectedTeamHeader extends StatelessWidget {
  final HomeController controller;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _SelectedTeamHeader({required this.controller, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final team    = controller.selectedTeam!;
    final initial = (team['name'] as String?)?.isNotEmpty == true
        ? (team['name'] as String)[0].toUpperCase() : '?';
    final logoUrl = team['logo_url'] as String?;
    final hasLogo = logoUrl != null && logoUrl.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderGreen),
        ),
        child: Row(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: AppColors.accentLo,
              shape: BoxShape.circle,
              image: hasLogo
                  ? DecorationImage(
                      image: NetworkImage(logoUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: hasLogo
                ? null
                : Center(child: Text(initial, style: const TextStyle(
                    color: AppColors.accent, fontSize: 22, fontWeight: FontWeight.w700))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(team['name'] ?? '—',
                style: const TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w700)),
            Text('${team['club'] ?? '—'} · ${team['category'] ?? '—'}',
                style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          ])),
          GestureDetector(
            onTap: controller.clearTeamSelection,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentLo,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('Change', style: TextStyle(
                  color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(onTap: onEdit,
              child: const Icon(Icons.edit_outlined, color: AppColors.muted, size: 18)),
          const SizedBox(width: 8),
          GestureDetector(onTap: onDelete,
              child: const Icon(Icons.delete_outline, color: AppColors.danger, size: 18)),
        ]),
      ),
    );
  }
}

class _AnalyseButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AnalyseButton({required this.onTap});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderGreen),
        ),
        child: Row(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.videocam_outlined, color: AppColors.accent, size: 26),
          ),
          const SizedBox(width: 16),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Analyse video', style: TextStyle(
                color: AppColors.textHi, fontSize: 17, fontWeight: FontWeight.w700)),
            SizedBox(height: 4),
            Text('Upload a match video and get AI stats',
                style: TextStyle(color: AppColors.muted, fontSize: 12)),
          ])),
          const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.accent, size: 16),
        ]),
      ),
    ),
  );
}

class _ViewAnalysisButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ViewAnalysisButton({required this.onTap});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.analytics_outlined, color: AppColors.bg, size: 20),
          SizedBox(width: 8),
          Text('View analysis', style: TextStyle(
              color: AppColors.bg, fontSize: 15, fontWeight: FontWeight.w700)),
        ]),
      ),
    ),
  );
}

class _PreviousAnalysesSection extends StatelessWidget {
  final HomeController controller;
  final void Function(int)? onTabChange;
  const _PreviousAnalysesSection({required this.controller, this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final teamId = controller.selectedTeam?['id'] as int?;
    if (teamId == null) return const SizedBox.shrink();

    final isLoading = controller.isLoadingMatchesForTeam(teamId);
    final matches = controller.selectedTeamMatches;

    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 30),
        child: Center(child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 1.5)),
      );
    }

    if (matches.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Team matches',
              style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(child: Text('No analysed matches yet', 
                style: TextStyle(color: AppColors.muted, fontSize: 13))),
          ),
        ]),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Team matches',
              style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...matches.map((m) => _MatchItem(
            match: m,
            controller: controller,
            onTap: () {
              onTabChange?.call(1);
            },
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
    final controller = widget.controller;

    final opponent = widget.match['opponent'] as String? ?? 'Unknown opponent';
    final dateStr = widget.match['match_date'] as String? ?? '';
    final status = widget.match['status'] as String? ?? 'uploaded';
    final matchId = widget.match['id'] as int;

    DateTime? dt;
    if (dateStr.isNotEmpty) {
      try {
        dt = DateTime.parse(dateStr).toLocal();
      } catch (_) {}
    }
    final formattedDate =
        dt != null ? DateFormat(AppConstants.dateFormat).format(dt) : '—';

    Color statusColor;
    String statusLabel;

    if (status == AppConstants.statusDone) {
      statusColor = AppColors.success;
      statusLabel = AppConstants.labelAnalysed;
    } else if (status == AppConstants.statusProcessing) {
      statusColor = AppColors.warning;
      statusLabel = AppConstants.labelProcessing;
    } else {
      statusColor = AppColors.dim;
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
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('This match is not analysed yet.'),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.elevated,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.sports_soccer_outlined,
                  color: AppColors.dim, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'vs $opponent',
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_isDownloading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: AppColors.accent,
                  strokeWidth: 2,
                ),
              )
            else
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.dim,
                size: 13,
              ),
          ],
        ),
      ),
    );
  }
}

class _SparkLine extends StatelessWidget {
  final List<double> values;
  const _SparkLine({required this.values});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 80, height: 36,
    child: CustomPaint(painter: _SparkPainter(values)),
  );
}

class _SparkPainter extends CustomPainter {
  final List<double> values;
  const _SparkPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final y = size.height * (1 - values[i]);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _TabSelector extends StatelessWidget {
  final int selected;
  final void Function(int) onSelect;
  const _TabSelector({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
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
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.accentLo : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: active ? Border.all(color: AppColors.borderGreen) : null,
        ),
        child: Text(label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: active ? AppColors.accent : AppColors.muted,
            fontSize: 13, fontWeight: active ? FontWeight.w700 : FontWeight.w400,
          )),
      ),
    ),
  );
}

class _ResultadosAPISection extends StatelessWidget {
  final bool isLoading;
  final List<dynamic> matches;
  
  const _ResultadosAPISection({required this.isLoading, required this.matches});

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 1.5)),
      );
    }

    if (matches.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: const Center(child: Column(children: [
            Icon(Icons.sports_soccer_outlined, color: AppColors.dim, size: 28),
            SizedBox(height: 8),
            Text('No real matches today', style: TextStyle(color: AppColors.muted, fontSize: 13)),
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
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
        child: Row(children: [
          Container(
            width: 24, height: 24,
            decoration: const BoxDecoration(color: Colors.transparent, shape: BoxShape.circle),
            child: leagueLogo.isNotEmpty 
                ? Image.network(leagueLogo) 
                : const Icon(Icons.emoji_events, color: AppColors.accent, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(leagueName, style: const TextStyle(
                color: AppColors.text, fontSize: 13, fontWeight: FontWeight.w700)),
          ),
        ]),
      ),
      ...matches.map((m) => _ResultRowAPI(match: m)),
      const SizedBox(height: 8),
    ],
  );
}

class _ResultRowAPI extends StatelessWidget {
  final Map<String, dynamic> match;
  const _ResultRowAPI({required this.match});

  @override
  Widget build(BuildContext context) {
    final homeTeam = match['teams']?['home']?['name'] ?? 'Local';
    final awayTeam = match['teams']?['away']?['name'] ?? 'Away';
    final homeLogo = match['teams']?['home']?['logo'] ?? '';
    final awayLogo = match['teams']?['away']?['logo'] ?? '';
    
    final homeGoals = match['goals']?['home'];
    final awayGoals = match['goals']?['away'];
    
    final statusShort = match['fixture']?['status']?['short'] ?? 'NS';
    final elapsed = match['fixture']?['status']?['elapsed'] ?? 0;
    final dateStr = match['fixture']?['date'] ?? '';

    String timeLabel = '—';
    String dateLabel = '—';
    if (dateStr.isNotEmpty) {
      try {
        final dt = DateTime.parse(dateStr).toLocal();
        timeLabel = DateFormat('HH:mm').format(dt);
        dateLabel = DateFormat('dd MMM').format(dt);
      } catch (_) {}
    }

    Color statusColor;
    String statusLabel;
    String scoreText;

    if (statusShort == 'FT' || statusShort == 'AET' || statusShort == 'PEN') {
      statusColor = AppColors.dim;
      statusLabel = 'Finalizado';
      scoreText = '$homeGoals : $awayGoals';
    } else if (statusShort == '1H' || statusShort == '2H' || statusShort == 'HT') {
      statusColor = AppColors.success;
      statusLabel = 'En Vivo';
      timeLabel = "$elapsed'";
      scoreText = '$homeGoals : $awayGoals';
    } else {
      statusColor = AppColors.muted;
      statusLabel = 'Programado';
      scoreText = '— : —';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(children: [
        SizedBox(
          width: 58,
          child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Text(statusLabel,
                textAlign: TextAlign.center,
                style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(timeLabel, style: TextStyle(color: statusShort == '1H' || statusShort == '2H' ? statusColor : AppColors.muted, fontSize: 12, fontWeight: FontWeight.bold)),
            Text(dateLabel, style: const TextStyle(color: AppColors.dim, fontSize: 10)),
          ]),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: _TeamBadgeAPI(name: homeTeam, logoUrl: homeLogo)),
            const SizedBox(width: 8),
            const Text('vs', style: TextStyle(color: AppColors.dim, fontSize: 11)),
            const SizedBox(width: 8),
            Expanded(child: _TeamBadgeAPI(name: awayTeam, logoUrl: awayLogo)),
          ]),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusShort == 'FT' ? AppColors.surface : (statusShort == '1H' || statusShort == '2H' ? AppColors.successBg : AppColors.surface),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            scoreText,
            style: TextStyle(
              color: statusShort == 'FT' ? AppColors.text : (statusShort == '1H' || statusShort == '2H' ? AppColors.success : AppColors.dim),
              fontSize: 14, fontWeight: FontWeight.w800,
            ),
          ),
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
    return Row(children: [
      if (logoUrl.isNotEmpty)
        Image.network(logoUrl, width: 22, height: 22, errorBuilder: (_, __, ___) => const SizedBox(width: 22, height: 22))
      else
        Container(
          width: 22, height: 22,
          decoration: const BoxDecoration(color: AppColors.elevated, shape: BoxShape.circle),
          child: Center(child: Text(name.isNotEmpty ? name[0] : '?',
              style: const TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.w700))),
        ),
      const SizedBox(width: 5),
      Expanded(child: Text(name, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.text, fontSize: 12, fontWeight: FontWeight.w500))),
    ]);
  }
}

class _NoticiasSection extends StatelessWidget {
  const _NoticiasSection();

  static const _articles = [
    (
      category: 'Análisis',
      title: 'Cómo el análisis de video está cambiando el fútbol moderno',
      time: 'Hace 2 horas',
      icon: Icons.analytics_outlined,
    ),
    (
      category: 'Táctica',
      title: 'Presión alta vs bloque bajo: cuál funciona mejor según los datos',
      time: 'Hace 5 horas',
      icon: Icons.architecture_outlined,
    ),
    (
      category: 'Entrenamiento',
      title: '5 ejercicios para mejorar el recorrido total de tus jugadores',
      time: 'Hace 1 día',
      icon: Icons.fitness_center_outlined,
    ),
    (
      category: 'IA & Fútbol',
      title: 'YOLO y la detección de jugadores: el futuro del scouting',
      time: 'Hace 2 días',
      icon: Icons.smart_toy_outlined,
    ),
    (
      category: 'Posiciones',
      title: 'Mapas de calor: cómo leer las zonas de dominio en cancha',
      time: 'Hace 3 días',
      icon: Icons.map_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
    child: Column(children: _articles.map((a) => _ArticleCard(
      category: a.category, title: a.title,
      time: a.time, icon: a.icon,
    )).toList()),
  );
}

class _ArticleCard extends StatelessWidget {
  final String category;
  final String title;
  final String time;
  final IconData icon;
  const _ArticleCard({required this.category, required this.title,
      required this.time, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(children: [
      Container(
        width: 52, height: 52,
        decoration: BoxDecoration(
          color: AppColors.accentLo,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.accent, size: 24),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.accentLo,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(category, style: const TextStyle(
              color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(height: 6),
        Text(title, maxLines: 2, overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.text, fontSize: 13,
                fontWeight: FontWeight.w600, height: 1.3)),
        const SizedBox(height: 4),
        Text(time, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
      ])),
      const SizedBox(width: 8),
      const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.dim, size: 13),
    ]),
  );
}