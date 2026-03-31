import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/form_text_field.dart';
import '../../../shared/widgets/section_label.dart';
import '../controller/matches_controller.dart';
import 'widgets/match_card.dart';

class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key});

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  late final MatchesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MatchesController();
    _controller.fetchData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (_controller.errorMessage != null) {
          _controller.consumeError();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(_controller.errorMessage ?? ''),
              backgroundColor: AppColors.elevated,
            ));
          });
        }

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: Column(children: [
              // ── Header ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Row(children: [
                  const Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Matches',
                          style: TextStyle(color: AppColors.text, fontSize: 24,
                              fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                      SizedBox(height: 4),
                      Text('Match history',
                          style: TextStyle(color: AppColors.dim, fontSize: 13)),
                    ]),
                  ),
                  GestureDetector(
                    onTap: _controller.fetchData,
                    child: Container(
                      width: 40, height: 40,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: AppColors.elevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border2),
                      ),
                      child: const Icon(Icons.refresh_outlined, color: AppColors.accent, size: 18),
                    ),
                  ),
                  GestureDetector(
                    onTap: _openCreateMatchDialog,
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.elevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border2),
                      ),
                      child: const Icon(Icons.add, color: AppColors.accent, size: 20),
                    ),
                  ),
                ]),
              ),

              const SizedBox(height: 24),

              // ── Body ─────────────────────────────────────────────
              Expanded(
                child: _controller.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 1.5))
                    : _controller.matches.isEmpty
                        ? Center(
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              const Icon(Icons.sports_soccer_outlined, color: AppColors.accentLo, size: 48),
                              const SizedBox(height: 14),
                              const Text('No matches registered',
                                  style: TextStyle(color: AppColors.dim, fontSize: 14)),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: _openCreateMatchDialog,
                                child: const Text('+ Add match',
                                    style: TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w500)),
                              ),
                            ]),
                          )
                        : ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            children: [
                              const SectionLabel('MATCHES'),
                              const SizedBox(height: 14),
                              ..._controller.matches.map((m) {
                                final teamData = m['teams'];
                                final teamName = teamData is Map ? (teamData['name'] ?? 'No team') : 'No team';
                                return MatchCard(
                                  rival: m['opponent'] ?? '—',
                                  date: _formatDate(m['match_date']),
                                  team: teamName,
                                  source: (m['source_type'] ?? '—').toString(),
                                  statusText: _matchStatusLabel(m['status']),
                                  statusColor: _matchStatusColor(m['status']),
                                );
                              }),
                            ],
                          ),
              ),
            ]),
          ),
        );
      },
    );
  }

  Future<void> _openCreateMatchDialog() async {
    if (_controller.teams.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Create at least one team first.'),
          backgroundColor: AppColors.elevated,
        ),
      );
      return;
    }

    final opponentController  = TextEditingController();
    DateTime selectedDate     = DateTime.now();
    TimeOfDay selectedTime    = TimeOfDay.now();
    int selectedTeamId        = _controller.teams.first['id'] as int;
    String selectedSourceType = AppConstants.sourceUpload;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('New match',
              style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              DropdownButtonFormField<int>(
                initialValue: selectedTeamId,
                dropdownColor: AppColors.elevated,
                decoration: _fieldDecoration('Team'),
                style: const TextStyle(color: AppColors.text),
                items: _controller.teams.map((t) => DropdownMenuItem<int>(
                  value: t['id'] as int,
                  child: Text(t['name'] ?? '—', style: const TextStyle(color: AppColors.text)),
                )).toList(),
                onChanged: (v) { if (v != null) setDialogState(() => selectedTeamId = v); },
              ),
              const SizedBox(height: 12),
              FormTextField(controller: opponentController, label: 'Opponent'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedSourceType,
                dropdownColor: AppColors.elevated,
                decoration: _fieldDecoration('Video source'),
                style: const TextStyle(color: AppColors.text),
                items: const [
                  DropdownMenuItem(value: AppConstants.sourceUpload,  child: Text('Upload',  style: TextStyle(color: AppColors.text))),
                  DropdownMenuItem(value: AppConstants.sourceYoutube, child: Text('YouTube', style: TextStyle(color: AppColors.text))),
                ],
                onChanged: (v) { if (v != null) setDialogState(() => selectedSourceType = v); },
              ),
              const SizedBox(height: 4),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Date: ${DateFormat(AppConstants.dateFormat).format(selectedDate)}',
                    style: const TextStyle(color: AppColors.text, fontSize: 14)),
                trailing: const Icon(Icons.calendar_today_outlined, color: AppColors.accent, size: 18),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx, initialDate: selectedDate,
                    firstDate: DateTime(2024), lastDate: DateTime(2030),
                  );
                  if (picked != null) setDialogState(() => selectedDate = picked);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Time: ${selectedTime.format(ctx)}',
                    style: const TextStyle(color: AppColors.text, fontSize: 14)),
                trailing: const Icon(Icons.access_time_outlined, color: AppColors.accent, size: 18),
                onTap: () async {
                  final picked = await showTimePicker(context: ctx, initialTime: selectedTime);
                  if (picked != null) setDialogState(() => selectedTime = picked);
                },
              ),
            ]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.dim)),
            ),
            GestureDetector(
              onTap: () async {
                if (opponentController.text.trim().isEmpty) return;
                final dt = DateTime(
                  selectedDate.year, selectedDate.month, selectedDate.day,
                  selectedTime.hour, selectedTime.minute,
                );
                await _controller.createMatch(
                  teamId: selectedTeamId,
                  opponent: opponentController.text.trim(),
                  matchDate: dt,
                  sourceType: selectedSourceType,
                );
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Match saved'), backgroundColor: AppColors.elevated),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.elevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border2),
                ),
                child: const Text('Save',
                    style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: AppColors.dim, fontSize: 13),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: AppColors.border2),
      borderRadius: BorderRadius.circular(10),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: AppColors.accent),
      borderRadius: BorderRadius.circular(10),
    ),
    filled: true,
    fillColor: AppColors.elevated,
  );

  String _formatDate(String value) =>
      DateFormat(AppConstants.dateTimeFormat).format(DateTime.parse(value).toLocal());

  Color _matchStatusColor(String? status) => switch (status) {
    AppConstants.statusDone       => AppColors.catTech,
    AppConstants.statusProcessing => AppColors.catPhysical,
    _                             => AppColors.catTactic,
  };

  String _matchStatusLabel(String? status) => switch (status) {
    AppConstants.statusDone       => AppConstants.labelAnalysed,
    AppConstants.statusProcessing => AppConstants.labelProcessing,
    _                             => AppConstants.labelUploaded,
  };
}
