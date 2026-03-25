import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/supabase/supabase_service.dart';
import '../../../core/theme/app_colors.dart';

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
        return AppColors.success;
      case 'processing':
        return AppColors.warning;
      case 'uploaded':
        return AppColors.accent;
      default:
        return AppColors.textMuted;
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

  String resolveMatchDate() {
    final raw = match?['match_date'] ?? match?['matchdate'];
    return raw?.toString() ?? '';
  }

  String resolveSourceType() {
    return (match?['source_type'] ?? match?['sourcetype'] ?? '').toString();
  }

  String resolveStatus() {
    return (match?['status'] ?? '').toString();
  }

  String? resolveVideoUrl() {
    final value = (match?['video_url'] ?? match?['videourl'])?.toString().trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  String? resolveSourceUrl() {
    final value =
        (match?['source_url'] ?? match?['sourceurl'])?.toString().trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  bool hasVideoUrl() => resolveVideoUrl() != null;

  bool hasSourceUrl() => resolveSourceUrl() != null;

  bool hasAnyAssociatedSource() => hasVideoUrl() || hasSourceUrl();

  Widget sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.8,
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
          color: AppColors.textMuted,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.45,
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
        team is Map ? (team['name'] ?? 'Sin equipo').toString() : 'Sin equipo';
    final currentStatus = resolveStatus();
    final currentStatusColor = statusColor(currentStatus);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        centerTitle: true,
        title: const Text(
          'DETALLE DEL PARTIDO',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.4,
            fontSize: 15,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.accent,
            ),
            onPressed: loadMatchDetail,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(
            height: 3,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : match == null
              ? Center(
                  child: Container(
                    margin: const EdgeInsets.all(18),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Text(
                      'No se encontró el partido',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.card,
                  onRefresh: loadMatchDetail,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        sectionTitle('RESUMEN'),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: AppColors.heroGradient,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.border),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.10),
                                blurRadius: 22,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      gradient: AppColors.primaryGradient,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      Icons.sports_soccer_rounded,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      '${match?['opponent'] ?? 'Sin rival'}',
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 21,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              infoRow(Icons.groups_2_outlined, teamName),
                              const SizedBox(height: 8),
                              infoRow(
                                Icons.calendar_today_rounded,
                                formatMatchDate(resolveMatchDate()),
                              ),
                              const SizedBox(height: 8),
                              infoRow(
                                Icons.link_rounded,
                                sourceLabel(resolveSourceType()),
                              ),
                              const SizedBox(height: 14),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: currentStatusColor.withValues(
                                        alpha: 0.14,
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: currentStatusColor.withValues(
                                          alpha: 0.20,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      statusLabel(currentStatus),
                                      style: TextStyle(
                                        color: currentStatusColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: (hasAnyAssociatedSource()
                                              ? AppColors.success
                                              : AppColors.textMuted)
                                          .withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: (hasAnyAssociatedSource()
                                                ? AppColors.success
                                                : AppColors.textMuted)
                                            .withValues(alpha: 0.20),
                                      ),
                                    ),
                                    child: Text(
                                      hasAnyAssociatedSource()
                                          ? 'Fuente asociada'
                                          : 'Sin fuente asociada',
                                      style: TextStyle(
                                        color: hasAnyAssociatedSource()
                                            ? AppColors.success
                                            : AppColors.textSecondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: generatingFake ? null : generateFakeAnalysis,
                          icon: generatingFake
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.auto_awesome_rounded),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor: AppColors.border,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          label: Text(
                            generatingFake
                                ? 'GENERANDO ANÁLISIS...'
                                : 'GENERAR ANÁLISIS FAKE',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        sectionTitle('VIDEO'),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (hasSourceUrl()) ...[
                                const Text(
                                  'Fuente registrada',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SelectableText(
                                  resolveSourceUrl()!,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 14),
                              ],
                              if (hasVideoUrl()) ...[
                                const Text(
                                  'URL del video',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SelectableText(
                                  resolveVideoUrl()!,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                              if (!hasSourceUrl() && !hasVideoUrl())
                                const Text(
                                  'Todavía no hay una fuente de video asociada a este partido.',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        sectionTitle('ESTADÍSTICAS'),
                        const SizedBox(height: 12),
                        if (playerStats.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Text(
                              'Aún no hay estadísticas generadas para este partido.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          )
                        else
                          ...playerStats.map((stat) {
                            final player = stat['players'];
                            final playerName = player is Map
                                ? (player['name'] ?? 'Jugador').toString()
                                : 'Jugador';
                            final position = player is Map
                                ? (player['position'] ?? 'Sin posición')
                                    .toString()
                                : 'Sin posición';
                            final shirtNumber = player is Map
                                ? (player['shirt_number'] ??
                                        player['shirtnumber'])
                                    ?.toString()
                                : null;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    shirtNumber != null &&
                                            shirtNumber.trim().isNotEmpty
                                        ? '$playerName • #$shirtNumber'
                                        : playerName,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    position,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
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
                                        value: '${stat['passes_ok'] ?? stat['passesok'] ?? 0}',
                                      ),
                                      _StatChip(
                                        label: 'Pases mal',
                                        value: '${stat['passes_bad'] ?? stat['passesbad'] ?? 0}',
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
                                        value: '${stat['shots_on_target'] ?? stat['shotsontarget'] ?? 0}',
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
                        const SizedBox(height: 22),
                        sectionTitle('RECOMENDACIONES'),
                        const SizedBox(height: 12),
                        if (recommendations.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Text(
                              'Todavía no hay recomendaciones para este partido.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          )
                        else
                          ...recommendations.map((item) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 14),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (item['title'] ?? 'Recomendación')
                                        .toString(),
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    (item['description'] ?? '').toString(),
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _MiniTag(
                                        text: (item['scope'] ?? 'general')
                                            .toString(),
                                        color: AppColors.accent,
                                      ),
                                      _MiniTag(
                                        text: (item['priority'] ?? 'media')
                                            .toString(),
                                        color: AppColors.primary,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                        const SizedBox(height: 8),
                      ],
                    ),
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: 0.20),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
