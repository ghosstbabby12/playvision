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
    final titleCtrl      = TextEditingController();
    final descCtrl       = TextEditingController();
    String category      = TrainingSession.categories.first;
    int durationMinutes  = 60;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141414),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        final c = ctx.colors;
        return StatefulBuilder(
          builder: (ctx, setModal) => Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text('Nueva sesión',
                    style: TextStyle(color: c.textHi, fontSize: 18, fontWeight: FontWeight.w800))),
                GestureDetector(onTap: () => Navigator.of(ctx).pop(),
                    child: Icon(Icons.close_rounded, color: c.muted)),
              ]),
              const SizedBox(height: 20),
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Título de la sesión',
                  hintStyle: TextStyle(color: c.muted),
                  filled: true, fillColor: c.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: c.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: c.border)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Descripción (opcional)',
                  hintStyle: TextStyle(color: c.muted),
                  filled: true, fillColor: c.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: c.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: c.border)),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(spacing: 8, children: TrainingSession.categories.map((cat) {
                final selected = cat == category;
                return GestureDetector(
                  onTap: () => setModal(() => category = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: selected ? TrainingSession.categoryColor(cat) : c.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: selected ? TrainingSession.categoryColor(cat) : c.border),
                    ),
                    child: Text(cat, style: TextStyle(
                        color: selected ? Colors.white : c.muted, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                );
              }).toList()),
              const SizedBox(height: 12),
              Row(children: [
                Text('Duración:', style: TextStyle(color: c.muted, fontSize: 13)),
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
                      child: Text('${min}m', style: TextStyle(
                          color: sel ? c.accent : c.muted, fontSize: 12, fontWeight: FontWeight.w700)),
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
                      title: title, category: category,
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
                  child: const Text('Crear sesión', style: TextStyle(fontWeight: FontWeight.w800)),
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
            icon: Icons.videocam_rounded, label: 'Analizar entrenamiento',
            subtitle: 'Sube un vídeo y obtén métricas con IA',
            color: const Color(0xFF39D353),
            onTap: () { Navigator.of(context).pop(); widget.onTabChange?.call(1); },
          ),
          const SizedBox(height: 12),
          _AddOptionTile(
            icon: Icons.edit_note_rounded, label: 'Crear sesión manual',
            subtitle: 'Planifica una sesión de entrenamiento',
            color: const Color(0xFF3B82F6),
            onTap: () { Navigator.of(context).pop(); _showCreateSessionDialog(context, _controller); },
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
              SliverToBoxAdapter(child: _SmartHero(l10n: l10n, ctrl: _controller)),

              // ── AI Insights panel ─────────────────────────────────────
              SliverToBoxAdapter(child: _AIInsightsPanel(ctrl: _controller)),

              // ── Smart analysis workflow / fitness card ─────────────────
              SliverToBoxAdapter(child: _FitnessCard(
                ctrl: _controller,
                onAnalyze: () => widget.onTabChange?.call(1),
              )),

              // ── Top Players ───────────────────────────────────────────
              SliverToBoxAdapter(child: _TopPlayersSection(ctrl: _controller)),

              // ── Weekly calendar ───────────────────────────────────────
              SliverToBoxAdapter(child: _WeeklyActivityInteractive(ctrl: _controller)),

              // ── Progress chart ────────────────────────────────────────
              SliverToBoxAdapter(child: _ProgressChart(ctrl: _controller)),

              // ── Alerts ────────────────────────────────────────────────
              const SliverToBoxAdapter(child: _AIAlertsCard()),

              // ── Player connections ────────────────────────────────────
              SliverToBoxAdapter(child: _PlayerConnectionsCard(ctrl: _controller)),

              // ── Team analysis (if result exists) ─────────────────────
              if (hasResult) ...[
                SliverToBoxAdapter(child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                  child: Text(l10n.aiRecommendationsTeam,
                      style: TextStyle(color: c.text, fontSize: 16, fontWeight: FontWeight.w800)),
                )),
                SliverToBoxAdapter(child: _TeamInsightsBanner(insights: _controller.buildTeamInsights())),
                if (_controller.players != null && _controller.players!.isNotEmpty) ...[
                  SliverToBoxAdapter(child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                    child: Text(l10n.personalisedPlanByPlayer,
                        style: TextStyle(color: c.text, fontSize: 16, fontWeight: FontWeight.w800)),
                  )),
                  SliverList(delegate: SliverChildBuilderDelegate(
                    (_, i) => _PlayerArcCard(
                      player: _controller.players![i] as Map<String, dynamic>,
                      recommendations: _controller.buildPlayerRecommendations(
                          _controller.players![i] as Map<String, dynamic>),
                    ),
                    childCount: _controller.players!.length,
                  )),
                ],
              ],

              // ── AI Coach ──────────────────────────────────────────────
              const SliverToBoxAdapter(child: _AICoachCard()),

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
                SliverToBoxAdapter(child: _SectionHeader(label: 'MIS SESIONES', c: c)),
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

// ══════════════════════════════════════════════════════════════════════════════
// SMART HERO
// ══════════════════════════════════════════════════════════════════════════════

class _SmartHero extends StatelessWidget {
  final AppLocalizations l10n;
  final TrainingController ctrl;
  const _SmartHero({required this.l10n, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final c         = context.colors;
    final hasResult = ctrl.result != null;
    final score     = ctrl.fitnessScore;

    return SizedBox(
      height: 270,
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
                Colors.black.withValues(alpha: 0.20),
                Colors.black.withValues(alpha: 0.94),
              ],
            ),
          ),
        ),
        // Ambient glow
        Positioned(
          bottom: 0, left: 0, right: 0, height: 120,
          child: DecoratedBox(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: c.accent.withValues(alpha: 0.10),
                  blurRadius: 40, spreadRadius: 0,
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const PvBackButton(lightIcon: true),
                const Spacer(),
                // Pulse badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: c.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: c.accent.withValues(alpha: 0.4)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(
                        color: c.accent, shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: c.accent.withValues(alpha: 0.6), blurRadius: 5)],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('AI TRAINING', style: TextStyle(
                        color: c.accent, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ]),
                ),
              ]),
              const Spacer(),
              Text(l10n.trainingTitle,
                  style: const TextStyle(color: Colors.white, fontSize: 30,
                      fontWeight: FontWeight.w900, letterSpacing: -0.5, height: 1.1)),
              const SizedBox(height: 2),
              Text(DateFormat('EEEE, d MMMM').format(DateTime.now()),
                  style: const TextStyle(color: Colors.white54, fontSize: 13)),
              const SizedBox(height: 16),
              // Floating stat pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  _HeroPill(
                    icon: Icons.fitness_center_rounded,
                    label: hasResult ? '${score.toInt()}%' : '--',
                    sublabel: 'Fitness',
                  ),
                  const SizedBox(width: 8),
                  _HeroPill(
                    icon: Icons.people_rounded,
                    label: hasResult ? '${ctrl.players?.length ?? 0}' : '--',
                    sublabel: 'Jugadores',
                  ),
                  const SizedBox(width: 8),
                  _HeroPill(
                    icon: Icons.calendar_today_rounded,
                    label: '${ctrl.sessions.length}',
                    sublabel: 'Sesiones',
                  ),
                  const SizedBox(width: 8),
                  _HeroPill(
                    icon: Icons.auto_awesome_rounded,
                    label: hasResult ? 'LIVE' : 'AI',
                    sublabel: 'Estado',
                    highlight: true,
                  ),
                ]),
              ),
              const SizedBox(height: 22),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _HeroPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final bool highlight;
  const _HeroPill({required this.icon, required this.label, required this.sublabel, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: highlight
            ? c.accent.withValues(alpha: 0.14)
            : Colors.black.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight
              ? c.accent.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: highlight ? c.accent : Colors.white70, size: 13),
        const SizedBox(width: 6),
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(label, style: TextStyle(
              color: highlight ? c.accent : Colors.white,
              fontSize: 12, fontWeight: FontWeight.w800)),
          Text(sublabel, style: const TextStyle(color: Colors.white54, fontSize: 9)),
        ]),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// AI INSIGHTS PANEL
// ══════════════════════════════════════════════════════════════════════════════

class _AIInsightsPanel extends StatelessWidget {
  final TrainingController ctrl;
  const _AIInsightsPanel({required this.ctrl});

  static const _demo = [
    (Icons.warning_amber_rounded,          Color(0xFFFF6B6B), 'Defensa demasiado abierta',   'Espacios de 12m entre centrales'),
    (Icons.trending_up_rounded,            Color(0xFF32FF88), 'Mejora destacada +14%',        'Jugador #8 incrementó su resistencia'),
    (Icons.local_fire_department_rounded,  Color(0xFFFF9500), 'Conexión: Torres ↔ Ramírez',  '87% de pases entre sí'),
    (Icons.track_changes_rounded,          Color(0xFF64B5F6), 'Posesión del equipo: 63%',    'Por encima de la media del torneo'),
    (Icons.bolt_rounded,                   Color(0xFFFFD60A), 'Riesgo de fatiga detectado',  'Jugador #3 supera umbral aeróbico'),
  ];

  @override
  Widget build(BuildContext context) {
    final c        = context.colors;
    final insights = ctrl.autoInsights;
    final hasReal  = insights.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [c.accent, c.accentHi]),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: c.accent.withValues(alpha: 0.4), blurRadius: 12)],
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.black, size: 16),
          ),
          const SizedBox(width: 10),
          Text('AI Insights', style: TextStyle(
              color: c.textHi, fontSize: 17, fontWeight: FontWeight.w800)),
          const Spacer(),
          if (!hasReal)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: c.elevated, borderRadius: BorderRadius.circular(20),
                border: Border.all(color: c.border),
              ),
              child: Text('demo', style: TextStyle(
                  color: c.muted, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
            ),
        ]),
        const SizedBox(height: 14),
        if (hasReal)
          ...insights.map((txt) => _InsightCard(
            icon: Icons.auto_awesome_rounded, color: c.accent,
            title: txt, subtitle: '', c: c))
        else
          ..._demo.map((d) => _InsightCard(
            icon: d.$1, color: d.$2, title: d.$3, subtitle: d.$4, c: c)),
      ]),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final AppColorTokens c;
  const _InsightCard({required this.icon, required this.color, required this.title,
      required this.subtitle, required this.c});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: c.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withValues(alpha: 0.22)),
    ),
    child: Row(children: [
      Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(color: c.text, fontSize: 13, fontWeight: FontWeight.w700, height: 1.2)),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(color: c.muted, fontSize: 11)),
        ],
      ])),
      Icon(Icons.chevron_right_rounded, color: c.dim, size: 16),
    ]),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// FITNESS / WORKFLOW CARD
// ══════════════════════════════════════════════════════════════════════════════

class _FitnessCard extends StatelessWidget {
  final TrainingController ctrl;
  final VoidCallback onAnalyze;
  const _FitnessCard({required this.ctrl, required this.onAnalyze});

  static const _steps = [
    (Icons.upload_rounded,         'Subir vídeo de entrenamiento'),
    (Icons.people_alt_rounded,     'Detectar jugadores con IA'),
    (Icons.sports_rounded,         'Analizar movimientos y táctica'),
    (Icons.bar_chart_rounded,      'Generar insights y métricas'),
    (Icons.picture_as_pdf_rounded, 'Exportar reporte del equipo'),
  ];

  @override
  Widget build(BuildContext context) {
    final c         = context.colors;
    final hasResult = ctrl.result != null;

    if (!hasResult) {
      return Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: c.accentLo, borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: c.borderGreen),
                ),
                child: Icon(Icons.videocam_rounded, color: c.accent, size: 20),
              ),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Smart Analysis', style: TextStyle(
                    color: c.textHi, fontSize: 15, fontWeight: FontWeight.w800)),
                Text('Flujo de análisis con IA', style: TextStyle(color: c.muted, fontSize: 11)),
              ]),
            ]),
          ),
          Divider(height: 1, color: c.border),
          ..._steps.asMap().entries.map((e) {
            final active = e.key == 0;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(children: [
                Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    color: active ? c.accentLo : c.elevated,
                    shape: BoxShape.circle,
                    border: active ? Border.all(color: c.borderGreen) : null,
                  ),
                  child: Icon(e.value.$1,
                      color: active ? c.accent : c.dim, size: 15),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(e.value.$2,
                    style: TextStyle(
                        color: active ? c.text : c.dim,
                        fontSize: 13,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w400))),
                if (active)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: c.accentLo, borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('Pendiente', style: TextStyle(
                        color: c.accent, fontSize: 9, fontWeight: FontWeight.w700)),
                  ),
              ]),
            );
          }),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: GestureDetector(
              onTap: onAnalyze,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [c.accent, c.accentHi]),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: c.accent.withValues(alpha: 0.35),
                        blurRadius: 18, offset: const Offset(0, 4)),
                  ],
                ),
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.upload_rounded, color: Colors.black, size: 18),
                  SizedBox(width: 8),
                  Text('Subir vídeo de entrenamiento',
                      style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w800)),
                ]),
              ),
            ),
          ),
        ]),
      );
    }

    // ── Has real result ──
    final score       = ctrl.fitnessScore;
    final status      = ctrl.fitnessStatusLabel;
    final statusColor = ctrl.fitnessStatusColor;

    return GlassCard(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(20),
      neonBorder: true,
      accentColor: statusColor,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
          Text('Estado físico', style: TextStyle(color: c.muted, fontSize: 11)),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          SizedBox(width: 80, height: 80,
            child: CustomPaint(
              painter: _ArcPainter(progress: score / 100, trackColor: c.elevated, fillColor: statusColor),
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
          decoration: BoxDecoration(color: c.elevated, borderRadius: BorderRadius.circular(10)),
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

// ══════════════════════════════════════════════════════════════════════════════
// TOP PLAYERS
// ══════════════════════════════════════════════════════════════════════════════

class _TopPlayersSection extends StatelessWidget {
  final TrainingController ctrl;
  const _TopPlayersSection({required this.ctrl});

  static const _demo = [
    (Icons.directions_run_rounded,        Color(0xFF32FF88), '#7  Sánchez',  '11.2 km', '↑ +0.8', 'Distancia'),
    (Icons.bolt_rounded,                  Color(0xFFFFD60A), '#10 Ramírez',  '31 km/h',  '↑ +2.1', 'Velocidad'),
    (Icons.track_changes_rounded,         Color(0xFF64B5F6), '#5  Torres',   '92%',      '→  =',   'Precisión'),
    (Icons.star_rounded,                  Color(0xFFFF9500), '#8  Fernández','94 pts',   '↑  MVP', 'Rating AI'),
  ];

  @override
  Widget build(BuildContext context) {
    final c       = context.colors;
    final players = ctrl.players;
    final hasReal = players != null && players.isNotEmpty;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 26, 20, 12),
        child: Row(children: [
          Text('TOP JUGADORES', style: TextStyle(
              color: c.muted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.4)),
          const Spacer(),
          if (!hasReal)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: c.elevated, borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: c.border)),
              child: Text('demo', style: TextStyle(
                  color: c.muted, fontSize: 9, fontWeight: FontWeight.w700)),
            ),
        ]),
      ),
      SizedBox(
        height: 130,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: hasReal
              ? players.take(4).map((p) {
                  final player = p as Map<String, dynamic>;
                  final rank   = player['rank'] as int? ?? 0;
                  final km     = (player['distance_km'] as num?)?.toDouble() ?? 0;
                  return _TopPlayerCard(
                    icon: Icons.directions_run_rounded, color: c.accent,
                    name: '#$rank Jugador', value: '${km.toStringAsFixed(1)} km',
                    trend: '↑', label: 'Distancia', c: c,
                  );
                }).toList()
              : _demo.map((d) => _TopPlayerCard(
                  icon: d.$1, color: d.$2, name: d.$3, value: d.$4,
                  trend: d.$5, label: d.$6, c: c)).toList(),
        ),
      ),
    ]);
  }
}

class _TopPlayerCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String name;
  final String value;
  final String trend;
  final String label;
  final AppColorTokens c;
  const _TopPlayerCard({required this.icon, required this.color, required this.name,
      required this.value, required this.trend, required this.label, required this.c});

  @override
  Widget build(BuildContext context) {
    final isUp       = trend.startsWith('↑');
    final isDown     = trend.startsWith('↓');
    final trendColor = isUp ? c.accent : isDown ? const Color(0xFFFF6B6B) : c.muted;

    return Container(
      width: 114,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.25)),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 14)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 17),
        ),
        const Spacer(),
        Text(value, style: TextStyle(
            color: c.textHi, fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        Text(label, style: TextStyle(color: c.muted, fontSize: 9)),
        const SizedBox(height: 5),
        Row(children: [
          Expanded(child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(color: c.text, fontSize: 9))),
          Text(trend.trim(), style: TextStyle(
              color: trendColor, fontSize: 10, fontWeight: FontWeight.w800)),
        ]),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ALERTS
// ══════════════════════════════════════════════════════════════════════════════

class _AIAlertsCard extends StatelessWidget {
  const _AIAlertsCard();

  static const _alerts = [
    (Icons.warning_rounded,          Color(0xFFFF6B6B), 'Fatiga detectada',     'Jugadores #3 y #7 en zona de riesgo'),
    (Icons.accessibility_new_rounded,Color(0xFFFFD60A), 'Movilidad reducida',   'Línea defensiva con baja actividad'),
    (Icons.sports_soccer_rounded,    Color(0xFF64B5F6), 'Desorden táctico',     'Alta presión con baja organización'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFF6B6B).withValues(alpha: 0.22)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.notifications_active_rounded,
              color: Color(0xFFFF6B6B), size: 16),
          const SizedBox(width: 8),
          Text('Alertas AI', style: TextStyle(
              color: c.text, fontSize: 13, fontWeight: FontWeight.w800)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('${_alerts.length}', style: const TextStyle(
                color: Color(0xFFFF6B6B), fontSize: 11, fontWeight: FontWeight.w800)),
          ),
        ]),
        const SizedBox(height: 14),
        ..._alerts.map((a) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                  color: a.$2.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9)),
              child: Icon(a.$1, color: a.$2, size: 15),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(a.$3, style: TextStyle(color: c.text, fontSize: 12, fontWeight: FontWeight.w700)),
              Text(a.$4, style: TextStyle(color: c.muted, fontSize: 11)),
            ])),
          ]),
        )),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PLAYER CONNECTIONS
// ══════════════════════════════════════════════════════════════════════════════

class _PlayerConnectionsCard extends StatelessWidget {
  final TrainingController ctrl;
  const _PlayerConnectionsCard({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final c        = context.colors;
    final hasResult = ctrl.result != null;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.hub_rounded, color: c.accent, size: 18),
          const SizedBox(width: 8),
          Text('Conexiones tácticas', style: TextStyle(
              color: c.text, fontSize: 13, fontWeight: FontWeight.w800)),
          const Spacer(),
          if (!hasResult)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: c.elevated, borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: c.border)),
              child: Text('demo', style: TextStyle(
                  color: c.muted, fontSize: 9, fontWeight: FontWeight.w700)),
            ),
        ]),
        const SizedBox(height: 14),
        _ConnectionRow(from: 'Torres', to: 'Ramírez',   pct: 0.87),
        _ConnectionRow(from: 'Sánchez', to: 'Torres',   pct: 0.72),
        _ConnectionRow(from: 'Ramírez', to: 'Fernández',pct: 0.61),
      ]),
    );
  }
}

class _ConnectionRow extends StatelessWidget {
  final String from;
  final String to;
  final double pct;
  const _ConnectionRow({required this.from, required this.to, required this.pct});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        _PlayerBadge(name: from),
        const SizedBox(width: 8),
        Expanded(child: Stack(children: [
          Container(height: 3, decoration: BoxDecoration(
              color: c.elevated, borderRadius: BorderRadius.circular(2))),
          FractionallySizedBox(
            widthFactor: pct,
            child: Container(height: 3, decoration: BoxDecoration(
                gradient: LinearGradient(colors: [c.accent, c.accentHi]),
                borderRadius: BorderRadius.circular(2))),
          ),
        ])),
        const SizedBox(width: 8),
        Text('${(pct * 100).toInt()}%', style: TextStyle(
            color: c.accent, fontSize: 11, fontWeight: FontWeight.w800)),
        const SizedBox(width: 8),
        _PlayerBadge(name: to),
      ]),
    );
  }
}

class _PlayerBadge extends StatelessWidget {
  final String name;
  const _PlayerBadge({required this.name});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: c.accentLo, borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.borderGreen),
      ),
      child: Text(name, style: TextStyle(
          color: c.accent, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// AI COACH CARD
// ══════════════════════════════════════════════════════════════════════════════

class _AICoachCard extends StatelessWidget {
  const _AICoachCard();

  static const _tips = [
    (Icons.grid_4x4_rounded,      'Formación sugerida: 4-2-3-1'),
    (Icons.arrow_upward_rounded,  'Subir bloque defensivo 10 metros'),
    (Icons.block_rounded,         'Evitar presión por banda izquierda'),
    (Icons.swap_horiz_rounded,    'Mayor rotación en mediocampo'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [c.accentLo, c.surface],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.borderGreen),
        boxShadow: [BoxShadow(color: c.accent.withValues(alpha: 0.10), blurRadius: 24)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [c.accent, c.accentHi]),
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: c.accent.withValues(alpha: 0.45), blurRadius: 14)],
              ),
              child: const Icon(Icons.psychology_rounded, color: Colors.black, size: 19),
            ),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('AI Coach Mode', style: TextStyle(
                  color: c.textHi, fontSize: 15, fontWeight: FontWeight.w800)),
              Text('Recomendaciones tácticas', style: TextStyle(color: c.muted, fontSize: 11)),
            ]),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: c.elevated, borderRadius: BorderRadius.circular(20),
                border: Border.all(color: c.border),
              ),
              child: Text('demo', style: TextStyle(
                  color: c.muted, fontSize: 9, fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 16),
          ..._tips.map((t) => Padding(
            padding: const EdgeInsets.only(bottom: 11),
            child: Row(children: [
              Container(
                width: 30, height: 30,
                decoration: BoxDecoration(
                    color: c.accent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(9)),
                child: Icon(t.$1, color: c.accent, size: 15),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(t.$2,
                  style: TextStyle(color: c.text, fontSize: 13, height: 1.3))),
            ]),
          )),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// WEEKLY CALENDAR (unchanged logic)
// ══════════════════════════════════════════════════════════════════════════════

class _WeeklyActivityInteractive extends StatelessWidget {
  final TrainingController ctrl;
  const _WeeklyActivityInteractive({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final c     = context.colors;
    const days  = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    final today = DateTime.now().weekday - 1;
    final byDay = ctrl.sessionsByWeekday;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: c.surface, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (i) {
          final sessions = byDay[i] ?? [];
          final isToday  = i == today;
          final hasSess  = sessions.isNotEmpty;

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
                      : isToday ? Icons.today_rounded : Icons.remove,
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
    const dayNames = ['Lunes','Martes','Miércoles','Jueves','Viernes','Sábado','Domingo'];
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
                Text('${s.durationMinutes} min', style: TextStyle(color: c.muted, fontSize: 11)),
              ]),
            )),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PROGRESS CHART
// ══════════════════════════════════════════════════════════════════════════════

class _ProgressChart extends StatelessWidget {
  final TrainingController ctrl;
  const _ProgressChart({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final c    = context.colors;
    final spots = ctrl.weeklySpots;
    final maxY  = spots.map((s) => s.$2).fold(0.0, (a, b) => a > b ? a : b);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: c.surface, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Actividad semanal', style: TextStyle(
              color: c.text, fontSize: 13, fontWeight: FontWeight.w700)),
          const Spacer(),
          Text('sesiones / día', style: TextStyle(color: c.muted, fontSize: 11)),
        ]),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: LineChart(LineChartData(
            minY: 0,
            maxY: maxY < 1 ? 3 : maxY + 1,
            gridData: FlGridData(
              show: true, drawVerticalLine: false, horizontalInterval: 1,
              getDrawingHorizontalLine: (_) =>
                  FlLine(color: c.border.withValues(alpha: 0.5), strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(sideTitles: SideTitles(
                showTitles: true, interval: 1,
                getTitlesWidget: (v, _) {
                  const labels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
                  final i = v.toInt();
                  if (i < 0 || i > 6) return const SizedBox.shrink();
                  return Text(labels[i], style: TextStyle(color: c.muted, fontSize: 10));
                },
              )),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots.map((s) => FlSpot(s.$1, s.$2)).toList(),
                isCurved: true, curveSmoothness: 0.3,
                color: c.accent, barWidth: 2.5,
                dotData: FlDotData(show: true,
                  getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                    radius: spot.y > 0 ? 4 : 2,
                    color: spot.y > 0 ? c.accent : c.border,
                    strokeWidth: 0, strokeColor: Colors.transparent,
                  ),
                ),
                belowBarData: BarAreaData(show: true,
                  gradient: LinearGradient(
                    colors: [c.accent.withValues(alpha: 0.18), c.accent.withValues(alpha: 0.0)],
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          )),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SHARED SECTION HEADER
// ══════════════════════════════════════════════════════════════════════════════

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
          style: TextStyle(color: c.muted, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.4))),
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

// ══════════════════════════════════════════════════════════════════════════════
// ADD OPTION TILE
// ══════════════════════════════════════════════════════════════════════════════

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

// ══════════════════════════════════════════════════════════════════════════════
// TEAM INSIGHTS BANNER
// ══════════════════════════════════════════════════════════════════════════════

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
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.borderGreen),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 32, height: 32,
              decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.black, size: 16)),
          const SizedBox(width: 10),
          Text('AI Team Analysis',
              style: TextStyle(color: c.text, fontSize: 14, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 14),
        ...insights.map((txt) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 6, height: 6,
                margin: const EdgeInsets.only(top: 5, right: 10),
                decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle)),
            Expanded(child: Text(txt,
                style: TextStyle(color: c.text, fontSize: 13, height: 1.5))),
          ]),
        )),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PER-PLAYER ARC CARD
// ══════════════════════════════════════════════════════════════════════════════

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
    final c           = context.colors;
    final rank        = widget.player['rank'] as int;
    final km          = (widget.player['distance_km']    as num?)?.toDouble() ?? 0;
    final spd         = (widget.player['speed_ms']       as num?)?.toDouble() ?? 0;
    final poss        = (widget.player['possession_pct'] as num?)?.toDouble() ?? 0;
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
              SizedBox(width: 56, height: 56,
                child: CustomPaint(
                  painter: _ArcPainter(
                      progress: kmProgress, trackColor: c.elevated,
                      fillColor: c.accent, strokeWidth: 5),
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
                  _MiniStat(label: 'km',   value: km.toStringAsFixed(1),  c: c),
                  const SizedBox(width: 16),
                  _MiniStat(label: 'm/s',  value: spd.toStringAsFixed(1), c: c),
                  const SizedBox(width: 16),
                  _MiniStat(label: 'poss', value: '$poss%',               c: c),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(children: [
                _ProgressBar(label: 'Distance', value: kmProgress,
                    displayVal: '${km.toStringAsFixed(2)} km', c: c),
                const SizedBox(height: 8),
                _ProgressBar(label: 'Speed', value: spdProgress,
                    displayVal: '${spd.toStringAsFixed(1)} m/s', c: c),
              ]),
            ),
            Divider(color: c.border, height: 1),
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

// ══════════════════════════════════════════════════════════════════════════════
// AI SUGGESTIONS CAROUSEL
// ══════════════════════════════════════════════════════════════════════════════

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
          Positioned(top: 10, right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
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

// ══════════════════════════════════════════════════════════════════════════════
// DYNAMIC SESSION CAROUSEL
// ══════════════════════════════════════════════════════════════════════════════

class _DynamicSessionCarousel extends StatelessWidget {
  final TrainingController controller;
  const _DynamicSessionCarousel({required this.controller});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (controller.loadingSessions) {
      return SizedBox(height: 200,
          child: Center(child: CircularProgressIndicator(color: c.accent, strokeWidth: 1.5)));
    }
    if (controller.sessions.isEmpty) {
      return Container(
        height: 140, margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: c.surface, borderRadius: BorderRadius.circular(18),
          border: Border.all(color: c.border),
        ),
        child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.fitness_center_rounded, color: c.dim, size: 32),
          const SizedBox(height: 10),
          Text('Sin sesiones aún', style: TextStyle(color: c.text, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Toca "+ Nuevo" para crear tu primera sesión',
              style: TextStyle(color: c.muted, fontSize: 12)),
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
            Image.network(imageUrl, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: c.surface)),
            DecoratedBox(decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.88)]))),
            Positioned(top: 12, left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: catColor, borderRadius: BorderRadius.circular(6)),
                child: Text(session.category,
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
              ),
            ),
            Positioned(top: 8, right: 8,
              child: GestureDetector(
                onTap: () => _confirmDelete(context),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.close_rounded, color: Colors.white70, size: 13),
                ),
              ),
            ),
            Positioned(left: 12, right: 12, bottom: 12,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(session.title, maxLines: 2, overflow: TextOverflow.ellipsis,
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
        title: const Text('¿Eliminar sesión?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        content: Text('"${session.title}" será eliminada.',
            style: const TextStyle(color: Colors.white60)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar', style: TextStyle(color: Colors.white60))),
          TextButton(
            onPressed: () { Navigator.of(context).pop(); onDelete(); },
            child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SHARED SMALL WIDGETS
// ══════════════════════════════════════════════════════════════════════════════

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
    Expanded(child: ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: value,
        backgroundColor: c.elevated,
        valueColor: AlwaysStoppedAnimation<Color>(c.accent),
        minHeight: 6,
      ),
    )),
    const SizedBox(width: 8),
    SizedBox(width: 52, child: Text(displayVal, textAlign: TextAlign.right,
        style: TextStyle(color: c.accent, fontSize: 11, fontWeight: FontWeight.w700))),
  ]);
}

// ══════════════════════════════════════════════════════════════════════════════
// ARC PAINTER
// ══════════════════════════════════════════════════════════════════════════════

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color fillColor;
  final double strokeWidth;
  const _ArcPainter({
    required this.progress, required this.trackColor,
    required this.fillColor, this.strokeWidth = 7,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect   = Rect.fromCircle(center: center, radius: radius);
    const start  = -math.pi * 0.75;
    const sweep  = math.pi * 1.5;

    canvas.drawArc(rect, start, sweep, false,
        Paint()..color = trackColor..strokeWidth = strokeWidth
            ..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    if (progress > 0) {
      canvas.drawArc(rect, start, sweep * progress, false,
          Paint()..color = fillColor..strokeWidth = strokeWidth
              ..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    }
  }

  @override
  bool shouldRepaint(covariant _ArcPainter old) =>
      old.progress != progress || old.fillColor != fillColor;
}
