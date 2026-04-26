import 'package:flutter/material.dart';
import '../../domain/player_token.dart';

class PlayerChip extends StatelessWidget {
  final PlayerToken player;
  final bool isSelected;
  final VoidCallback onTap;
  final void Function(double dx, double dy) onDrag;

  static const double size = 44;

  const PlayerChip({
    super.key,
    required this.player,
    required this.isSelected,
    required this.onTap,
    required this.onDrag,
  });

  Color _positionColor(String pos) {
    if (pos == 'GK') return const Color(0xFFF59E0B);
    if (pos.contains('B') && !pos.contains('A')) return const Color(0xFF3B82F6);
    if (pos.contains('M') || pos.contains('D')) return const Color(0xFF8B5CF6);
    return const Color(0xFF3DCF6E);
  }

  @override
  Widget build(BuildContext context) {
    final color = _positionColor(player.position);

    return GestureDetector(
      onTap: onTap,
      onPanUpdate: (d) => onDrag(d.delta.dx, d.delta.dy),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [
            color.withValues(alpha: 0.9),
            color.withValues(alpha: 0.6),
          ]),
          border: Border.all(
            color: isSelected ? Colors.white : color.withValues(alpha: 0.4),
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: isSelected ? 0.7 : 0.3),
              blurRadius: isSelected ? 16 : 6,
              spreadRadius: isSelected ? 2 : 0,
            ),
          ],
        ),
        child: Center(
          child: Text(
            '${player.number}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

// Small floating label shown below a player chip
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
        player.name.split(' ').last, // last name only
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
