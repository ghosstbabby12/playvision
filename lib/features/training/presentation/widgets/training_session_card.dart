import 'package:flutter/material.dart';

import '../../../../../core/theme/app_color_tokens.dart';

class TrainingSessionCard extends StatelessWidget {
  final String title;
  final String date;
  final String duration;
  final String category;
  final Color color;

  const TrainingSessionCard({
    super.key,
    required this.title,
    required this.date,
    required this.duration,
    required this.category,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
      ),
      child: Row(children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.fitness_center_outlined, color: color, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: TextStyle(color: c.text, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 5),
          Text('$date · $duration',
              style: TextStyle(color: c.dim, fontSize: 11)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(category,
              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}
