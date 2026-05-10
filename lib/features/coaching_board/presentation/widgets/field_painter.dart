import 'dart:math' as math;
import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FieldProjector — bilinear trapezoid mapping
//   u ∈ [0,1] left→right  |  v ∈ [0,1] attack(top)→defense(bottom)
//
// Layout:  top at 4 % height  (far / attack)
//          bottom at 88% height (near / defense)
//          leaves 12% for the 3-D slab below
// ─────────────────────────────────────────────────────────────────────────────

class FieldProjector {
  final double fw, fh;
  final Offset tl, tr, bl, br;

  FieldProjector(this.fw, this.fh)
      : tl = Offset(fw * 0.16, fh * 0.04),
        tr = Offset(fw * 0.84, fh * 0.04),
        bl = Offset(fw * 0.00, fh * 0.88),
        br = Offset(fw * 1.00, fh * 0.88);

  /// Field (u,v) → screen Offset.
  Offset call(double u, double v) {
    final top = Offset.lerp(tl, tr, u)!;
    final bot = Offset.lerp(bl, br, u)!;
    return Offset.lerp(top, bot, v)!;
  }

  /// Screen → (u, v).  Exact for a symmetric trapezoid.
  (double u, double v) inverse(Offset p) {
    final v = ((p.dy - tl.dy) / (bl.dy - tl.dy)).clamp(0.0, 1.0);
    final lx = lerpDouble(tl.dx, bl.dx, v)!;
    final rx = lerpDouble(tr.dx, br.dx, v)!;
    return (((p.dx - lx) / (rx - lx)).clamp(0.0, 1.0), v);
  }

  /// Horizontal screen width of field at row v.
  double rowWidth(double v) =>
      lerpDouble(tr.dx - tl.dx, br.dx - bl.dx, v)!;

  /// Total vertical screen height of the field surface.
  double get colHeight => bl.dy - tl.dy;
}

// ─────────────────────────────────────────────────────────────────────────────
// FieldPainter  — 3-D floating slab + perspective field markings
// ─────────────────────────────────────────────────────────────────────────────

class FieldPainter extends CustomPainter {
  final Color lineColor;
  final Color bgColor;
  const FieldPainter({required this.lineColor, required this.bgColor});

  // Slab thickness as fraction of height
  static const _slabFraction = 0.07;

  @override
  void paint(Canvas canvas, Size size) {
    final proj = FieldProjector(size.width, size.height);
    final slabH = size.height * _slabFraction;

    _drawGroundShadow(canvas, proj, size, slabH);
    _drawSlab(canvas, proj, size, slabH);
    _drawSurface(canvas, proj, size);
    _drawMarkings(canvas, proj);
  }

  // ── 1. Diffuse shadow cast on the "ground" ─────────────────────────────────

  void _drawGroundShadow(
      Canvas canvas, FieldProjector proj, Size size, double slabH) {
    final path = Path()
      ..moveTo(proj.tl.dx - 8, proj.tl.dy + slabH * 0.2)
      ..lineTo(proj.tr.dx + 8, proj.tr.dy + slabH * 0.2)
      ..lineTo(proj.br.dx + 14, proj.br.dy + slabH + 12)
      ..lineTo(proj.bl.dx - 14, proj.bl.dy + slabH + 12)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
    );
  }

  // ── 2. 3-D slab faces ──────────────────────────────────────────────────────

  void _drawSlab(
      Canvas canvas, FieldProjector proj, Size size, double slabH) {
    final w = size.width;

    // Pre-compute bottom edge of slab
    final blB = Offset(proj.bl.dx, proj.bl.dy + slabH);
    final brB = Offset(proj.br.dx, proj.br.dy + slabH);
    final tlB = Offset(proj.tl.dx, proj.tl.dy + slabH * 0.22);
    final trB = Offset(proj.tr.dx, proj.tr.dy + slabH * 0.22);

    // Left face — darkest (shadow side)
    canvas.drawPath(
      _quad(proj.tl, proj.bl, blB, tlB),
      Paint()..color = const Color(0xFF071207),
    );

    // Right face — slightly lit
    canvas.drawPath(
      _quad(proj.tr, proj.br, brB, trB),
      Paint()..color = const Color(0xFF0A1A0A),
    );

    // Front face — gradient top→bottom (dark green → near black)
    canvas.drawPath(
      _quad(proj.bl, proj.br, brB, blB),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0xFF1E5A1E), Color(0xFF060C06)],
        ).createShader(
            Rect.fromLTWH(0, proj.bl.dy, w, slabH)),
    );

    // Subtle edge highlight on near top border
    canvas.drawLine(
      proj.bl, proj.br,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.12)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );
  }

  Path _quad(Offset a, Offset b, Offset c, Offset d) => Path()
    ..moveTo(a.dx, a.dy)
    ..lineTo(b.dx, b.dy)
    ..lineTo(c.dx, c.dy)
    ..lineTo(d.dx, d.dy)
    ..close();

  // ── 3. Field surface (base + grass stripes + lighting) ─────────────────────

  void _drawSurface(Canvas canvas, FieldProjector proj, Size size) {
    final fieldPath = _fieldOutline(proj);

    // Base fill
    canvas.drawPath(fieldPath, Paint()..color = bgColor);

    // Alternating grass stripes
    final stripe = Paint()..color = Colors.white.withValues(alpha: 0.022);
    for (int i = 0; i < 9; i += 2) {
      canvas.drawPath(_band(proj, i / 9, (i + 1) / 9), stripe);
    }

    // Directional lighting: dark at far/top → brighter at near/bottom
    final h = proj.bl.dy - proj.tl.dy;
    canvas.drawPath(
      fieldPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.32),
            Colors.transparent,
            Colors.white.withValues(alpha: 0.05),
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromLTWH(0, proj.tl.dy, size.width, h)),
    );

    // Lateral vignette (edges darker)
    canvas.save();
    canvas.clipPath(fieldPath);
    canvas.drawRect(
      Rect.fromLTWH(0, proj.tl.dy, size.width * 0.14, h),
      Paint()
        ..shader = LinearGradient(
          colors: [Colors.black.withValues(alpha: 0.18), Colors.transparent],
        ).createShader(Rect.fromLTWH(0, 0, size.width * 0.14, h)),
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.86, proj.tl.dy, size.width * 0.14, h),
      Paint()
        ..shader = LinearGradient(
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.18)],
        ).createShader(
            Rect.fromLTWH(size.width * 0.86, 0, size.width * 0.14, h)),
    );
    canvas.restore();
  }

  Path _fieldOutline(FieldProjector p) => Path()
    ..moveTo(p.tl.dx, p.tl.dy)
    ..lineTo(p.tr.dx, p.tr.dy)
    ..lineTo(p.br.dx, p.br.dy)
    ..lineTo(p.bl.dx, p.bl.dy)
    ..close();

  Path _band(FieldProjector proj, double v0, double v1) => Path()
    ..moveTo(proj(0, v0).dx, proj(0, v0).dy)
    ..lineTo(proj(1, v0).dx, proj(1, v0).dy)
    ..lineTo(proj(1, v1).dx, proj(1, v1).dy)
    ..lineTo(proj(0, v1).dx, proj(0, v1).dy)
    ..close();

  // ── 4. Field markings (regulation proportions) ─────────────────────────────

  void _drawMarkings(Canvas canvas, FieldProjector proj) {
    final ln = Paint()
      ..color = lineColor
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Glow pass (same lines, wider + more transparent)
    final glow = Paint()
      ..color = lineColor.withValues(alpha: 0.18)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final dot = Paint()..color = lineColor..style = PaintingStyle.fill;

    void line(List<Offset> pts) {
      _poly(canvas, pts, glow);
      _poly(canvas, pts, ln);
    }

    // Outer border
    line([proj(0,0), proj(1,0), proj(1,1), proj(0,1), proj(0,0)]);
    // Halfway
    line([proj(0, 0.5), proj(1, 0.5)]);

    // Center circle  (r = 9.15m → u:0.135, v:0.087)
    _ellipse(canvas, proj, 0.5, 0.5, 0.135, 0.087, glow);
    _ellipse(canvas, proj, 0.5, 0.5, 0.135, 0.087, ln);
    canvas.drawCircle(proj(0.5, 0.5), 2.5, dot);

    // Penalty areas  (40.32m → u[0.204,0.796]  |  16.5m → v 0.157)
    line([proj(.204,0), proj(.204,.157), proj(.796,.157), proj(.796,0)]);
    line([proj(.204,1), proj(.204,.843), proj(.796,.843), proj(.796,1)]);

    // Goal areas  (18.32m → u[0.365,0.635]  |  5.5m → v 0.052)
    line([proj(.365,0), proj(.365,.052), proj(.635,.052), proj(.635,0)]);
    line([proj(.365,1), proj(.365,.948), proj(.635,.948), proj(.635,1)]);

    // Penalty spots
    canvas.drawCircle(proj(0.5, 0.105), 2.5, dot);
    canvas.drawCircle(proj(0.5, 0.895), 2.5, dot);

    // Penalty arcs (clipped outside box)
    _clippedArc(canvas, proj, 0.5, 0.105, 0.135, 0.087, glow, clipV: 0.157, below: true);
    _clippedArc(canvas, proj, 0.5, 0.105, 0.135, 0.087, ln,   clipV: 0.157, below: true);
    _clippedArc(canvas, proj, 0.5, 0.895, 0.135, 0.087, glow, clipV: 0.843, below: false);
    _clippedArc(canvas, proj, 0.5, 0.895, 0.135, 0.087, ln,   clipV: 0.843, below: false);

    // Corner arcs  (r=1m → u:0.015, v:0.010)
    _corner(canvas, proj, 0, 0, glow); _corner(canvas, proj, 0, 0, ln);
    _corner(canvas, proj, 1, 0, glow); _corner(canvas, proj, 1, 0, ln);
    _corner(canvas, proj, 0, 1, glow); _corner(canvas, proj, 0, 1, ln);
    _corner(canvas, proj, 1, 1, glow); _corner(canvas, proj, 1, 1, ln);
  }

  // ── Primitives ────────────────────────────────────────────────────────────

  void _poly(Canvas canvas, List<Offset> pts, Paint paint) {
    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  void _ellipse(Canvas canvas, FieldProjector proj,
      double cu, double cv, double ru, double rv, Paint paint,
      {int n = 52}) {
    final path = Path();
    for (int i = 0; i <= n; i++) {
      final a = i * 2 * math.pi / n;
      final pt = proj(cu + ru * math.cos(a), cv + rv * math.sin(a));
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _clippedArc(Canvas canvas, FieldProjector proj,
      double cu, double cv, double ru, double rv, Paint paint,
      {required double clipV, required bool below}) {
    canvas.save();
    final clipY = proj(0.5, clipV).dy;
    canvas.clipRect(below
        ? Rect.fromLTWH(-9999, clipY - 1, 99999, 99999)
        : Rect.fromLTWH(-9999, -9999, 99999, clipY + 1));
    _ellipse(canvas, proj, cu, cv, ru, rv, paint);
    canvas.restore();
  }

  void _corner(Canvas canvas, FieldProjector proj,
      double cu, double cv, Paint paint, {int n = 10}) {
    const ru = 0.015;
    const rv = 0.010;
    final path = Path();
    for (int i = 0; i <= n; i++) {
      final a = (math.pi / 2) * i / n;
      final du = (cu == 0 ? 1 : -1) * ru * math.cos(a);
      final dv = (cv == 0 ? 1 : -1) * rv * math.sin(a);
      final pt = proj((cu + du).clamp(0.0, 1.0), (cv + dv).clamp(0.0, 1.0));
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant FieldPainter old) => false;
}
