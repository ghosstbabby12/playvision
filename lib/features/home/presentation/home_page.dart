import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/form_text_field.dart';
import '../../../shared/widgets/section_label.dart';
import '../controller/home_controller.dart';
import 'widgets/mini_stat_card.dart';
import 'widgets/quick_action_button.dart';
import 'widgets/team_list_item.dart';

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
          backgroundColor: AppColors.elevated,
          behavior: SnackBarBehavior.floating,
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
        final result    = _controller.lastResult;
        final team      = result?['team'] as Map<String, dynamic>?;
        final players   = result?['players'] as List?;
        final topPlayer = players != null && players.isNotEmpty
            ? players.reduce((a, b) =>
                ((a['distance_km'] as num?) ?? 0) > ((b['distance_km'] as num?) ?? 0) ? a : b)
            : null;

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Hero ──────────────────────────────────────────
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0F1E35), AppColors.bg],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 64, 24, 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(children: [
                        Icon(Icons.sports_soccer_outlined, color: AppColors.accent, size: 18),
                        SizedBox(width: 8),
                        Text('PLAYVISION',
                            style: TextStyle(color: AppColors.accent, fontSize: 12,
                                fontWeight: FontWeight.w700, letterSpacing: 3)),
                      ]),
                      const SizedBox(height: 32),
                      const Text('Intelligent\nfootball\nanalysis',
                          style: TextStyle(color: AppColors.text, fontSize: 34,
                              fontWeight: FontWeight.w800, height: 1.2, letterSpacing: -0.5)),
                      const SizedBox(height: 12),
                      const Text('AI that detects, tracks and analyses\nevery player in real time.',
                          style: TextStyle(color: AppColors.dim, fontSize: 14, height: 1.6)),
                    ],
                  ),
                ),

                // ── Upload card ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Transform.translate(
                    offset: const Offset(0, -20),
                    child: GestureDetector(
                      onTap: _controller.isAnalyzing ? null : _controller.pickAndAnalyze,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border2),
                          boxShadow: [BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 20, offset: const Offset(0, 8),
                          )],
                        ),
                        child: _controller.isAnalyzing
                            ? const Column(children: [
                                CircularProgressIndicator(color: AppColors.accent, strokeWidth: 1.5),
                                SizedBox(height: 16),
                                Text('Analysing with AI...',
                                    style: TextStyle(color: AppColors.accent, fontSize: 14, fontWeight: FontWeight.w500)),
                                SizedBox(height: 4),
                                Text('This may take a few minutes',
                                    style: TextStyle(color: AppColors.dim, fontSize: 12)),
                              ])
                            : const Row(children: [
                                _UploadIcon(),
                                SizedBox(width: 16),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text('Analyse match',
                                      style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w700)),
                                  SizedBox(height: 4),
                                  Text('Upload a video and get stats in seconds',
                                      style: TextStyle(color: AppColors.dim, fontSize: 12)),
                                ])),
                                Icon(Icons.arrow_forward_ios_rounded, color: AppColors.accentLo, size: 16),
                              ]),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    // ── Quick access ──────────────────────────────
                    const SectionLabel('QUICK ACCESS'),
                    const SizedBox(height: 12),
                    Row(children: [
                      QuickActionButton(icon: Icons.analytics_outlined,     label: 'Analysis', onTap: () => widget.onTabChange?.call(1)),
                      const SizedBox(width: 10),
                      QuickActionButton(icon: Icons.sports_soccer_outlined, label: 'Matches',  onTap: () => widget.onTabChange?.call(2)),
                      const SizedBox(width: 10),
                      QuickActionButton(icon: Icons.fitness_center_outlined, label: 'Training', onTap: () => widget.onTabChange?.call(3)),
                    ]),

                    // ── Last analysis ─────────────────────────────
                    if (result != null) ...[
                      const SizedBox(height: 28),
                      const SectionLabel('LAST ANALYSIS'),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            const Icon(Icons.auto_awesome_outlined, color: AppColors.accent, size: 16),
                            const SizedBox(width: 8),
                            const Text('Match summary',
                                style: TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w700)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0x1A7C9EBF),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('Completed',
                                  style: TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.w600)),
                            ),
                          ]),
                          const SizedBox(height: 16),
                          Row(children: [
                            MiniStatCard('${result['players_detected']}', 'Players'),
                            MiniStatCard('${team?['total_distance_km'] ?? '—'} km', 'Distance'),
                            MiniStatCard('${team?['possession_pct'] ?? 0}%', 'Possession'),
                          ]),
                          if (topPlayer != null) ...[
                            const SizedBox(height: 14),
                            const Divider(color: AppColors.border, height: 1),
                            const SizedBox(height: 14),
                            Row(children: [
                              const Icon(Icons.bolt_outlined, color: AppColors.accent, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'Player ${topPlayer['rank']} most active — '
                                '${(topPlayer['distance_km'] as num?)?.toStringAsFixed(2)} km',
                                style: const TextStyle(color: AppColors.muted, fontSize: 12),
                              ),
                            ]),
                          ],
                        ]),
                      ),
                    ],

                    // ── Teams ─────────────────────────────────────
                    const SizedBox(height: 28),
                    Row(children: [
                      const Expanded(child: SectionLabel('MY TEAMS')),
                      GestureDetector(
                        onTap: _controller.loadTeams,
                        child: const Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Icon(Icons.refresh_outlined, color: AppColors.dim, size: 16),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _openTeamDialog(),
                        child: const Icon(Icons.add, color: AppColors.accent, size: 18),
                      ),
                    ]),
                    const SizedBox(height: 12),

                    if (_controller.isLoading)
                      const Center(child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 1.5))
                    else if (_controller.teams.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Column(children: [
                          Icon(Icons.groups_outlined, color: AppColors.accentLo, size: 36),
                          SizedBox(height: 10),
                          Text('No teams yet', style: TextStyle(color: AppColors.dim, fontSize: 13)),
                          SizedBox(height: 4),
                          Text('Tap + to create a team',
                              style: TextStyle(color: AppColors.accent, fontSize: 12)),
                        ]),
                      )
                    else
                      ..._controller.teams.map((t) => TeamListItem(
                        team: t,
                        onEdit: () => _openTeamDialog(team: t),
                        onDelete: () => _deleteTeam(t),
                      )),

                    const SizedBox(height: 32),
                  ]),
                ),
              ],
            ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.dim)),
          ),
          GestureDetector(
            onTap: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              if (isEdit) {
                await _controller.updateTeam(
                  id: team['id'] as int,
                  name: nameCtrl.text.trim(),
                  category: categoryCtrl.text.trim().isEmpty ? null : categoryCtrl.text.trim(),
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.elevated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border2),
              ),
              child: Text(isEdit ? 'Save' : 'Create',
                  style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600)),
            ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete team',
            style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w700)),
        content: Text('Delete "${team['name']}"? This action cannot be undone.',
            style: const TextStyle(color: AppColors.muted, fontSize: 13, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.dim)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Color(0xFFE05C5C))),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _controller.deleteTeam(team['id'] as int);
    }
  }
}

class _UploadIcon extends StatelessWidget {
  const _UploadIcon();

  @override
  Widget build(BuildContext context) => Container(
    width: 56, height: 56,
    decoration: BoxDecoration(
      color: const Color(0x1A7C9EBF),
      borderRadius: BorderRadius.circular(14),
    ),
    child: const Icon(Icons.videocam_outlined, color: AppColors.accent, size: 28),
  );
}
