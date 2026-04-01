import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/form_text_field.dart';
import '../controller/home_controller.dart';
import 'widgets/settings_drawer.dart';

class HomePage extends StatefulWidget {
  final void Function(int)? onTabChange;
  const HomePage({super.key, this.onTabChange});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HomeController();
    _controller.loadTeams();
    _controller.loadRecentMatches();
  }

  @override
  void dispose() {
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
              // ── Hero ──────────────────────────────────────
              SliverToBoxAdapter(child: _HeroSection(controller: _controller)),

              // ── FLOW: no team selected ─────────────────────
              if (!hasTeam) ...[
                SliverToBoxAdapter(child: _TeamSelectorSection(
                  controller: _controller,
                  onAdd: () => _openTeamDialog(),
                )),
              ],

              // ── FLOW: team selected ────────────────────────
              if (hasTeam) ...[
                // Selected team header
                SliverToBoxAdapter(child: _SelectedTeamHeader(
                  controller: _controller,
                  onEdit: () => _openTeamDialog(team: _controller.selectedTeam),
                  onDelete: () => _deleteTeam(_controller.selectedTeam!),
                )),

                // Analyse video button
                SliverToBoxAdapter(child: _AnalyseButton(controller: _controller)),

                // If analysis result exists → Ver Análisis button
                if (_controller.hasResult)
                  SliverToBoxAdapter(child: _ViewAnalysisButton(
                    onTap: () => widget.onTabChange?.call(1),
                  )),

                // Previous analyses
                SliverToBoxAdapter(child: _PreviousAnalysesSection(
                  controller: _controller,
                  onTabChange: widget.onTabChange,
                )),
              ],

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

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isEdit ? 'Edit team' : 'New team',
            style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          FormTextField(controller: nameCtrl,     label: 'Name'),
          const SizedBox(height: 10),
          FormTextField(controller: categoryCtrl, label: 'Category'),
          const SizedBox(height: 10),
          FormTextField(controller: clubCtrl,     label: 'Club'),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.muted))),
          TextButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              if (isEdit) {
                await _controller.updateTeam(
                  id: team['id'] as int, name: nameCtrl.text.trim(),
                  category: nameCtrl.text.trim().isEmpty ? null : categoryCtrl.text.trim(),
                  club: clubCtrl.text.trim().isEmpty ? null : clubCtrl.text.trim(),
                );
              } else {
                await _controller.createTeam(
                  name: nameCtrl.text.trim(),
                  category: categoryCtrl.text.trim().isEmpty ? null : categoryCtrl.text.trim(),
                  club: clubCtrl.text.trim().isEmpty ? null : clubCtrl.text.trim(),
                );
              }
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
            },
            child: Text(isEdit ? 'Save' : 'Create',
                style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700)),
          ),
        ],
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

// ─────────────────────────────────────────────────────────────
// Hero
// ─────────────────────────────────────────────────────────────
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
            // Top bar
            Row(children: [
              const Icon(Icons.sports_soccer_outlined, color: AppColors.accent, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('PlayVision', style: TextStyle(
                    color: AppColors.text, fontSize: 18, fontWeight: FontWeight.w800)),
              ),
              GestureDetector(onTap: () {},
                  child: const Icon(Icons.search_rounded, color: AppColors.muted, size: 22)),
              const SizedBox(width: 8),
              Builder(builder: (ctx) => GestureDetector(
                onTap: () => Scaffold.of(ctx).openEndDrawer(),
                child: const Icon(Icons.settings_outlined, color: AppColors.muted, size: 22),
              )),
            ]),

            const SizedBox(height: 24),

            // Stats
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Total matches', style: TextStyle(color: AppColors.muted, fontSize: 12)),
                const SizedBox(height: 4),
                Text('$total', style: const TextStyle(
                    color: AppColors.textHi, fontSize: 52,
                    fontWeight: FontWeight.w800, letterSpacing: -2, height: 1)),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 14),
                  const SizedBox(width: 4),
                  Text('$done analysed', style: const TextStyle(
                      color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w600)),
                ]),
              ])),
              _SparkLine(values: const [0.4, 0.6, 0.3, 0.8, 0.5, 0.9, 0.7]),
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

// ─────────────────────────────────────────────────────────────
// STATE 1: Team selector (no team selected)
// ─────────────────────────────────────────────────────────────
class _TeamSelectorSection extends StatelessWidget {
  final HomeController controller;
  final VoidCallback onAdd;
  const _TeamSelectorSection({required this.controller, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Label
        const Text('Select or create a team',
            style: TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text('Choose a team to start a new analysis',
            style: TextStyle(color: AppColors.muted, fontSize: 13)),
        const SizedBox(height: 20),

        if (controller.isLoading)
          const Center(child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 1.5))
        else if (controller.teams.isEmpty)
          // Empty state — create team card
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
          // Horizontal team list
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
                    label: t['name'] as String? ?? '—',
                    initial: _initial(t['name'] as String?),
                    isAdd: false,
                    onTap: () => controller.selectTeam(t),
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
  final bool isAdd;
  final VoidCallback onTap;
  const _TeamCircleItem({required this.label, required this.initial,
      required this.isAdd, required this.onTap});

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
        ),
        child: Center(child: Text(initial, style: TextStyle(
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

// ─────────────────────────────────────────────────────────────
// STATE 2: Selected team header
// ─────────────────────────────────────────────────────────────
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderGreen),
        ),
        child: Row(children: [
          // Avatar
          Container(
            width: 52, height: 52,
            decoration: const BoxDecoration(color: AppColors.accentLo, shape: BoxShape.circle),
            child: Center(child: Text(initial, style: const TextStyle(
                color: AppColors.accent, fontSize: 22, fontWeight: FontWeight.w700))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(team['name'] ?? '—',
                style: const TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w700)),
            Text('${team['club'] ?? '—'} · ${team['category'] ?? '—'}',
                style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          ])),
          // Change team button
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

// ─────────────────────────────────────────────────────────────
// Analyse video button
// ─────────────────────────────────────────────────────────────
class _AnalyseButton extends StatelessWidget {
  final HomeController controller;
  const _AnalyseButton({required this.controller});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
    child: GestureDetector(
      onTap: controller.isAnalyzing ? null : () => controller.pickAndAnalyze(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.accentMid, AppColors.accentLo],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderGreen),
        ),
        child: controller.isAnalyzing
            ? const Column(children: [
                CircularProgressIndicator(color: AppColors.accent, strokeWidth: 1.5),
                SizedBox(height: 12),
                Text('Analysing with AI...', style: TextStyle(
                    color: AppColors.accent, fontSize: 14, fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Text('This may take a few minutes',
                    style: TextStyle(color: AppColors.muted, fontSize: 12)),
              ])
            : Row(children: [
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

// ─────────────────────────────────────────────────────────────
// Ver análisis button (only after analysis)
// ─────────────────────────────────────────────────────────────
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

// ─────────────────────────────────────────────────────────────
// Previous analyses section
// ─────────────────────────────────────────────────────────────
class _PreviousAnalysesSection extends StatelessWidget {
  final HomeController controller;
  final void Function(int)? onTabChange;
  const _PreviousAnalysesSection({required this.controller, this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final teamId  = controller.selectedTeam?['id'] as int?;
    final loading = teamId != null && controller.isLoadingMatchesForTeam(teamId);
    final matches = controller.selectedTeamMatches;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
        child: Row(children: [
          const Expanded(child: Text('Previous analyses', style: TextStyle(
              color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w700))),
          GestureDetector(
            onTap: () => onTabChange?.call(2),
            child: const Text('View all', style: TextStyle(
                color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ]),
      ),
      if (loading)
        const Center(child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 1.5),
        ))
      else if (matches.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(children: [
              Icon(Icons.history_rounded, color: AppColors.dim, size: 28),
              SizedBox(height: 8),
              Text('No analyses yet for this team',
                  style: TextStyle(color: AppColors.muted, fontSize: 13)),
              SizedBox(height: 4),
              Text('Tap "Analyse video" to start',
                  style: TextStyle(color: AppColors.accent, fontSize: 12)),
            ]),
          ),
        )
      else
        ...matches.take(6).map((m) => _MatchRow(match: m)),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────
// Match row
// ─────────────────────────────────────────────────────────────
class _MatchRow extends StatelessWidget {
  final Map<String, dynamic> match;
  const _MatchRow({required this.match});

  @override
  Widget build(BuildContext context) {
    final status   = match['status'] as String? ?? AppConstants.statusUploaded;
    final opponent = match['opponent'] as String? ?? '—';
    final rawDate  = match['match_date'] as String?;
    String dateLabel = '—';
    if (rawDate != null) {
      try { dateLabel = DateFormat('d MMM').format(DateTime.parse(rawDate)); } catch (_) {}
    }

    final (Color col, String lbl) = switch (status) {
      AppConstants.statusDone       => (AppColors.positive, AppConstants.labelAnalysed),
      AppConstants.statusProcessing => (AppColors.warning,  AppConstants.labelProcessing),
      _                             => (AppColors.muted,    AppConstants.labelUploaded),
    };

    final initial = opponent.isNotEmpty ? opponent[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
              color: AppColors.accentLo, borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(initial, style: const TextStyle(
              color: AppColors.accent, fontSize: 18, fontWeight: FontWeight.w700))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('vs $opponent', style: const TextStyle(
              color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(dateLabel, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
        ])),
        Text(lbl, style: TextStyle(color: col, fontSize: 12, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Spark line decoration
// ─────────────────────────────────────────────────────────────
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
