import 'dart:math' as math;

import 'package:flutter/material.dart';

class SoccerLogo extends StatelessWidget {
  final double size;
  const SoccerLogo({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E676).withValues(alpha: 0.15),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: const CustomPaint(painter: _SoccerPainter()),
    );
  }
}

class _SoccerPainter extends CustomPainter {
  const _SoccerPainter();

  static const _green = Color(0xFF00E676);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background gradient
    final basePaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.3, -0.3),
        radius: 1.0,
        colors: [Color(0xFF2C3248), Color(0xFF13141F)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, basePaint);

    // Outer ring
    canvas.drawCircle(
      center,
      radius - 2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..color = _green,
    );

    // Pentagon
    final pentagonRadius = radius * 0.35;
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * math.pi / 5) - (math.pi / 2);
      final x = center.dx + pentagonRadius * math.cos(angle);
      final y = center.dy + pentagonRadius * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = _green);

    // Seam lines
    final seamPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..color = _green
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * math.pi / 5) - (math.pi / 2);
      canvas.drawLine(
        Offset(center.dx + pentagonRadius * math.cos(angle),
               center.dy + pentagonRadius * math.sin(angle)),
        Offset(center.dx + radius * 0.85 * math.cos(angle),
               center.dy + radius * 0.85 * math.sin(angle)),
        seamPaint,
      );
    }

    // Highlight (3D effect)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy - radius * 0.4),
        width: radius * 1.2,
        height: radius * 0.6,
      ),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
