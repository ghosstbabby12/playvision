import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/store/analysis_store.dart';
import '../../../core/supabase/supabase_service.dart';
import '../../../core/theme/app_color_tokens.dart';
import '../../../l10n/generated/app_localizations.dart'; // IMPORTANTE
import 'analysis_page.dart';

class AnalysesHistoryPage extends StatefulWidget {
  const AnalysesHistoryPage({super.key});

  @override
  State<AnalysesHistoryPage> createState() => _AnalysesHistoryPageState();
}

class _AnalysesHistoryPageState extends State<AnalysesHistoryPage> {
  final _service = SupabaseService.instance;

  List<Map<String, dynamic>> _teams   = [];
  List<Map<String, dynamic>> _matches = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _service.getTeams(),
        _service.getMatches(),
      ]);
      _teams   = results[0];
      _matches = results[1];
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Map<int, List<Map<String, dynamic>>> get _grouped {
    final map = <int, List<Map<String, dynamic>>>{};
    for (final m in _matches) {
      final id = m['team_id'] as int?;
      if (id == null) continue;
      (map[id] ??= []).add(m);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final c       = context.colors;
    final l10n    = AppLocalizations.of(context)!;
    final grouped = _grouped;
    final teamsWithMatches = _teams
        .where((t) => grouped.containsKey(t['id'] as int?))
        .toList();

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l10n.myAnalysesTitle,
                      style: TextStyle(color: c.text, fontSize: 24,
                          fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                  const SizedBox(height: 3),
                  Text(l10n.allMatchesGrouped,
                      style: TextStyle(color: c.dim, fontSize: 13)),
                ]),
              ),
              GestureDetector(
                onTap: _load,
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: c.elevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: c.border),
                  ),
                  child: Icon(Icons.refresh_rounded, color: c.accent, size: 18),
                ),
              ),
            ]),
          ),

          Expanded(
            child: _loading
                ? Center(child: CircularProgressIndicator(color: c.accent, strokeWidth: 2))
                : teamsWithMatches.isEmpty
                    ? _EmptyState()
                    : RefreshIndicator(
                        color: c.accent,
                        backgroundColor: c.surface,
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                          itemCount: teamsWithMatches.length,
                          itemBuilder: (_, i) {
                            final team    = teamsWithMatches[i];
                            final teamId  = team['id'] as int;
                            final matches = grouped[teamId] ?? [];
                            return _TeamSection(
                              team:       team,
                              matches:    matches,
                              onTapMatch: _openAnalysis,
                            );
                          },
                        ),
                      ),
          ),
        ]),
      ),
    );
  }

  void _openAnalysis(Map<String, dynamic> match) {
    final report = match['summary_json'] as Map<String, dynamic>?;
    if (report != null) {
      AnalysisStore.instance.save(report);
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalysisPage()));
      return;
    }
    _loadAndOpen(match);
  }

  Future<void> _loadAndOpen(Map<String, dynamic> match) async {
    final matchId = match['id'] as int?;
    if (matchId == null) return;
    final c = context.colors;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
          child: CircularProgressIndicator(color: c.accent, strokeWidth: 2)),
    );

    try {
      final report = await _service.getMatchReport(matchId);
      if (!mounted) return;
      Navigator.pop(context);

      if (report != null) {
        AnalysisStore.instance.save(report);
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalysisPage()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.noAnalysisData),
          backgroundColor: c.elevated,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: c.danger,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }
}

class _TeamSection extends StatefulWidget {
  final Map<String, dynamic> team;
  final List<Map<String, dynamic>> matches;
  final void Function(Map<String, dynamic>) onTapMatch;
  const _TeamSection({required this.team, required this.matches, required this.onTapMatch});

  @override
  State<_TeamSection> createState() => _TeamSectionState();
}

class _TeamSectionState extends State<_TeamSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final c       = context.colors;
    final l10n    = AppLocalizations.of(context)!;
    final name    = widget.team['name']     as String? ?? '—';
    final club    = widget.team['club']     as String?;
    final logoUrl = widget.team['logo_url'] as String?;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final done    = widget.matches.where((m) => m['status'] == 'done').length;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.border),
      ),
      child: Column(children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: c.accentLo,
                  shape: BoxShape.circle,
                  image: (logoUrl != null && logoUrl.isNotEmpty)
                      ? DecorationImage(image: NetworkImage(logoUrl), fit: BoxFit.cover)
                      : null,
                ),
                child: (logoUrl == null || logoUrl.isEmpty)
                    ? Center(child: Text(initial,
                        style: TextStyle(color: c.accent, fontSize: 18, fontWeight: FontWeight.w800)))
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: TextStyle(
                    color: c.text, fontSize: 15, fontWeight: FontWeight.w700)),
                if (club != null && club.isNotEmpty)
                  Text(club, style: TextStyle(color: c.muted, fontSize: 12)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: c.accentLo,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('$done / ${widget.matches.length} ${l10n.analysed}',
                    style: TextStyle(
                        color: c.accent, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              Icon(_expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: c.dim, size: 20),
            ]),
          ),
        ),

        if (_expanded) ...[
          Divider(height: 1, color: c.border),
          ...widget.matches.map((m) => _MatchRow(
                match: m,
                onTap: () => widget.onTapMatch(m),
              )),
          const SizedBox(height: 4),
        ],
      ]),
    );
  }
}

class _MatchRow extends StatelessWidget {
  final Map<String, dynamic> match;
  final VoidCallback onTap;
  const _MatchRow({required this.match, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c          = context.colors;
    final l10n       = AppLocalizations.of(context)!;
    final opponent   = match['opponent'] as String?;
    final dateStr    = match['match_date'] as String? ?? '';
    final status     = match['status']   as String? ?? 'uploaded';
    final videoUrl   = match['video_url'] as String?;

    DateTime? dt;
    try { dt = DateTime.parse(dateStr).toLocal(); } catch (_) {}
    final dateLabel = dt != null ? DateFormat('d MMM y · HH:mm').format(dt) : '—';

    final (statusColor, statusLabel) = switch (status) {
      'done'       => (c.success, l10n.statusAnalysed),
      'processing' => (c.warning, l10n.statusProcessing),
      'error'      => (c.danger,  l10n.statusError),
      _            => (c.dim,     l10n.statusUploaded),
    };

    final hasAnalysis = status == 'done' && videoUrl != null;

    return GestureDetector(
      onTap: hasAnalysis ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: c.border)),
        ),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: c.elevated,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              hasAnalysis ? Icons.analytics_outlined : Icons.videocam_outlined,
              color: hasAnalysis ? c.accent : c.dim,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(opponent != null && opponent.isNotEmpty ? 'vs $opponent' : l10n.matchWord,
                style: TextStyle(color: c.text, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(dateLabel, style: TextStyle(color: c.dim, fontSize: 11)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(statusLabel,
                style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w700)),
          ),
          if (hasAnalysis) ...[
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded, color: c.dim, size: 12),
          ],
        ]),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: c.accentLo, shape: BoxShape.circle),
            child: Icon(Icons.analytics_outlined, color: c.accent, size: 36),
          ),
          const SizedBox(height: 20),
          Text(l10n.noAnalysesYet, style: TextStyle(
              color: c.text, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(l10n.selectTeamAndAnalyseDesc,
              textAlign: TextAlign.center,
              style: TextStyle(color: c.muted, fontSize: 13, height: 1.5)),
        ]),
      ),
    );
  }
}