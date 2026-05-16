import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:playvision/l10n/generated/app_localizations.dart';
import '../core/theme/app_color_tokens.dart';
import '../features/home/presentation/home_page.dart';
import '../features/analysis/presentation/analyses_history_page.dart';
import '../features/coaching_board/presentation/coaching_board_page.dart';
import '../features/squad/presentation/squad_page.dart';
import '../features/training/presentation/training_page.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}


class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _goToTab(int? i) {
    if (i == null) return;
    setState(() => _currentIndex = i);
  }

  List<Widget> get _pages => [
    HomePage(onTabChange: _goToTab),
    const AnalysesHistoryPage(),
    SquadPage(onTabChange: _goToTab),
    TrainingPage(onTabChange: _goToTab),
    const CoachingBoardPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final c      = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: c.bg,
      extendBody: true,
      body: Stack(
        children: [
          // ── Fondo oscuro — gradiente puro, sin imagen externa ──────────
          if (isDark)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF040C07),
                      const Color(0xFF071510),
                      const Color(0xFF0A1C0C),
                    ],
                  ),
                ),
              ),
            ),

          // ── Fondo claro — Sage + orbs ambientales ─────────────────────
          if (!isDark) ...[
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0.0, 0.38, 0.72, 1.0],
                    colors: [
                      Color(0xFFF5F7F3),
                      Color(0xFFEDF8F3),
                      Color(0xFFF1F4F9),
                      Color(0xFFF4F6F2),
                    ],
                  ),
                ),
              ),
            ),
            // Orb superior derecha
            Positioned(
              top: -110,
              right: -80,
              child: IgnorePointer(
                child: Container(
                  width: 360,
                  height: 360,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF16C86A).withValues(alpha: 0.09),
                        const Color(0xFF16C86A).withValues(alpha: 0.02),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            // Orb inferior izquierda
            Positioned(
              bottom: 80,
              left: -100,
              child: IgnorePointer(
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF16C86A).withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Orb central izquierda
            Positioned(
              top: 200,
              left: -40,
              child: IgnorePointer(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF16C86A).withValues(alpha: 0.03),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],

          // ── Contenido de la página activa ──────────────────────────────
          _pages[_currentIndex],
        ],
      ),
      bottomNavigationBar: _GlassNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}


// ── Nav bar glassmorphism ────────────────────────────────────────────────────

class _GlassNavBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const _GlassNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n   = AppLocalizations.of(context)!;
    final c      = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final items = [
      (
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: l10n.navHome,
      ),
      (
        icon: Icons.play_circle_outline,
        activeIcon: Icons.play_circle_filled,
        label: l10n.navAnalysis,
      ),
      (
        icon: Icons.people_outline,
        activeIcon: Icons.people_rounded,
        label: l10n.navPlayers,
      ),
      (
        icon: Icons.timer_outlined,
        activeIcon: Icons.timer_rounded,
        label: l10n.navTraining,
      ),
      (
        icon: Icons.draw_outlined,
        activeIcon: Icons.draw_rounded,
        label: l10n.navBoard,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: c.navBg,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: c.navBorder,
                width: isDark ? 1.0 : 1.2,
              ),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 40,
                        spreadRadius: 0,
                        offset: const Offset(0, -6),
                      ),
                      BoxShadow(
                        color: const Color(0xFF16C86A).withValues(alpha: 0.12),
                        blurRadius: 28,
                        spreadRadius: -8,
                        offset: const Offset(0, -2),
                      ),
                    ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (i) {
                final active = i == currentIndex;
                final item   = items[i];

                return GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: active ? c.navActive : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: (active && !isDark)
                          ? [
                              BoxShadow(
                                color: const Color(0xFF16C86A)
                                    .withValues(alpha: 0.22),
                                blurRadius: 14,
                                spreadRadius: -3,
                              ),
                            ]
                          : null,
                      border: (active && !isDark)
                          ? Border.all(
                              color: const Color(0xFF16C86A)
                                  .withValues(alpha: 0.20),
                              width: 1,
                            )
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 240),
                          padding: (active && !isDark)
                              ? const EdgeInsets.all(1)
                              : EdgeInsets.zero,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: (active && !isDark)
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF16C86A)
                                          .withValues(alpha: 0.35),
                                      blurRadius: 10,
                                      spreadRadius: 0,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            active ? item.activeIcon : item.icon,
                            color: active ? c.accent : c.muted,
                            size: 21,
                          ),
                        ),
                        const SizedBox(height: 3),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 240),
                          style: TextStyle(
                            color:      active ? c.accent : c.muted,
                            fontSize:   9.5,
                            fontWeight: active
                                ? FontWeight.w700
                                : FontWeight.w400,
                            letterSpacing: active ? 0.3 : 0.1,
                          ),
                          child: Text(item.label),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
