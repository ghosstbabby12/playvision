import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/theme/app_color_tokens.dart';
import '../../../../../core/theme/theme_controller.dart';

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

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
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: c.accentLo,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.sports_soccer_outlined, color: c.accent, size: 20),
                ),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('PlayVision',
                      style: TextStyle(color: c.text, fontSize: 16, fontWeight: FontWeight.w700)),
                  Text('Settings', style: TextStyle(color: c.dim, fontSize: 12)),
                ]),
              ]),
            ),
            Divider(color: c.border, height: 1),
            const SizedBox(height: 12),

            _DrawerItem(
              icon: Icons.settings_outlined,
              label: 'Configuración',
              onTap: () => Navigator.pop(context),
            ),
            _DrawerItem(
              icon: Icons.language_outlined,
              label: 'Idioma',
              onTap: () => Navigator.pop(context),
            ),
            _DrawerItem(
              icon: Icons.help_outline_rounded,
              label: 'Ayuda',
              onTap: () => Navigator.pop(context),
            ),

            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Text('APARIENCIA',
                  style: TextStyle(color: c.dim, fontSize: 10,
                      fontWeight: FontWeight.w700, letterSpacing: 1.5)),
            ),

            ListenableBuilder(
              listenable: themeController,
              builder: (context, _) => ListTile(
                leading: Icon(
                  themeController.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  color: c.accent, size: 20,
                ),
                title: Text(
                  themeController.isDark ? 'Modo Claro' : 'Modo Oscuro',
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
              child: Text('INFORMACIÓN',
                  style: TextStyle(color: c.dim, fontSize: 10,
                      fontWeight: FontWeight.w700, letterSpacing: 1.5)),
            ),

            _DrawerItem(
              icon: Icons.people_outline_rounded,
              label: 'Sobre Nosotros',
              onTap: () => Navigator.pop(context),
            ),
            _DrawerItem(
              icon: Icons.info_outline_rounded,
              label: 'Sobre PlayVision',
              onTap: () => _showAbout(context),
            ),

            const Spacer(),

            Divider(color: c.border, height: 1),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.logout_rounded, color: c.danger, size: 20),
              title: Text(
                'Cerrar Sesión',
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
                  debugPrint('Error al cerrar sesión: $e');
                }
              },
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Text('v1.0.0', style: TextStyle(color: c.dim, fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    Navigator.pop(context);
    showAboutDialog(
      context: context,
      applicationName: 'PlayVision',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2026 PlayVision. All rights reserved.',
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
