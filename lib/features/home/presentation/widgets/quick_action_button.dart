import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(children: [
          Icon(icon, color: AppColors.accent, size: 22),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
        ]),
      ),
    ),
  );
}
