import 'package:flutter/material.dart';

import 'package:playvision/core/theme/app_color_tokens.dart';

import '../../../../../../l10n/generated/app_localizations.dart';

class HomeTabBar extends StatelessWidget {
  final int selected;
  final void Function(int) onSelect;
  const HomeTabBar({super.key, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final c    = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.border),
        ),
        child: Row(children: [
          HomeTabPill(label: l10n.resultsTab, active: selected == 0, onTap: () => onSelect(0)),
          HomeTabPill(label: l10n.newsTab,    active: selected == 1, onTap: () => onSelect(1)),
        ]),
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
    final c = context.colors;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? c.accentLo : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: active ? Border.all(color: c.borderGreen) : null,
          ),
          child: Text(label, textAlign: TextAlign.center,
              style: TextStyle(
                  color: active ? c.accent : c.muted,
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
        ),
      ),
    );
  }
}
