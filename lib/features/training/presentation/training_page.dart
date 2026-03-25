import 'package:flutter/material.dart';
import '../../../core/store/analysis_store.dart';

class TrainingPage extends StatelessWidget {
  const TrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final result  = AnalysisStore.instance.lastResult;
    final players = result?['players'] as List?;
    final team    = result?['team']    as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            // ── Header ────────────────────────────────────────
            Row(children: [
              const Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Entrenamiento',
                      style: TextStyle(color: Color(0xFFE2E8F4), fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                  SizedBox(height: 4),
                  Text('Plan basado en tu rendimiento',
                      style: TextStyle(color: Color(0xFF4A5568), fontSize: 13)),
                ]),
              ),
            ]),

            const SizedBox(height: 28),

            if (result == null) ...[
              // ── No data state ────────────────────────────────
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x0FFFFFFF)),
                ),
                child: const Column(children: [
                  Icon(Icons.auto_awesome_outlined, color: Color(0xFF2D4A6A), size: 36),
                  SizedBox(height: 12),
                  Text('Sin análisis disponible',
                      style: TextStyle(color: Color(0xFF4A5568), fontSize: 14, fontWeight: FontWeight.w500)),
                  SizedBox(height: 6),
                  Text('Analiza un partido para obtener\nrecomendaciones personalizadas.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF2D4A6A), fontSize: 12, height: 1.6)),
                ]),
              ),

              const SizedBox(height: 32),
              const _SLabel('SESIONES SUGERIDAS'),
              const SizedBox(height: 14),
            ] else ...[
              // ── Team AI Insights ─────────────────────────────
              const _SLabel('RECOMENDACIONES IA — EQUIPO'),
              const SizedBox(height: 12),
              _AIInsightsCard(team: team, players: players),

              const SizedBox(height: 28),

              // ── Player Plans ─────────────────────────────────
              if (players != null && players.isNotEmpty) ...[
                const _SLabel('PLAN PERSONALIZADO POR JUGADOR'),
                const SizedBox(height: 12),
                ...players.map((p) => _PlayerPlanCard(player: p as Map<String, dynamic>)),
                const SizedBox(height: 28),
              ],
            ],

            // ── Static session cards (always shown) ─────────
            const _SLabel('SESIONES SUGERIDAS'),
            const SizedBox(height: 14),
            _SessionCard(
              title: 'Pressing alto y transiciones',
              date: '14 Mar 2026', duration: '90 min', category: 'Táctica',
              color: const Color(0xFF4A7FA5),
            ),
            _SessionCard(
              title: 'Juego de posición 4-3-3',
              date: '12 Mar 2026', duration: '75 min', category: 'Técnica',
              color: const Color(0xFF3D7A5E),
            ),
            _SessionCard(
              title: 'Preparación física — resistencia',
              date: '10 Mar 2026', duration: '60 min', category: 'Físico',
              color: const Color(0xFF7A6A3D),
            ),
            _SessionCard(
              title: 'Balón parado — córners ofensivos',
              date: '8 Mar 2026', duration: '45 min', category: 'Set piece',
              color: const Color(0xFF5A4A7A),
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

// ── AI Team Insights card ────────────────────────────────────────────────────

class _AIInsightsCard extends StatelessWidget {
  final Map<String, dynamic>? team;
  final List? players;
  const _AIInsightsCard({required this.team, required this.players});

  List<String> _buildInsights() {
    final insights = <String>[];
    if (team == null || players == null || players!.isEmpty) return insights;

    final avgKm        = (team!['avg_distance_km'] as num?)?.toDouble() ?? 0;
    final possPct      = (team!['possession_pct']  as num?)?.toDouble() ?? 0;
    final mostActive   = team!['most_active'];
    final leastActive  = team!['least_active'];
    final mostPoss     = team!['most_possession'];

    if (avgKm < 1.5) {
      insights.add('El equipo recorre poca distancia promedio (${avgKm.toStringAsFixed(2)} km). Aumenta la intensidad aeróbica en sesiones de resistencia.');
    } else if (avgKm > 3.0) {
      insights.add('El equipo tiene alta movilidad (${avgKm.toStringAsFixed(2)} km/jugador). Trabaja recuperación y gestión del esfuerzo.');
    }

    if (possPct < 30) {
      insights.add('El equipo pierde posesión con frecuencia (${possPct.toStringAsFixed(1)}%). Refuerza el juego de posición en campo propio.');
    } else if (possPct > 60) {
      insights.add('Buena posesión del equipo (${possPct.toStringAsFixed(1)}%). Enfócate en finalizar jugadas y aprovechar el dominio.');
    }

    if (mostActive != null && leastActive != null && mostActive != leastActive) {
      insights.add('Gran diferencia entre jugador más activo (#$mostActive) y menos activo (#$leastActive). Trabaja en distribución del esfuerzo táctico.');
    }

    if (mostPoss != null) {
      insights.add('El jugador #$mostPoss concentra mayor tiempo en posesión. Trabaja la circulación de balón para distribuir más.');
    }

    if (insights.isEmpty) {
      insights.add('El rendimiento general del equipo es equilibrado. Continúa con el plan táctico actual y refuerza la comunicación en campo.');
    }

    return insights;
  }

  @override
  Widget build(BuildContext context) {
    final insights = _buildInsights();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x0FFFFFFF)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: const [
          Icon(Icons.auto_awesome_outlined, color: Color(0xFF7C9EBF), size: 16),
          SizedBox(width: 8),
          Text('Análisis del equipo', style: TextStyle(color: Color(0xFFE2E8F4), fontSize: 14, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 14),
        ...insights.map((txt) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Padding(
              padding: EdgeInsets.only(top: 3),
              child: Icon(Icons.circle, color: Color(0xFF7C9EBF), size: 5),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(txt, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.5))),
          ]),
        )),
      ]),
    );
  }
}

// ── Player plan card ─────────────────────────────────────────────────────────

class _PlayerPlanCard extends StatelessWidget {
  final Map<String, dynamic> player;
  const _PlayerPlanCard({required this.player});

  List<String> _tips() {
    final tips     = <String>[];
    final km       = (player['distance_km']   as num?)?.toDouble() ?? 0;
    final speed    = (player['speed_ms']       as num?)?.toDouble() ?? 0;
    final poss     = (player['possession_pct'] as num?)?.toDouble() ?? 0;
    final presence = (player['presence_pct']   as num?)?.toDouble() ?? 0;
    final zone     = player['zone'] as String? ?? '';

    if (km < 0.5) {
      tips.add('Mejorar resistencia aeróbica — recorrido bajo (${km.toStringAsFixed(2)} km)');
    } else if (km > 2.5) {
      tips.add('Alta actividad (${km.toStringAsFixed(2)} km) — incluir trabajo de recuperación');
    }

    if (speed < 1.0) {
      tips.add('Mejorar velocidad de desplazamiento');
    } else if (speed > 4.0) {
      tips.add('Potencia explosiva alta — refuerza coordinación táctica');
    }

    if (poss < 5) {
      tips.add('Mejorar participación con balón — posesión baja (${poss.toStringAsFixed(1)}%)');
    }

    if (presence < 50) {
      tips.add('Mejorar posicionamiento — presencia en campo del ${presence.toStringAsFixed(0)}%');
    }

    if (zone.contains('Defensa')) {
      tips.add('Refuerza salida de balón desde zona defensiva');
    } else if (zone.contains('Ataque')) {
      tips.add('Trabajar finalización y pressing ofensivo');
    }

    if (tips.isEmpty) {
      tips.add('Rendimiento equilibrado — mantener plan físico actual');
    }

    return tips;
  }

  @override
  Widget build(BuildContext context) {
    final rank = player['rank'] as int? ?? 0;
    final km   = (player['distance_km'] as num?)?.toStringAsFixed(2) ?? '—';
    final zone = player['zone'] as String? ?? '—';
    final tips = _tips();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x0FFFFFFF)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 38, height: 38,
            decoration: const BoxDecoration(color: Color(0x1A7C9EBF), shape: BoxShape.circle),
            child: Center(
              child: Text('$rank',
                  style: const TextStyle(color: Color(0xFF7C9EBF), fontSize: 14, fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Jugador #$rank', style: const TextStyle(color: Color(0xFFE2E8F4), fontSize: 13, fontWeight: FontWeight.w600)),
            Text('$km km · $zone', style: const TextStyle(color: Color(0xFF4A5568), fontSize: 11)),
          ])),
        ]),
        const SizedBox(height: 12),
        ...tips.map((tip) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Padding(
              padding: EdgeInsets.only(top: 5),
              child: Icon(Icons.arrow_right_rounded, color: Color(0xFF4A7FA5), size: 14),
            ),
            const SizedBox(width: 6),
            Expanded(child: Text(tip, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.4))),
          ]),
        )),
      ]),
    );
  }
}

// ── Session card ─────────────────────────────────────────────────────────────

class _SessionCard extends StatelessWidget {
  final String title, date, duration, category;
  final Color color;
  const _SessionCard({required this.title, required this.date, required this.duration, required this.category, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFF111827),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0x0FFFFFFF)),
    ),
    child: Row(children: [
      Container(
        width: 42, height: 42,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
        child: Icon(Icons.fitness_center_outlined, color: color, size: 18),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: Color(0xFFE2E8F4), fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        Text('$date · $duration', style: const TextStyle(color: Color(0xFF4A5568), fontSize: 11)),
      ])),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
        child: Text(category, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
      ),
    ]),
  );
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SLabel extends StatelessWidget {
  final String text;
  const _SLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(color: Color(0xFF4A5568), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2));
}
