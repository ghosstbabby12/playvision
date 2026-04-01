import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../features/home/presentation/home_page.dart';
import '../features/analysis/presentation/analysis_page.dart';
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
    const AnalysisPage(),
    const MatchesPage(),
    const TrainingPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBarItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Inicio', index: 0, current: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
                _NavBarItem(icon: Icons.analytics_outlined, activeIcon: Icons.analytics_rounded, label: 'Análisis', index: 1, current: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
                _NavBarItem(icon: Icons.sports_soccer_outlined, activeIcon: Icons.sports_soccer, label: 'Partidos', index: 2, current: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
                _NavBarItem(icon: Icons.fitness_center_outlined, activeIcon: Icons.fitness_center, label: 'Entreno', index: 3, current: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int current;
  final void Function(int) onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.accentLo : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active ? activeIcon : icon,
              color: active ? AppColors.accent : AppColors.dim,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: active ? AppColors.accent : AppColors.dim,
                fontSize: 10,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
