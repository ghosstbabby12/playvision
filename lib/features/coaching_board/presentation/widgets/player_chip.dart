import 'package:flutter/material.dart';
import '../../domain/player_token.dart';

class PlayerChip extends StatelessWidget {
  final PlayerToken player;
  final bool isSelected;
  final bool isSwapSource;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final void Function(double dx, double dy) onDrag;

  static const double chipW = 44;
  static const double chipH = 50;
  static const double size  = chipW;

  const PlayerChip({
    super.key,
    required this.player,
    required this.isSelected,
    required this.onTap,
    required this.onDrag,
    this.isSwapSource = false,
    this.onLongPress,
  });

  static Color positionColor(String pos) {
    if (pos == 'GK') return const Color(0xFFF59E0B);
    if ({'CB', 'RB', 'LB', 'WB', 'RWB', 'LWB'}.contains(pos)) return const Color(0xFF3B82F6);
    if ({'ST', 'CF', 'RW', 'LW', 'SS'}.contains(pos)) return const Color(0xFF3DCF6E);
    return const Color(0xFF8B5CF6); // all midfielders
  }

  @override
  Widget build(BuildContext context) {
    final color = positionColor(player.position);
    final borderColor = isSwapSource
        ? const Color(0xFFF59E0B)
        : isSelected
            ? Colors.white
            : color.withValues(alpha: 0.5);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      onPanUpdate: (d) => onDrag(d.delta.dx, d.delta.dy),
      child: SizedBox(
        width: chipW,
        height: chipH,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            CustomPaint(
              size: const Size(chipW, chipH),
              painter: _JerseyPainter(
                fillColor: color,
                borderColor: borderColor,
                glowColor: isSwapSource ? const Color(0xFFF59E0B) : color,
                isHighlighted: isSelected || isSwapSource,
              ),
            ),
            Positioned(
              top: chipH * 0.56,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  '${player.number}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JerseyPainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;
  final Color glowColor;
  final bool isHighlighted;

  const _JerseyPainter({
    required this.fillColor,
    required this.borderColor,
    required this.glowColor,
    this.isHighlighted = false,
  });

  Path _buildPath(double w, double h) {
    final p = Path();
    p.moveTo(w * 0.34, 0);          // left neck edge
    p.lineTo(w * 0.50, h * 0.19);  // V-neck tip
    p.lineTo(w * 0.66, 0);          // right neck edge
    p.lineTo(w * 0.96, h * 0.09);  // right shoulder
    p.lineTo(w,        h * 0.15);  // right sleeve top outer
    p.lineTo(w,        h * 0.43);  // right sleeve bottom outer
    p.lineTo(w * 0.78, h * 0.43);  // right underarm
    p.lineTo(w * 0.86, h);          // right hem
    p.lineTo(w * 0.14, h);          // left hem
    p.lineTo(w * 0.22, h * 0.43);  // left underarm
    p.lineTo(0,        h * 0.43);  // left sleeve bottom outer
    p.lineTo(0,        h * 0.15);  // left sleeve top outer
    p.lineTo(w * 0.04, h * 0.09);  // left shoulder
    p.close();
    return p;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = _buildPath(w, h);

    // Glow when selected or swap source
    if (isHighlighted) {
      canvas.drawPath(path, Paint()
        ..color = glowColor.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9)
        ..style = PaintingStyle.fill);
    }

    // Gradient fill (top lighter → bottom darker for depth)
    final shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        fillColor.withValues(alpha: 0.98),
        fillColor.withValues(alpha: 0.72),
      ],
    ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(path, Paint()..shader = shader..style = PaintingStyle.fill);

    // Subtle center stripe (decorative)
    canvas.save();
    canvas.clipPath(path);
    canvas.drawRect(
      Rect.fromLTWH(w * 0.43, h * 0.21, w * 0.14, h * 0.72),
      Paint()..color = Colors.white.withValues(alpha: 0.09)..style = PaintingStyle.fill,
    );
    canvas.restore();

    // Border
    canvas.drawPath(path, Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = isHighlighted ? 2.0 : 1.2
      ..strokeJoin = StrokeJoin.round);
  }

  @override
  bool shouldRepaint(covariant _JerseyPainter old) =>
      old.fillColor != fillColor ||
      old.borderColor != borderColor ||
      old.isHighlighted != isHighlighted;
}

class PlayerLabel extends StatelessWidget {
  final PlayerToken player;
  final bool isSelected;

  const PlayerLabel({super.key, required this.player, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.white.withValues(alpha: 0.9)
            : Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        player.name.split(' ').last,
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
