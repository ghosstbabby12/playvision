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
      style: TextStyle(color: c.text, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: c.dim, fontSize: 13),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: c.border2),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: c.accent),
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: c.elevated,
      ),
    );
  }
}
