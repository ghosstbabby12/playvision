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
      builder: (context, _) => switch (_ctrl.step) {
        BoardStep.selectTeam => _TeamSelectorStep(ctrl: _ctrl),
        BoardStep.analyzing  => _AnalyzingStep(ctrl: _ctrl),
        BoardStep.board      => _BoardStep(ctrl: _ctrl),
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(children: [
              const Icon(Icons.space_dashboard_rounded, color: Color(0xFF3DCF6E), size: 20),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Coaching Board',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              ),
            ]),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Select a team',
                  style: TextStyle(color: c.textHi, fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('Choose a team to analyze and build the tactical board',
                  style: TextStyle(color: c.muted, fontSize: 13)),
            ]),
          ),

          const SizedBox(height: 8),

          // Team list
          Expanded(
            child: ctrl.loadingTeams
                ? Center(child: CircularProgressIndicator(color: c.accent, strokeWidth: 1.5))
                : ctrl.teams.isEmpty
                    ? _EmptyTeams(c: c)
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                        itemCount: ctrl.teams.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _TeamCard(
                          team: ctrl.teams[i],
                          c: c,
                          onTap: () => ctrl.selectTeamAndAnalyze(ctrl.teams[i]),
                        ),
                      ),
          ),
        ]),
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  final Map<String, dynamic> team;
  final AppColorTokens c;
  final VoidCallback onTap;
  const _TeamCard({required this.team, required this.c, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final logo    = team['logo_url'] as String?;
    final name    = team['name']     as String? ?? 'Team';
    final club    = team['club']     as String? ?? '';
    final cat     = team['category'] as String? ?? '';
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
        child: Row(children: [
          // Logo
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c.accentLo,
              border: Border.all(color: c.borderGreen, width: 1.5),
              image: logo != null && logo.isNotEmpty
                  ? DecorationImage(image: NetworkImage(logo), fit: BoxFit.cover)
                  : null,
            ),
            child: logo == null || logo.isEmpty
                ? Center(child: Text(initial,
                    style: TextStyle(color: c.accent, fontSize: 22, fontWeight: FontWeight.w800)))
                : null,
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name,
                style: TextStyle(color: c.textHi, fontSize: 16, fontWeight: FontWeight.w700)),
            if (club.isNotEmpty || cat.isNotEmpty)
              Text('$club${club.isNotEmpty && cat.isNotEmpty ? ' · ' : ''}$cat',
                  style: TextStyle(color: c.muted, fontSize: 12)),
          ])),

          // Arrow with accent bg
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: c.accentLo,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.arrow_forward_ios_rounded, color: c.accent, size: 14),
          ),
        ]),
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
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.groups_outlined, color: c.dim, size: 48),
        const SizedBox(height: 16),
        Text('No teams yet', style: TextStyle(color: c.text, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text('Create a team on the Home tab first', style: TextStyle(color: c.muted, fontSize: 13)),
      ]),
    );
  }
}

// ── Step 2: Analyzing ──────────────────────────────────────────────────────────

class _AnalyzingStep extends StatelessWidget {
  final CoachingBoardController ctrl;
  const _AnalyzingStep({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final c    = context.colors;
    final team = ctrl.selectedTeam;
    final name = team?['name'] as String? ?? 'Team';

    return Scaffold(
      backgroundColor: const Color(0xFF080C08),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Pulsing ball
            _PulsingBall(color: c.accent),
            const SizedBox(height: 32),

            Text('Analyzing $name',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text('Building your tactical board with AI',
                style: TextStyle(color: c.muted, fontSize: 13)),
            const SizedBox(height: 36),

            // Steps
            ...List.generate(CoachingBoardController.analysisSteps.length, (i) {
              final done    = i < ctrl.completedSteps;
              final current = i == ctrl.completedSteps;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: done
                        ? Icon(Icons.check_circle_rounded, color: c.accent, size: 20, key: const ValueKey('done'))
                        : current
                            ? SizedBox(width: 20, height: 20,
                                child: CircularProgressIndicator(color: c.accent, strokeWidth: 2))
                            : Icon(Icons.radio_button_unchecked, color: c.dim, size: 20, key: ValueKey(i)),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    CoachingBoardController.analysisSteps[i],
                    style: TextStyle(
                      color: done ? c.textHi : current ? c.text : c.dim,
                      fontSize: 14,
                      fontWeight: done || current ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ]),
              );
            }),
          ]),
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

class _PulsingBallState extends State<_PulsingBall> with SingleTickerProviderStateMixin {
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
          width: 80, height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(alpha: 0.15),
            boxShadow: [BoxShadow(
              color: widget.color.withValues(alpha: 0.3 + _anim.value * 0.3),
              blurRadius: 24 + _anim.value * 12,
              spreadRadius: 4,
            )],
          ),
          child: Icon(Icons.sports_soccer, color: widget.color, size: 40),
        ),
      ),
    );
  }
}

// ── Step 3: Interactive board ──────────────────────────────────────────────────

class _BoardStep extends StatelessWidget {
  final CoachingBoardController ctrl;
  const _BoardStep({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final c        = context.colors;
    final selected = ctrl.selectedPlayer;
    final team     = ctrl.selectedTeam;

    return Scaffold(
      backgroundColor: const Color(0xFF080C08),
      body: SafeArea(
        child: Column(children: [
          // AppBar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Row(children: [
              GestureDetector(
                onTap: ctrl.goBack,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.arrow_back_rounded, color: c.text, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(team?['name'] as String? ?? 'Tactical Board',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                  Text(ctrl.formation,
                      style: TextStyle(color: c.accent, fontSize: 12, fontWeight: FontWeight.w600)),
                ]),
              ),
              GestureDetector(
                onTap: ctrl.resetFormation,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: c.accentLo,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: c.borderGreen),
                  ),
                  child: Text('Reset', style: TextStyle(color: c.accent, fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          ),

          // Field
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LayoutBuilder(builder: (context, constraints) {
                  final fw = constraints.maxWidth;
                  final fh = constraints.maxHeight;
                  return Stack(children: [
                    SizedBox.expand(
                      child: CustomPaint(
                        painter: FieldPainter(
                          bgColor:   const Color(0xFF0B1A0B),
                          lineColor: Colors.white.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10, right: 10,
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.arrow_upward_rounded, color: Colors.white24, size: 12),
                        const SizedBox(width: 4),
                        Text('Attack', style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.3), fontSize: 10)),
                      ]),
                    ),
                    ..._buildPlayerTokens(context, ctrl.players, selected, fw, fh),
                  ]);
                }),
              ),
            ),
          ),

          // Selected player footer
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: selected != null ? 68 : 0,
            child: selected != null
                ? _PlayerFooter(
                    player: selected,
                    c: c,
                    onTap: () => PlayerStatsSheet.show(context, selected),
                  )
                : null,
          ),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }

  List<Widget> _buildPlayerTokens(
    BuildContext context,
    List<PlayerToken> players,
    PlayerToken? selected,
    double fw,
    double fh,
  ) {
    return players.map((player) {
      final px = player.dx * fw;
      final py = player.dy * fh;
      final isSelected = player.id == selected?.id;
      return Positioned(
        left: px - PlayerChip.size / 2,
        top:  py - PlayerChip.size / 2 - 12,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          PlayerChip(
            player: player,
            isSelected: isSelected,
            onTap: () {
              ctrl.selectPlayer(player);
              if (!isSelected) PlayerStatsSheet.show(context, player);
            },
            onDrag: (ddx, ddy) => ctrl.movePlayer(
              player.id,
              (player.dx + ddx / fw).clamp(0.03, 0.97),
              (player.dy + ddy / fh).clamp(0.03, 0.97),
            ),
          ),
          const SizedBox(height: 3),
          PlayerLabel(player: player, isSelected: isSelected),
        ]),
      );
    }).toList();
  }
}

class _PlayerFooter extends StatelessWidget {
  final PlayerToken player;
  final AppColorTokens c;
  final VoidCallback onTap;
  const _PlayerFooter({required this.player, required this.c, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final rating = (player.stats['rating'] as num?)?.toDouble() ?? 7.0;
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
          Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
              children: [
            Text(player.name, style: TextStyle(color: c.textHi, fontSize: 14, fontWeight: FontWeight.w700)),
            Text('#${player.number} · ${player.stats['minutes']} min',
                style: TextStyle(color: c.muted, fontSize: 11)),
          ])),
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
