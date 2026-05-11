import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:playvision/core/constants/app_constants.dart';
import 'package:playvision/core/theme/app_color_tokens.dart';
import 'package:playvision/features/home/presentation/home_controller.dart';
import 'package:playvision/features/home/presentation/widgets/home_search_delegate.dart';
import 'package:playvision/shared/widgets/pv_back_button.dart';

import '../../../../../../l10n/generated/app_localizations.dart';

class HeroSection extends StatelessWidget {
  final HomeController controller;
  const HeroSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final c      = context.colors;
    final l10n   = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total  = controller.recentMatches.length;
    final done   = controller.recentMatches
        .where((m) => m['status'] == AppConstants.statusDone).length;
    final todayStr = DateFormat('d MMM').format(DateTime.now());

    return SizedBox(
      height: 290,
      child: Stack(fit: StackFit.expand, children: [
        // ── Stadium background image ────────────────────────────────────────
        Image.network(
          'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=900&q=80',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: c.heroTop),
        ),

        // ── Cinematic gradient overlay (brightness-aware) ───────────────────
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [
                      const Color(0xFF050816).withValues(alpha: 0.55),
                      const Color(0xFF050816).withValues(alpha: 0.95),
                    ]
                  : [
                      const Color(0xFF07111F).withValues(alpha: 0.35),
                      const Color(0xFF07111F).withValues(alpha: 0.90),
                    ],
            ),
          ),
        ),

        // ── Left ambient accent glow blob ───────────────────────────────────
        Positioned(
          bottom: -30,
          left: -30,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF32FF88).withValues(alpha: isDark ? 0.12 : 0.18),
                  blurRadius: 80,
                  spreadRadius: 40,
                ),
              ],
            ),
          ),
        ),

        // ── Content ─────────────────────────────────────────────────────────
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Header row
              Row(children: [
                const PvBackButton(lightIcon: true),
                const SizedBox(width: 10),
                Icon(Icons.sports_soccer_outlined, color: c.accent, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.appTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
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
                      color: Colors.white70, size: 22),
                ),
                const SizedBox(width: 8),
                Builder(builder: (ctx) => GestureDetector(
                  onTap: () => Scaffold.of(ctx).openEndDrawer(),
                  child: const Icon(Icons.settings_outlined,
                      color: Colors.white70, size: 22),
                )),
              ]),

              const Spacer(),

              // ── 4-pill stat row ────────────────────────────────────────────
              Row(children: [
                _StatPill(label: l10n.totalMatches,  value: '$total'),
                const SizedBox(width: 8),
                _StatPill(label: l10n.analysed,      value: '$done'),
                const SizedBox(width: 8),
                _StatPill(label: l10n.heroAiAccuracy, value: '94%'),
                const SizedBox(width: 8),
                _StatPill(label: l10n.heroLatest,     value: todayStr),
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
    final c      = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.40)
                  : const Color(0xFF07111F).withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.20),
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
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: c.accent,
                    fontSize: 18,
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
