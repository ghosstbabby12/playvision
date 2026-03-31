import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class FormTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  const FormTextField({super.key, required this.controller, required this.label});

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    style: const TextStyle(color: AppColors.text, fontSize: 14),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.dim, fontSize: 13),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.border2),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.accent),
        borderRadius: BorderRadius.circular(10),
      ),
      filled: true,
      fillColor: AppColors.elevated,
    ),
  );
}
