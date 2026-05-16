import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/app_color_tokens.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../../shared/widgets/section_label.dart';

class SummaryTab extends StatelessWidget {
  final Map<String, dynamic> data;
  const SummaryTab({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final team = data['team'] as Map<String, dynamic>;
    final players = data['players'] as List;

    final maxKm = players.fold<double>(0, (p, e) {
      final d = (e['distance_km'] as num?)?.toDouble() ?? 0;
      return d > p ? d : p;
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatCard(
                '${data['players_detected']}',
                l10n.summaryPlayers,
                Icons.groups_outlined,
              ),
              const SizedBox(width: 10),
              StatCard(
                '${team['total_distance_km'] ?? '—'} km',
                l10n.summaryTotalDist,
                Icons.route_outlined,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              StatCard(
                '${team['avg_distance_km'] ?? '—'} km',
                l10n.summaryAvgDist,
                Icons.person_pin_outlined,
              ),
              const SizedBox(width: 10),
              StatCard(
                '${team['possession_pct'] ?? 0}%',
                l10n.summaryPossession,
                Icons.sports_soccer_outlined,
              ),
            ],
          ),
          const SizedBox(height: 28),
          SectionLabel(l10n.summaryAiInsights),
          const SizedBox(height: 12),
          ..._buildInsights(context, team, players, data)
              .map((i) => AiInsightCard(text: i)),
          const SizedBox(height: 28),
          SectionLabel(l10n.summaryDistByPlayer),
          const SizedBox(height: 12),
          DistanceBarChart(players: players, maxKm: maxKm),
          const SizedBox(height: 28),
          SectionLabel(l10n.summaryHighlights),
          const SizedBox(height: 12),
          HighlightRow(
            icon: Icons.bolt_outlined,
            label: l10n.summaryMostActive,
            value: l10n.summaryPlayerRef('${team['most_active'] ?? '—'}'),
          ),
          const SizedBox(height: 8),
          HighlightRow(
            icon: Icons.sports_soccer_outlined,
            label: l10n.summaryMostPossession,
            value: l10n.summaryPlayerRef('${team['most_possession'] ?? '—'}'),
          ),
          const SizedBox(height: 8),
          HighlightRow(
            icon: Icons.battery_saver_outlined,
            label: l10n.summaryLeastActive,
            value: l10n.summaryPlayerRef('${team['least_active'] ?? '—'}'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  static List<String> _buildInsights(
    BuildContext context,
    Map<String, dynamic> team,
    List players,
    Map<String, dynamic> data,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final insights = <String>[];
    final totalKm = (team['total_distance_km'] as num?)?.toDouble() ?? 0;
    final poss = (team['possession_pct'] as num?)?.toDouble() ?? 0;
    final count = data['players_detected'] as int? ?? 0;

    if (totalKm > 0) {
      insights.add(l10n.insightTotalKm(totalKm.toStringAsFixed(2)));
    }
    if (poss > 0) {
      insights.add(l10n.insightPossession(poss.toStringAsFixed(1)));
    }
    if (count > 0) {
      insights.add(l10n.insightActivePlayers(count.toString()));
    }

    if (players.isNotEmpty) {
      final fastest = players.reduce(
        (a, b) =>
            ((a['speed_ms'] as num?) ?? 0) > ((b['speed_ms'] as num?) ?? 0)
                ? a
                : b,
      );

      final spd = (fastest['speed_ms'] as num?)?.toDouble() ?? 0;
      if (spd > 0) {
        insights.add(
          l10n.insightFastestPlayer(
            '${fastest['rank']}',
            spd.toStringAsFixed(1),
          ),
        );
      }

      final zones = players.map((p) => p['zone'] as String? ?? '').toList();
      final zoneCount = <String, int>{};

      for (final z in zones) {
        zoneCount[z] = (zoneCount[z] ?? 0) + 1;
      }

      final topZone =
          zoneCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;

      if (topZone.isNotEmpty) {
        insights.add(l10n.insightTopZone(topZone));
      }
    }

    return insights.take(4).toList();
  }
}

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const StatCard(this.value, this.label, this.icon, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: c.accent, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: c.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    label,
                    style: TextStyle(color: c.dim, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AiInsightCard extends StatelessWidget {
  final String text;
  const AiInsightCard({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.accentLo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.accentLo),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome_outlined, color: c.accent, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: c.text, fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class HighlightRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const HighlightRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: c.accent, size: 18),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: c.muted, fontSize: 13)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: c.text,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class DistanceBarChart extends StatelessWidget {
  final List players;
  final double maxKm;

  const DistanceBarChart({
    super.key,
    required this.players,
    required this.maxKm,
  });

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty || maxKm == 0) return const SizedBox();

    final c = context.colors;

    final bars = players.map((p) {
      final km = (p['distance_km'] as num?)?.toDouble() ?? 0;
      final rank = p['rank'] as int;
      final ratio = maxKm > 0 ? km / maxKm : 0.0;
      final color =
          ratio > 0.66 ? c.textHi : ratio > 0.33 ? c.accent : c.accentLo;

      return BarChartGroupData(
        x: rank,
        barRods: [
          BarChartRodData(
            toY: km,
            color: color,
            width: 12,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();

    final borderColor = c.border;
    final dimColor = c.dim;

    return Container(
      height: 160,
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
      ),
      child: BarChart(
        BarChartData(
          maxY: maxKm * 1.2,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) =>
                FlLine(color: borderColor, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${v.toInt()}',
                    style: TextStyle(color: dimColor, fontSize: 10),
                  ),
                ),
              ),
            ),
          ),
          barGroups: bars,
        ),
      ),
    );
  }
}