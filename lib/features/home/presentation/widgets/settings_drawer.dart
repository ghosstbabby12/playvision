import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/theme/app_colors.dart';

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Row(children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.accentLo,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.sports_soccer_outlined, color: AppColors.accent, size: 20),
                ),
                const SizedBox(width: 12),
                const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('PlayVision',
                      style: TextStyle(color: AppColors.text, fontSize: 16, fontWeight: FontWeight.w700)),
                  Text('Settings', style: TextStyle(color: AppColors.dim, fontSize: 12)),
                ]),
              ]),
            ),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 12),

            // ── Menu items ───────────────────────────────────
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Text('INFORMACIÓN',
                  style: TextStyle(color: AppColors.dim, fontSize: 10,
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
            
            // ── Botón de Cerrar Sesión ───────────────────────
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.danger, size: 20),
              title: const Text(
                'Cerrar Sesión', 
                style: TextStyle(color: AppColors.danger, fontSize: 14, fontWeight: FontWeight.w600)
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              visualDensity: const VisualDensity(vertical: -1),
              onTap: () async {
                // 1. Mostrar loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  ),
                );

                try {
                  // 2. Cerrar sesión en Supabase
                  await Supabase.instance.client.auth.signOut();
                  
                  if (context.mounted) {
                    // 3. Quitar loading y redirigir explícitamente al /login
                    Navigator.pop(context);
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  }
                } catch (e) {
                  if (context.mounted) Navigator.pop(context);
                  debugPrint('Error al cerrar sesión: $e');
                }
              },
            ),
            
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Text('v1.0.0', style: TextStyle(color: AppColors.dim, fontSize: 11)),
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
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: AppColors.accentLo, size: 20),
    title: Text(label, style: const TextStyle(color: AppColors.text, fontSize: 14)),
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    visualDensity: const VisualDensity(vertical: -1),
  );
}