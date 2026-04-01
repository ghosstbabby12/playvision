import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Fondos ───────────────────────────────────────────────
  static const Color bg       = Color(0xFF080C08); // verde-negro
  static const Color surface  = Color(0xFF0E1410); // tarjetas
  static const Color elevated = Color(0xFF141C12); // elevado

  // ── Hero gradient ────────────────────────────────────────
  static const Color heroTop    = Color(0xFF1A3A20); // inicio gradiente
  static const Color heroBottom = Color(0xFF0A160A); // fin gradiente

  // ── Bordes ───────────────────────────────────────────────
  static const Color border   = Color(0x12FFFFFF);
  static const Color border2  = Color(0x22FFFFFF);
  static const Color borderGreen = Color(0x1A3DCF6E);

  // ── Texto ────────────────────────────────────────────────
  static const Color text     = Color(0xFFF0F8F0);
  static const Color textHi   = Color(0xFFFFFFFF);
  static const Color muted    = Color(0xFF7A9A80);
  static const Color dim      = Color(0xFF3A5A40);

  // ── Acento verde ─────────────────────────────────────────
  static const Color accent    = Color(0xFF3DCF6E); // verde brillante
  static const Color accentHi  = Color(0xFF6EE89A); // verde claro
  static const Color accentLo  = Color(0xFF1A3A20); // verde oscuro (fondos)
  static const Color accentMid = Color(0xFF22522E); // verde medio

  // ── Nav bar glass ────────────────────────────────────────
  static const Color navBg     = Color(0xCC0A1209);
  static const Color navActive = Color(0xFF1C3020);
  static const Color navBorder = Color(0x2A3DCF6E);

  // ── Estado ───────────────────────────────────────────────
  static const Color positive     = Color(0xFF3DCF6E);
  static const Color positiveBg   = Color(0x1A3DCF6E);
  static const Color negative     = Color(0xFFFF4444);
  static const Color negativeBg   = Color(0x1AFF4444);
  static const Color success      = Color(0xFF4CAF50);
  static const Color successBg    = Color(0x1A4CAF50);
  static const Color warning      = Color(0xFFFFA726);
  static const Color warningBg    = Color(0x1AFFA726);
  static const Color danger       = Color(0xFFFF4D4D);
  static const Color dangerBg     = Color(0x1AFF4D4D);

  // ── Categorías ───────────────────────────────────────────
  static const Color catTactic   = Color(0xFF2D6A4F);
  static const Color catTech     = Color(0xFF1D5A8A);
  static const Color catPhysical = Color(0xFF7A5A1D);
  static const Color catSetPiece = Color(0xFF5A2D7A);
}
