import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_color_tokens.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/pv_back_button.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/training_session.dart';
import 'training_controller.dart';
import 'training_session_detail_page.dart';

class TrainingPage extends StatefulWidget {
  final void Function(int)? onTabChange;
  const TrainingPage({super.key, this.onTabChange});

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
    _controller.loadSuggestions();
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

  void _showAddOptions(BuildContext context) {
    final c = context.colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141414),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 4,
              decoration: BoxDecoration(color: c.border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Text('¿Qué quieres hacer?',
              style: TextStyle(color: c.textHi, fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          _AddOptionTile(
            icon: Icons.videocam_rounded,
            label: 'Analizar entrenamiento',
            subtitle: 'Sube un vídeo y obtén métricas con IA',
            color: const Color(0xFF39D353),
            onTap: () {
              Navigator.of(context).pop();
              widget.onTabChange?.call(1);
            },
          ),
          const SizedBox(height: 12),
          _AddOptionTile(
            icon: Icons.edit_note_rounded,
            label: 'Crear sesión manual',
            subtitle: 'Planifica una sesión de entrenamiento',
            color: const Color(0xFF3B82F6),
            onTap: () {
              Navigator.of(context).pop();
              _showCreateSessionDialog(context, _controller);
            },
          ),
        ]),
      ),
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
              SliverToBoxAdapter(child: _TrainingHero(l10n: l10n)),

              // ── Fitness card ─────────────────────────────────────────
              SliverToBoxAdapter(child: _FitnessCard(
                ctrl: _controller,
                onAnalyze: () => widget.onTabChange?.call(1),
              )),

              // ── Interactive weekly calendar ───────────────────────────
              SliverToBoxAdapter(child: _WeeklyActivityInteractive(ctrl: _controller)),

              // ── Auto-insights ─────────────────────────────────────────
              SliverToBoxAdapter(child: _AutoInsightsBanner(ctrl: _controller)),

              // ── Progress chart ────────────────────────────────────────
              SliverToBoxAdapter(child: _ProgressChart(ctrl: _controller)),

              // ── Team analysis (if result exists) ─────────────────────
              if (hasResult) ...[
                SliverToBoxAdapter(child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                  child: Text(l10n.aiRecommendationsTeam,
                      style: TextStyle(color: c.text, fontSize: 16,
                          fontWeight: FontWeight.w800, letterSpacing: 0.2)),
                )),
                SliverToBoxAdapter(child: _TeamInsightsBanner(
                    insights: _controller.buildTeamInsights())),
                if (_controller.players != null && _controller.players!.isNotEmpty) ...[
                  SliverToBoxAdapter(child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                    child: Text(l10n.personalisedPlanByPlayer,
                        style: TextStyle(color: c.text, fontSize: 16,
                            fontWeight: FontWeight.w800, letterSpacing: 0.2)),
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

              // ── AI suggestions ────────────────────────────────────────
              SliverToBoxAdapter(child: _SectionHeader(
                label: 'SUGERIDO POR IA',
                actionLabel: '+ Nuevo',
                onAction: () => _showAddOptions(context),
                c: c,
              )),
              SliverToBoxAdapter(child: _AISuggestionsCarousel(ctrl: _controller)),

              // ── My sessions ───────────────────────────────────────────
              if (_controller.sessions.isNotEmpty || _controller.loadingSessions) ...[
                SliverToBoxAdapter(child: _SectionHeader(
                  label: 'MIS SESIONES',
                  c: c,
                )),
                SliverToBoxAdapter(child: _DynamicSessionCarousel(controller: _controller)),
              ],

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
              // Back button + badge row
              Row(children: [
                const PvBackButton(lightIcon: true),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: c.accent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.bolt_rounded, color: Colors.black, size: 12),
                    SizedBox(width: 4),
                    Text('AI TRAINING', style: TextStyle(
                        color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ]),
                ),
              ]),
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

// ── Shared section header ─────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final String? actionLabel;
  final VoidCallback? onAction;
  final AppColorTokens c;
  const _SectionHeader({required this.label, required this.c, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
    child: Row(children: [
      Expanded(child: Text(label,
          style: TextStyle(color: c.muted, fontSize: 11,
              fontWeight: FontWeight.w700, letterSpacing: 1.4))),
      if (actionLabel != null)
        GestureDetector(
          onTap: onAction,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: c.accentLo, borderRadius: BorderRadius.circular(8),
              border: Border.all(color: c.borderGreen),
            ),
            child: Text(actionLabel!,
                style: TextStyle(color: c.accent, fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ),
    ]),
  );
}

// ── Option tile for add-options bottom sheet ──────────────────────────────────

class _AddOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _AddOptionTile({required this.icon, required this.label,
      required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        radius: 16,
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(color: c.textHi, fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(color: c.muted, fontSize: 12)),
          ])),
          Icon(Icons.chevron_right_rounded, color: c.dim, size: 20),
        ]),
      ),
    );
  }
}

// ── Fitness card (redesigned) ─────────────────────────────────────────────────

class _FitnessCard extends StatelessWidget {
  final TrainingController ctrl;
  final VoidCallback onAnalyze;
  const _FitnessCard({required this.ctrl, required this.onAnalyze});

  @override
  Widget build(BuildContext context) {
    final c         = context.colors;
    final hasResult = ctrl.result != null;

    if (!hasResult) {
      return GlassCard(
        margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        padding: const EdgeInsets.all(20),
        child: Row(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: c.accentLo, shape: BoxShape.circle,
              border: Border.all(color: c.borderGreen),
            ),
            child: const Icon(Icons.sports_soccer, color: Color(0xFF39D353), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Empieza tu análisis',
                style: TextStyle(color: c.textHi, fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Sube un vídeo para obtener distancia, mapa de calor y rendimiento por jugador.',
                style: TextStyle(color: c.muted, fontSize: 12, height: 1.4)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onAnalyze,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: c.accent, borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Subir vídeo',
                    style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w800)),
              ),
            ),
          ])),
        ]),
      );
    }

    final score       = ctrl.fitnessScore;
    final status      = ctrl.fitnessStatusLabel;
    final statusColor = ctrl.fitnessStatusColor;

    return GlassCard(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      neonBorder: true,
      accentColor: statusColor,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Status badge
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 7, height: 7,
                  decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text('Carga: $status',
                  style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w800)),
            ]),
          ),
          const Spacer(),
          Text('Estado físico del equipo',
              style: TextStyle(color: c.muted, fontSize: 11)),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          // Arc
          SizedBox(width: 80, height: 80,
            child: CustomPaint(
              painter: _ArcPainter(
                  progress: score / 100, trackColor: c.elevated, fillColor: statusColor),
              child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('${score.toInt()}%',
                    style: TextStyle(color: c.textHi, fontSize: 16, fontWeight: FontWeight.w900)),
                Text('fitness', style: TextStyle(color: c.muted, fontSize: 9)),
              ])),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _StatRow(icon: Icons.directions_run_rounded, label: 'Distancia prom.',
                value: '${ctrl.avgDistanceKm.toStringAsFixed(1)} km', c: c),
            const SizedBox(height: 8),
            _StatRow(icon: Icons.speed_rounded, label: 'Velocidad prom.',
                value: '${ctrl.avgSpeedMs.toStringAsFixed(1)} m/s', c: c),
            const SizedBox(height: 8),
            _StatRow(icon: Icons.group_rounded, label: 'Jugadores',
                value: '${ctrl.players?.length ?? 0}', c: c),
          ])),
        ]),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: c.elevated, borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            Icon(Icons.lightbulb_outline_rounded, color: statusColor, size: 14),
            const SizedBox(width: 8),
            Expanded(child: Text(ctrl.fitnessRecommendation,
                style: TextStyle(color: c.text, fontSize: 12, height: 1.4))),
          ]),
        ),
      ]),
    );
  }
}

// ── Interactive weekly calendar ────────────────────────────────────────────────

class _WeeklyActivityInteractive extends StatelessWidget {
  final TrainingController ctrl;
  const _WeeklyActivityInteractive({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final c      = context.colors;
    const days   = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    final today  = DateTime.now().weekday - 1;
    final byDay  = ctrl.sessionsByWeekday;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: c.surface, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (i) {
          final sessions  = byDay[i] ?? [];
          final isToday   = i == today;
          final hasSess   = sessions.isNotEmpty;

          return GestureDetector(
            onTap: () => _showDaySessions(context, i, sessions, c),
            child: Column(children: [
              Text(days[i], style: TextStyle(
                  color: isToday ? c.accent : c.muted,
                  fontSize: 11, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: isToday ? c.accent : hasSess ? c.accentLo : c.elevated,
                  shape: BoxShape.circle,
                  border: isToday ? null : Border.all(
                    color: hasSess ? c.borderGreen : c.border, width: 1.5),
                ),
                child: Icon(
                  hasSess ? Icons.fitness_center_rounded
                      : isToday ? Icons.today_rounded
                      : Icons.remove,
                  color: isToday ? Colors.black : hasSess ? c.accent : c.border,
                  size: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(hasSess ? '${sessions.length}' : '',
                  style: TextStyle(color: c.accent, fontSize: 9, fontWeight: FontWeight.w800)),
            ]),
          );
        }),
      ),
    );
  }

  void _showDaySessions(BuildContext context, int dayIdx,
      List<TrainingSession> sessions, AppColorTokens c) {
    const dayNames = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141414),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(dayNames[dayIdx],
              style: TextStyle(color: c.textHi, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('${sessions.length} sesión${sessions.length != 1 ? "es" : ""}',
              style: TextStyle(color: c.muted, fontSize: 13)),
          const SizedBox(height: 16),
          if (sessions.isEmpty)
            Center(child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text('Sin sesiones este día', style: TextStyle(color: c.dim)),
            ))
          else
            ...sessions.map((s) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: c.surface, borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.border),
              ),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: TrainingSession.categoryColor(s.category).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(s.category, style: TextStyle(
                      color: TrainingSession.categoryColor(s.category),
                      fontSize: 10, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(s.title,
                    style: TextStyle(color: c.textHi, fontSize: 13, fontWeight: FontWeight.w600))),
                Text('${s.durationMinutes} min',
                    style: TextStyle(color: c.muted, fontSize: 11)),
              ]),
            )),
        ]),
      ),
    );
  }
}

// ── Auto-insights banner ──────────────────────────────────────────────────────

class _AutoInsightsBanner extends StatelessWidget {
  final TrainingController ctrl;
  const _AutoInsightsBanner({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final c       = context.colors;
    final insights = ctrl.autoInsights;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [c.accentLo, c.surface],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.borderGreen),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 28, height: 28,
              decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.black, size: 14)),
          const SizedBox(width: 8),
          Text('Insights automáticos',
              style: TextStyle(color: c.text, fontSize: 13, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 12),
        ...insights.map((txt) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(txt, style: TextStyle(color: c.text, fontSize: 13, height: 1.4)),
        )),
      ]),
    );
  }
}

// ── Progress chart (fl_chart) ─────────────────────────────────────────────────

class _ProgressChart extends StatelessWidget {
  final TrainingController ctrl;
  const _ProgressChart({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final c     = context.colors;
    final spots = ctrl.weeklySpots;
    final maxY  = spots.map((s) => s.$2).fold(0.0, (a, b) => a > b ? a : b);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: c.surface, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Actividad semanal',
              style: TextStyle(color: c.text, fontSize: 13, fontWeight: FontWeight.w700)),
          const Spacer(),
          Text('sesiones / día',
              style: TextStyle(color: c.muted, fontSize: 11)),
        ]),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: maxY < 1 ? 3 : maxY + 1,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (_) => FlLine(
                    color: c.border.withValues(alpha: 0.5), strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (v, _) {
                    const labels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
                    final i = v.toInt();
                    if (i < 0 || i > 6) return const SizedBox.shrink();
                    return Text(labels[i],
                        style: TextStyle(color: c.muted, fontSize: 10));
                  },
                )),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots.map((s) => FlSpot(s.$1, s.$2)).toList(),
                  isCurved: true,
                  curveSmoothness: 0.3,
                  color: c.accent,
                  barWidth: 2.5,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                      radius: spot.y > 0 ? 4 : 2,
                      color: spot.y > 0 ? c.accent : c.border,
                      strokeWidth: 0,
                      strokeColor: Colors.transparent,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: c.accent.withValues(alpha: 0.08),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

// ── AI suggestions carousel ────────────────────────────────────────────────────

class _AISuggestionsCarousel extends StatelessWidget {
  final TrainingController ctrl;
  const _AISuggestionsCarousel({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    if (ctrl.loadingSuggestions) {
      return SizedBox(height: 160,
          child: Center(child: CircularProgressIndicator(color: c.accent, strokeWidth: 1.5)));
    }

    if (ctrl.suggestions.isEmpty) {
      return Container(
        height: 100, margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(color: c.surface,
            borderRadius: BorderRadius.circular(16), border: Border.all(color: c.border)),
        child: Center(child: Text('Sin sugerencias disponibles',
            style: TextStyle(color: c.muted, fontSize: 13))),
      );
    }

    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: ctrl.suggestions.length,
        itemBuilder: (_, i) => _AISuggestionCard(
          data: ctrl.suggestions[i],
          onSave: () async {
            final s = ctrl.suggestions[i];
            await ctrl.createSession(
              title: s['title'] as String,
              category: s['category'] as String,
              durationMinutes: s['duration_minutes'] as int,
              description: s['reason'] as String?,
            );
          },
        ),
      ),
    );
  }
}

class _AISuggestionCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onSave;
  const _AISuggestionCard({required this.data, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final title    = data['title']            as String? ?? '';
    final category = data['category']         as String? ?? 'Tactical';
    final duration = data['duration_minutes'] as int?    ?? 60;
    final reason   = data['reason']           as String? ?? '';
    final catColor = TrainingSession.categoryColor(category);
    final imgUrl   = TrainingSession.categoryImage(category);

    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(fit: StackFit.expand, children: [
          Image.network(imgUrl, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: catColor.withValues(alpha: 0.3))),
          DecoratedBox(decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.92)]))),
          Positioned(top: 10, left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(color: catColor, borderRadius: BorderRadius.circular(6)),
              child: Text(category,
                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
            ),
          ),
          // AI badge
          Positioned(top: 10, right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                  color: Colors.black54, borderRadius: BorderRadius.circular(6)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.auto_awesome_rounded, color: Colors.amber, size: 9),
                SizedBox(width: 3),
                Text('IA', style: TextStyle(color: Colors.amber, fontSize: 9, fontWeight: FontWeight.w800)),
              ]),
            ),
          ),
          Positioned(left: 10, right: 10, bottom: 10,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 12,
                      fontWeight: FontWeight.w700, height: 1.3)),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.timer_outlined, color: Colors.white60, size: 11),
                const SizedBox(width: 3),
                Expanded(child: Text('$duration min',
                    style: const TextStyle(color: Colors.white60, fontSize: 10))),
                GestureDetector(
                  onTap: onSave,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Guardar',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
                ),
              ]),
              if (reason.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(reason, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white38, fontSize: 9)),
                ),
            ]),
          ),
        ]),
      ),
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
