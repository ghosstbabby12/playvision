import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:playvision/core/constants/app_constants.dart';
import 'package:playvision/core/theme/app_color_tokens.dart';
import 'package:playvision/features/home/presentation/home_controller.dart';
import 'package:playvision/features/home/presentation/widgets/home_search_delegate.dart';
import '../../../../../../l10n/generated/app_localizations.dart';

class HeroSection extends StatelessWidget {
  final HomeController controller;
  const HeroSection({super.key, required this.controller});

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Buenos días, DT';
    if (h < 19) return 'Buenas tardes, DT';
    return 'Buenas noches, DT';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final total = controller.recentMatches.length;
    final done = controller.recentMatches
        .where((m) => m['status'] == AppConstants.statusDone)
        .length;
    final todayStr = DateFormat('d MMM').format(DateTime.now());
    final teamName = controller.selectedTeam?['name'] as String?;

    return SizedBox(
      height: 185,
      child: Stack(fit: StackFit.expand, children: [
        // Stadium background
        Image.network(
          'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=900&q=80',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: c.heroTop),
        ),

        // Gradient overlay
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [
                      const Color(0xFF050816).withValues(alpha: 0.50),
                      const Color(0xFF050816).withValues(alpha: 0.96),
                    ]
                  : [
                      const Color(0xFF07111F).withValues(alpha: 0.30),
                      const Color(0xFF07111F).withValues(alpha: 0.94),
                    ],
            ),
          ),
        ),

        // Ambient glow blob bottom-left
        Positioned(
          bottom: -20,
          left: -20,
          child: IgnorePointer(
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF32FF88)
                        .withValues(alpha: isDark ? 0.12 : 0.18),
                    blurRadius: 70,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Content
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── App bar row ────────────────────────────────────────────
                  Row(children: [
                    Icon(Icons.sports_soccer_outlined,
                        color: c.accent, size: 18),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        l10n.appTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => showSearch(
                          context: context,
                          delegate: HomeSearchDelegate(controller)),
                      child: const Icon(Icons.search_rounded,
                          color: Colors.white70, size: 21),
                    ),
                    const SizedBox(width: 10),
                    Builder(
                      builder: (ctx) => GestureDetector(
                        onTap: () => Scaffold.of(ctx).openEndDrawer(),
                        child: const Icon(Icons.settings_outlined,
                            color: Colors.white70, size: 21),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 10),

                  // ── Greeting ───────────────────────────────────────────────
                  Text(
                    _greeting(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    teamName != null
                        ? '$teamName · listo para analizar'
                        : 'PlayVision · plataforma táctica IA',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.60),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const Spacer(),

                  // ── Stat pills ─────────────────────────────────────────────
                  Row(children: [
                    _StatPill(label: l10n.totalMatches, value: '$total'),
                    const SizedBox(width: 7),
                    _StatPill(label: l10n.analysed, value: '$done'),
                    const SizedBox(width: 7),
                    _StatPill(label: l10n.heroAiAccuracy, value: '94%'),
                    const SizedBox(width: 7),
                    _StatPill(label: l10n.heroLatest, value: todayStr),
                  ]),
                ]),
          ),
        ),
      ]),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.38)
                  : const Color(0xFF07111F).withValues(alpha: 0.52),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : Colors.white.withValues(alpha: 0.18),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: c.muted,
                    fontSize: 7.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    color: c.accent,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// SparkLine kept for potential reuse elsewhere
class SparkLine extends StatelessWidget {
  final List<double> values;
  final Color color;
  const SparkLine({super.key, required this.values, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 36,
      child: CustomPaint(painter: SparkPainter(values, color)),
    );
  }
}

class SparkPainter extends CustomPainter {
  final List<double> values;
  final Color color;
  const SparkPainter(this.values, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final x = size.width * (i / (values.length - 1));
      final y = size.height * (1 - values[i]);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SparkPainter old) => old.color != color;
}
