import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/section_label.dart';

class SummaryTab extends StatelessWidget {
  final Map<String, dynamic> data;
  const SummaryTab({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final team    = data['team'] as Map<String, dynamic>;
    final players = data['players'] as List;
    final maxKm   = players.fold<double>(0, (p, e) {
      final d = (e['distance_km'] as num?)?.toDouble() ?? 0;
      return d > p ? d : p;
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          StatCard('${data['players_detected']}', 'Players', Icons.groups_outlined),
          const SizedBox(width: 10),
          StatCard('${team['total_distance_km'] ?? '—'} km', 'Total dist.', Icons.route_outlined),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          StatCard('${team['avg_distance_km'] ?? '—'} km', 'Avg. dist.', Icons.person_pin_outlined),
          const SizedBox(width: 10),
          StatCard('${team['possession_pct'] ?? 0}%', 'Possession', Icons.sports_soccer_outlined),
        ]),

        const SizedBox(height: 28),
        const SectionLabel('AI INSIGHTS'),
        const SizedBox(height: 12),
        ..._buildInsights(team, players, data).map((i) => AiInsightCard(text: i)),

        const SizedBox(height: 28),
        const SectionLabel('DISTANCE BY PLAYER'),
        const SizedBox(height: 12),
        DistanceBarChart(players: players, maxKm: maxKm),

        const SizedBox(height: 28),
        const SectionLabel('HIGHLIGHTS'),
        const SizedBox(height: 12),
        HighlightRow(icon: Icons.bolt_outlined,          label: 'Most active',     value: 'Player ${team['most_active'] ?? '—'}'),
        const SizedBox(height: 8),
        HighlightRow(icon: Icons.sports_soccer_outlined, label: 'Most possession', value: 'Player ${team['most_possession'] ?? '—'}'),
        const SizedBox(height: 8),
        HighlightRow(icon: Icons.battery_saver_outlined, label: 'Least active',    value: 'Player ${team['least_active'] ?? '—'}'),
        const SizedBox(height: 20),
      ]),
    );
  }

  static List<String> _buildInsights(
    Map<String, dynamic> team,
    List players,
    Map<String, dynamic> data,
  ) {
    final insights = <String>[];
    final totalKm = (team['total_distance_km'] as num?)?.toDouble() ?? 0;
    final poss    = (team['possession_pct']    as num?)?.toDouble() ?? 0;
    final count   = data['players_detected'] as int? ?? 0;

    if (totalKm > 0) insights.add('The team covered ${totalKm.toStringAsFixed(2)} km in total during the analysis.');
    if (poss > 0)    insights.add('Ball possession: ${poss.toStringAsFixed(1)}% of analysed time.');
    if (count > 0)   insights.add('$count active players were detected on the field.');

    if (players.isNotEmpty) {
      final fastest = players.reduce((a, b) =>
          ((a['speed_ms'] as num?) ?? 0) > ((b['speed_ms'] as num?) ?? 0) ? a : b);
      final spd = (fastest['speed_ms'] as num?)?.toDouble() ?? 0;
      if (spd > 0) insights.add('Player ${fastest['rank']} reached the highest speed: ${spd.toStringAsFixed(1)} m/s.');

      final zones     = players.map((p) => p['zone'] as String? ?? '').toList();
      final zoneCount = <String, int>{};
      for (final z in zones) { zoneCount[z] = (zoneCount[z] ?? 0) + 1; }
      final topZone   = zoneCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      if (topZone.isNotEmpty) insights.add('The team was mainly concentrated in the $topZone zone.');
    }

    return insights.take(4).toList();
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  const StatCard(this.value, this.label, this.icon, {super.key});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        Icon(icon, color: AppColors.accent, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value,
              style: const TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.w800),
              overflow: TextOverflow.ellipsis),
          Text(label, style: const TextStyle(color: AppColors.dim, fontSize: 11)),
        ])),
      ]),
    ),
  );
}

class AiInsightCard extends StatelessWidget {
  final String text;
  const AiInsightCard({super.key, required this.text});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.accentLo,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.accentLo),
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.auto_awesome_outlined, color: AppColors.accent, size: 16),
      const SizedBox(width: 10),
      Expanded(child: Text(text,
          style: const TextStyle(color: AppColors.text, fontSize: 13, height: 1.5))),
    ]),
  );
}

class HighlightRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const HighlightRow({super.key, required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(children: [
      Icon(icon, color: AppColors.accent, size: 18),
      const SizedBox(width: 12),
      Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 13)),
      const Spacer(),
      Text(value, style: const TextStyle(color: AppColors.text, fontSize: 13, fontWeight: FontWeight.w600)),
    ]),
  );
}

class DistanceBarChart extends StatelessWidget {
  final List players;
  final double maxKm;
  const DistanceBarChart({super.key, required this.players, required this.maxKm});

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty || maxKm == 0) return const SizedBox();
    final bars = players.map((p) {
      final km    = (p['distance_km'] as num?)?.toDouble() ?? 0;
      final rank  = p['rank'] as int;
      final ratio = maxKm > 0 ? km / maxKm : 0.0;
      final color = ratio > 0.66 ? AppColors.textHi : ratio > 0.33 ? AppColors.accent : AppColors.accentLo;
      return BarChartGroupData(x: rank, barRods: [BarChartRodData(
        toY: km, color: color, width: 12,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      )]);
    }).toList();

    return Container(
      height: 160,
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: BarChart(BarChartData(
        maxY: maxKm * 1.2,
        gridData: FlGridData(
          show: true, drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => const FlLine(color: AppColors.border, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (v, _) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('${v.toInt()}',
                  style: const TextStyle(color: AppColors.dim, fontSize: 10)),
            ),
          )),
        ),
        barGroups: bars,
      )),
    );
  }
}
