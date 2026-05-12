import 'package:flutter/material.dart';

import '../../core/theme/app_color_tokens.dart';

class FormTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  const FormTextField({super.key, required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return TextField(
      controller: controller,
      style: TextStyle(color: c.textHi, fontSize: 14, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: c.text, fontSize: 13),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: c.border2.withValues(alpha: 0.7)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: c.accent, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: c.elevated,
      ),
    );
  }
}
