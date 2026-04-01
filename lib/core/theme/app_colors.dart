import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Fondos ───────────────────────────────────────────────
  static const Color bg       = Color(0xFF090910); // fondo principal
  static const Color surface  = Color(0xFF111118); // tarjetas
  static const Color elevated = Color(0xFF1A1A26); // elementos elevados

  // ── Bordes ───────────────────────────────────────────────
  static const Color border   = Color(0x14FFFFFF); // sutil
  static const Color border2  = Color(0x22FFFFFF); // visible

  // ── Texto ────────────────────────────────────────────────
  static const Color text     = Color(0xFFF0F2F8); // primario
  static const Color textHi   = Color(0xFFFFFFFF); // destacado
  static const Color muted    = Color(0xFF7A7A8F); // secundario
  static const Color dim      = Color(0xFF4A4A5F); // apagado

  // ── Acento: lime green ───────────────────────────────────
  static const Color accent   = Color(0xFFAAFF00); // lime principal
  static const Color accentLo = Color(0xFF2D4400); // lime oscuro (fondos)
  static const Color accentMid = Color(0xFF557700); // lime medio

  // ── Gradiente hero ───────────────────────────────────────
  static const Color gradStart = Color(0xFF1C3300); // inicio gradiente
  static const Color gradEnd   = Color(0xFF0A1500); // fin gradiente

  // ── Estado ───────────────────────────────────────────────
  static const Color success      = Color(0xFF4CAF50);
  static const Color successBg    = Color(0x1A4CAF50);
  static const Color warning      = Color(0xFFFFA726);
  static const Color warningBg    = Color(0x1AFFA726);
  static const Color danger       = Color(0xFFFF4D4D);
  static const Color dangerBg     = Color(0x1AFF4D4D);

  // ── Categorías sesiones ──────────────────────────────────
  static const Color catTactic   = Color(0xFF2D6A4F);
  static const Color catTech     = Color(0xFF1D5A8A);
  static const Color catPhysical = Color(0xFF7A5A1D);
  static const Color catSetPiece = Color(0xFF5A2D7A);
}
