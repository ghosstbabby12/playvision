import 'package:flutter/material.dart';
import 'package:playvision/core/theme/app_color_tokens.dart';
import 'package:playvision/features/analysis/data/analysis_store.dart';

class AiInsightsSection extends StatelessWidget {
  const AiInsightsSection({super.key});

  // Builds real insights from the last analysis result, or returns defaults.
  static List<({IconData icon, String text})> _buildInsights(
      Map<String, dynamic>? result) {
    if (result == null) {
      return [
        (icon: Icons.trending_up_rounded,    text: 'Analiza un partido para ver insights reales de tu equipo'),
        (icon: Icons.psychology_outlined,     text: 'La IA detectará patrones tácticos y de rendimiento'),
        (icon: Icons.sports_soccer_rounded,   text: 'Sube un video desde "Analizar Video" para comenzar'),
      ];
    }

    final team    = result['team'] as Map<String, dynamic>? ?? {};
    final players = result['players'] as List? ?? [];
    final out     = <({IconData icon, String text})>[];

    final totalKm = (team['total_distance_km'] as num?)?.toDouble() ?? 0;
    final poss    = (team['possession_pct']    as num?)?.toDouble() ?? 0;
    final count   = result['players_detected'] as int? ?? 0;
    final most    = team['most_active'];
    final least   = team['least_active'];

    if (totalKm > 0) {
      out.add((
        icon: Icons.route_rounded,
        text: 'Distancia total del equipo: ${totalKm.toStringAsFixed(2)} km',
      ));
    }

    if (poss > 0) {
      out.add((
        icon: Icons.sports_soccer_rounded,
        text: 'Posesión del balón: ${poss.toStringAsFixed(1)}%',
      ));
    }

    if (count > 0) {
      out.add((
        icon: Icons.groups_rounded,
        text: '$count jugadores activos detectados en el análisis',
      ));
    }

    if (most != null) {
      out.add((
        icon: Icons.bolt_rounded,
        text: 'Jugador #$most fue el más activo del partido',
      ));
    }

    if (least != null) {
      out.add((
        icon: Icons.battery_saver_outlined,
        text: 'Jugador #$least registró la menor actividad',
      ));
    }

    if (players.isNotEmpty) {
      final fastest = players.reduce((a, b) =>
          ((a['speed_ms'] as num?) ?? 0) > ((b['speed_ms'] as num?) ?? 0)
              ? a
              : b);
      final spd = (fastest['speed_ms'] as num?)?.toDouble() ?? 0;
      if (spd > 0) {
        out.add((
          icon: Icons.speed_rounded,
          text: 'Jugador #${fastest['rank']} fue el más rápido: ${spd.toStringAsFixed(1)} m/s',
        ));
      }

      final zones    = players.map((p) => p['zone'] as String? ?? '').toList();
      final zoneCnt  = <String, int>{};
      for (final z in zones) {
        if (z.isNotEmpty) zoneCnt[z] = (zoneCnt[z] ?? 0) + 1;
      }
      if (zoneCnt.isNotEmpty) {
        final topZone = zoneCnt.entries.reduce((a, b) => a.value > b.value ? a : b).key;
        out.add((
          icon: Icons.map_outlined,
          text: 'Zona más activa del partido: $topZone',
        ));
      }
    }

    return out.take(4).toList();
  }

  @override
  Widget build(BuildContext context) {
    final c       = context.colors;
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final result  = AnalysisStore.instance.lastResult;
    final insights = _buildInsights(result);
    final hasData  = result != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: c.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(Icons.psychology_outlined, color: c.accent, size: 17),
          ),
          const SizedBox(width: 10),
          Text(
            'Insights IA',
            style: TextStyle(
              color: c.textHi,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          if (hasData)
            _LiveBadge(c: c)
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: c.dim.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: c.dim.withValues(alpha: 0.20)),
              ),
              child: Text(
                'Sin datos',
                style: TextStyle(
                    color: c.muted, fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ),
        ]),
        const SizedBox(height: 12),
        ...insights.map((ins) => _InsightRow(
              icon: ins.icon,
              text: ins.text,
              isDark: isDark,
            )),
      ]),
    );
  }
}

class _LiveBadge extends StatefulWidget {
  final AppColorTokens c;
  const _LiveBadge({required this.c});

  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _pulse = Tween(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: c.accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.accent.withValues(alpha: 0.22)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        AnimatedBuilder(
          animation: _pulse,
          builder: (_, __) => Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c.accent.withValues(alpha: _pulse.value),
              boxShadow: [
                BoxShadow(
                  color: c.accent.withValues(alpha: _pulse.value * 0.6),
                  blurRadius: 5,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          'En vivo',
          style: TextStyle(
              color: c.accent, fontSize: 10, fontWeight: FontWeight.w700),
        ),
      ]),
    );
  }
}

class _InsightRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;
  const _InsightRow(
      {required this.icon, required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: isDark
            ? c.elevated.withValues(alpha: 0.60)
            : Colors.white.withValues(alpha: 0.80),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : c.accent.withValues(alpha: 0.10),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Row(children: [
        Icon(icon, color: c.accent, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: c.text,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
        ),
      ]),
    );
  }
}
