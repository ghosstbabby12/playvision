import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:playvision/core/theme/app_color_tokens.dart';
import 'package:playvision/features/analysis/presentation/analysis_page.dart';

class QuickActionsSection extends StatelessWidget {
  final void Function(int)? onTabChange;
  const QuickActionsSection({super.key, this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    const actions = [
      _Action(Icons.videocam_rounded, 'Analizar\nVideo', Color(0xFF32FF88), -1),
      _Action(Icons.draw_rounded, 'Tablero\nTáctico', Color(0xFF64B5F6), 4),
      _Action(Icons.people_rounded, 'Mis\nJugadores', Color(0xFFFFB74D), 2),
      _Action(Icons.timer_rounded, 'Entrena-\nmiento', Color(0xFFBA68C8), 3),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 22, 0, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Text(
            'Acciones rápidas',
            style: TextStyle(
              color: c.textHi,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: actions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) => _QuickActionCard(
              action: actions[i],
              onTabChange: onTabChange,
            ),
          ),
        ),
      ]),
    );
  }
}

class _Action {
  final IconData icon;
  final String label;
  final Color color;
  final int tabIndex; // -1 = push AnalysisPage
  const _Action(this.icon, this.label, this.color, this.tabIndex);
}

class _QuickActionCard extends StatefulWidget {
  final _Action action;
  final void Function(int)? onTabChange;
  // ignore: unused_element
  const _QuickActionCard({required this.action, this.onTabChange});

  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}

class _QuickActionCardState extends State<_QuickActionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween(begin: 1.0, end: 0.92)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleTap(BuildContext context) {
    if (widget.action.tabIndex == -1) {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const AnalysisPage()));
    } else {
      widget.onTabChange?.call(widget.action.tabIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = widget.action.color;

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        _handleTap(context);
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              width: 110,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? c.elevated.withValues(alpha: 0.78)
                    : Colors.white.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: color.withValues(alpha: isDark ? 0.18 : 0.22),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: isDark ? 0.08 : 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: isDark ? 0.14 : 0.10),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            color.withValues(alpha: isDark ? 0.0 : 0.16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: isDark ? 0.12 : 0.08),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Icon(widget.action.icon, color: color, size: 20),
                  ),
                  const Spacer(),
                  Text(
                    widget.action.label,
                    style: TextStyle(
                      color: c.textHi,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
