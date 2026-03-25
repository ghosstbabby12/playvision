import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0B1020);
  static const Color backgroundSoft = Color(0xFF0F1530);

  static const Color surface = Color(0xFF121832);
  static const Color card = Color(0xFF1B2142);
  static const Color cardSoft = Color(0xFF202850);
  static const Color border = Color(0xFF2A3366);

  static const Color primary = Color(0xFF6C3BFF);
  static const Color secondary = Color(0xFF9D4EDD);
  static const Color accent = Color(0xFF2F6BFF);

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFAAB3D1);
  static const Color textMuted = Color(0xFF7C86B2);

  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF151B3B),
      Color(0xFF1A2250),
      Color(0xFF251B5C),
    ],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      primary,
      secondary,
      accent,
    ],
  );
}
