import 'dart:ui';
import 'package:flutter/material.dart';
import '../../domain/player_token.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PlayerChip — premium tactical card with photo, rating ring & drag animation
// ─────────────────────────────────────────────────────────────────────────────

class PlayerChip extends StatefulWidget {
  final PlayerToken player;
  final bool isSelected;
  final bool isSwapSource;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final void Function(double dx, double dy) onDrag;

  static const double chipW = 54;
  static const double chipH = 74;
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
    if ({'CB', 'RB', 'LB', 'WB', 'RWB', 'LWB'}.contains(pos)) {
      return const Color(0xFF3B82F6);
    }
    if ({'ST', 'CF', 'RW', 'LW', 'SS'}.contains(pos)) {
      return const Color(0xFF22C55E);
    }
    return const Color(0xFF8B5CF6);
  }

  static Color performanceColor(double rating) {
    if (rating >= 8.0) return const Color(0xFF22C55E);
    if (rating >= 7.0) return const Color(0xFFF59E0B);
    if (rating >= 6.0) return const Color(0xFFFB923C);
    return const Color(0xFFEF4444);
  }

  @override
  State<PlayerChip> createState() => _PlayerChipState();
}

class _PlayerChipState extends State<PlayerChip>
    with SingleTickerProviderStateMixin {
  bool _dragging = false;
  late final AnimationController _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.isSelected) _glowAnim.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(PlayerChip old) {
    super.didUpdateWidget(old);
    if (widget.isSelected && !old.isSelected) {
      _glowAnim.repeat(reverse: true);
    } else if (!widget.isSelected && old.isSelected) {
      _glowAnim.stop();
      _glowAnim.reset();
    }
  }

  @override
  void dispose() {
    _glowAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player    = widget.player;
    final pos       = player.position;
    final number    = player.number;
    final rating    = (player.stats['rating'] as num?)?.toDouble() ?? 0.0;
    final posColor  = PlayerChip.positionColor(pos);
    final perfColor = PlayerChip.performanceColor(rating);
    final isActive  = widget.isSelected || widget.isSwapSource;
    final glowColor = widget.isSwapSource ? const Color(0xFFF59E0B) : posColor;
    final hasPhoto  = player.photoUrl != null && player.photoUrl!.isNotEmpty;
    final hasRating = rating > 0;

    // Short name: last word, max 8 chars, uppercase
    final parts     = player.name.trim().split(' ');
    final lastName  = parts.length > 1 ? parts.last : parts.first;
    final shortName = lastName.substring(0, lastName.length.clamp(0, 8)).toUpperCase();

    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onPanStart: (_) => setState(() => _dragging = true),
      onPanUpdate: (d) => widget.onDrag(d.delta.dx, d.delta.dy),
      onPanEnd: (_) => setState(() => _dragging = false),
      onPanCancel: () => setState(() => _dragging = false),
      child: AnimatedBuilder(
        animation: _glowAnim,
        builder: (_, child) {
          final glowPulse = widget.isSelected ? (0.45 + _glowAnim.value * 0.25) : 0.45;
          return AnimatedScale(
            scale: _dragging ? 1.20 : (isActive ? 1.07 : 1.0),
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: PlayerChip.chipW,
              height: PlayerChip.chipH,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: const Color(0xD0060C06),
                border: Border.all(
                  color: widget.isSwapSource
                      ? const Color(0xFFF59E0B)
                      : isActive
                          ? Colors.white
                          : posColor.withValues(alpha: 0.50),
                  width: isActive ? 2.0 : 1.2,
                ),
                boxShadow: [
                  if (isActive || _dragging)
                    BoxShadow(
                      color: glowColor.withValues(alpha: glowPulse),
                      blurRadius: _dragging ? 24 : 18,
                      spreadRadius: _dragging ? 3 : 1,
                    ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.55),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Column(
              children: [
                // ── Header strip: position + rating ──────────────────────
                Container(
                  height: 19,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        posColor.withValues(alpha: 0.45),
                        posColor.withValues(alpha: 0.18),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Row(
                    children: [
                      // Position pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: posColor.withValues(alpha: 0.28),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: posColor.withValues(alpha: 0.55),
                              width: 0.8),
                        ),
                        child: Text(
                          pos,
                          style: TextStyle(
                            color: posColor,
                            fontSize: 6.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                            height: 1,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Rating / AI badge
                      if (hasRating)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: perfColor.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            rating.toStringAsFixed(1),
                            style: TextStyle(
                              color: perfColor,
                              fontSize: 7,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // ── Avatar: photo or dorsal with performance ring ─────────
                Expanded(
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer glow ring (performance)
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (hasRating ? perfColor : posColor)
                                    .withValues(alpha: 0.50),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        // Photo circle with status ring
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: posColor.withValues(alpha: 0.18),
                            border: Border.all(
                              color: hasRating ? perfColor : posColor,
                              width: 2.5,
                            ),
                            image: hasPhoto
                                ? DecorationImage(
                                    image: NetworkImage(player.photoUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: hasPhoto
                              ? null
                              : Center(
                                  child: Text(
                                    '#$number',
                                    style: TextStyle(
                                      color: posColor,
                                      fontSize: number > 9 ? 11 : 13,
                                      fontWeight: FontWeight.w900,
                                      height: 1,
                                    ),
                                  ),
                                ),
                        ),
                        // Status dot — bottom right of avatar
                        Positioned(
                          right: 5,
                          bottom: 2,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  hasRating ? perfColor : posColor,
                              border: Border.all(
                                  color: const Color(0xFF060C06), width: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Name footer ───────────────────────────────────────────
                Container(
                  height: 17,
                  color: Colors.black.withValues(alpha: 0.50),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Text(
                    shortName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 7.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      height: 1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

// ─────────────────────────────────────────────────────────────────────────────
// PlayerLabel — kept for API compat, now a no-op (name is in the chip footer)
// ─────────────────────────────────────────────────────────────────────────────

class PlayerLabel extends StatelessWidget {
  final PlayerToken player;
  final bool isSelected;
  const PlayerLabel({super.key, required this.player, required this.isSelected});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
