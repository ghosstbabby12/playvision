import 'dart:math' as math;
import 'package:flutter/material.dart';

class FieldPainter extends CustomPainter {
  final Color lineColor;
  final Color bgColor;

  const FieldPainter({required this.lineColor, required this.bgColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = bgColor,
    );

    // Subtle grass stripes
    final stripePaint = Paint()..color = Colors.white.withValues(alpha: 0.02);
    const stripes = 7;
    for (int i = 0; i < stripes; i++) {
      if (i.isEven) {
        canvas.drawRect(
          Rect.fromLTWH(0, h * i / stripes, w, h / stripes),
          stripePaint,
        );
      }
    }

    final line = Paint()
      ..color = lineColor
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final dot = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    // Outer border
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), line);

    // Halfway line
    canvas.drawLine(Offset(0, h * 0.5), Offset(w, h * 0.5), line);

    // Center circle (radius ≈ 9.15m / 68m width = 13.5%)
    final ccR = w * 0.135;
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), ccR, line);
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), 2.5, dot);

    // Penalty areas: 40.32m wide (59.3%), 16.5m deep (15.7%)
    final paW = w * 0.593;
    final paH = h * 0.157;
    final paX = (w - paW) / 2;
    canvas.drawRect(Rect.fromLTWH(paX, h - paH, paW, paH), line); // bottom
    canvas.drawRect(Rect.fromLTWH(paX, 0, paW, paH), line);        // top

    // Goal areas: 18.32m wide (26.9%), 5.5m deep (5.2%)
    final gaW = w * 0.269;
    final gaH = h * 0.052;
    final gaX = (w - gaW) / 2;
    canvas.drawRect(Rect.fromLTWH(gaX, h - gaH, gaW, gaH), line); // bottom
    canvas.drawRect(Rect.fromLTWH(gaX, 0, gaW, gaH), line);        // top

    // Penalty spots at 11m = 10.5% from goal line
    final psH = h * 0.105;
    canvas.drawCircle(Offset(w * 0.5, h - psH), 2.5, dot); // bottom
    canvas.drawCircle(Offset(w * 0.5, psH), 2.5, dot);      // top

    // Penalty arcs — clip to outside penalty area
    final arcR = w * 0.135;

    // Bottom arc: clip to y < h - paH
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, w, h - paH));
    canvas.drawCircle(Offset(w * 0.5, h - psH), arcR, line);
    canvas.restore();

    // Top arc: clip to y > paH
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, paH, w, h - paH));
    canvas.drawCircle(Offset(w * 0.5, psH), arcR, line);
    canvas.restore();

    // Corner arcs (radius ≈ 1m = ~3% of width)
    final cR = w * 0.032;
    canvas.drawArc(Rect.fromCircle(center: Offset(0, 0), radius: cR),
        0, math.pi / 2, false, line);
    canvas.drawArc(Rect.fromCircle(center: Offset(w, 0), radius: cR),
        math.pi / 2, math.pi / 2, false, line);
    canvas.drawArc(Rect.fromCircle(center: Offset(0, h), radius: cR),
        -math.pi / 2, math.pi / 2, false, line);
    canvas.drawArc(Rect.fromCircle(center: Offset(w, h), radius: cR),
        math.pi, math.pi / 2, false, line);
  }

  @override
  bool shouldRepaint(covariant FieldPainter old) => false;
}
