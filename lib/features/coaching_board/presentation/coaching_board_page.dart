import 'package:flutter/material.dart';
import 'package:playvision/core/theme/app_color_tokens.dart';

import 'coaching_board_controller.dart';
import '../domain/player_token.dart';
import 'widgets/field_painter.dart';
import 'widgets/player_chip.dart';
import 'widgets/player_stats_sheet.dart';

class CoachingBoardPage extends StatefulWidget {
  const CoachingBoardPage({super.key});

  @override
  State<CoachingBoardPage> createState() => _CoachingBoardPageState();
}

class _CoachingBoardPageState extends State<CoachingBoardPage> {
  final _controller = CoachingBoardController();
  static const _formations = ['4-3-3', '4-4-2', '3-5-2', '4-2-3-1'];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: const Color(0xFF080C08),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            final selected = _controller.selectedPlayer;
            return Column(children: [
              // ── AppBar ──────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(children: [
                  const Icon(Icons.space_dashboard_rounded, color: Color(0xFF3DCF6E), size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text('Coaching Board',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                  ),
                  GestureDetector(
                    onTap: _controller.resetFormation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: c.accentLo,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: c.borderGreen),
                      ),
                      child: Text('Reset', style: TextStyle(color: c.accent, fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ]),
              ),

              // ── Formation chips ─────────────────────────────────────────────
              SizedBox(
                height: 38,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  children: _formations.map((f) {
                    final active = f == _controller.formation;
                    return GestureDetector(
                      onTap: () => _controller.applyFormation(f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: active ? c.accent : c.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: active ? c.accent : c.border2,
                          ),
                        ),
                        child: Text(f,
                            style: TextStyle(
                              color: active ? Colors.black : c.muted,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            )),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 10),

              // ── Field ───────────────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LayoutBuilder(builder: (context, constraints) {
                      final fw = constraints.maxWidth;
                      final fh = constraints.maxHeight;

                      return Stack(children: [
                        // Painted field
                        SizedBox.expand(
                          child: CustomPaint(
                            painter: FieldPainter(
                              bgColor: const Color(0xFF0B1A0B),
                              lineColor: Colors.white.withValues(alpha: 0.55),
                            ),
                          ),
                        ),

                        // Attack direction arrow
                        Positioned(
                          top: 10, right: 10,
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.arrow_upward_rounded, color: Colors.white24, size: 12),
                            const SizedBox(width: 4),
                            Text('Attack', style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 10)),
                          ]),
                        ),

                        // Players
                        ..._controller.players.map((player) {
                          final px = player.dx * fw;
                          final py = player.dy * fh;
                          final isSelected = player.id == selected?.id;

                          return Positioned(
                            left: px - PlayerChip.size / 2,
                            top:  py - PlayerChip.size / 2 - 12, // offset up to make room for label
                            child: Column(mainAxisSize: MainAxisSize.min, children: [
                              PlayerChip(
                                player: player,
                                isSelected: isSelected,
                                onTap: () {
                                  _controller.selectPlayer(player);
                                  if (!isSelected) {
                                    PlayerStatsSheet.show(context, player);
                                  }
                                },
                                onDrag: (ddx, ddy) => _controller.movePlayer(
                                  player.id,
                                  (player.dx + ddx / fw).clamp(0.03, 0.97),
                                  (player.dy + ddy / fh).clamp(0.03, 0.97),
                                ),
                              ),
                              const SizedBox(height: 3),
                              PlayerLabel(player: player, isSelected: isSelected),
                            ]),
                          );
                        }),
                      ]);
                    }),
                  ),
                ),
              ),

              // ── Selected player footer bar ──────────────────────────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: selected != null ? 64 : 0,
                child: selected != null
                    ? _PlayerFooter(
                        player: selected,
                        onTap: () => PlayerStatsSheet.show(context, selected),
                        c: c,
                      )
                    : null,
              ),

              const SizedBox(height: 12),
            ]);
          },
        ),
      ),
    );
  }
}

// ── Footer strip when player is selected ──────────────────────────────────────

class _PlayerFooter extends StatelessWidget {
  final PlayerToken player;
  final VoidCallback onTap;
  final AppColorTokens c;

  const _PlayerFooter({required this.player, required this.onTap, required this.c});

  @override
  Widget build(BuildContext context) {
    final rating = (player.stats['rating'] as num).toDouble();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: c.borderGreen),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: c.accentLo, borderRadius: BorderRadius.circular(8)),
            child: Text(player.position,
                style: TextStyle(color: c.accent, fontSize: 11, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(player.name, style: TextStyle(color: c.textHi, fontSize: 14, fontWeight: FontWeight.w700)),
              Text('#${player.number} · ${player.stats['minutes']} min',
                  style: TextStyle(color: c.muted, fontSize: 11)),
            ]),
          ),
          Text(rating.toStringAsFixed(1),
              style: TextStyle(color: c.accent, fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(width: 4),
          Icon(Icons.star_rounded, color: c.accent, size: 16),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded, color: c.muted, size: 20),
        ]),
      ),
    );
  }
}
