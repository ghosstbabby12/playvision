import 'package:flutter/material.dart';

/// Paleta de colores centralizada de PlayVision.
/// Todos los widgets deben referenciar estos valores en lugar de
/// usar Color() directamente.
class AppColors {
  AppColors._();

  // Fondos
  static const Color bg       = Color(0xFF0B1120); // fondo principal
  static const Color surface  = Color(0xFF111827); // tarjetas
  static const Color elevated = Color(0xFF1C2537); // elementos elevados

  // Bordes
  static const Color border   = Color(0x0FFFFFFF); // sutil
  static const Color border2  = Color(0x1AFFFFFF); // visible

  // Texto
  static const Color text     = Color(0xFFE2E8F4); // primario
  static const Color textHi   = Color(0xFFBDD4EA); // destacado
  static const Color muted    = Color(0xFF64748B); // secundario
  static const Color dim      = Color(0xFF4A5568); // apagado

  // Acento
  static const Color accent   = Color(0xFF7C9EBF); // azul accent
  static const Color accentLo = Color(0xFF2D4A6A); // accent oscuro

  // Categorías de sesiones
  static const Color catTactic   = Color(0xFF4A7FA5);
  static const Color catTech     = Color(0xFF3D7A5E);
  static const Color catPhysical = Color(0xFF7A6A3D);
  static const Color catSetPiece = Color(0xFF5A4A7A);
}
