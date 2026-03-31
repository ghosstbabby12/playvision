import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class MatchCard extends StatelessWidget {
  final String rival;
  final String date;
  final String team;
  final String source;
  final String statusText;
  final Color statusColor;

  const MatchCard({
    super.key,
    required this.rival,
    required this.date,
    required this.team,
    required this.source,
    required this.statusText,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(children: [
      Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.sports_soccer_outlined, color: AppColors.accent, size: 20),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(rival,
              style: const TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('$team · $date',
              style: const TextStyle(color: AppColors.dim, fontSize: 11)),
          const SizedBox(height: 2),
          Text(source,
              style: const TextStyle(color: AppColors.accentLo, fontSize: 10)),
        ]),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(statusText,
            style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w600)),
      ),
    ]),
  );
}
