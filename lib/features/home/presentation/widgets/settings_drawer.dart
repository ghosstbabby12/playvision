import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../../core/theme/app_color_tokens.dart';
import '../../../../../core/providers/theme_controller.dart';
import '../../../../../core/providers/locale_provider.dart';
import '../../../../../l10n/generated/app_localizations.dart';

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final themeController = Provider.of<ThemeController?>(context, listen: false);

    return Drawer(
      backgroundColor: c.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Row(children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: c.accentLo,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.sports_soccer_outlined, color: c.accent, size: 20),
                ),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    l10n.appTitle,
                    style: TextStyle(color: c.text, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    l10n.settingsTitle,
                    style: TextStyle(color: c.dim, fontSize: 12),
                  ),
                ]),
              ]),
            ),
            Divider(color: c.border, height: 1),
            const SizedBox(height: 12),
            _DrawerItem(
              icon: Icons.settings_outlined,
              label: l10n.settingsTitle,
              onTap: () => Navigator.pop(context),
            ),
            Theme(
              data: Theme.of(context).copyWith(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: PopupMenuButton<String>(
                color: c.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                position: PopupMenuPosition.under,
                onSelected: (String result) {
                  final localeProv = Provider.of<LocaleProvider?>(context, listen: false);
                  if (localeProv != null) {
                    localeProv.setLocale(Locale(result));
                  }
                  Navigator.pop(context);
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'es',
                    child: Text(l10n.languageSpanish, style: TextStyle(color: c.text)),
                  ),
                  PopupMenuItem<String>(
                    value: 'en',
                    child: Text(l10n.languageEnglish, style: TextStyle(color: c.text)),
                  ),
                ],
                child: _DrawerItemWidgetOnly(
                  icon: Icons.language_outlined,
                  label: l10n.languageItem,
                ),
              ),
            ),
            _DrawerItem(
              icon: Icons.help_outline_rounded,
              label: l10n.helpItem,
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Text(
                l10n.appearanceSection,
                style: TextStyle(
                  color: c.dim,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            if (themeController != null)
              ListenableBuilder(
                listenable: themeController,
                builder: (context, _) => ListTile(
                  leading: Icon(
                    themeController.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                    color: c.accent,
                    size: 20,
                  ),
                  title: Text(
                    l10n.lightModeItem,
                    style: TextStyle(color: c.text, fontSize: 14),
                  ),
                  trailing: Switch(
                    value: !themeController.isDark,
                    onChanged: (_) => themeController.toggle(),
                    activeThumbColor: c.accent,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  visualDensity: const VisualDensity(vertical: -1),
                  onTap: themeController.toggle,
                ),
              ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Text(
                l10n.infoSection,
                style: TextStyle(
                  color: c.dim,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            _DrawerItem(
              icon: Icons.people_outline_rounded,
              label: l10n.aboutUsItem,
              onTap: () => Navigator.pop(context),
            ),
            _DrawerItem(
              icon: Icons.info_outline_rounded,
              label: l10n.aboutAppItem,
              onTap: () => _showAbout(context),
            ),
            const Spacer(),
            Divider(color: c.border, height: 1),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.logout_rounded, color: c.danger, size: 20),
              title: Text(
                l10n.logoutButton,
                style: TextStyle(color: c.danger, fontSize: 14, fontWeight: FontWeight.w600),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              visualDensity: const VisualDensity(vertical: -1),
              onTap: () async {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => Center(
                    child: CircularProgressIndicator(color: c.accent),
                  ),
                );
                try {
                  await Supabase.instance.client.auth.signOut();
                  if (context.mounted) {
                    Navigator.pop(context);
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  }
                } catch (e) {
                  if (context.mounted) Navigator.pop(context);
                  debugPrint('${l10n.logoutErrorDebug}: $e');
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Text(l10n.appVersionLabel, style: TextStyle(color: c.dim, fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Navigator.pop(context);
    showAboutDialog(
      context: context,
      applicationName: l10n.appTitle,
      applicationVersion: l10n.appVersionNumber,
      applicationLegalese: l10n.aboutLegalese,
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ListTile(
      leading: Icon(icon, color: c.accentLo, size: 20),
      title: Text(label, style: TextStyle(color: c.text, fontSize: 14)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      visualDensity: const VisualDensity(vertical: -1),
    );
  }
}

class _DrawerItemWidgetOnly extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DrawerItemWidgetOnly({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: c.accentLo, size: 20),
          const SizedBox(width: 32),
          Text(label, style: TextStyle(color: c.text, fontSize: 14)),
        ],
      ),
    );
  }
}
