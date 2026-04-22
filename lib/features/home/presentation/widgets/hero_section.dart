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

  @override
  Widget build(BuildContext context) {
    final c     = context.colors;
    final l10n  = AppLocalizations.of(context)!;
    final total = controller.recentMatches.length;
    final done  = controller.recentMatches
        .where((m) => m['status'] == AppConstants.statusDone).length;

    return SizedBox(
      height: 260,
      child: Stack(fit: StackFit.expand, children: [
        Image.network(
          'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=900&q=80',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: c.heroTop),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.55),
                Colors.black.withValues(alpha: 0.82),
              ],
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.sports_soccer_outlined, color: c.accent, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('PlayVision',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                ),
                GestureDetector(
                  onTap: () => showSearch(context: context, delegate: HomeSearchDelegate(controller)),
                  child: const Icon(Icons.search_rounded, color: Colors.white70, size: 22),
                ),
                const SizedBox(width: 8),
                Builder(builder: (ctx) => GestureDetector(
                  onTap: () => Scaffold.of(ctx).openEndDrawer(),
                  child: const Icon(Icons.settings_outlined, color: Colors.white70, size: 22),
                )),
              ]),
              const Spacer(),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l10n.totalMatches,
                      style: const TextStyle(color: Colors.white60, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text('$total',
                      style: const TextStyle(
                        color: Colors.white, fontSize: 52, fontWeight: FontWeight.w900,
                        letterSpacing: -2, height: 1,
                      )),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: c.accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: c.accent.withValues(alpha: 0.5)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.check_circle_rounded, color: c.accent, size: 12),
                      const SizedBox(width: 4),
                      Text('$done ${l10n.analysed}',
                          style: TextStyle(color: c.accent, fontSize: 11, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  SparkLine(values: const [0.4, 0.6, 0.3, 0.8, 0.5, 0.9, 0.7], color: c.accent),
                  const SizedBox(height: 6),
                  Text(DateFormat('EEE d MMM').format(DateTime.now()),
                      style: const TextStyle(color: Colors.white54, fontSize: 11)),
                ]),
              ]),
            ]),
          ),
        ),
      ]),
    );
  }
}

class SparkLine extends StatelessWidget {
  final List<double> values;
  final Color color;
  const SparkLine({super.key, required this.values, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80, height: 36,
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
