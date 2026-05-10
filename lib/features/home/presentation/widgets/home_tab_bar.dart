import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:playvision/core/theme/app_color_tokens.dart';

import '../../../../../../l10n/generated/app_localizations.dart';

class HomeTabBar extends StatelessWidget {
  final int selected;
  final void Function(int) onSelect;
  const HomeTabBar({super.key, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final l10n   = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.10)
                    : const Color(0x14000000),
              ),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Row(children: [
              HomeTabPill(
                label: l10n.resultsTab,
                active: selected == 0,
                onTap: () => onSelect(0),
              ),
              HomeTabPill(
                label: l10n.newsTab,
                active: selected == 1,
                onTap: () => onSelect(1),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class HomeTabPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const HomeTabPill({super.key, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c      = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: active && isDark
                ? LinearGradient(
                    colors: [
                      c.accentLo,
                      Color.lerp(c.accentLo, const Color(0xFF0F2A18), 0.5)!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: active
                ? (isDark ? null : c.accentLo)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: active
                ? Border.all(
                    color: c.accent.withValues(alpha: isDark ? 0.60 : 0.50),
                  )
                : null,
            boxShadow: active
                ? [
                    BoxShadow(
                      color: c.accent.withValues(alpha: isDark ? 0.15 : 0.20),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? c.accent : c.muted,
              fontSize: 13,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
