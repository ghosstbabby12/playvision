import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_color_tokens.dart';
import '../../controller/home_controller.dart';

class TeamAnalysisCard extends StatefulWidget {
  final Map<String, dynamic> team;
  final HomeController controller;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TeamAnalysisCard({
    super.key,
    required this.team,
    required this.controller,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<TeamAnalysisCard> createState() => _TeamAnalysisCardState();
}

class _TeamAnalysisCardState extends State<TeamAnalysisCard> {
  bool _expanded = false;

  int get _teamId => widget.team['id'] as int;

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded && widget.controller.teamMatches[_teamId] == null) {
      widget.controller.loadMatchesForTeam(_teamId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final matches = widget.controller.teamMatches[_teamId];
    final isLoadingMatches = widget.controller.isLoadingMatchesForTeam(_teamId);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _expanded ? c.accent.withValues(alpha: 0.4) : c.border,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: c.accentLo,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.groups_outlined, color: c.accent, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.team['name'] ?? '—',
                      style: TextStyle(color: c.text, fontSize: 14, fontWeight: FontWeight.w600)),
                  Text('${widget.team['club'] ?? '—'} · ${widget.team['category'] ?? '—'}',
                      style: TextStyle(color: c.dim, fontSize: 11)),
                ])),
                GestureDetector(
                  onTap: widget.onEdit,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(Icons.edit_outlined, color: c.dim, size: 16),
                  ),
                ),
                GestureDetector(
                  onTap: widget.onDelete,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(Icons.delete_outline, color: c.danger, size: 16),
                  ),
                ),
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.keyboard_arrow_down_rounded, color: c.dim, size: 20),
                ),
              ]),
            ),
          ),

          if (_expanded) ...[
            Divider(color: c.border, height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: isLoadingMatches
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: CircularProgressIndicator(color: c.accent, strokeWidth: 1.5),
                      ),
                    )
                  : matches == null || matches.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(children: [
                            Icon(Icons.history_rounded, color: c.accentLo, size: 16),
                            const SizedBox(width: 8),
                            Text('No analyses yet for this team',
                                style: TextStyle(color: c.dim, fontSize: 12)),
                          ]),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Previous analyses',
                                style: TextStyle(color: c.muted, fontSize: 11,
                                    fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                            const SizedBox(height: 10),
                            ...matches.map((m) => _MatchRow(match: m)),
                          ],
                        ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MatchRow extends StatelessWidget {
  final Map<String, dynamic> match;
  const _MatchRow({required this.match});

  @override
  Widget build(BuildContext context) {
    final c      = context.colors;
    final status   = match['status'] as String? ?? AppConstants.statusUploaded;
    final opponent = match['opponent'] as String? ?? '—';
    final rawDate  = match['match_date'] as String?;
    String dateLabel = '—';
    if (rawDate != null) {
      try {
        dateLabel = DateFormat(AppConstants.dateFormat).format(DateTime.parse(rawDate));
      } catch (_) {}
    }

    final (Color chipColor, Color chipText, String chipLabel) = switch (status) {
      AppConstants.statusDone       => (c.successBg, c.success, AppConstants.labelAnalysed),
      AppConstants.statusProcessing => (c.warningBg, c.warning, AppConstants.labelProcessing),
      _                             => (c.border,    c.dim,     AppConstants.labelUploaded),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.border),
      ),
      child: Row(children: [
        Icon(Icons.sports_soccer_outlined, color: c.accentLo, size: 14),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('vs $opponent',
              style: TextStyle(color: c.text, fontSize: 13, fontWeight: FontWeight.w600)),
          Text(dateLabel, style: TextStyle(color: c.dim, fontSize: 11)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: chipColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(chipLabel,
              style: TextStyle(color: chipText, fontSize: 10, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}
