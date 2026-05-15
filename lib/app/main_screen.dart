import 'dart:ui';
import 'package:flutter/material.dart';
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

  List<Widget> get _pages => [
    HomePage(onTabChange: (i) => setState(() => _currentIndex = i)),
    const AnalysesHistoryPage(),
    SquadPage(onTabChange: (i) => setState(() => _currentIndex = i)),
    TrainingPage(onTabChange: (i) => setState(() => _currentIndex = i)),
    const CoachingBoardPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: c.bg,
      extendBody: true,
      body: Stack(children: [
        // ── Global background (dark theme only) ──────────────────────────
        if (isDark) ...[
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1518604964608-5ad2e5a2dcb9?w=1200&q=80',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF040C07).withValues(alpha: 0.94),
                    const Color(0xFF071510).withValues(alpha: 0.91),
                    const Color(0xFF0A1C0C).withValues(alpha: 0.88),
                  ],
                ),
              ),
            ),
          ),
        ],
        // ── Global background light: Glassmorphism + Ambient Glow ────────
        if (!isDark) ...[
          // Gradiente sage multi-stop — base premium
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.0, 0.38, 0.72, 1.0],
                  colors: [
                    Color(0xFFF5F7F3),  // Sage claro
                    Color(0xFFEDF8F3),  // Verde tint sutil
                    Color(0xFFF1F4F9),  // Azul tint sutil
                    Color(0xFFF4F6F2),  // Sage base
                  ],
                ),
              ),
            ),
          ),
          // Orb ambiental — esquina superior derecha (verde neón suave)
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
          // Orb ambiental — inferior izquierda (verde muy sutil)
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
          // Orb central-alto — halo difuso premium
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
        // ── Page content ─────────────────────────────────────────────────
        _pages[_currentIndex],
      ]),
      bottomNavigationBar: _GlassNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _GlassNavBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const _GlassNavBar({required this.currentIndex, required this.onTap});

  static const _items = [
    (icon: Icons.home_outlined,           activeIcon: Icons.home_rounded,           label: 'Inicio'),
    (icon: Icons.play_circle_outline,     activeIcon: Icons.play_circle_filled,     label: 'Análisis'),
    (icon: Icons.people_outline,          activeIcon: Icons.people_rounded,         label: 'Jugadores'),
    (icon: Icons.timer_outlined,          activeIcon: Icons.timer_rounded,          label: 'Entreno'),
    (icon: Icons.draw_outlined,           activeIcon: Icons.draw_rounded,           label: 'Tablero'),
  ];

  @override
  Widget build(BuildContext context) {
    final c      = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              // Glass sage en light · oscuro translúcido en dark
              color: isDark ? c.navBg : c.navBg,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: c.navBorder,
                width: isDark ? 1.0 : 1.2,
              ),
              boxShadow: isDark
                  ? null
                  : [
                      // Sombra difusa neutra
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 40,
                        spreadRadius: 0,
                        offset: const Offset(0, -6),
                      ),
                      // Glow verde ambiental (el toque premium)
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
              children: List.generate(_items.length, (i) {
                final active = i == currentIndex;
                final item   = _items[i];
                return GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? c.navActive : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      // Glow verde en ítem activo (solo light)
                      boxShadow: (active && !isDark)
                          ? [
                              BoxShadow(
                                color: const Color(0xFF16C86A).withValues(alpha: 0.22),
                                blurRadius: 14,
                                spreadRadius: -3,
                              ),
                            ]
                          : null,
                      border: (active && !isDark)
                          ? Border.all(
                              color: const Color(0xFF16C86A).withValues(alpha: 0.20),
                              width: 1,
                            )
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Ícono con glow cuando activo en light
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 240),
                          padding: active && !isDark
                              ? const EdgeInsets.all(1)
                              : EdgeInsets.zero,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: (active && !isDark)
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF16C86A).withValues(alpha: 0.35),
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
                            color: active ? c.accent : c.muted,
                            fontSize: 9.5,
                            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
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
