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
    const SquadPage(),
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
        // ── Global background (light theme) ──────────────────────────────
        if (!isDark)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFF0F4FA),
                    const Color(0xFFE8F0FE).withValues(alpha: 0.60),
                    const Color(0xFFF7F9FC),
                  ],
                ),
              ),
            ),
          ),
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
    (icon: Icons.home_outlined,              activeIcon: Icons.home_rounded),
    (icon: Icons.analytics_outlined,         activeIcon: Icons.analytics_rounded),
    (icon: Icons.sports_soccer_outlined,     activeIcon: Icons.sports_soccer),
    (icon: Icons.fitness_center_outlined,    activeIcon: Icons.fitness_center),
    (icon: Icons.space_dashboard_outlined,   activeIcon: Icons.space_dashboard_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final c      = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 28),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              color: isDark ? c.navBg : Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: isDark ? c.navBorder : Colors.black.withValues(alpha: 0.08),
              ),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 24,
                        offset: const Offset(0, -6),
                      ),
                    ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_items.length, (i) {
                final active = i == currentIndex;
                final item   = _items[i];
                return GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: active ? c.navActive : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      active ? item.activeIcon : item.icon,
                      color: active ? c.accent : c.muted,
                      size: 22,
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
