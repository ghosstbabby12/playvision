import 'package:flutter/material.dart';
import 'app_color_tokens.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColorTokens.dark.bg,
    colorScheme: ColorScheme.dark(
      primary: AppColorTokens.dark.accent,
      surface: AppColorTokens.dark.surface,
      error: AppColorTokens.dark.danger,
    ),
    cardColor: AppColorTokens.dark.card,
    dividerColor: AppColorTokens.dark.border,
    extensions: const [AppColorTokens.dark],
  );

  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColorTokens.light.bg,
    colorScheme: ColorScheme.light(
      primary: AppColorTokens.light.accent,
      surface: AppColorTokens.light.surface,
      error: AppColorTokens.light.danger,
    ),
    cardColor: AppColorTokens.light.card,
    dividerColor: AppColorTokens.light.border,
    extensions: const [AppColorTokens.light],
  );
}
