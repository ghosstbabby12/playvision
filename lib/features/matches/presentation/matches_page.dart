import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_color_tokens.dart';
import '../../../shared/widgets/form_text_field.dart';
import '../../../shared/widgets/section_label.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'matches_controller.dart';
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
    final c = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (_controller.errorMessage != null) {
          final msg = _controller.errorMessage!;
          _controller.consumeError();

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                backgroundColor: c.elevated,
              ),
            );
          });
        }

        return Scaffold(
          backgroundColor: c.bg,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.matchesTitle,
                              style: TextStyle(
                                color: c.text,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.matchHistory,
                              style: TextStyle(color: c.dim, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _controller.fetchData,
                        child: Container(
                          width: 40,
                          height: 40,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: c.elevated,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: c.border2),
                          ),
                          child: Icon(
                            Icons.refresh_outlined,
                            color: c.accent,
                            size: 18,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _openCreateMatchDialog(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: c.elevated,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: c.border2),
                          ),
                          child: Icon(Icons.add, color: c.accent, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: _controller.isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: c.accent,
                            strokeWidth: 1.5,
                          ),
                        )
                      : _controller.matches.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.sports_soccer_outlined,
                                    color: c.accentLo,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    'No matches registered',
                                    style: TextStyle(
                                      color: c.dim,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: _openCreateMatchDialog,
                                    child: Text(
                                      '+ Add match',
                                      style: TextStyle(
                                        color: c.accent,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              children: [
                                SectionLabel(
                                  l10n.matchesTitle.toUpperCase(),
                                ),
                                const SizedBox(height: 14),
                                ..._controller.matches.map((m) {
                                  final teamData = m['teams'];
                                  final teamName = teamData is Map
                                      ? (teamData['name'] ?? 'No team')
                                      : 'No team';

                                  return MatchCard(
                                    rival: m['opponent'] ?? '—',
                                    date: _formatDate(m['match_date']),
                                    team: teamName,
                                    source:
                                        (m['source_type'] ?? '—').toString(),
                                    statusText:
                                        _matchStatusLabel(m['status'], l10n),
                                    statusColor:
                                        _matchStatusColor(m['status']),
                                  );
                                }),
                              ],
                            ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openCreateMatchDialog() async {
    final c = context.colors;

    if (_controller.teams.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Create at least one team first.'),
          backgroundColor: c.elevated,
        ),
      );
      return;
    }

    final opponentController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    int selectedTeamId = _controller.teams.first['id'] as int;
    String selectedSourceType = AppConstants.sourceUpload;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final dc = ctx.colors;

          return AlertDialog(
            backgroundColor: dc.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'New match',
              style: TextStyle(
                color: dc.text,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: selectedTeamId,
                    dropdownColor: dc.elevated,
                    decoration: _fieldDecoration('Team', dc),
                    style: TextStyle(color: dc.text),
                    items: _controller.teams
                        .map(
                          (t) => DropdownMenuItem<int>(
                            value: t['id'] as int,
                            child: Text(
                              t['name'] ?? '—',
                              style: TextStyle(color: dc.text),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setDialogState(() => selectedTeamId = v);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  FormTextField(
                    controller: opponentController,
                    label: 'Opponent',
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedSourceType,
                    dropdownColor: dc.elevated,
                    decoration: _fieldDecoration('Video source', dc),
                    style: TextStyle(color: dc.text),
                    items: [
                      DropdownMenuItem(
                        value: AppConstants.sourceUpload,
                        child: Text(
                          'Upload',
                          style: TextStyle(color: dc.text),
                        ),
                      ),
                      DropdownMenuItem(
                        value: AppConstants.sourceYoutube,
                        child: Text(
                          'YouTube',
                          style: TextStyle(color: dc.text),
                        ),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setDialogState(() => selectedSourceType = v);
                      }
                    },
                  ),
                  const SizedBox(height: 4),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Date: ${DateFormat(AppConstants.dateFormat).format(selectedDate)}',
                      style: TextStyle(color: dc.text, fontSize: 14),
                    ),
                    trailing: Icon(
                      Icons.calendar_today_outlined,
                      color: dc.accent,
                      size: 18,
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: selectedDate,
                        firstDate: DateTime(2024),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setDialogState(() => selectedDate = picked);
                      }
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Time: ${selectedTime.format(ctx)}',
                      style: TextStyle(color: dc.text, fontSize: 14),
                    ),
                    trailing: Icon(
                      Icons.access_time_outlined,
                      color: dc.accent,
                      size: 18,
                    ),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: ctx,
                        initialTime: selectedTime,
                      );
                      if (picked != null) {
                        setDialogState(() => selectedTime = picked);
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: dc.dim),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  if (opponentController.text.trim().isEmpty) return;

                  final dt = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedTime.hour,
                    selectedTime.minute,
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
                    SnackBar(
                      content: const Text('Match saved'),
                      backgroundColor: dc.elevated,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: dc.elevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: dc.border2),
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: dc.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  InputDecoration _fieldDecoration(String label, AppColorTokens c) =>
      InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: c.dim, fontSize: 13),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: c.border2),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: c.accent),
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: c.elevated,
      );

  String _formatDate(String value) {
    return DateFormat(AppConstants.dateTimeFormat)
        .format(DateTime.parse(value).toLocal());
  }

  Color _matchStatusColor(String? status) => switch (status) {
        AppConstants.statusDone => const Color(0xFF1D5A8A),
        AppConstants.statusProcessing => const Color(0xFF7A5A1D),
        _ => const Color(0xFF2D6A4F),
      };

  String _matchStatusLabel(String? status, AppLocalizations l10n) =>
      switch (status) {
        AppConstants.statusDone => l10n.statusAnalysed,
        AppConstants.statusProcessing => l10n.statusProcessing,
        _ => l10n.statusUploaded,
      };
}