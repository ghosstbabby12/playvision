import 'package:flutter/material.dart';
import 'package:playvision/features/matches/presentation/match_summary_page.dart';

class OpenMatchSummaryButton extends StatelessWidget {
  const OpenMatchSummaryButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.analytics_outlined),
        label: const Text('Ver resumen del análisis'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MatchSummaryPage(),
            ),
          );
        },
      ),
    );
  }
}
