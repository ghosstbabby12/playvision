import 'dart:ui';
import 'package:flutter/material.dart';

/// Botón de retroceso consistente en todas las interfaces de PlayVision.
/// Usa BackdropFilter para funcionar sobre fondos tanto de imagen como sólidos.
class PvBackButton extends StatelessWidget {
  const PvBackButton({super.key, this.onTap, this.lightIcon = false});

  /// Acción custom. Si es null usa [Navigator.maybePop].
  final VoidCallback? onTap;

  /// Fuerza ícono blanco (útil sobre fondos oscuros / imágenes).
  final bool lightIcon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = lightIcon || isDark ? Colors.white : const Color(0xFF111111);

    return GestureDetector(
      onTap: onTap ?? () => Navigator.maybePop(context),
      behavior: HitTestBehavior.opaque,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isDark || lightIcon
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.80),
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark || lightIcon
                    ? Colors.white.withValues(alpha: 0.20)
                    : Colors.black.withValues(alpha: 0.10),
              ),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: iconColor,
              size: 15,
            ),
          ),
        ),
      ),
    );
  }
}
