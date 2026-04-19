import 'package:flutter/material.dart';

import '../../../../core/theme/app_color_tokens.dart';

class LoginTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;
  final TextInputType keyboardType;

  const LoginTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<LoginTextField> createState() => _LoginTextFieldState();
}

class _LoginTextFieldState extends State<LoginTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.isPassword && _obscure,
      style: TextStyle(color: c.textHi, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: widget.label,
        hintStyle: TextStyle(color: c.muted),
        prefixIcon: Icon(widget.icon, color: c.muted, size: 22),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: c.muted,
                  size: 22,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
        filled: true,
        fillColor: c.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: c.accent, width: 2),
        ),
      ),
    );
  }
}
