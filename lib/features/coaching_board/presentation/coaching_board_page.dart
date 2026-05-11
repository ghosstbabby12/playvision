import 'package:flutter/material.dart';
import 'package:playvision/core/theme/app_color_tokens.dart';
import 'package:playvision/shared/widgets/pv_back_button.dart';

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
  final _ctrl = CoachingBoardController();

  @override
  void initState() {
    super.initState();
    _ctrl.loadTeams();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _ctrl,
      builder: (context, _) {
        if (_ctrl.savedMessage != null) {
          final msg = _ctrl.savedMessage!;
          _ctrl.consumeSavedMessage();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            final c = context.colors;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  msg,
                  style: TextStyle(color: c.text),
                ),
                backgroundColor: c.elevated,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: c.border2),
                ),
              ),
            );
          });
        }

        return switch (_ctrl.step) {
          BoardStep.selectTeam => _TeamSelectorStep(ctrl: _ctrl),
          BoardStep.analyzing => _AnalyzingStep(ctrl: _ctrl),
          BoardStep.board => _BoardStep(ctrl: _ctrl),
        };
      },
    );
  }
}

// ── Step 1: Team selector ──────────────────────────────────────────────────────

class _TeamSelectorStep extends StatelessWidget {
  final CoachingBoardController ctrl;
  const _TeamSelectorStep({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const PvBackButton(),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.space_dashboard_rounded,
                    color: Color(0xFF39D353),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Coaching Board',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Title + subtitle
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selecciona un equipo',
                    style: TextStyle(
                      color: c.textHi,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Elige un equipo para construir el tablero táctico',
                    style: TextStyle(color: c.muted, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Teams list
            Expanded(
              child: ctrl.loadingTeams
                  ? Center(
                      child: CircularProgressIndicator(
                        color: c.accent,
                        strokeWidth: 1.5,
                      ),
                    )
                  : ctrl.teams.isEmpty
                      ? _EmptyTeams(c: c)
                      : ListView.separated(
                          padding:
                              const EdgeInsets.fromLTRB(20, 8, 20, 32),
                          itemCount: ctrl.teams.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) => _TeamCard(
                            team: ctrl.teams[i],
                            c: c,
                            onTap: () =>
                                ctrl.selectTeamAndAnalyze(ctrl.teams[i]),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  final Map<String, dynamic> team;
  final AppColorTokens c;
  final VoidCallback onTap;
  const _TeamCard({
    required this.team,
    required this.c,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final logo = team['logo_url'] as String?;
    final name = team['name'] as String? ?? 'Team';
    final club = team['club'] as String? ?? '';
    final cat = team['category'] as String? ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.border),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.accentLo,
                border: Border.all(color: c.borderGreen, width: 1.5),
                image: logo != null && logo.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(logo),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: logo == null || logo.isEmpty
                  ? Center(
                      child: Text(
                        initial,
                        style: TextStyle(
                          color: c.accent,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: c.textHi,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (club.isNotEmpty || cat.isNotEmpty)
                    Text(
                      '$club${club.isNotEmpty && cat.isNotEmpty ? ' · ' : ''}$cat',
                      style: TextStyle(color: c.muted, fontSize: 12),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: c.accentLo,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: c.accent,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyTeams extends StatelessWidget {
  final AppColorTokens c;
  const _EmptyTeams({required this.c});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.groups_outlined, color: c.dim, size: 48),
          const SizedBox(height: 16),
          Text(
            'Sin equipos',
            style: TextStyle(
              color: c.text,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Crea un equipo en la pestaña Inicio',
            style: TextStyle(color: c.muted, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ── Step 2: Analyzing ──────────────────────────────────────────────────────────

class _AnalyzingStep extends StatelessWidget {
  final CoachingBoardController ctrl;
  const _AnalyzingStep({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final name = ctrl.selectedTeam?['name'] as String? ?? 'Team';

    return Scaffold(
      backgroundColor: const Color(0xFF080C08),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PulsingBall(color: c.accent),
              const SizedBox(height: 32),
              Text(
                'Analizando $name',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Construyendo el tablero táctico con IA',
                style: TextStyle(color: c.muted, fontSize: 13),
              ),
              const SizedBox(height: 36),
              ...List.generate(
                CoachingBoardController.analysisSteps.length,
                (i) {
                  final done = i < ctrl.completedSteps;
                  final current = i == ctrl.completedSteps;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: done
                              ? Icon(
                                  Icons.check_circle_rounded,
                                  color: c.accent,
                                  size: 20,
                                  key: const ValueKey('done'),
                                )
                              : current
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: c.accent,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Icon(
                                      Icons.radio_button_unchecked,
                                      color: c.dim,
                                      size: 20,
                                      key: ValueKey(i),
                                    ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          CoachingBoardController.analysisSteps[i],
                          style: TextStyle(
                            color: done
                                ? c.textHi
                                : current
                                    ? c.text
                                    : c.dim,
                            fontSize: 14,
                            fontWeight: done || current
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulsingBall extends StatefulWidget {
  final Color color;
  const _PulsingBall({required this.color});

  @override
  State<_PulsingBall> createState() => _PulsingBallState();
}

class _PulsingBallState extends State<_PulsingBall>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Transform.scale(
        scale: 0.85 + _anim.value * 0.2,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(alpha: 0.15),
            boxShadow: [
              BoxShadow(
                color:
                    widget.color.withValues(alpha: 0.3 + _anim.value * 0.3),
                blurRadius: 24 + _anim.value * 12,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Icon(
            Icons.sports_soccer,
            color: widget.color,
            size: 40,
          ),
        ),
      ),
    );
  }
}

// ── Step 3: Interactive isometric board ───────────────────────────────────────

class _BoardStep extends StatelessWidget {
  final CoachingBoardController ctrl;
  const _BoardStep({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final selected = ctrl.selectedPlayer;
    final swapSource = ctrl.swapSource;
    final team = ctrl.selectedTeam;

    return Scaffold(
      backgroundColor: const Color(0xFF080C08),
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Row(
                children: [
                  PvBackButton(onTap: ctrl.goBack),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          team?['name'] as String? ?? 'Tactical Board',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          ctrl.formation,
                          style: TextStyle(
                            color: c.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Save button
                  GestureDetector(
                    onTap: ctrl.isSaving ? null : ctrl.saveFormation,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: c.accentLo,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: c.borderGreen),
                      ),
                      child: ctrl.isSaving
                          ? SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                color: c.accent,
                                strokeWidth: 1.5,
                              ),
                            )
                          : Text(
                              'Guardar',
                              style: TextStyle(
                                color: c.accent,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  GestureDetector(
                    onTap: ctrl.resetFormation,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: c.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: c.border),
                      ),
                      child: Text(
                        'Reset',
                        style: TextStyle(
                          color: c.dim,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Formation pills
            SizedBox(
              height: 34,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children:
                    CoachingBoardController.availableFormations.map((f) {
                  final active = f == ctrl.formation;
                  return GestureDetector(
                    onTap: () => ctrl.switchFormation(f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: active ? c.accentLo : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: active
                              ? c.borderGreen
                              : c.border.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        f,
                        style: TextStyle(
                          color: active ? c.accent : c.dim,
                          fontSize: 11,
                          fontWeight:
                              active ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 6),

            // Legend
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _LegendDot(
                    color: Color(0xFFF59E0B),
                    label: 'GK',
                  ),
                  const SizedBox(width: 14),
                  const _LegendDot(
                    color: Color(0xFF3B82F6),
                    label: 'DEF',
                  ),
                  const SizedBox(width: 14),
                  const _LegendDot(
                    color: Color(0xFF8B5CF6),
                    label: 'MID',
                  ),
                  const SizedBox(width: 14),
                  const _LegendDot(
                    color: Color(0xFF39D353),
                    label: 'ATK',
                  ),
                  const Spacer(),
                  Icon(
                    Icons.swap_vert_rounded,
                    color: c.dim,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Long press = swap',
                    style: TextStyle(color: c.dim, fontSize: 9),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Isometric field
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final fw = constraints.maxWidth;
                    final fh = constraints.maxHeight;
                    final proj = FieldProjector(fw, fh);

                    return Stack(
                      children: [
                        // Field surface
                        SizedBox.expand(
                          child: CustomPaint(
                            painter: FieldPainter(
                              bgColor: const Color(0xFF071407),
                              lineColor: Colors.white.withValues(
                                alpha: 0.50,
                              ),
                            ),
                          ),
                        ),

                        // Formation connection lines
                        SizedBox.expand(
                          child: CustomPaint(
                            painter:
                                _IsometricLinesPainter(ctrl.players, proj),
                          ),
                        ),

                        // Zone labels on left edge
                        ..._zoneLabels(proj),

                        // Swap banner
                        if (swapSource != null)
                          Positioned(
                            top: 8,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B)
                                      .withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black38,
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.swap_horiz_rounded,
                                      color: Colors.black,
                                      size: 13,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      'Toca otro jugador para intercambiar',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        // Player tokens
                        ..._buildTokens(
                          context,
                          ctrl.players,
                          selected,
                          swapSource,
                          proj,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            // Selected player footer
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: selected != null ? 72 : 0,
              child: selected != null
                  ? _PlayerFooter(
                      player: selected,
                      c: c,
                      onTap: () => PlayerStatsSheet.show(
                        context,
                        selected,
                        allPlayers: ctrl.players,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // Zone labels
  List<Widget> _zoneLabels(FieldProjector proj) {
    return [
      ('ATK', 0.13),
      ('MID', 0.43),
      ('DEF', 0.67),
      ('GK', 0.86),
    ].map(((String, double) z) {
      final pos = proj(0.02, z.$2);
      return Positioned(
        left: pos.dx,
        top: pos.dy - 5,
        child: _ZoneLabel(z.$1),
      );
    }).toList();
  }

  // Player tokens with isometric drag
  List<Widget> _buildTokens(
    BuildContext context,
    List<PlayerToken> players,
    PlayerToken? selected,
    PlayerToken? swapSource,
    FieldProjector proj,
  ) {
    return players.map((player) {
      final screenPos = proj(player.dx, player.dy);
      final isSelected = player.id == selected?.id;
      final isSwapSrc = player.id == swapSource?.id;

      return Positioned(
        left: screenPos.dx - PlayerChip.chipW / 2,
        top: screenPos.dy - PlayerChip.chipH / 2,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PlayerChip(
              player: player,
              isSelected: isSelected,
              isSwapSource: isSwapSrc,
              onTap: () {
                if (swapSource != null) {
                  ctrl.finishSwap(player);
                } else {
                  ctrl.selectPlayer(player);
                  if (!isSelected) {
                    PlayerStatsSheet.show(
                      context,
                      player,
                      allPlayers: ctrl.players,
                    );
                  }
                }
              },
              onLongPress: () => ctrl.startSwap(player),
              // Perspective-aware drag
              onDrag: (ddx, ddy) => ctrl.movePlayer(
                player.id,
                (player.dx + ddx / proj.rowWidth(player.dy))
                    .clamp(0.03, 0.97),
                (player.dy + ddy / proj.colHeight).clamp(0.03, 0.97),
              ),
            ),
            const SizedBox(height: 2),
            PlayerLabel(
              player: player,
              isSelected: isSelected || isSwapSrc,
            ),
          ],
        ),
      );
    }).toList();
  }
}

// ── Isometric formation lines painter ─────────────────────────────────────────

class _IsometricLinesPainter extends CustomPainter {
  final List<PlayerToken> players;
  final FieldProjector proj;
  const _IsometricLinesPainter(this.players, this.proj);

  static String _group(String pos) {
    if (pos == 'GK') return 'GK';
    if ({'CB', 'RB', 'LB', 'WB', 'RWB', 'LWB'}.contains(pos)) return 'DEF';
    if ({'ST', 'CF', 'RW', 'LW', 'SS'}.contains(pos)) return 'FWD';
    return 'MID';
  }

  static Color _color(String group) => switch (group) {
        'GK' => const Color(0xFFF59E0B),
        'DEF' => const Color(0xFF3B82F6),
        'MID' => const Color(0xFF8B5CF6),
        _ => const Color(0xFF39D353),
      };

  @override
  void paint(Canvas canvas, Size size) {
    final groups = <String, List<PlayerToken>>{};
    for (final p in players) {
      groups.putIfAbsent(_group(p.position), () => []).add(p);
    }

    for (final entry in groups.entries) {
      if (entry.value.length < 2) continue;
      final sorted = [...entry.value]
        ..sort((a, b) => a.dx.compareTo(b.dx));
      final paint = Paint()
        ..color = _color(entry.key).withValues(alpha: 0.30)
        ..strokeWidth = 1.6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i < sorted.length - 1; i++) {
        canvas.drawLine(
          proj(sorted[i].dx, sorted[i].dy),
          proj(sorted[i + 1].dx, sorted[i + 1].dy),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _IsometricLinesPainter old) =>
      old.players != players;
}

// ── Small widgets ──────────────────────────────────────────────────────────────

class _ZoneLabel extends StatelessWidget {
  final String label;
  const _ZoneLabel(this.label);

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.18),
          fontSize: 8,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
        ),
      );
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.45),
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}

class _PlayerFooter extends StatelessWidget {
  final PlayerToken player;
  final AppColorTokens c;
  final VoidCallback onTap;
  const _PlayerFooter({
    required this.player,
    required this.c,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final rating =
        (player.stats['rating'] as num?)?.toDouble() ?? 7.0;
    final goals = (player.stats['goals'] as num?)?.toInt() ?? 0;
    final assists = (player.stats['assists'] as num?)?.toInt() ?? 0;
    final minutes = (player.stats['minutes'] as num?)?.toInt() ?? 90;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 0),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: c.borderGreen),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              height: 32,
              child: CustomPaint(
                painter: _MiniJerseyPainter(
                  color: PlayerChip.positionColor(player.position),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    player.name,
                    style: TextStyle(
                      color: c.textHi,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: c.accentLo,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          player.position,
                          style: TextStyle(
                            color: c.accent,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '#${player.number} · ${minutes}min',
                        style: TextStyle(color: c.muted, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _FooterStat(label: 'G', value: '$goals', c: c),
            const SizedBox(width: 10),
            _FooterStat(label: 'A', value: '$assists', c: c),
            const SizedBox(width: 12),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  rating.toStringAsFixed(1),
                  style: TextStyle(
                    color: c.accent,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded,
                        color: c.accent, size: 10),
                    Text(
                      ' rating',
                      style: TextStyle(color: c.dim, fontSize: 8),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: c.muted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterStat extends StatelessWidget {
  final String label, value;
  final AppColorTokens c;
  const _FooterStat({
    required this.label,
    required this.value,
    required this.c,
  });

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: c.textHi,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: c.dim, fontSize: 9),
          ),
        ],
      );
}

class _MiniJerseyPainter extends CustomPainter {
  final Color color;
  const _MiniJerseyPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final p = Path()
      ..moveTo(w * 0.34, 0)
      ..lineTo(w * 0.50, h * 0.19)
      ..lineTo(w * 0.66, 0)
      ..lineTo(w * 0.96, h * 0.09)
      ..lineTo(w, h * 0.15)
      ..lineTo(w, h * 0.43)
      ..lineTo(w * 0.78, h * 0.43)
      ..lineTo(w * 0.86, h)
      ..lineTo(w * 0.14, h)
      ..lineTo(w * 0.22, h * 0.43)
      ..lineTo(0, h * 0.43)
      ..lineTo(0, h * 0.15)
      ..lineTo(w * 0.04, h * 0.09)
      ..close();

    canvas.drawPath(
      p,
      Paint()
        ..color = color.withValues(alpha: 0.85)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      p,
      Paint()
        ..color = color.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _MiniJerseyPainter old) =>
      old.color != color;
}