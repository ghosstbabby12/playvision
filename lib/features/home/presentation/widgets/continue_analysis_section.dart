import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:playvision/core/theme/app_color_tokens.dart';
import 'package:playvision/features/analysis/data/analysis_store.dart';
import 'package:playvision/features/analysis/presentation/analysis_page.dart';
import 'package:playvision/features/home/presentation/home_controller.dart';

class ContinueAnalysisSection extends StatelessWidget {
  final HomeController controller;
  const ContinueAnalysisSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final lastResult = AnalysisStore.instance.lastResult;
    if (lastResult == null) return const SizedBox.shrink();

    final c = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final matches = controller.selectedTeamMatches;
    final lastMatch = matches.isNotEmpty ? matches.first : null;
    final opponent =
        lastMatch?['opponent'] as String? ?? 'Último partido';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          'Continúa tu análisis',
          style: TextStyle(
            color: c.textHi,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AnalysisPage()),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? c.elevated.withValues(alpha: 0.72)
                      : Colors.white.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: c.borderGreen,
                    width: isDark ? 1.0 : 1.2,
                  ),
                  boxShadow: isDark
                      ? [
                          BoxShadow(
                            color: c.accent.withValues(alpha: 0.10),
                            blurRadius: 20,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                          BoxShadow(
                            color: c.accent.withValues(alpha: 0.08),
                            blurRadius: 14,
                            spreadRadius: -4,
                          ),
                        ],
                ),
                child: Row(children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: c.accent.withValues(alpha: isDark ? 0.15 : 0.10),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: c.accent.withValues(alpha: isDark ? 0.0 : 0.15),
                      ),
                    ),
                    child: Icon(Icons.play_arrow_rounded,
                        color: c.accent, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'vs $opponent',
                            style: TextStyle(
                              color: c.textHi,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Análisis completado · Toca para ver',
                            style:
                                TextStyle(color: c.muted, fontSize: 11.5),
                          ),
                        ]),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF32FF88), Color(0xFF1A8A44)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF32FF88)
                              .withValues(alpha: 0.30),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: const Text(
                      'Ver',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
