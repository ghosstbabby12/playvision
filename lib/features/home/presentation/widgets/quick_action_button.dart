import 'package:flutter/material.dart';

import '../../../../../core/theme/app_color_tokens.dart';

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
  Widget build(BuildContext context) {
    final c = context.colors;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.border),
          ),
          child: Column(children: [
            Icon(icon, color: c.accent, size: 22),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(color: c.muted, fontSize: 11)),
          ]),
        ),
      ),
    );
  }
}
