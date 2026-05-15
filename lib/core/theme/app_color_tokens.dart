import 'package:flutter/material.dart';

@immutable
class AppColorTokens extends ThemeExtension<AppColorTokens> {
  const AppColorTokens({
    required this.bg,
    required this.surface,
    required this.elevated,
    required this.card,
    required this.heroTop,
    required this.heroBottom,
    required this.border,
    required this.border2,
    required this.borderGreen,
    required this.text,
    required this.textHi,
    required this.muted,
    required this.dim,
    required this.accent,
    required this.accentHi,
    required this.accentLo,
    required this.accentMid,
    required this.navBg,
    required this.navActive,
    required this.navBorder,
    required this.positive,
    required this.positiveBg,
    required this.negative,
    required this.negativeBg,
    required this.success,
    required this.successBg,
    required this.warning,
    required this.warningBg,
    required this.danger,
    required this.dangerBg,
  });

  final Color bg;
  final Color surface;
  final Color elevated;
  final Color card;
  final Color heroTop;
  final Color heroBottom;
  final Color border;
  final Color border2;
  final Color borderGreen;
  final Color text;
  final Color textHi;
  final Color muted;
  final Color dim;
  final Color accent;
  final Color accentHi;
  final Color accentLo;
  final Color accentMid;
  final Color navBg;
  final Color navActive;
  final Color navBorder;
  final Color positive;
  final Color positiveBg;
  final Color negative;
  final Color negativeBg;
  final Color success;
  final Color successBg;
  final Color warning;
  final Color warningBg;
  final Color danger;
  final Color dangerBg;

  static const dark = AppColorTokens(
    bg:          Color(0xFF050816),
    surface:     Color(0xFF07111F),
    elevated:    Color(0xFF0B1829),
    card:        Color(0xFF0D1A2E),
    heroTop:     Color(0xFF0A1530),
    heroBottom:  Color(0xFF020408),
    border:      Color(0x14FFFFFF),
    border2:     Color(0x22FFFFFF),
    borderGreen: Color(0x3032FF88),
    text:        Color(0xFFD8E8FF),
    textHi:      Color(0xFFFFFFFF),
    muted:       Color(0xFF4A6A8A),
    dim:         Color(0xFF1E3050),
    accent:      Color(0xFF32FF88),
    accentHi:    Color(0xFF5FFFAA),
    accentLo:    Color(0xFF071A10),
    accentMid:   Color(0xFF0F3020),
    navBg:       Color(0xEA050816),
    navActive:   Color(0xFF0F2018),
    navBorder:   Color(0x2832FF88),
    positive:    Color(0xFF32FF88),
    positiveBg:  Color(0x1A32FF88),
    negative:    Color(0xFFFF4444),
    negativeBg:  Color(0x1AFF4444),
    success:     Color(0xFF4CAF50),
    successBg:   Color(0x1A4CAF50),
    warning:     Color(0xFFFFA726),
    warningBg:   Color(0x1AFFA726),
    danger:      Color(0xFFFF4D4D),
    dangerBg:    Color(0x1AFF4D4D),
  );

  // ── Premium Light — Glassmorphism · Sage · Futurista ──────────────────────
  static const light = AppColorTokens(
    // Backgrounds: sage mist base + translucent glass layers
    bg:          Color(0xFFF4F6F2),  // Sage mist premium
    surface:     Color(0xF0FFFFFF),  // Glass white 94%
    elevated:    Color(0xF7FFFFFF),  // Glass white 97%
    card:        Color(0xEBFFFFFF),  // Glass white 92%

    // Hero (mantiene dark para contraste visual)
    heroTop:     Color(0xFF07111F),
    heroBottom:  Color(0xFF0D1A2E),

    // Borders: ultra-suaves, elegantes
    border:      Color(0x0D000000),  // 5% negro — casi imperceptible
    border2:     Color(0x1A000000),  // 10% negro — sutil
    borderGreen: Color(0x4816C86A),  // 28% verde accent

    // Tipografía premium: azul-pizarra, no negro puro
    text:        Color(0xFF1D2B3A),  // Slate profundo
    textHi:      Color(0xFF0B1926),  // Near-black premium
    muted:       Color(0xFF5E7082),  // Azul-gris cálido
    dim:         Color(0xFFB4C6D4),  // Gris suave con azul

    // Accent verde — verde neón suave
    accent:      Color(0xFF16C86A),  // Verde marca
    accentHi:    Color(0xFF1DE882),  // Verde neón brillante
    accentLo:    Color(0x2016C86A),  // 12.5% verde — glass tint
    accentMid:   Color(0x3816C86A),  // 22% verde

    // Navbar glassmorphism
    navBg:       Color(0xDFF4F6F2),  // Sage glass 87%
    navActive:   Color(0x2016C86A),  // Verde active 12.5%
    navBorder:   Color(0x4016C86A),  // Verde border 25%

    // Semáforos premium
    positive:    Color(0xFF16C86A),
    positiveBg:  Color(0x1616C86A),  // 8.6%
    negative:    Color(0xFFD12D2D),
    negativeBg:  Color(0x16D12D2D),
    success:     Color(0xFF1A8840),
    successBg:   Color(0x161A8840),
    warning:     Color(0xFFE07600),
    warningBg:   Color(0x16E07600),
    danger:      Color(0xFFCC2828),
    dangerBg:    Color(0x16CC2828),
  );

  @override
  AppColorTokens copyWith({
    Color? bg, Color? surface, Color? elevated, Color? card,
    Color? heroTop, Color? heroBottom, Color? border, Color? border2,
    Color? borderGreen, Color? text, Color? textHi, Color? muted, Color? dim,
    Color? accent, Color? accentHi, Color? accentLo, Color? accentMid,
    Color? navBg, Color? navActive, Color? navBorder,
    Color? positive, Color? positiveBg, Color? negative, Color? negativeBg,
    Color? success, Color? successBg, Color? warning, Color? warningBg,
    Color? danger, Color? dangerBg,
  }) => AppColorTokens(
    bg: bg ?? this.bg,
    surface: surface ?? this.surface,
    elevated: elevated ?? this.elevated,
    card: card ?? this.card,
    heroTop: heroTop ?? this.heroTop,
    heroBottom: heroBottom ?? this.heroBottom,
    border: border ?? this.border,
    border2: border2 ?? this.border2,
    borderGreen: borderGreen ?? this.borderGreen,
    text: text ?? this.text,
    textHi: textHi ?? this.textHi,
    muted: muted ?? this.muted,
    dim: dim ?? this.dim,
    accent: accent ?? this.accent,
    accentHi: accentHi ?? this.accentHi,
    accentLo: accentLo ?? this.accentLo,
    accentMid: accentMid ?? this.accentMid,
    navBg: navBg ?? this.navBg,
    navActive: navActive ?? this.navActive,
    navBorder: navBorder ?? this.navBorder,
    positive: positive ?? this.positive,
    positiveBg: positiveBg ?? this.positiveBg,
    negative: negative ?? this.negative,
    negativeBg: negativeBg ?? this.negativeBg,
    success: success ?? this.success,
    successBg: successBg ?? this.successBg,
    warning: warning ?? this.warning,
    warningBg: warningBg ?? this.warningBg,
    danger: danger ?? this.danger,
    dangerBg: dangerBg ?? this.dangerBg,
  );

  @override
  AppColorTokens lerp(AppColorTokens? other, double t) {
    if (other == null) return this;
    return AppColorTokens(
      bg:          Color.lerp(bg, other.bg, t)!,
      surface:     Color.lerp(surface, other.surface, t)!,
      elevated:    Color.lerp(elevated, other.elevated, t)!,
      card:        Color.lerp(card, other.card, t)!,
      heroTop:     Color.lerp(heroTop, other.heroTop, t)!,
      heroBottom:  Color.lerp(heroBottom, other.heroBottom, t)!,
      border:      Color.lerp(border, other.border, t)!,
      border2:     Color.lerp(border2, other.border2, t)!,
      borderGreen: Color.lerp(borderGreen, other.borderGreen, t)!,
      text:        Color.lerp(text, other.text, t)!,
      textHi:      Color.lerp(textHi, other.textHi, t)!,
      muted:       Color.lerp(muted, other.muted, t)!,
      dim:         Color.lerp(dim, other.dim, t)!,
      accent:      Color.lerp(accent, other.accent, t)!,
      accentHi:    Color.lerp(accentHi, other.accentHi, t)!,
      accentLo:    Color.lerp(accentLo, other.accentLo, t)!,
      accentMid:   Color.lerp(accentMid, other.accentMid, t)!,
      navBg:       Color.lerp(navBg, other.navBg, t)!,
      navActive:   Color.lerp(navActive, other.navActive, t)!,
      navBorder:   Color.lerp(navBorder, other.navBorder, t)!,
      positive:    Color.lerp(positive, other.positive, t)!,
      positiveBg:  Color.lerp(positiveBg, other.positiveBg, t)!,
      negative:    Color.lerp(negative, other.negative, t)!,
      negativeBg:  Color.lerp(negativeBg, other.negativeBg, t)!,
      success:     Color.lerp(success, other.success, t)!,
      successBg:   Color.lerp(successBg, other.successBg, t)!,
      warning:     Color.lerp(warning, other.warning, t)!,
      warningBg:   Color.lerp(warningBg, other.warningBg, t)!,
      danger:      Color.lerp(danger, other.danger, t)!,
      dangerBg:    Color.lerp(dangerBg, other.dangerBg, t)!,
    );
  }
}

extension AppColorTokensX on BuildContext {
  AppColorTokens get colors => Theme.of(this).extension<AppColorTokens>()!;
}
