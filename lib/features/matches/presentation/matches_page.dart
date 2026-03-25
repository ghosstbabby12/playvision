import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/supabase/supabase_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/app_routes.dart';
import 'match_detail_page.dart';

class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  final SupabaseService supabaseService = SupabaseService();

  List<Map<String, dynamic>> matches = [];
  List<Map<String, dynamic>> teams = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);

    try {
      final teamsData = await supabaseService.getTeams();
      final matchesData = await supabaseService.getMatches();

      if (!mounted) return;

      setState(() {
        teams = teamsData;
        matches = matchesData;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando datos: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> openCreateMatchDialog() async {
    if (teams.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero crea al menos un equipo en la base de datos.'),
        ),
      );
      return;
    }

    final opponentController = TextEditingController();
    final sourceUrlController = TextEditingController();

    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    int selectedTeamId = teams.first['id'] as int;
    String selectedSourceType = 'upload';

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setLocalState) {
            final bool needsUrl =
                selectedSourceType == 'youtube' ||
                selectedSourceType == 'external';

            return AlertDialog(
              backgroundColor: AppColors.card,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: const BorderSide(color: AppColors.border),
              ),
              titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              contentPadding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Nuevo partido',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Registra el partido y define la fuente inicial del video.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      value: selectedTeamId,
                      dropdownColor: AppColors.surface,
                      style: const TextStyle(color: AppColors.textPrimary),
                      iconEnabledColor: AppColors.accent,
                      decoration: _inputDecoration('Equipo'),
                      items: teams.map((team) {
                        return DropdownMenuItem<int>(
                          value: team['id'] as int,
                          child: Text(
                            (team['name'] ?? 'Sin nombre').toString(),
                            style:
                                const TextStyle(color: AppColors.textPrimary),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setLocalState(() => selectedTeamId = value);
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: opponentController,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: _inputDecoration('Rival'),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: selectedSourceType,
                      dropdownColor: AppColors.surface,
                      style: const TextStyle(color: AppColors.textPrimary),
                      iconEnabledColor: AppColors.accent,
                      decoration: _inputDecoration('Tipo de fuente inicial'),
                      items: const [
                        DropdownMenuItem(
                          value: 'upload',
                          child: Text(
                            'Upload (recomendado)',
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'youtube',
                          child: Text(
                            'YouTube (beta)',
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'external',
                          child: Text(
                            'Link externo (beta)',
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setLocalState(() {
                            selectedSourceType = value;
                            if (selectedSourceType == 'upload') {
                              sourceUrlController.clear();
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        selectedSourceType == 'upload'
                            ? 'Recomendado para la versión final de la app.'
                            : selectedSourceType == 'youtube'
                                ? 'Modo beta: puede requerir configuración adicional del backend.'
                                : 'Modo beta: usa una URL pública directa del video.',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          height: 1.45,
                        ),
                      ),
                    ),
                    if (needsUrl) ...[
                      const SizedBox(height: 14),
                      TextField(
                        controller: sourceUrlController,
                        keyboardType: TextInputType.url,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: _inputDecoration(
                          selectedSourceType == 'youtube'
                              ? 'URL de YouTube'
                              : 'URL externa',
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    _PickerTile(
                      icon: Icons.calendar_today_rounded,
                      title:
                          'Fecha: ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: dialogContext,
                          initialDate: selectedDate,
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2030),
                        );

                        if (picked != null) {
                          setLocalState(() => selectedDate = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    _PickerTile(
                      icon: Icons.access_time_rounded,
                      title: 'Hora: ${selectedTime.format(dialogContext)}',
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: dialogContext,
                          initialTime: selectedTime,
                        );

                        if (picked != null) {
                          setLocalState(() => selectedTime = picked);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    if (opponentController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text('Debes ingresar el rival'),
                        ),
                      );
                      return;
                    }

                    final bool needsUrl =
                        selectedSourceType == 'youtube' ||
                        selectedSourceType == 'external';

                    final sourceUrl = sourceUrlController.text.trim();

                    if (needsUrl && sourceUrl.isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text(
                            selectedSourceType == 'youtube'
                                ? 'Debes ingresar la URL de YouTube'
                                : 'Debes ingresar la URL externa',
                          ),
                        ),
                      );
                      return;
                    }

                    if (needsUrl &&
                        !(sourceUrl.startsWith('http://') ||
                            sourceUrl.startsWith('https://'))) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'La URL debe comenzar con http:// o https://',
                          ),
                        ),
                      );
                      return;
                    }

                    final matchDateTime = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );

                    try {
                      await supabaseService.createMatch(
                        teamId: selectedTeamId,
                        opponent: opponentController.text.trim(),
                        matchDate: matchDateTime,
                        sourceType: selectedSourceType,
                        videoUrl: null,
                        sourceUrl: needsUrl ? sourceUrl : null,
                        latitude: null,
                        longitude: null,
                      );

                      if (!dialogContext.mounted) return;
                      Navigator.of(dialogContext).pop();

                      await loadData();

                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Partido guardado correctamente'),
                        ),
                      );
                    } catch (e) {
                      if (!dialogContext.mounted) return;
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text('Error guardando partido: $e'),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Guardar',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    opponentController.dispose();
    sourceUrlController.dispose();
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.surface,
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        borderRadius: BorderRadius.circular(14),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.danger),
        borderRadius: BorderRadius.circular(14),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.danger, width: 1.4),
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  String formatMatchDate(String value) {
    final date = DateTime.parse(value).toLocal();
    return DateFormat('dd MMM yyyy • HH:mm').format(date);
  }

  String resolveMatchDate(Map<String, dynamic> match) {
    final raw = match['match_date'] ?? match['matchdate'];
    return (raw ?? DateTime.now().toIso8601String()).toString();
  }

  Color statusColor(String? status) {
    switch (status) {
      case 'done':
        return AppColors.success;
      case 'processing':
        return AppColors.warning;
      case 'uploaded':
      default:
        return AppColors.accent;
    }
  }

  String statusLabel(String? status) {
    switch (status) {
      case 'done':
        return 'Analizado';
      case 'processing':
        return 'Procesando';
      case 'uploaded':
      default:
        return 'Cargado';
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

  bool hasAssociatedSource(Map<String, dynamic> match) {
    final videoUrl =
        (match['video_url'] ?? match['videourl'] ?? '').toString().trim();
    final sourceUrl =
        (match['source_url'] ?? match['sourceurl'] ?? '').toString().trim();
    return videoUrl.isNotEmpty || sourceUrl.isNotEmpty;
  }

  String associatedSourceLabel(Map<String, dynamic> match) {
    final videoUrl =
        (match['video_url'] ?? match['videourl'] ?? '').toString().trim();
    final sourceUrl =
        (match['source_url'] ?? match['sourceurl'] ?? '').toString().trim();

    if (sourceUrl.isNotEmpty) return 'Fuente asociada';
    if (videoUrl.isNotEmpty) return 'Video asociado';
    return 'Sin fuente asociada';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        centerTitle: true,
        title: const Text(
          'PARTIDOS',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.analytics_outlined,
              color: AppColors.accent,
            ),
            tooltip: 'Ver resumen del análisis',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.matchSummary);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.accent),
            onPressed: loadData,
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.primary),
            onPressed: openCreateMatchDialog,
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
          : RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.card,
              onRefresh: loadData,
              child: matches.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.all(18),
                      children: [
                        _AnalysisSummaryButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.matchSummary,
                            );
                          },
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.sports_soccer_rounded,
                                color: AppColors.textMuted,
                                size: 42,
                              ),
                              SizedBox(height: 14),
                              Text(
                                'No hay partidos guardados todavía',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Crea el primero para comenzar a cargar fuentes de video y análisis.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView(
                      padding: const EdgeInsets.all(18),
                      children: [
                        _AnalysisSummaryButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.matchSummary,
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        const _SectionLabel('PARTIDOS REGISTRADOS'),
                        const SizedBox(height: 12),
                        ...matches.map((match) {
                          final team = match['teams'];
                          final teamName = team is Map
                              ? (team['name'] ?? 'Sin equipo').toString()
                              : 'Sin equipo';

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MatchDetailPage(
                                    matchId: match['id'] as int,
                                  ),
                                ),
                              );
                            },
                            child: _MatchCard(
                              rival: (match['opponent'] ?? 'Sin rival')
                                  .toString(),
                              date: formatMatchDate(resolveMatchDate(match)),
                              teamName: teamName,
                              sourceText: sourceLabel(
                                (match['source_type'] ?? match['sourcetype'])
                                    ?.toString(),
                              ),
                              statusText:
                                  statusLabel(match['status']?.toString()),
                              statusColor:
                                  statusColor(match['status']?.toString()),
                              hasSource: hasAssociatedSource(match),
                              sourceAssociationText:
                                  associatedSourceLabel(match),
                            ),
                          );
                        }),
                        const SizedBox(height: 10),
                      ],
                    ),
            ),
    );
  }
}

class _AnalysisSummaryButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _AnalysisSummaryButton({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onPressed,
          child: const Padding(
            padding: EdgeInsets.all(18),
            child: Row(
              children: [
                Icon(Icons.analytics_rounded, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ver resumen del análisis IA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white, size: 16),
              ],
            ),
          ),
        ),
      ),
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
        color: AppColors.textMuted,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.8,
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _PickerTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final String rival;
  final String date;
  final String teamName;
  final String sourceText;
  final String statusText;
  final Color statusColor;
  final bool hasSource;
  final String sourceAssociationText;

  const _MatchCard({
    required this.rival,
    required this.date,
    required this.teamName,
    required this.sourceText,
    required this.statusText,
    required this.statusColor,
    required this.hasSource,
    required this.sourceAssociationText,
  });

  @override
  Widget build(BuildContext context) {
    final sourceColor =
        hasSource ? AppColors.success : AppColors.textMuted;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rival,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                _InfoRow(
                  icon: Icons.calendar_today_rounded,
                  text: date,
                ),
                const SizedBox(height: 6),
                _InfoRow(
                  icon: Icons.groups_2_outlined,
                  text: teamName,
                ),
                const SizedBox(height: 6),
                _InfoRow(
                  icon: Icons.link_rounded,
                  text: sourceText,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      hasSource
                          ? Icons.check_circle_rounded
                          : Icons.cancel_outlined,
                      size: 15,
                      color: sourceColor,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        sourceAssociationText,
                        style: TextStyle(
                          color: sourceColor,
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
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.14),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: statusColor.withOpacity(0.24),
              ),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: AppColors.textMuted,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
