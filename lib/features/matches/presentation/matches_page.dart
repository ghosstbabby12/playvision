import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_color_tokens.dart';
import '../../../shared/widgets/form_text_field.dart';
import '../../../shared/widgets/pv_back_button.dart';
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
        final resolvedError = _resolveMatchesError(l10n, _controller.errorKey);

        if (resolvedError != null) {
          _controller.consumeError();

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(resolvedError),
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
                      const PvBackButton(),
                      const SizedBox(width: 12),
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
                                    l10n.matchesEmptyTitle,
                                    style: TextStyle(
                                      color: c.dim,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: _openCreateMatchDialog,
                                    child: Text(
                                      l10n.matchesAddButton,
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
                                      ? (teamData['name'] ??
                                          l10n.matchesNoTeam)
                                      : l10n.matchesNoTeam;

                                  return MatchCard(
                                    rival: (m['opponent'] as String?)?.trim().isNotEmpty ==
                                            true
                                        ? m['opponent'] as String
                                        : l10n.matchUnknownOpponent,
                                    date: _formatDate(m['match_date']),
                                    team: teamName,
                                    source: _sourceLabel(
                                      (m['source_type'] ?? '').toString(),
                                      l10n,
                                    ),
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
    final l10n = AppLocalizations.of(context)!;

    if (_controller.teams.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.matchesRequireTeamFirst),
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
          final l10n = AppLocalizations.of(ctx)!;

          return AlertDialog(
            backgroundColor: dc.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              l10n.matchesNewTitle,
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
                    decoration: _fieldDecoration(l10n.matchesTeamLabel, dc),
                    style: TextStyle(color: dc.text),
                    items: _controller.teams
                        .map(
                          (t) => DropdownMenuItem<int>(
                            value: t['id'] as int,
                            child: Text(
                              (t['name'] ?? '—').toString(),
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
                    label: l10n.matchesOpponentLabel,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedSourceType,
                    dropdownColor: dc.elevated,
                    decoration:
                        _fieldDecoration(l10n.matchesVideoSourceLabel, dc),
                    style: TextStyle(color: dc.text),
                    items: [
                      DropdownMenuItem(
                        value: AppConstants.sourceUpload,
                        child: Text(
                          l10n.matchesUploadSource,
                          style: TextStyle(color: dc.text),
                        ),
                      ),
                      DropdownMenuItem(
                        value: AppConstants.sourceYoutube,
                        child: Text(
                          l10n.matchesYouTubeSource,
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
                      l10n.matchesDateLabel(
                        DateFormat(AppConstants.dateFormat)
                            .format(selectedDate),
                      ),
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
                      l10n.matchesTimeLabel(selectedTime.format(ctx)),
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
                  l10n.cancelBtn,
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
                      content: Text(l10n.matchesSaved),
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
                    l10n.saveBtn,
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

  String? _resolveMatchesError(AppLocalizations l10n, String? key) {
    switch (key) {
      case 'matchesTimeoutError':
        return l10n.matchesTimeoutError;
      case 'matchesLoadError':
        return l10n.matchesLoadError;
      case 'matchesSaveError':
        return l10n.matchesSaveError;
      default:
        return null;
    }
  }

  String _sourceLabel(String sourceType, AppLocalizations l10n) {
    switch (sourceType) {
      case AppConstants.sourceYoutube:
        return l10n.matchesYouTubeSource;
      case AppConstants.sourceUpload:
        return l10n.matchesUploadSource;
      default:
        return sourceType.isEmpty ? '—' : sourceType;
    }
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