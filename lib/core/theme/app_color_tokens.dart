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

  static const light = AppColorTokens(
    bg:          Color(0xFFF0F4FA),
    surface:     Color(0xFFFFFFFF),
    elevated:    Color(0xFFF7F9FC),
    card:        Color(0xFFFFFFFF),
    heroTop:     Color(0xFF07111F),
    heroBottom:  Color(0xFF0D1A2E),
    border:      Color(0x18000000),
    border2:     Color(0x28000000),
    borderGreen: Color(0x4016C86A),
    text:        Color(0xFF1A2332),
    textHi:      Color(0xFF07111F),
    muted:       Color(0xFF667085),
    dim:         Color(0xFFB0BEC5),
    accent:      Color(0xFF16C86A),
    accentHi:    Color(0xFF32FF88),
    accentLo:    Color(0xFFE6FAF1),
    accentMid:   Color(0xFFC2F0D9),
    navBg:       Color(0xF2FFFFFF),
    navActive:   Color(0xFFDDFBEA),
    navBorder:   Color(0x4016C86A),
    positive:    Color(0xFF16C86A),
    positiveBg:  Color(0x1A16C86A),
    negative:    Color(0xFFD32F2F),
    negativeBg:  Color(0x1AD32F2F),
    success:     Color(0xFF1E8A45),
    successBg:   Color(0x1A1E8A45),
    warning:     Color(0xFFF57C00),
    warningBg:   Color(0x1AF57C00),
    danger:      Color(0xFFD32F2F),
    dangerBg:    Color(0x1AD32F2F),
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
