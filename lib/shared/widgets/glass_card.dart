import 'dart:ui';
import 'package:flutter/material.dart';

/// Glassmorphism card — Flutter equivalent of the web GlassCard component.
/// Uses BackdropFilter + semi-transparent overlay to create a frosted-glass effect.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.radius = 20.0,
    this.neonBorder = false,
    this.accentColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final bool neonBorder;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final br = BorderRadius.circular(radius);
    final accent = accentColor ?? const Color(0xFF22FF88);

    final borderColor = neonBorder
        ? accent.withValues(alpha: 0.35)
        : isDark
            ? Colors.white.withValues(alpha: 0.10)
            : Colors.black.withValues(alpha: 0.08);

    final bgColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.white.withValues(alpha: 0.85);

    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.20)
        : Colors.black.withValues(alpha: 0.10);

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: br,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: br,
              border: Border.all(color: borderColor),
              boxShadow: [
                if (neonBorder)
                  BoxShadow(
                    color: accent.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 0),
                  ),
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 32,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
