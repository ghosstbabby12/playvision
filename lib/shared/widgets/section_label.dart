import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: AppColors.dim,
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 2,
    ),
  );
}
