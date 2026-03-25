import 'dart:convert';
import 'dart:ui' as ui;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import '../../../core/store/analysis_store.dart';

const String _apiBase = 'http://127.0.0.1:8000';

// ── Paleta ─────────────────────────────────────────────────────
class _C {
  static const bg      = Color(0xFF0B1120);
  static const s1      = Color(0xFF111827);
  static const s2      = Color(0xFF1C2537);
  static const border  = Color(0x0FFFFFFF);
  static const border2 = Color(0x1AFFFFFF);
  static const text    = Color(0xFFE2E8F4);
  static const muted   = Color(0xFF64748B);
  static const dim     = Color(0xFF4A5568);
  static const accent  = Color(0xFF7C9EBF);
  static const hi      = Color(0xFFBDD4EA);
  static const mid     = Color(0xFF7C9EBF);
  static const lo      = Color(0xFF2D4A6A);
}

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage>
    with SingleTickerProviderStateMixin {
  XFile? videoFile;
  bool isAnalyzing = false;
  Map<String, dynamic>? result;
  late TabController _tabs;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    result = AnalysisStore.instance.lastResult;
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> pickVideo() async {
    final v = await _picker.pickVideo(source: ImageSource.gallery);
    if (v != null) setState(() { videoFile = v; result = null; });
  }

  Future<void> analyzeVideo() async {
    if (videoFile == null) return;
    setState(() => isAnalyzing = true);
    try {
      final bytes   = await videoFile!.readAsBytes();
      final request = http.MultipartRequest('POST', Uri.parse('$_apiBase/analyze'));
      request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: videoFile!.name));
      final streamed = await request.send().timeout(const Duration(minutes: 10));
      final body     = await streamed.stream.bytesToString();
      if (streamed.statusCode == 200) {
        final r = jsonDecode(body) as Map<String, dynamic>;
        AnalysisStore.instance.save(r);
        setState(() { result = r; _tabs.animateTo(0); });
      } else {
        _err('Error ${streamed.statusCode}');
      }
    } catch (e) {
      _err('Sin conexión con el backend.\n$e');
    } finally {
      setState(() => isAnalyzing = false);
    }
  }

  void _err(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: _C.text)),
      backgroundColor: _C.s2,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: _C.border2)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final hasResult = result != null;
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Análisis', style: TextStyle(color: _C.text, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                        SizedBox(height: 3),
                        Text('Rendimiento con IA', style: TextStyle(color: _C.dim, fontSize: 13)),
                      ],
                    ),
                  ),
                  if (!hasResult)
                    GestureDetector(
                      onTap: isAnalyzing ? null : pickVideo,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(color: _C.s2, borderRadius: BorderRadius.circular(10), border: Border.all(color: _C.border2)),
                        child: Row(children: [
                          const Icon(Icons.upload_file_outlined, color: _C.accent, size: 16),
                          const SizedBox(width: 6),
                          Text(videoFile != null ? 'Listo' : 'Subir video', style: const TextStyle(color: _C.text, fontSize: 13, fontWeight: FontWeight.w500)),
                        ]),
                      ),
                    ),
                  if (hasResult) ...[
                    GestureDetector(
                      onTap: () => setState(() { result = null; videoFile = null; }),
                      child: Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(color: _C.s2, borderRadius: BorderRadius.circular(10), border: Border.all(color: _C.border)),
                        child: const Icon(Icons.refresh_outlined, color: _C.accent, size: 18),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            if (hasResult)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Container(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: _C.border))),
                  child: TabBar(
                    controller: _tabs,
                    indicatorColor: _C.hi,
                    indicatorWeight: 1,
                    labelColor: _C.hi,
                    unselectedLabelColor: _C.dim,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, letterSpacing: 1.5),
                    dividerColor: Colors.transparent,
                    tabs: const [Tab(text: 'RESUMEN'), Tab(text: 'CAMPO'), Tab(text: 'JUGADORES'), Tab(text: 'VIDEO')],
                  ),
                ),
              )
            else
              const SizedBox(height: 16),

            Expanded(
              child: hasResult
                  ? TabBarView(controller: _tabs, children: [
                      _ResumenTab(data: result!),
                      _CampoTab(players: result!['players'] as List),
                      _JugadoresTab(players: result!['players'] as List),
                      _VideoTab(videoUrl: result!['video_url'] as String?),
                    ])
                  : _UploadView(
                      videoFile: videoFile,
                      isAnalyzing: isAnalyzing,
                      onPickVideo: pickVideo,
                      onAnalyze: analyzeVideo,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Upload ────────────────────────────────────────────────────

class _UploadView extends StatelessWidget {
  final XFile? videoFile;
  final bool isAnalyzing;
  final VoidCallback onPickVideo;
  final VoidCallback onAnalyze;
  const _UploadView({required this.videoFile, required this.isAnalyzing, required this.onPickVideo, required this.onAnalyze});

  @override
  Widget build(BuildContext context) {
    final has = videoFile != null;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Upload card
          GestureDetector(
            onTap: isAnalyzing ? null : onPickVideo,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: _C.s1,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: has ? _C.border2 : _C.border, width: 1),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(color: const Color(0x1A7C9EBF), shape: BoxShape.circle),
                  child: Icon(has ? Icons.check_circle_outline_rounded : Icons.videocam_outlined,
                      color: _C.accent, size: 30),
                ),
                const SizedBox(height: 16),
                Text(has ? 'Video listo para analizar' : 'Seleccionar video del partido',
                    style: const TextStyle(color: _C.text, fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(has ? videoFile!.name : 'Toca para abrir galería',
                    style: const TextStyle(color: _C.dim, fontSize: 12), textAlign: TextAlign.center),
              ]),
            ),
          ),
          const SizedBox(height: 14),

          // Botón analizar
          GestureDetector(
            onTap: (has && !isAnalyzing) ? onAnalyze : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: has && !isAnalyzing ? _C.s2 : _C.s1,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: has && !isAnalyzing ? _C.border2 : _C.border),
              ),
              alignment: Alignment.center,
              child: isAnalyzing
                  ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: _C.accent, strokeWidth: 1.5)),
                      SizedBox(width: 12),
                      Text('Analizando con IA...', style: TextStyle(color: _C.muted, fontSize: 14)),
                    ])
                  : Text('Iniciar análisis',
                      style: TextStyle(color: has ? _C.text : _C.dim, fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ),

          const SizedBox(height: 32),

          // ¿Cómo funciona?
          const Align(alignment: Alignment.centerLeft,
            child: Text('CÓMO FUNCIONA', style: TextStyle(color: _C.dim, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2))),
          const SizedBox(height: 14),
          _StepCard(n: '1', title: 'Sube el video', desc: 'Selecciona el video del partido desde tu galería'),
          _StepCard(n: '2', title: 'IA analiza', desc: 'YOLO detecta y rastrea a cada jugador en tiempo real'),
          _StepCard(n: '3', title: 'Ve los resultados', desc: 'Obtén estadísticas, mapa de campo e insights automáticos'),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String n;
  final String title;
  final String desc;
  const _StepCard({required this.n, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: _C.s1, borderRadius: BorderRadius.circular(12), border: Border.all(color: _C.border)),
    child: Row(children: [
      Container(
        width: 32, height: 32,
        decoration: BoxDecoration(color: const Color(0x1A7C9EBF), shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Text(n, style: const TextStyle(color: _C.accent, fontWeight: FontWeight.w800, fontSize: 14)),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: _C.text, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 3),
        Text(desc, style: const TextStyle(color: _C.dim, fontSize: 12)),
      ])),
    ]),
  );
}

// ─── Tab 1: Resumen ────────────────────────────────────────────

class _ResumenTab extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ResumenTab({required this.data});

  @override
  Widget build(BuildContext context) {
    final team    = data['team'] as Map<String, dynamic>;
    final players = data['players'] as List;
    final maxKm   = players.fold<double>(0, (p, e) {
      final d = (e['distance_km'] as num?)?.toDouble() ?? 0;
      return d > p ? d : p;
    });

    // Insights automáticos
    final insights = _generateInsights(team, players);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Métricas hero
        Row(children: [
          _BigStat('${data['players_detected']}', 'Jugadores', Icons.groups_outlined),
          const SizedBox(width: 10),
          _BigStat('${team['total_distance_km'] ?? '—'} km', 'Dist. total', Icons.route_outlined),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          _BigStat('${team['avg_distance_km'] ?? '—'} km', 'Dist. media', Icons.person_pin_outlined),
          const SizedBox(width: 10),
          _BigStat('${team['possession_pct'] ?? 0}%', 'Posesión', Icons.sports_soccer_outlined),
        ]),

        const SizedBox(height: 28),

        // Insights IA
        const _SLabel('INSIGHTS IA'),
        const SizedBox(height: 12),
        ...insights.map((i) => _InsightCard(text: i)),

        const SizedBox(height: 28),

        // Distancia por jugador
        const _SLabel('DISTANCIA POR JUGADOR'),
        const SizedBox(height: 12),
        _KmBarChart(players: players, maxKm: maxKm),

        const SizedBox(height: 28),

        // Destacados
        const _SLabel('DESTACADOS'),
        const SizedBox(height: 12),
        _HighRow(icon: Icons.bolt_outlined, label: 'Más activo', value: 'Jugador ${team['most_active'] ?? '—'}'),
        const SizedBox(height: 8),
        _HighRow(icon: Icons.sports_soccer_outlined, label: 'Mayor posesión', value: 'Jugador ${team['most_possession'] ?? '—'}'),
        const SizedBox(height: 8),
        _HighRow(icon: Icons.battery_saver_outlined, label: 'Menos activo', value: 'Jugador ${team['least_active'] ?? '—'}'),
        const SizedBox(height: 20),
      ]),
    );
  }

  List<String> _generateInsights(Map<String, dynamic> team, List players) {
    final insights = <String>[];
    final totalKm = (team['total_distance_km'] as num?)?.toDouble() ?? 0;
    final poss    = (team['possession_pct'] as num?)?.toDouble() ?? 0;
    final count   = (team['players_detected'] as int?) ?? 0;

    if (totalKm > 0) insights.add('El equipo recorrió ${totalKm.toStringAsFixed(2)} km en total durante el análisis.');
    if (poss > 0) insights.add('Posesión del balón: ${poss.toStringAsFixed(1)}% del tiempo analizado.');
    if (count > 0) insights.add('Se detectaron $count jugadores activos en campo.');

    // Jugador más rápido
    if (players.isNotEmpty) {
      final fastest = players.reduce((a, b) =>
          ((a['speed_ms'] as num?) ?? 0) > ((b['speed_ms'] as num?) ?? 0) ? a : b);
      final spd = (fastest['speed_ms'] as num?)?.toDouble() ?? 0;
      if (spd > 0) insights.add('Jugador ${fastest['rank']} alcanzó la mayor velocidad: ${spd.toStringAsFixed(1)} m/s.');

      // Zona predominante del equipo
      final zones = players.map((p) => p['zone'] as String? ?? '').toList();
      final zoneCount = <String, int>{};
      for (final z in zones) { zoneCount[z] = (zoneCount[z] ?? 0) + 1; }
      final topZone = zoneCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      if (topZone.isNotEmpty) insights.add('El equipo se concentró principalmente en la zona $topZone.');
    }

    return insights.take(4).toList();
  }
}

class _BigStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  const _BigStat(this.value, this.label, this.icon);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _C.s1, borderRadius: BorderRadius.circular(14), border: Border.all(color: _C.border)),
      child: Row(children: [
        Icon(icon, color: _C.accent, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: const TextStyle(color: _C.text, fontSize: 18, fontWeight: FontWeight.w800), overflow: TextOverflow.ellipsis),
          Text(label, style: const TextStyle(color: _C.dim, fontSize: 11)),
        ])),
      ]),
    ),
  );
}

class _InsightCard extends StatelessWidget {
  final String text;
  const _InsightCard({required this.text});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0x0A7C9EBF),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0x1A7C9EBF)),
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.auto_awesome_outlined, color: _C.accent, size: 16),
      const SizedBox(width: 10),
      Expanded(child: Text(text, style: const TextStyle(color: _C.text, fontSize: 13, height: 1.5))),
    ]),
  );
}

class _HighRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _HighRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    decoration: BoxDecoration(color: _C.s1, borderRadius: BorderRadius.circular(10), border: Border.all(color: _C.border)),
    child: Row(children: [
      Icon(icon, color: _C.accent, size: 18),
      const SizedBox(width: 12),
      Text(label, style: const TextStyle(color: _C.muted, fontSize: 13)),
      const Spacer(),
      Text(value, style: const TextStyle(color: _C.text, fontSize: 13, fontWeight: FontWeight.w600)),
    ]),
  );
}

class _KmBarChart extends StatelessWidget {
  final List players;
  final double maxKm;
  const _KmBarChart({required this.players, required this.maxKm});

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty || maxKm == 0) return const SizedBox();
    final bars = players.map((p) {
      final km    = (p['distance_km'] as num?)?.toDouble() ?? 0;
      final rank  = p['rank'] as int;
      final ratio = maxKm > 0 ? km / maxKm : 0.0;
      final color = ratio > 0.66 ? _C.hi : ratio > 0.33 ? _C.mid : _C.lo;
      return BarChartGroupData(x: rank, barRods: [BarChartRodData(
        toY: km, color: color, width: 12,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      )]);
    }).toList();

    return Container(
      height: 160,
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
      decoration: BoxDecoration(color: _C.s1, borderRadius: BorderRadius.circular(12), border: Border.all(color: _C.border)),
      child: BarChart(BarChartData(
        maxY: maxKm * 1.2,
        gridData: FlGridData(show: true, drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => const FlLine(color: _C.border, strokeWidth: 1)),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (v, _) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('${v.toInt()}', style: const TextStyle(color: _C.dim, fontSize: 10)),
            ),
          )),
        ),
        barGroups: bars,
      )),
    );
  }
}

// ─── Tab 2: Campo ──────────────────────────────────────────────

class _CampoTab extends StatelessWidget {
  final List players;
  const _CampoTab({required this.players});

  @override
  Widget build(BuildContext context) {
    final maxKm = players.fold<double>(0, (p, e) {
      final d = (e['distance_km'] as num?)?.toDouble() ?? 0;
      return d > p ? d : p;
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _SLabel('POSICIÓN MEDIA EN CAMPO'),
        const SizedBox(height: 14),
        AspectRatio(
          aspectRatio: 1.55,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: CustomPaint(painter: _PitchPainter(players: players.cast(), maxKm: maxKm)),
          ),
        ),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
          _Dot(color: _C.hi, label: 'Alta actividad'),
          SizedBox(width: 20),
          _Dot(color: _C.mid, label: 'Media'),
          SizedBox(width: 20),
          _Dot(color: _C.lo, label: 'Baja'),
        ]),
        const SizedBox(height: 30),
        const _SLabel('ZONAS'),
        const SizedBox(height: 12),
        ...players.map((p) => _ZoneRow(player: p as Map<String, dynamic>)),
      ]),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final String label;
  const _Dot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 6),
    Text(label, style: const TextStyle(color: _C.dim, fontSize: 11)),
  ]);
}

class _ZoneRow extends StatelessWidget {
  final Map<String, dynamic> player;
  const _ZoneRow({required this.player});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(color: _C.s1, borderRadius: BorderRadius.circular(10), border: Border.all(color: _C.border)),
    child: Row(children: [
      SizedBox(width: 28, child: Text('${player['rank']}',
          style: const TextStyle(color: _C.muted, fontSize: 13, fontWeight: FontWeight.w700))),
      const SizedBox(width: 4),
      Text(player['zone'] as String? ?? '—', style: const TextStyle(color: _C.text, fontSize: 13)),
      const Spacer(),
      Text('${player['presence_pct']}%', style: const TextStyle(color: _C.dim, fontSize: 12)),
    ]),
  );
}

class _PitchPainter extends CustomPainter {
  final List<Map<String, dynamic>> players;
  final double maxKm;
  const _PitchPainter({required this.players, required this.maxKm});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width; final h = size.height;
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFF0E1A0E));
    for (int i = 0; i < 10; i++) {
      if (i.isEven) {
        canvas.drawRect(Rect.fromLTWH(i * w / 10, 0, w / 10, h),
            Paint()..color = const Color(0xFF0C180C));
      }
    }
    final line = Paint()..color = Colors.white.withValues(alpha: 0.18)..strokeWidth = 1.0..style = PaintingStyle.stroke;
    canvas.drawRect(Rect.fromLTWH(8, 8, w - 16, h - 16), line);
    canvas.drawLine(Offset(w / 2, 8), Offset(w / 2, h - 8), line);
    canvas.drawCircle(Offset(w / 2, h / 2), h * 0.17, line);
    canvas.drawCircle(Offset(w / 2, h / 2), 2.5, Paint()..color = Colors.white.withValues(alpha: 0.3));
    final paW = w * 0.14; final paH = h * 0.52; final paT = (h - paH) / 2;
    canvas.drawRect(Rect.fromLTWH(8, paT, paW, paH), line);
    canvas.drawRect(Rect.fromLTWH(w - 8 - paW, paT, paW, paH), line);
    final gaW = w * 0.055; final gaH = h * 0.27; final gaT = (h - gaH) / 2;
    canvas.drawRect(Rect.fromLTWH(8, gaT, gaW, gaH), line);
    canvas.drawRect(Rect.fromLTWH(w - 8 - gaW, gaT, gaW, gaH), line);

    for (final p in players) {
      final xN   = (p['avg_x_norm'] as num).toDouble();
      final yN   = (p['avg_y_norm'] as num).toDouble();
      final km   = (p['distance_km'] as num?)?.toDouble() ?? 0;
      final rank = p['rank'] as int;
      final px = xN * w; final py = yN * h;
      final ratio = maxKm > 0 ? km / maxKm : 0.0;
      final color = ratio > 0.66 ? _C.hi : ratio > 0.33 ? _C.mid : _C.lo;
      canvas.drawCircle(Offset(px + 1, py + 2), 14, Paint()..color = Colors.black.withValues(alpha: 0.4));
      canvas.drawCircle(Offset(px, py), 13, Paint()..color = color);
      canvas.drawCircle(Offset(px, py), 13,
          Paint()..color = Colors.white.withValues(alpha: 0.2)..strokeWidth = 1..style = PaintingStyle.stroke);
      final tp = TextPainter(
        text: TextSpan(text: '$rank', style: TextStyle(
            color: ratio > 0.4 ? Colors.black : Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(px - tp.width / 2, py - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}

// ─── Tab 3: Jugadores ──────────────────────────────────────────

class _JugadoresTab extends StatelessWidget {
  final List players;
  const _JugadoresTab({required this.players});

  @override
  Widget build(BuildContext context) => ListView.builder(
    padding: const EdgeInsets.all(20),
    itemCount: players.length + 1,
    itemBuilder: (ctx, i) {
      if (i == 0) return const Padding(padding: EdgeInsets.only(bottom: 16), child: _SLabel('JUGADORES'));
      return _PlayerCard(player: players[i - 1] as Map<String, dynamic>);
    },
  );
}

class _PlayerCard extends StatelessWidget {
  final Map<String, dynamic> player;
  const _PlayerCard({required this.player});

  @override
  Widget build(BuildContext context) {
    final rank    = player['rank'] as int;
    final km      = (player['distance_km'] as num?)?.toDouble() ?? 0;
    final spd     = (player['speed_ms'] as num?)?.toDouble() ?? 0;
    final poss    = (player['possession_pct'] as num).toDouble();
    final presence = (player['presence_pct'] as num).toDouble();

    return GestureDetector(
      onTap: () => _showDetail(context, player),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: _C.s1, borderRadius: BorderRadius.circular(14), border: Border.all(color: _C.border)),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(color: const Color(0x1A7C9EBF), borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.center,
                child: Text('$rank', style: const TextStyle(color: _C.accent, fontWeight: FontWeight.w900, fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Jugador $rank', style: const TextStyle(color: _C.text, fontWeight: FontWeight.w700, fontSize: 14)),
                Text(player['zone'] as String? ?? '—', style: const TextStyle(color: _C.dim, fontSize: 12)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: _C.s2, borderRadius: BorderRadius.circular(8), border: Border.all(color: _C.border2)),
                child: Text('Ver detalle', style: const TextStyle(color: _C.accent, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(value: presence / 100, backgroundColor: _C.border, valueColor: const AlwaysStoppedAnimation<Color>(_C.lo), minHeight: 3),
            ),
          ),
          Container(
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: _C.border))),
            child: Row(children: [
              _SC('DISTANCIA', '${km.toStringAsFixed(2)} km'),
              Container(width: 1, height: 36, color: _C.border),
              _SC('VELOCIDAD', '${spd.toStringAsFixed(1)} m/s'),
              Container(width: 1, height: 36, color: _C.border),
              _SC('POSESIÓN', '$poss%'),
            ]),
          ),
        ]),
      ),
    );
  }

  void _showDetail(BuildContext context, Map<String, dynamic> p) {
    final rank    = p['rank'] as int;
    final km      = (p['distance_km'] as num?)?.toDouble() ?? 0;
    final spd     = (p['speed_ms'] as num?)?.toDouble() ?? 0;
    final poss    = (p['possession_pct'] as num).toDouble();
    final presence = (p['presence_pct'] as num).toDouble();

    showModalBottomSheet(
      context: context,
      backgroundColor: _C.s1,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: const Color(0x1A7C9EBF), borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.center,
              child: Text('$rank', style: const TextStyle(color: _C.accent, fontWeight: FontWeight.w900, fontSize: 22)),
            ),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Jugador $rank', style: const TextStyle(color: _C.text, fontSize: 18, fontWeight: FontWeight.w700)),
              Text(p['zone'] as String? ?? '—', style: const TextStyle(color: _C.dim, fontSize: 13)),
            ]),
          ]),
          const SizedBox(height: 24),
          _DetailRow('Distancia recorrida', '${km.toStringAsFixed(2)} km'),
          _DetailRow('Velocidad media', '${spd.toStringAsFixed(1)} m/s'),
          _DetailRow('Posesión del balón', '$poss%'),
          _DetailRow('Presencia en campo', '$presence%'),
          _DetailRow('Zona predominante', p['zone'] as String? ?? '—'),
          const SizedBox(height: 20),
          // Mini insight del jugador
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0x0A7C9EBF), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0x1A7C9EBF))),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.auto_awesome_outlined, color: _C.accent, size: 16),
              const SizedBox(width: 10),
              Expanded(child: Text(
                km > 0.5
                    ? 'Jugador con alta actividad. Recorrió ${km.toStringAsFixed(2)} km y alcanzó ${spd.toStringAsFixed(1)} m/s de velocidad media.'
                    : 'Jugador con actividad moderada. Mantuvo posición en zona ${p['zone'] ?? '—'}.',
                style: const TextStyle(color: _C.text, fontSize: 13, height: 1.5),
              )),
            ]),
          ),
          const SizedBox(height: 10),
        ]),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(children: [
      Text(label, style: const TextStyle(color: _C.muted, fontSize: 13)),
      const Spacer(),
      Text(value, style: const TextStyle(color: _C.text, fontSize: 13, fontWeight: FontWeight.w600)),
    ]),
  );
}

class _SC extends StatelessWidget {
  final String label;
  final String value;
  const _SC(this.label, this.value);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Padding(padding: const EdgeInsets.symmetric(vertical: 10), child:
      Column(children: [
        Text(label, style: const TextStyle(color: _C.dim, fontSize: 9, letterSpacing: 0.8)),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(color: _C.text, fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    ),
  );
}

// ─── Shared ────────────────────────────────────────────────────

class _SLabel extends StatelessWidget {
  final String text;
  const _SLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(color: _C.dim, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2));
}

// ─── Video Tab ─────────────────────────────────────────────────

class _VideoTab extends StatefulWidget {
  final String? videoUrl;
  const _VideoTab({required this.videoUrl});

  @override
  State<_VideoTab> createState() => _VideoTabState();
}

class _VideoTabState extends State<_VideoTab> {
  VideoPlayerController? _ctrl;
  bool _initialized = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    if (widget.videoUrl != null) {
      _ctrl = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!))
        ..initialize().then((_) {
          if (mounted) setState(() => _initialized = true);
        }).catchError((_) {
          if (mounted) setState(() => _error = true);
        });
    }
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videoUrl == null || _error) {
      return const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.videocam_off_outlined, color: _C.lo, size: 40),
          SizedBox(height: 12),
          Text('Video no disponible', style: TextStyle(color: _C.muted, fontSize: 14)),
        ]),
      );
    }

    if (!_initialized) {
      return const Center(child: CircularProgressIndicator(color: _C.accent, strokeWidth: 2));
    }

    return Column(children: [
      // Player
      Expanded(
        child: Container(
          color: Colors.black,
          child: Center(
            child: AspectRatio(
              aspectRatio: _ctrl!.value.aspectRatio,
              child: VideoPlayer(_ctrl!),
            ),
          ),
        ),
      ),

      // Controles
      Container(
        color: _C.s1,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(children: [
          // Barra de progreso
          VideoProgressIndicator(
            _ctrl!,
            allowScrubbing: true,
            colors: const VideoProgressColors(
              playedColor: _C.accent,
              bufferedColor: _C.s2,
              backgroundColor: _C.lo,
            ),
          ),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            // Retroceder 10s
            IconButton(
              icon: const Icon(Icons.replay_10_rounded, color: _C.muted),
              onPressed: () {
                final pos = _ctrl!.value.position - const Duration(seconds: 10);
                _ctrl!.seekTo(pos < Duration.zero ? Duration.zero : pos);
              },
            ),
            // Play / Pause
            GestureDetector(
              onTap: () => setState(() {
                _ctrl!.value.isPlaying ? _ctrl!.pause() : _ctrl!.play();
              }),
              child: Container(
                width: 52, height: 52,
                decoration: const BoxDecoration(color: _C.accent, shape: BoxShape.circle),
                child: Icon(
                  _ctrl!.value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: _C.bg, size: 28,
                ),
              ),
            ),
            // Adelantar 10s
            IconButton(
              icon: const Icon(Icons.forward_10_rounded, color: _C.muted),
              onPressed: () {
                final pos  = _ctrl!.value.position + const Duration(seconds: 10);
                final max  = _ctrl!.value.duration;
                _ctrl!.seekTo(pos > max ? max : pos);
              },
            ),
          ]),
        ]),
      ),
    ]);
  }
}
