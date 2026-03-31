import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/section_label.dart';
import '../controller/training_controller.dart';
import 'widgets/player_plan_card.dart';
import 'widgets/team_insights_card.dart';
import 'widgets/training_session_card.dart';

class TrainingPage extends StatefulWidget {
  const TrainingPage({super.key});

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  late final TrainingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TrainingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final hasResult = _controller.result != null;

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              children: [
                // ── Header ────────────────────────────────────────
                const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Training',
                      style: TextStyle(color: AppColors.text, fontSize: 24,
                          fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                  SizedBox(height: 4),
                  Text('Performance-based plan',
                      style: TextStyle(color: AppColors.dim, fontSize: 13)),
                ]),

                const SizedBox(height: 28),

                if (!hasResult) ...[
                  // ── Empty state ───────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Column(children: [
                      Icon(Icons.auto_awesome_outlined, color: AppColors.accentLo, size: 36),
                      SizedBox(height: 12),
                      Text('No analysis available',
                          style: TextStyle(color: AppColors.dim, fontSize: 14, fontWeight: FontWeight.w500)),
                      SizedBox(height: 6),
                      Text('Analyse a match to get\npersonalised recommendations.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.accentLo, fontSize: 12, height: 1.6)),
                    ]),
                  ),
                  const SizedBox(height: 32),
                ] else ...[
                  // ── Team AI insights ──────────────────────────
                  const SectionLabel('AI RECOMMENDATIONS — TEAM'),
                  const SizedBox(height: 12),
                  TeamInsightsCard(insights: _controller.buildTeamInsights()),
                  const SizedBox(height: 28),

                  // ── Player personalised plans ─────────────────
                  if (_controller.players != null && _controller.players!.isNotEmpty) ...[
                    const SectionLabel('PERSONALISED PLAN BY PLAYER'),
                    const SizedBox(height: 12),
                    ..._controller.players!.map((p) {
                      final player = p as Map<String, dynamic>;
                      return PlayerPlanCard(
                        player: player,
                        recommendations: _controller.buildPlayerRecommendations(player),
                      );
                    }),
                    const SizedBox(height: 28),
                  ],
                ],

                // ── Suggested sessions (always visible) ──────────
                const SectionLabel('SUGGESTED SESSIONS'),
                const SizedBox(height: 14),
                const TrainingSessionCard(
                  title: 'High press and transitions',
                  date: '14 Mar 2026', duration: '90 min', category: 'Tactical',
                  color: AppColors.catTactic,
                ),
                const TrainingSessionCard(
                  title: 'Positional play 4-3-3',
                  date: '12 Mar 2026', duration: '75 min', category: 'Technical',
                  color: AppColors.catTech,
                ),
                const TrainingSessionCard(
                  title: 'Physical prep — endurance',
                  date: '10 Mar 2026', duration: '60 min', category: 'Physical',
                  color: AppColors.catPhysical,
                ),
                const TrainingSessionCard(
                  title: 'Set pieces — offensive corners',
                  date: '8 Mar 2026', duration: '45 min', category: 'Set piece',
                  color: AppColors.catSetPiece,
                ),

                const SizedBox(height: 28),
              ],
            ),
          ),
        );
      },
    );
  }
}
