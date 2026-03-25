import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

// ⚠️ Si usas celular físico cambia esta IP por la de tu Mac (ifconfig)
const String _apiBase = 'http://127.0.0.1:8000';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  XFile? videoFile;
  bool isAnalyzing = false;
  Map<String, dynamic>? result;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        videoFile = video;
        result = null;
      });
    }
  }

  Future<void> analyzeVideo() async {
    if (videoFile == null) return;
    setState(() => isAnalyzing = true);

    try {
      final bytes = await videoFile!.readAsBytes();
      final filename = videoFile!.name;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_apiBase/analyze'),
      );
      request.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: filename),
      );

      final streamed = await request.send().timeout(
        const Duration(minutes: 10),
      );
      final body = await streamed.stream.bytesToString();

      if (streamed.statusCode == 200) {
        setState(() => result = jsonDecode(body) as Map<String, dynamic>);
      } else {
        _showError('Error del servidor: ${streamed.statusCode}');
      }
    } catch (e) {
      _showError('No se pudo conectar con el backend.\n$e');
    } finally {
      setState(() => isAnalyzing = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red[800]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        title: const Text(
          'ANÁLISIS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: const Color(0xFFE84C1E)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),

            // ── Selector de video ──────────────────────────────
            GestureDetector(
              onTap: isAnalyzing ? null : pickVideo,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: videoFile != null
                        ? const Color(0xFFE84C1E)
                        : const Color(0xFF333333),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      videoFile != null ? Icons.check_circle : Icons.upload_file,
                      color: const Color(0xFFE84C1E),
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      videoFile != null ? 'Video cargado' : 'Subir video del partido',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      videoFile != null
                          ? videoFile!.name
                          : 'Toca para seleccionar desde galería',
                      style: const TextStyle(color: Color(0xFF888888), fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Botón analizar ─────────────────────────────────
            ElevatedButton(
              onPressed: (videoFile != null && !isAnalyzing) ? analyzeVideo : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE84C1E),
                disabledBackgroundColor: const Color(0xFF333333),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                elevation: 0,
              ),
              child: isAnalyzing
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text('ANALIZANDO...', style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                      ],
                    )
                  : const Text(
                      'INICIAR ANÁLISIS',
                      style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
            ),

            // ── Resultados ─────────────────────────────────────
            if (result != null) ...[
              const SizedBox(height: 32),
              _ResultsView(data: result!),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Vista de resultados ────────────────────────────────────────

class _ResultsView extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ResultsView({required this.data});

  @override
  Widget build(BuildContext context) {
    final team = data['team'] as Map<String, dynamic>;
    final players = data['players'] as List<dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Resumen equipo
        _SectionLabel('RESUMEN DEL EQUIPO'),
        const SizedBox(height: 12),
        _StatGrid(items: [
          _StatItem('Jugadores', '${data['players_detected']}'),
          _StatItem('Distancia total', '${team['total_distance']} px'),
          _StatItem('Dist. media/jugador', '${team['avg_distance']} px'),
          _StatItem('Posesión equipo', '${team['possession_pct']}%'),
          _StatItem('Más activo', 'Jugador ${team['most_active'] ?? '-'}'),
          _StatItem('Más posesión', 'Jugador ${team['most_possession'] ?? '-'}'),
        ]),

        const SizedBox(height: 28),
        _SectionLabel('ANÁLISIS POR JUGADOR'),
        const SizedBox(height: 12),

        ...players.map((p) => _PlayerCard(player: p as Map<String, dynamic>)),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF888888),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  final List<_StatItem> items;
  const _StatGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.4,
      children: items.map((item) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF222222)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(item.label,
                  style: const TextStyle(color: Color(0xFF888888), fontSize: 10)),
              const SizedBox(height: 4),
              Text(item.value,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  const _StatItem(this.label, this.value);
}

class _PlayerCard extends StatelessWidget {
  final Map<String, dynamic> player;
  const _PlayerCard({required this.player});

  @override
  Widget build(BuildContext context) {
    final poss = (player['possession_pct'] as num).toDouble();
    final possColor = poss > 5
        ? const Color(0xFF2ECC71)
        : poss > 1
            ? const Color(0xFFFFAA00)
            : const Color(0xFF4A90D9);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF222222)),
      ),
      child: Row(
        children: [
          // Número
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFE84C1E).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(
              '${player['rank']}',
              style: const TextStyle(
                  color: Color(0xFFE84C1E), fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ),
          const SizedBox(width: 14),
          // Stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jugador ${player['rank']}',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Zona: ${player['zone']}  •  Presencia: ${player['presence_pct']}%',
                  style: const TextStyle(color: Color(0xFF888888), fontSize: 11),
                ),
                Text(
                  'Dist: ${player['total_distance']} px  •  Vel: ${player['avg_speed']} px/f',
                  style: const TextStyle(color: Color(0xFF888888), fontSize: 11),
                ),
              ],
            ),
          ),
          // Posesión badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: possColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${player['possession_pct']}%',
              style: TextStyle(
                  color: possColor, fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
