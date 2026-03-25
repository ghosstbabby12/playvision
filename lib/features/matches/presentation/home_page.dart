import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../../core/store/analysis_store.dart';
import '../../../core/supabase/supabase_service.dart';

const String _apiBase = 'http://127.0.0.1:8000';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SupabaseService _svc = SupabaseService();
  final ImagePicker _picker  = ImagePicker();

  List<Map<String, dynamic>> teams = [];
  bool loading      = false;
  bool isAnalyzing  = false;
  XFile? videoFile;

  Map<String, dynamic>? get lastResult => AnalysisStore.instance.lastResult;

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    setState(() => loading = true);
    try {
      final data = await _svc.getTeams();
      if (mounted) setState(() => teams = data);
    } catch (_) {
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _pickAndAnalyze() async {
    final v = await _picker.pickVideo(source: ImageSource.gallery);
    if (v == null) return;
    setState(() { videoFile = v; isAnalyzing = true; });

    try {
      final bytes   = await v.readAsBytes();
      final request = http.MultipartRequest('POST', Uri.parse('$_apiBase/analyze'));
      request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: v.name));
      final streamed = await request.send().timeout(const Duration(minutes: 10));
      final body     = await streamed.stream.bytesToString();

      if (streamed.statusCode == 200) {
        final r = jsonDecode(body) as Map<String, dynamic>;
        AnalysisStore.instance.save(r);
        if (mounted) {
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Análisis completado. Ve a la pestaña Análisis.'),
              backgroundColor: Color(0xFF1C2537),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: const Color(0xFF1C2537)),
        );
      }
    } finally {
      if (mounted) setState(() => isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = lastResult;
    final team   = result?['team'] as Map<String, dynamic>?;
    final players = result?['players'] as List?;
    final topPlayer = players != null && players.isNotEmpty
        ? players.reduce((a, b) =>
            ((a['distance_km'] as num?) ?? 0) > ((b['distance_km'] as num?) ?? 0) ? a : b)
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Hero ──────────────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0F1E35), Color(0xFF0B1120)],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 64, 24, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Row(children: const [
                    Icon(Icons.sports_soccer_outlined, color: Color(0xFF7C9EBF), size: 18),
                    SizedBox(width: 8),
                    Text('PLAYVISION',
                        style: TextStyle(color: Color(0xFF7C9EBF), fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 3)),
                  ]),
                  const SizedBox(height: 32),
                  const Text(
                    'Análisis\ninteligente\nde fútbol',
                    style: TextStyle(color: Color(0xFFE2E8F4), fontSize: 34, fontWeight: FontWeight.w800, height: 1.2, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'IA que detecta, rastrea y analiza\ncada jugador en tiempo real.',
                    style: TextStyle(color: Color(0xFF4A5568), fontSize: 14, height: 1.6),
                  ),
                ],
              ),
            ),

            // ── Card principal: subir video ────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Transform.translate(
                offset: const Offset(0, -20),
                child: GestureDetector(
                  onTap: isAnalyzing ? null : _pickAndAnalyze,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0x1AFFFFFF)),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
                    ),
                    child: isAnalyzing
                        ? const Column(children: [
                            CircularProgressIndicator(color: Color(0xFF7C9EBF), strokeWidth: 1.5),
                            SizedBox(height: 16),
                            Text('Analizando con IA...', style: TextStyle(color: Color(0xFF7C9EBF), fontSize: 14, fontWeight: FontWeight.w500)),
                            SizedBox(height: 4),
                            Text('Esto puede tardar unos minutos', style: TextStyle(color: Color(0xFF4A5568), fontSize: 12)),
                          ])
                        : Row(children: [
                            Container(
                              width: 56, height: 56,
                              decoration: BoxDecoration(color: const Color(0x1A7C9EBF), borderRadius: BorderRadius.circular(14)),
                              child: const Icon(Icons.videocam_outlined, color: Color(0xFF7C9EBF), size: 28),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Analizar partido', style: TextStyle(color: Color(0xFFE2E8F4), fontSize: 16, fontWeight: FontWeight.w700)),
                              SizedBox(height: 4),
                              Text('Sube un video y obtén estadísticas en segundos', style: TextStyle(color: Color(0xFF4A5568), fontSize: 12)),
                            ])),
                            const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF2D4A6A), size: 16),
                          ]),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // ── Acciones rápidas ────────────────────────────
                const _SLabel('ACCESO RÁPIDO'),
                const SizedBox(height: 12),
                Row(children: [
                  _QuickAction(icon: Icons.analytics_outlined, label: 'Análisis', onTap: () {}),
                  const SizedBox(width: 10),
                  _QuickAction(icon: Icons.sports_soccer_outlined, label: 'Partidos', onTap: () {}),
                  const SizedBox(width: 10),
                  _QuickAction(icon: Icons.fitness_center_outlined, label: 'Entreno', onTap: () {}),
                ]),

                // ── Último análisis ─────────────────────────────
                if (result != null) ...[
                  const SizedBox(height: 28),
                  const _SLabel('ÚLTIMO ANÁLISIS'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0x0FFFFFFF)),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        const Icon(Icons.auto_awesome_outlined, color: Color(0xFF7C9EBF), size: 16),
                        const SizedBox(width: 8),
                        const Text('Resumen del partido', style: TextStyle(color: Color(0xFFE2E8F4), fontSize: 14, fontWeight: FontWeight.w700)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: const Color(0x1A7C9EBF), borderRadius: BorderRadius.circular(6)),
                          child: const Text('Completado', style: TextStyle(color: Color(0xFF7C9EBF), fontSize: 10, fontWeight: FontWeight.w600)),
                        ),
                      ]),
                      const SizedBox(height: 16),
                      Row(children: [
                        _MiniStat('${result['players_detected']}', 'Jugadores'),
                        _MiniStat('${team?['total_distance_km'] ?? '—'} km', 'Distancia'),
                        _MiniStat('${team?['possession_pct'] ?? 0}%', 'Posesión'),
                      ]),
                      if (topPlayer != null) ...[
                        const SizedBox(height: 14),
                        const Divider(color: Color(0x0FFFFFFF), height: 1),
                        const SizedBox(height: 14),
                        Row(children: [
                          const Icon(Icons.bolt_outlined, color: Color(0xFF7C9EBF), size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Jugador ${topPlayer['rank']} más activo — ${(topPlayer['distance_km'] as num?)?.toStringAsFixed(2)} km',
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                          ),
                        ]),
                      ],
                    ]),
                  ),
                ],

                // ── Equipos ─────────────────────────────────────
                const SizedBox(height: 28),
                Row(children: [
                  const Expanded(child: _SLabel('MIS EQUIPOS')),
                  GestureDetector(
                    onTap: _loadTeams,
                    child: const Text('Recargar', style: TextStyle(color: Color(0xFF4A5568), fontSize: 12)),
                  ),
                ]),
                const SizedBox(height: 12),

                if (loading)
                  const Center(child: CircularProgressIndicator(color: Color(0xFF7C9EBF), strokeWidth: 1.5))
                else if (teams.isEmpty)
                  GestureDetector(
                    onTap: _createDemo,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111827),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0x0FFFFFFF)),
                      ),
                      child: const Column(children: [
                        Icon(Icons.groups_outlined, color: Color(0xFF2D4A6A), size: 36),
                        SizedBox(height: 10),
                        Text('Sin equipos', style: TextStyle(color: Color(0xFF4A5568), fontSize: 13)),
                        SizedBox(height: 4),
                        Text('Toca para crear un equipo demo', style: TextStyle(color: Color(0xFF7C9EBF), fontSize: 12)),
                      ]),
                    ),
                  )
                else
                  ...teams.map((t) => _TeamRow(team: t)),

                const SizedBox(height: 32),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createDemo() async {
    try {
      await _svc.createTeam(name: 'Club Deportivo Pasto', category: 'Juvenil', club: 'PlayVision FC');
      await _loadTeams();
    } catch (_) {}
  }
}

class _SLabel extends StatelessWidget {
  final String text;
  const _SLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(color: Color(0xFF4A5568), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2));
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x0FFFFFFF)),
        ),
        child: Column(children: [
          Icon(icon, color: const Color(0xFF7C9EBF), size: 22),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
        ]),
      ),
    ),
  );
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  const _MiniStat(this.value, this.label);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(children: [
      Text(value, style: const TextStyle(color: Color(0xFFE2E8F4), fontSize: 18, fontWeight: FontWeight.w800)),
      const SizedBox(height: 3),
      Text(label, style: const TextStyle(color: Color(0xFF4A5568), fontSize: 10)),
    ]),
  );
}

class _TeamRow extends StatelessWidget {
  final Map<String, dynamic> team;
  const _TeamRow({required this.team});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFF111827),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0x0FFFFFFF)),
    ),
    child: Row(children: [
      Container(
        width: 38, height: 38,
        decoration: const BoxDecoration(color: Color(0x1A7C9EBF), shape: BoxShape.circle),
        child: const Icon(Icons.groups_outlined, color: Color(0xFF7C9EBF), size: 18),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(team['name'] ?? '—', style: const TextStyle(color: Color(0xFFE2E8F4), fontSize: 14, fontWeight: FontWeight.w600)),
        Text('${team['club'] ?? '—'} · ${team['category'] ?? '—'}',
            style: const TextStyle(color: Color(0xFF4A5568), fontSize: 11)),
      ])),
    ]),
  );
}
