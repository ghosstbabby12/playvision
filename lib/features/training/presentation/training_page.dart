import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_color_tokens.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/training_session.dart';
import 'training_controller.dart';
import 'training_session_detail_page.dart';

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
    _controller.loadSessions();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showCreateSessionDialog(BuildContext context, TrainingController ctrl) {
    final titleCtrl    = TextEditingController();
    final descCtrl     = TextEditingController();
    String category    = TrainingSession.categories.first;
    int durationMinutes = 60;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141414),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final c = ctx.colors;
        return StatefulBuilder(
          builder: (ctx, setModal) => Padding(
            padding: EdgeInsets.fromLTRB(
                20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text('New Session',
                    style: TextStyle(color: c.textHi, fontSize: 18, fontWeight: FontWeight.w800))),
                GestureDetector(
                  onTap: () => Navigator.of(ctx).pop(),
                  child: Icon(Icons.close_rounded, color: c.muted),
                ),
              ]),
              const SizedBox(height: 20),

              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Session title',
                  hintStyle: TextStyle(color: c.muted),
                  filled: true,
                  fillColor: c.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: c.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: c.border),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: descCtrl,
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Description (optional)',
                  hintStyle: TextStyle(color: c.muted),
                  filled: true,
                  fillColor: c.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: c.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: c.border),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Category chips
              Wrap(spacing: 8, children: TrainingSession.categories.map((cat) {
                final selected = cat == category;
                return GestureDetector(
                  onTap: () => setModal(() => category = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: selected ? TrainingSession.categoryColor(cat) : c.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? TrainingSession.categoryColor(cat) : c.border,
                      ),
                    ),
                    child: Text(cat,
                        style: TextStyle(
                          color: selected ? Colors.white : c.muted,
                          fontSize: 12, fontWeight: FontWeight.w600,
                        )),
                  ),
                );
              }).toList()),
              const SizedBox(height: 12),

              // Duration picker
              Row(children: [
                Text('Duration:', style: TextStyle(color: c.muted, fontSize: 13)),
                const SizedBox(width: 12),
                ...([30, 45, 60, 75, 90].map((min) {
                  final sel = durationMinutes == min;
                  return GestureDetector(
                    onTap: () => setModal(() => durationMinutes = min),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: sel ? c.accentLo : c.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: sel ? c.borderGreen : c.border),
                      ),
                      child: Text('${min}m',
                          style: TextStyle(
                            color: sel ? c.accent : c.muted,
                            fontSize: 12, fontWeight: FontWeight.w700,
                          )),
                    ),
                  );
                })),
              ]),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final title = titleCtrl.text.trim();
                    if (title.isEmpty) return;
                    Navigator.of(ctx).pop();
                    await ctrl.createSession(
                      title: title,
                      category: category,
                      durationMinutes: durationMinutes,
                      description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: context.colors.accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Create Session',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c    = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final hasResult = _controller.result != null;

        return Scaffold(
          backgroundColor: c.bg,
          body: CustomScrollView(
            slivers: [
              // ── Hero ──────────────────────────────────────────────────
              SliverToBoxAdapter(child: _TrainingHero(l10n: l10n)),

              // ── Weekly activity strip ──────────────────────────────────
              SliverToBoxAdapter(child: _WeeklyActivity(c: c)),

              // ── Active task (glassmorphism) ────────────────────────────
              SliverToBoxAdapter(child: _ActiveFocusCard(
                hasResult: hasResult,
                controller: _controller,
                c: c,
              )),

              // ── Team insights ──────────────────────────────────────────
              if (hasResult) ...[
                SliverToBoxAdapter(child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                  child: Text(l10n.aiRecommendationsTeam,
                      style: TextStyle(color: c.text, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.2)),
                )),
                SliverToBoxAdapter(child: _TeamInsightsBanner(
                  insights: _controller.buildTeamInsights(),
                )),

                // ── Per-player cards ───────────────────────────────────
                if (_controller.players != null && _controller.players!.isNotEmpty) ...[
                  SliverToBoxAdapter(child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                    child: Text(l10n.personalisedPlanByPlayer,
                        style: TextStyle(color: c.text, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.2)),
                  )),
                  SliverList(delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final player = _controller.players![i] as Map<String, dynamic>;
                      return _PlayerArcCard(
                        player: player,
                        recommendations: _controller.buildPlayerRecommendations(player),
                      );
                    },
                    childCount: _controller.players!.length,
                  )),
                ],
              ],

              // ── Suggested sessions ─────────────────────────────────────
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
                child: Row(children: [
                  Expanded(child: Text('SUGGESTED SESSIONS',
                      style: TextStyle(color: c.muted, fontSize: 11,
                          fontWeight: FontWeight.w700, letterSpacing: 1.4))),
                  GestureDetector(
                    onTap: () => _showCreateSessionDialog(context, _controller),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: c.accentLo,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: c.borderGreen),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.add_rounded, color: c.accent, size: 14),
                        const SizedBox(width: 4),
                        Text('New', style: TextStyle(color: c.accent, fontSize: 12, fontWeight: FontWeight.w700)),
                      ]),
                    ),
                  ),
                ]),
              )),

              SliverToBoxAdapter(child: _DynamicSessionCarousel(controller: _controller)),

              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        );
      },
    );
  }
}

// ── Hero section ──────────────────────────────────────────────────────────────

class _TrainingHero extends StatelessWidget {
  final AppLocalizations l10n;
  const _TrainingHero({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      height: 230,
      child: Stack(fit: StackFit.expand, children: [
        Image.network(
          'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?w=900&q=80',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: c.heroTop),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.3),
                Colors.black.withValues(alpha: 0.85),
              ],
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: c.accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.bolt_rounded, color: Colors.black, size: 12),
                  const SizedBox(width: 4),
                  const Text('AI TRAINING', style: TextStyle(
                      color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                ]),
              ),
              const Spacer(),
              Text(l10n.trainingTitle,
                  style: const TextStyle(color: Colors.white, fontSize: 28,
                      fontWeight: FontWeight.w900, letterSpacing: -0.5, height: 1.1)),
              const SizedBox(height: 4),
              Text(DateFormat('EEEE, d MMMM').format(DateTime.now()),
                  style: const TextStyle(color: Colors.white60, fontSize: 13)),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ── Weekly activity strip ─────────────────────────────────────────────────────

class _WeeklyActivity extends StatelessWidget {
  final AppColorTokens c;
  const _WeeklyActivity({required this.c});

  @override
  Widget build(BuildContext context) {
    const days  = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final today = DateTime.now().weekday - 1; // 0 = Mon
    final done  = [true, true, true, false, false, false, false];

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (i) {
          final isToday = i == today;
          final isDone  = done[i];
          return Column(children: [
            Text(days[i], style: TextStyle(
                color: isToday ? c.accent : c.muted,
                fontSize: 11, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: isToday
                    ? c.accent
                    : isDone
                        ? c.accentLo
                        : c.elevated,
                shape: BoxShape.circle,
                border: isToday ? null : Border.all(
                  color: isDone ? c.borderGreen : c.border,
                  width: 1.5,
                ),
              ),
              child: Icon(
                isDone || isToday ? Icons.check_rounded : Icons.remove,
                color: isToday ? Colors.black : isDone ? c.accent : c.border,
                size: 16,
              ),
            ),
          ]);
        }),
      ),
    );
  }
}

// ── Active focus card (glassmorphism style) ───────────────────────────────────

class _ActiveFocusCard extends StatelessWidget {
  final bool hasResult;
  final TrainingController controller;
  final AppColorTokens c;
  const _ActiveFocusCard({required this.hasResult, required this.controller, required this.c});

  @override
  Widget build(BuildContext context) {
    final players = controller.players;
    final totalKm = players == null ? 0.0
        : players.fold(0.0, (sum, p) => sum + ((p as Map)['distance_km'] as num? ?? 0).toDouble());
    final avgSpeed = players == null || players.isEmpty ? 0.0
        : players.fold(0.0, (sum, p) => sum + ((p as Map)['speed_ms'] as num? ?? 0).toDouble()) / players.length;
    final fitnessScore = hasResult ? ((avgSpeed / 8.0) * 100).clamp(0.0, 100.0) : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.borderGreen.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: c.accent.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(children: [
        // Arc progress
        SizedBox(
          width: 90, height: 90,
          child: CustomPaint(
            painter: _ArcPainter(
              progress: fitnessScore / 100,
              trackColor: c.elevated,
              fillColor: c.accent,
            ),
            child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('${fitnessScore.toInt()}%',
                  style: TextStyle(color: c.textHi, fontSize: 18, fontWeight: FontWeight.w900)),
              Text('fitness', style: TextStyle(color: c.muted, fontSize: 9)),
            ])),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(hasResult ? 'Team Performance' : 'No analysis yet',
              style: TextStyle(color: c.text, fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _StatRow(icon: Icons.directions_run_rounded, label: 'Total distance',
              value: hasResult ? '${totalKm.toStringAsFixed(1)} km' : '—', c: c),
          const SizedBox(height: 8),
          _StatRow(icon: Icons.speed_rounded, label: 'Avg speed',
              value: hasResult ? '${avgSpeed.toStringAsFixed(1)} m/s' : '—', c: c),
          const SizedBox(height: 8),
          _StatRow(icon: Icons.group_rounded, label: 'Players tracked',
              value: hasResult ? '${players?.length ?? 0}' : '—', c: c),
        ])),
      ]),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final AppColorTokens c;
  const _StatRow({required this.icon, required this.label, required this.value, required this.c});

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, color: c.accent, size: 14),
    const SizedBox(width: 6),
    Expanded(child: Text(label, style: TextStyle(color: c.muted, fontSize: 11))),
    Text(value, style: TextStyle(color: c.text, fontSize: 12, fontWeight: FontWeight.w700)),
  ]);
}

// ── Team insights banner ──────────────────────────────────────────────────────

class _TeamInsightsBanner extends StatelessWidget {
  final List<String> insights;
  const _TeamInsightsBanner({required this.insights});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [c.accentLo, c.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.borderGreen),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.black, size: 16),
          ),
          const SizedBox(width: 10),
          Text('AI Team Analysis', style: TextStyle(
              color: c.text, fontSize: 14, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 14),
        ...insights.map((txt) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 6, height: 6,
              margin: const EdgeInsets.only(top: 5, right: 10),
              decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle),
            ),
            Expanded(child: Text(txt,
                style: TextStyle(color: c.text, fontSize: 13, height: 1.5))),
          ]),
        )),
      ]),
    );
  }
}

// ── Per-player arc card ───────────────────────────────────────────────────────

class _PlayerArcCard extends StatefulWidget {
  final Map<String, dynamic> player;
  final List<String> recommendations;
  const _PlayerArcCard({required this.player, required this.recommendations});

  @override
  State<_PlayerArcCard> createState() => _PlayerArcCardState();
}

class _PlayerArcCardState extends State<_PlayerArcCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final c    = context.colors;
    final rank = widget.player['rank'] as int;
    final km   = (widget.player['distance_km'] as num?)?.toDouble() ?? 0;
    final spd  = (widget.player['speed_ms']    as num?)?.toDouble() ?? 0;
    final poss = (widget.player['possession_pct'] as num?)?.toDouble() ?? 0;
    final kmProgress  = (km / 10.0).clamp(0.0, 1.0);
    final spdProgress = (spd / 10.0).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _expanded ? c.accent.withValues(alpha: 0.5) : c.border),
        ),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              // Two small arcs
              SizedBox(
                width: 56, height: 56,
                child: CustomPaint(
                  painter: _ArcPainter(
                    progress: kmProgress,
                    trackColor: c.elevated,
                    fillColor: c.accent,
                    strokeWidth: 5,
                  ),
                  child: Center(child: Text('$rank',
                      style: TextStyle(color: c.accent, fontSize: 16, fontWeight: FontWeight.w900))),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Player $rank',
                    style: TextStyle(color: c.text, fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Row(children: [
                  _MiniStat(label: 'km', value: km.toStringAsFixed(1), c: c),
                  const SizedBox(width: 16),
                  _MiniStat(label: 'm/s', value: spd.toStringAsFixed(1), c: c),
                  const SizedBox(width: 16),
                  _MiniStat(label: 'poss', value: '$poss%', c: c),
                ]),
              ])),
              AnimatedRotation(
                turns: _expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(Icons.keyboard_arrow_down_rounded, color: c.dim, size: 22),
              ),
            ]),
          ),

          if (_expanded) ...[
            // Progress bars
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(children: [
                _ProgressBar(label: 'Distance', value: kmProgress, displayVal: '${km.toStringAsFixed(2)} km', c: c),
                const SizedBox(height: 8),
                _ProgressBar(label: 'Speed', value: spdProgress, displayVal: '${spd.toStringAsFixed(1)} m/s', c: c),
              ]),
            ),
            Divider(color: c.border, height: 1),
            // Recommendations
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.recommendations.map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(Icons.arrow_right_rounded, color: c.accent, size: 18),
                    const SizedBox(width: 4),
                    Expanded(child: Text(rec,
                        style: TextStyle(color: c.muted, fontSize: 13, height: 1.4))),
                  ]),
                )).toList(),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final AppColorTokens c;
  const _MiniStat({required this.label, required this.value, required this.c});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(value, style: TextStyle(color: c.text, fontSize: 12, fontWeight: FontWeight.w700)),
    Text(label, style: TextStyle(color: c.muted, fontSize: 9)),
  ]);
}

class _ProgressBar extends StatelessWidget {
  final String label;
  final double value;
  final String displayVal;
  final AppColorTokens c;
  const _ProgressBar({required this.label, required this.value, required this.displayVal, required this.c});

  @override
  Widget build(BuildContext context) => Row(children: [
    SizedBox(width: 54, child: Text(label, style: TextStyle(color: c.muted, fontSize: 11))),
    Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: value,
          backgroundColor: c.elevated,
          valueColor: AlwaysStoppedAnimation<Color>(c.accent),
          minHeight: 6,
        ),
      ),
    ),
    const SizedBox(width: 8),
    SizedBox(
      width: 52,
      child: Text(displayVal, textAlign: TextAlign.right,
          style: TextStyle(color: c.accent, fontSize: 11, fontWeight: FontWeight.w700)),
    ),
  ]);
}

// ── Dynamic session carousel ──────────────────────────────────────────────────

class _DynamicSessionCarousel extends StatelessWidget {
  final TrainingController controller;
  const _DynamicSessionCarousel({required this.controller});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    if (controller.loadingSessions) {
      return SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator(color: c.accent, strokeWidth: 1.5)),
      );
    }

    if (controller.sessions.isEmpty) {
      return Container(
        height: 140,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: c.border),
        ),
        child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.fitness_center_rounded, color: c.dim, size: 32),
          const SizedBox(height: 10),
          Text('No sessions yet', style: TextStyle(color: c.text, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Tap "New" to create your first session', style: TextStyle(color: c.muted, fontSize: 12)),
        ])),
      );
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: controller.sessions.length,
        itemBuilder: (_, i) => _SessionCard(
          session: controller.sessions[i],
          onDelete: () => controller.deleteSession(controller.sessions[i].id),
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final TrainingSession session;
  final VoidCallback onDelete;
  const _SessionCard({required this.session, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final c        = context.colors;
    final catColor = TrainingSession.categoryColor(session.category);
    final imageUrl = session.imageUrl ?? TrainingSession.categoryImage(session.category);

    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => TrainingSessionDetailPage(session: session, onDelete: onDelete),
      )),
      child: Container(
        width: 170,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(fit: StackFit.expand, children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: c.surface),
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
              top: 12, left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: catColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(session.category,
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
              ),
            ),
            // Delete button
            Positioned(
              top: 8, right: 8,
              child: GestureDetector(
                onTap: () => _confirmDelete(context),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.close_rounded, color: Colors.white70, size: 13),
                ),
              ),
            ),
            Positioned(
              left: 12, right: 12, bottom: 12,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(session.title,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 13,
                        fontWeight: FontWeight.w700, height: 1.3)),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.timer_outlined, color: Colors.white60, size: 12),
                  const SizedBox(width: 4),
                  Text('${session.durationMinutes} min',
                      style: const TextStyle(color: Colors.white60, fontSize: 11)),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Remove session?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        content: Text('"${session.title}" will be deleted.',
            style: const TextStyle(color: Colors.white60)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

// ── Arc painter ───────────────────────────────────────────────────────────────

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color fillColor;
  final double strokeWidth;
  const _ArcPainter({
    required this.progress,
    required this.trackColor,
    required this.fillColor,
    this.strokeWidth = 7,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect   = Rect.fromCircle(center: center, radius: radius);
    const start  = -math.pi * 0.75;
    const sweep  = math.pi * 1.5;

    final track = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fill = Paint()
      ..color = fillColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, start, sweep, false, track);
    if (progress > 0) {
      canvas.drawArc(rect, start, sweep * progress, false, fill);
    }
  }

  @override
  bool shouldRepaint(covariant _ArcPainter old) =>
      old.progress != progress || old.fillColor != fillColor;
}
