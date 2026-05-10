import 'package:flutter/material.dart';

import '../../../../../core/theme/app_color_tokens.dart';
import '../../../../../shared/widgets/glass_card.dart';

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
  Widget build(BuildContext context) {
    final c = context.colors;
    final isYoutube = source.toLowerCase().contains('youtube');

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        // Status icon container
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: statusColor.withValues(alpha: 0.30),
              width: 0.8,
            ),
          ),
          child: Icon(
            Icons.sports_soccer_outlined,
            color: statusColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 14),

        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: rival name + status badge
              Row(children: [
                Expanded(
                  child: Text(
                    rival,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: c.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.30),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ]),

              const SizedBox(height: 5),

              // Bottom row: team + date + source
              Row(children: [
                Icon(Icons.shield_outlined, color: c.muted, size: 11),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    team,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: c.muted, fontSize: 11),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Container(
                    width: 2,
                    height: 2,
                    decoration: BoxDecoration(
                      color: c.muted.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Icon(Icons.calendar_today_outlined, color: c.muted, size: 11),
                const SizedBox(width: 4),
                Text(date, style: TextStyle(color: c.muted, fontSize: 11)),
              ]),

              const SizedBox(height: 3),

              // Source row
              Row(children: [
                Icon(
                  isYoutube
                      ? Icons.play_circle_outline_rounded
                      : Icons.upload_file_outlined,
                  color: c.accentHi,
                  size: 11,
                ),
                const SizedBox(width: 4),
                Text(
                  source,
                  style: TextStyle(
                    color: c.accentHi,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ]),
            ],
          ),
        ),
      ]),
    );
  }
}
