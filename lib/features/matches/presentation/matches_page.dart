import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/supabase/supabase_service.dart';

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
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    int selectedTeamId = teams.first['id'] as int;
    String selectedSourceType = 'upload';

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1A1A),
              title: const Text(
                'Nuevo partido',
                style: TextStyle(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<int>(
                      initialValue: selectedTeamId,
                      dropdownColor: const Color(0xFF1A1A1A),
                      decoration: _inputDecoration('Equipo'),
                      items: teams.map((team) {
                        return DropdownMenuItem<int>(
                          value: team['id'] as int,
                          child: Text(
                            team['name'] ?? 'Sin nombre',
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setLocalState(() => selectedTeamId = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: opponentController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration('Rival'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedSourceType,
                      dropdownColor: const Color(0xFF1A1A1A),
                      decoration: _inputDecoration('Tipo de fuente'),
                      items: const [
                        DropdownMenuItem(
                          value: 'upload',
                          child: Text('Upload', style: TextStyle(color: Colors.white)),
                        ),
                        DropdownMenuItem(
                          value: 'youtube',
                          child: Text('YouTube', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setLocalState(() => selectedSourceType = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Fecha: ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: const Icon(Icons.calendar_today, color: Color(0xFFE84C1E)),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setLocalState(() => selectedDate = picked);
                        }
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Hora: ${selectedTime.format(context)}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: const Icon(Icons.access_time, color: Color(0xFFE84C1E)),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE84C1E),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (opponentController.text.trim().isEmpty) return;

                    final matchDateTime = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );

                    await supabaseService.createMatch(
                      teamId: selectedTeamId,
                      opponent: opponentController.text.trim(),
                      matchDate: matchDateTime,
                      sourceType: selectedSourceType,
                      videoUrl: null,
                      latitude: null,
                      longitude: null,
                    );

                    if (!context.mounted) return;
                    Navigator.pop(context);
                    await loadData();

                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Partido guardado correctamente')),
                    );
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF333333)),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFE84C1E)),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  String formatMatchDate(String value) {
    final date = DateTime.parse(value).toLocal();
    return DateFormat('dd MMM yyyy • HH:mm').format(date);
  }

  Color statusColor(String? status) {
    switch (status) {
      case 'done':
        return const Color(0xFF2ECC71);
      case 'processing':
        return const Color(0xFFFFAA00);
      case 'uploaded':
      default:
        return const Color(0xFF4A90D9);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        title: const Text(
          'PARTIDOS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFE84C1E)),
            onPressed: loadData,
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFFE84C1E)),
            onPressed: openCreateMatchDialog,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: const Color(0xFFE84C1E)),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : matches.isEmpty
              ? const Center(
                  child: Text(
                    'No hay partidos guardados todavía',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const _SectionLabel('PARTIDOS REGISTRADOS'),
                    const SizedBox(height: 12),
                    ...matches.map((match) {
                      final team = match['teams'];
                      final teamName = team is Map ? (team['name'] ?? 'Sin equipo') : 'Sin equipo';

                      return _MatchCard(
                        rival: match['opponent'] ?? 'Sin rival',
                        date: formatMatchDate(match['match_date']),
                        time: teamName,
                        location: (match['source_type'] ?? 'Sin fuente').toString(),
                        statusText: statusLabel(match['status']),
                        statusColor: statusColor(match['status']),
                      );
                    }),
                  ],
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
        color: Color(0xFF888888),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final String rival;
  final String date;
  final String time;
  final String location;
  final String statusText;
  final Color statusColor;

  const _MatchCard({
    required this.rival,
    required this.date,
    required this.time,
    required this.location,
    required this.statusText,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF222222)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rival,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 12, color: Color(0xFF888888)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        date,
                        style: const TextStyle(
                          color: Color(0xFF888888),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.groups_2_outlined,
                        size: 12, color: Color(0xFF888888)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        time,
                        style: const TextStyle(
                          color: Color(0xFF888888),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.video_collection_outlined,
                        size: 12, color: Color(0xFF888888)),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: const TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
