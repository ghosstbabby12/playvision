import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class TeamInsightsCard extends StatelessWidget {
  final List<String> insights;
  const TeamInsightsCard({super.key, required this.insights});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [
        Icon(Icons.auto_awesome_outlined, color: AppColors.accent, size: 16),
        SizedBox(width: 8),
        Text('Team analysis',
            style: TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w700)),
      ]),
      const SizedBox(height: 14),
      ...insights.map((txt) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(
            padding: EdgeInsets.only(top: 5),
            child: Icon(Icons.circle, color: AppColors.accent, size: 5),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(txt,
              style: const TextStyle(color: AppColors.muted, fontSize: 13, height: 1.5))),
        ]),
      )),
    ]),
  );
}
