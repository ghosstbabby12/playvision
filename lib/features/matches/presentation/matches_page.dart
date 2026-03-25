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
      final teamsData   = await supabaseService.getTeams();
      final matchesData = await supabaseService.getMatches();
      if (!mounted) return;
      setState(() { teams = teamsData; matches = matchesData; });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: const Color(0xFF1C2537)),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> openCreateMatchDialog() async {
    if (teams.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero crea al menos un equipo.'), backgroundColor: Color(0xFF1C2537)),
      );
      return;
    }

    final opponentController = TextEditingController();
    DateTime selectedDate    = DateTime.now();
    TimeOfDay selectedTime   = TimeOfDay.now();
    int selectedTeamId       = teams.first['id'] as int;
    String selectedSourceType = 'upload';

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLS) => AlertDialog(
          backgroundColor: const Color(0xFF111827),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Nuevo partido', style: TextStyle(color: Color(0xFFE2E8F4), fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: selectedTeamId,
                  dropdownColor: const Color(0xFF1C2537),
                  decoration: _dec('Equipo'),
                  style: const TextStyle(color: Color(0xFFE2E8F4)),
                  items: teams.map((t) => DropdownMenuItem<int>(
                    value: t['id'] as int,
                    child: Text(t['name'] ?? '—', style: const TextStyle(color: Color(0xFFE2E8F4))),
                  )).toList(),
                  onChanged: (v) { if (v != null) setLS(() => selectedTeamId = v); },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: opponentController,
                  style: const TextStyle(color: Color(0xFFE2E8F4)),
                  decoration: _dec('Rival'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedSourceType,
                  dropdownColor: const Color(0xFF1C2537),
                  decoration: _dec('Fuente de video'),
                  style: const TextStyle(color: Color(0xFFE2E8F4)),
                  items: const [
                    DropdownMenuItem(value: 'upload', child: Text('Upload', style: TextStyle(color: Color(0xFFE2E8F4)))),
                    DropdownMenuItem(value: 'youtube', child: Text('YouTube', style: TextStyle(color: Color(0xFFE2E8F4)))),
                  ],
                  onChanged: (v) { if (v != null) setLS(() => selectedSourceType = v); },
                ),
                const SizedBox(height: 4),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Fecha: ${DateFormat('dd/MM/yyyy').format(selectedDate)}',
                      style: const TextStyle(color: Color(0xFFE2E8F4), fontSize: 14)),
                  trailing: const Icon(Icons.calendar_today_outlined, color: Color(0xFF7C9EBF), size: 18),
                  onTap: () async {
                    final p = await showDatePicker(
                      context: context, initialDate: selectedDate,
                      firstDate: DateTime(2024), lastDate: DateTime(2030),
                    );
                    if (p != null) setLS(() => selectedDate = p);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Hora: ${selectedTime.format(context)}',
                      style: const TextStyle(color: Color(0xFFE2E8F4), fontSize: 14)),
                  trailing: const Icon(Icons.access_time_outlined, color: Color(0xFF7C9EBF), size: 18),
                  onTap: () async {
                    final p = await showTimePicker(context: context, initialTime: selectedTime);
                    if (p != null) setLS(() => selectedTime = p);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Color(0xFF4A5568))),
            ),
            GestureDetector(
              onTap: () async {
                if (opponentController.text.trim().isEmpty) return;
                final dt = DateTime(selectedDate.year, selectedDate.month, selectedDate.day,
                    selectedTime.hour, selectedTime.minute);
                await supabaseService.createMatch(
                  teamId: selectedTeamId, opponent: opponentController.text.trim(),
                  matchDate: dt, sourceType: selectedSourceType,
                  videoUrl: null, latitude: null, longitude: null,
                );
                if (!context.mounted) return;
                Navigator.pop(context);
                await loadData();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Partido guardado'), backgroundColor: Color(0xFF1C2537)),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2537),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0x1AFFFFFF)),
                ),
                child: const Text('Guardar', style: TextStyle(color: Color(0xFFE2E8F4), fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _dec(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Color(0xFF4A5568), fontSize: 13),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0x1AFFFFFF)),
      borderRadius: BorderRadius.circular(10),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xFF7C9EBF)),
      borderRadius: BorderRadius.circular(10),
    ),
    filled: true,
    fillColor: const Color(0xFF1C2537),
  );

  String _fmtDate(String v) =>
      DateFormat('dd MMM yyyy · HH:mm').format(DateTime.parse(v).toLocal());

  Color _statusColor(String? s) => switch (s) {
    'done'       => const Color(0xFF3D7A5E),
    'processing' => const Color(0xFF7A6A3D),
    _            => const Color(0xFF4A7FA5),
  };

  String _statusLabel(String? s) => switch (s) {
    'done'       => 'Analizado',
    'processing' => 'Procesando',
    _            => 'Cargado',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Partidos',
                            style: TextStyle(color: Color(0xFFE2E8F4), fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                        SizedBox(height: 4),
                        Text('Historial de encuentros',
                            style: TextStyle(color: Color(0xFF4A5568), fontSize: 13)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: loadData,
                    child: Container(
                      width: 40, height: 40,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C2537),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0x14FFFFFF)),
                      ),
                      child: const Icon(Icons.refresh_outlined, color: Color(0xFF7C9EBF), size: 18),
                    ),
                  ),
                  GestureDetector(
                    onTap: openCreateMatchDialog,
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C2537),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0x14FFFFFF)),
                      ),
                      child: const Icon(Icons.add, color: Color(0xFF7C9EBF), size: 20),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Body
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF7C9EBF), strokeWidth: 1.5))
                  : matches.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.sports_soccer_outlined, color: Color(0xFF2D4A6A), size: 48),
                              const SizedBox(height: 14),
                              const Text('Sin partidos registrados',
                                  style: TextStyle(color: Color(0xFF4A5568), fontSize: 14)),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: openCreateMatchDialog,
                                child: const Text('+ Añadir partido',
                                    style: TextStyle(color: Color(0xFF7C9EBF), fontSize: 13, fontWeight: FontWeight.w500)),
                              ),
                            ],
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            const _SLabel('PARTIDOS'),
                            const SizedBox(height: 14),
                            ...matches.map((m) {
                              final team     = m['teams'];
                              final teamName = team is Map ? (team['name'] ?? 'Sin equipo') : 'Sin equipo';
                              return _MatchCard(
                                rival: m['opponent'] ?? '—',
                                date: _fmtDate(m['match_date']),
                                team: teamName,
                                source: (m['source_type'] ?? '—').toString(),
                                statusText: _statusLabel(m['status']),
                                statusColor: _statusColor(m['status']),
                              );
                            }),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SLabel extends StatelessWidget {
  final String text;
  const _SLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(color: Color(0xFF4A5568), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2),
  );
}

class _MatchCard extends StatelessWidget {
  final String rival;
  final String date;
  final String team;
  final String source;
  final String statusText;
  final Color statusColor;

  const _MatchCard({
    required this.rival,
    required this.date,
    required this.team,
    required this.source,
    required this.statusText,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x0FFFFFFF)),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.sports_soccer_outlined, color: Color(0xFF7C9EBF), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rival,
                    style: const TextStyle(color: Color(0xFFE2E8F4), fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('$team · $date',
                    style: const TextStyle(color: Color(0xFF4A5568), fontSize: 11)),
                const SizedBox(height: 2),
                Text(source, style: const TextStyle(color: Color(0xFF2D4A6A), fontSize: 10)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(statusText,
                style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
