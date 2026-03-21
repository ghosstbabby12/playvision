import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/supabase/supabase_service.dart';

class MatchDetailPage extends StatefulWidget {
  final int matchId;

  const MatchDetailPage({
    super.key,
    required this.matchId,
  });

  @override
  State<MatchDetailPage> createState() => _MatchDetailPageState();
}

class _MatchDetailPageState extends State<MatchDetailPage> {
  final SupabaseService supabaseService = SupabaseService();

  Map<String, dynamic>? match;
  List<Map<String, dynamic>> playerStats = [];
  List<Map<String, dynamic>> recommendations = [];

  bool isLoading = true;
  bool generatingFake = false;

  @override
  void initState() {
    super.initState();
    loadMatchDetail();
  }

  Future<void> loadMatchDetail() async {
    setState(() => isLoading = true);

    try {
      final matchData = await supabaseService.getMatchById(widget.matchId);
      final statsData = await supabaseService.getPlayerMatchStats(widget.matchId);
      final recommendationsData =
          await supabaseService.getRecommendationsByMatch(widget.matchId);

      if (!mounted) return;

      setState(() {
        match = matchData;
        playerStats = statsData;
        recommendations = recommendationsData;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando detalle del partido: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> generateFakeAnalysis() async {
    if (generatingFake) return;

    setState(() => generatingFake = true);

    try {
      await supabaseService.insertFakeAnalysisForMatch(widget.matchId);
      await loadMatchDetail();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Análisis fake generado correctamente'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generando análisis fake: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => generatingFake = false);
      }
    }
  }

  String formatMatchDate(String? value) {
    if (value == null || value.isEmpty) return 'Sin fecha';
    final date = DateTime.parse(value).toLocal();
    return DateFormat('dd MMM yyyy • HH:mm').format(date);
  }

  String statusLabel(String? status) {
    switch (status) {
      case 'done':
        return 'Analizado';
      case 'processing':
        return 'Procesando';
      case 'uploaded':
        return 'Cargado';
      default:
        return 'Sin estado';
    }
  }

  Color statusColor(String? status) {
    switch (status) {
      case 'done':
        return const Color(0xFF2ECC71);
      case 'processing':
        return const Color(0xFFFFAA00);
      case 'uploaded':
        return const Color(0xFF4A90D9);
      default:
        return const Color(0xFF888888);
    }
  }

  String sourceLabel(String? sourceType) {
    switch (sourceType) {
      case 'youtube':
        return 'YouTube';
      case 'external':
        return 'Link externo';
      case 'upload':
        return 'Upload';
      default:
        return 'Sin fuente';
    }
  }

  bool hasVideoUrl() {
    final videoUrl = match?['video_url'];
    return videoUrl != null && videoUrl.toString().trim().isNotEmpty;
  }

  Widget sectionTitle(String text) {
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

  Widget infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 15,
          color: const Color(0xFF888888),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFFDDDDDD),
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final team = match?['teams'];
    final teamName =
        team is Map ? (team['name'] ?? 'Sin equipo') : 'Sin equipo';

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        title: const Text(
          'DETALLE DEL PARTIDO',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            fontSize: 15,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Color(0xFFE84C1E),
            ),
            onPressed: loadMatchDetail,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(
            height: 3,
            color: const Color(0xFFE84C1E),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : match == null
              ? const Center(
                  child: Text(
                    'No se encontró el partido',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      sectionTitle('RESUMEN'),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF222222)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${match?['opponent'] ?? 'Sin rival'}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 12),
                            infoRow(
                              Icons.groups_2_outlined,
                              teamName,
                            ),
                            const SizedBox(height: 8),
                            infoRow(
                              Icons.calendar_today,
                              formatMatchDate(match?['match_date']),
                            ),
                            const SizedBox(height: 8),
                            infoRow(
                              Icons.link,
                              sourceLabel(match?['source_type']),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor(match?['status'])
                                        .withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    statusLabel(match?['status']),
                                    style: TextStyle(
                                      color: statusColor(match?['status']),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: hasVideoUrl()
                                        ? const Color(0xFF2ECC71)
                                            .withOpacity(0.15)
                                        : const Color(0xFF888888)
                                            .withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    hasVideoUrl()
                                        ? 'Video asociado'
                                        : 'Sin video asociado',
                                    style: TextStyle(
                                      color: hasVideoUrl()
                                          ? const Color(0xFF2ECC71)
                                          : const Color(0xFFAAAAAA),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: generatingFake ? null : generateFakeAnalysis,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE84C1E),
                          disabledBackgroundColor: const Color(0xFF333333),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          generatingFake
                              ? 'GENERANDO ANÁLISIS...'
                              : 'GENERAR ANÁLISIS FAKE',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      sectionTitle('VIDEO'),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF222222)),
                        ),
                        child: hasVideoUrl()
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'URL del video',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SelectableText(
                                    match!['video_url'].toString(),
                                    style: const TextStyle(
                                      color: Color(0xFFCCCCCC),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              )
                            : const Text(
                                'Todavía no hay una fuente de video asociada a este partido.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                      ),
                      const SizedBox(height: 20),
                      sectionTitle('ESTADÍSTICAS'),
                      const SizedBox(height: 12),
                      if (playerStats.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF222222)),
                          ),
                          child: const Text(
                            'Aún no hay estadísticas generadas para este partido.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      else
                        ...playerStats.map((stat) {
                          final player = stat['players'];
                          final playerName = player is Map
                              ? (player['name'] ?? 'Jugador').toString()
                              : 'Jugador';
                          final position = player is Map
                              ? (player['position'] ?? 'Sin posición').toString()
                              : 'Sin posición';
                          final shirtNumber =
                              player is Map ? player['shirt_number'] : null;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(8),
                              border:
                                  Border.all(color: const Color(0xFF222222)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  shirtNumber != null
                                      ? '$playerName • #$shirtNumber'
                                      : playerName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  position,
                                  style: const TextStyle(
                                    color: Color(0xFFAAAAAA),
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _StatChip(
                                      label: 'Min',
                                      value: '${stat['minutes'] ?? 0}',
                                    ),
                                    _StatChip(
                                      label: 'Distancia',
                                      value: '${stat['distance'] ?? 0}',
                                    ),
                                    _StatChip(
                                      label: 'Pases OK',
                                      value: '${stat['passes_ok'] ?? 0}',
                                    ),
                                    _StatChip(
                                      label: 'Pases mal',
                                      value: '${stat['passes_bad'] ?? 0}',
                                    ),
                                    _StatChip(
                                      label: 'Pérdidas',
                                      value: '${stat['losses'] ?? 0}',
                                    ),
                                    _StatChip(
                                      label: 'Recuperaciones',
                                      value: '${stat['recoveries'] ?? 0}',
                                    ),
                                    _StatChip(
                                      label: 'Tiros',
                                      value: '${stat['shots'] ?? 0}',
                                    ),
                                    _StatChip(
                                      label: 'Al arco',
                                      value: '${stat['shots_on_target'] ?? 0}',
                                    ),
                                    _StatChip(
                                      label: 'Rating',
                                      value: '${stat['rating'] ?? 0}',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                      const SizedBox(height: 20),
                      sectionTitle('RECOMENDACIONES'),
                      const SizedBox(height: 12),
                      if (recommendations.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF222222)),
                          ),
                          child: const Text(
                            'Todavía no hay recomendaciones para este partido.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      else
                        ...recommendations.map((item) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(8),
                              border:
                                  Border.all(color: const Color(0xFF222222)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (item['title'] ?? 'Recomendación').toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  (item['description'] ?? '').toString(),
                                  style: const TextStyle(
                                    color: Color(0xFFCCCCCC),
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _MiniTag(
                                      text: (item['scope'] ?? 'general')
                                          .toString(),
                                      color: const Color(0xFF4A90D9),
                                    ),
                                    _MiniTag(
                                      text: (item['priority'] ?? 'media')
                                          .toString(),
                                      color: const Color(0xFFE84C1E),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                color: Color(0xFF888888),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  final String text;
  final Color color;

  const _MiniTag({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
