import 'package:flutter/material.dart';

import '../../../../../core/theme/app_color_tokens.dart';

class TeamInsightsCard extends StatelessWidget {
  final List<String> insights;
  const TeamInsightsCard({super.key, required this.insights});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.auto_awesome_outlined, color: c.accent, size: 16),
          const SizedBox(width: 8),
          Text('Team analysis',
              style: TextStyle(color: c.text, fontSize: 14, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 14),
        ...insights.map((txt) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Icon(Icons.circle, color: c.accent, size: 5),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(txt,
                style: TextStyle(color: c.muted, fontSize: 13, height: 1.5))),
          ]),
        )),
      ]),
    );
  }
}
