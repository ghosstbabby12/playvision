import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/app_color_tokens.dart';
import '../features/home/presentation/home_page.dart';
import '../features/analysis/presentation/analyses_history_page.dart';
import '../features/coaching_board/presentation/coaching_board_page.dart';
import '../features/matches/presentation/matches_page.dart';
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
    const MatchesPage(),
    const TrainingPage(),
    const CoachingBoardPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      extendBody: true,
      body: _pages[_currentIndex],
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
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 28),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              color: c.navBg,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: c.navBorder),
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
