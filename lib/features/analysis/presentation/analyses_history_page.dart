import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/store/analysis_store.dart';
import '../../../core/supabase/supabase_service.dart';
import '../../../core/theme/app_colors.dart';
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

  // Group matches by team_id
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
    final grouped = _grouped;
    // Only teams that have at least one match
    final teamsWithMatches = _teams
        .where((t) => grouped.containsKey(t['id'] as int?))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(children: [
          // ── Header ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(children: [
              const Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('My Analyses',
                      style: TextStyle(color: AppColors.text, fontSize: 24,
                          fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                  SizedBox(height: 3),
                  Text('All matches grouped by team',
                      style: TextStyle(color: AppColors.dim, fontSize: 13)),
                ]),
              ),
              GestureDetector(
                onTap: _load,
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.elevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.refresh_rounded, color: AppColors.accent, size: 18),
                ),
              ),
            ]),
          ),

          // ── Content ─────────────────────────────────────────
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(
                    color: AppColors.accent, strokeWidth: 2))
                : teamsWithMatches.isEmpty
                    ? _EmptyState()
                    : RefreshIndicator(
                        color: AppColors.accent,
                        backgroundColor: AppColors.surface,
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                          itemCount: teamsWithMatches.length,
                          itemBuilder: (_, i) {
                            final team    = teamsWithMatches[i];
                            final teamId  = team['id'] as int;
                            final matches = grouped[teamId] ?? [];
                            return _TeamSection(
                              team:    team,
                              matches: matches,
                              onTapMatch: (match) => _openAnalysis(match),
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
      // If the match has a report inline, load it
      AnalysisStore.instance.save(report);
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const AnalysisPage()));
      return;
    }

    // Otherwise fetch the report from match_reports table
    _loadAndOpen(match);
  }

  Future<void> _loadAndOpen(Map<String, dynamic> match) async {
    final matchId = match['id'] as int?;
    if (matchId == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2)),
    );

    try {
      final report = await _service.getMatchReport(matchId);
      if (!mounted) return;
      Navigator.pop(context); // close loader

      if (report != null) {
        AnalysisStore.instance.save(report);
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AnalysisPage()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No analysis data for this match yet.'),
          backgroundColor: AppColors.elevated,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Team section
// ─────────────────────────────────────────────────────────────────────────────
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
    final name    = widget.team['name']     as String? ?? '—';
    final club    = widget.team['club']     as String?;
    final logoUrl = widget.team['logo_url'] as String?;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final done    = widget.matches.where((m) => m['status'] == 'done').length;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: [
        // Team header row
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              // Avatar
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: AppColors.accentLo,
                  shape: BoxShape.circle,
                  image: (logoUrl != null && logoUrl.isNotEmpty)
                      ? DecorationImage(image: NetworkImage(logoUrl), fit: BoxFit.cover)
                      : null,
                ),
                child: (logoUrl == null || logoUrl.isEmpty)
                    ? Center(child: Text(initial,
                        style: const TextStyle(color: AppColors.accent,
                            fontSize: 18, fontWeight: FontWeight.w800)))
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: const TextStyle(
                    color: AppColors.text, fontSize: 15, fontWeight: FontWeight.w700)),
                if (club != null && club.isNotEmpty)
                  Text(club, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
              ])),
              // Stats badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.accentLo,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('$done / ${widget.matches.length} analysed',
                    style: const TextStyle(
                        color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              Icon(_expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.dim, size: 20),
            ]),
          ),
        ),

        // Match list
        if (_expanded) ...[
          const Divider(height: 1, color: AppColors.border),
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

// ─────────────────────────────────────────────────────────────────────────────
// Match row
// ─────────────────────────────────────────────────────────────────────────────
class _MatchRow extends StatelessWidget {
  final Map<String, dynamic> match;
  final VoidCallback onTap;
  const _MatchRow({required this.match, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final opponent  = match['opponent'] as String?;
    final dateStr   = match['match_date'] as String? ?? '';
    final status    = match['status']   as String? ?? 'uploaded';
    final videoUrl  = match['video_url'] as String?;

    DateTime? dt;
    try { dt = DateTime.parse(dateStr).toLocal(); } catch (_) {}
    final dateLabel = dt != null ? DateFormat('d MMM y · HH:mm').format(dt) : '—';

    final (statusColor, statusLabel) = switch (status) {
      'done'       => (AppColors.success, 'Analysed'),
      'processing' => (AppColors.warning, 'Processing'),
      'error'      => (AppColors.danger,  'Error'),
      _            => (AppColors.dim,     'Uploaded'),
    };

    final hasAnalysis = status == 'done' && videoUrl != null;

    return GestureDetector(
      onTap: hasAnalysis ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.elevated,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              hasAnalysis ? Icons.analytics_outlined : Icons.videocam_outlined,
              color: hasAnalysis ? AppColors.accent : AppColors.dim,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(opponent != null && opponent.isNotEmpty
                ? 'vs $opponent' : 'Match',
                style: const TextStyle(
                    color: AppColors.text, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(dateLabel,
                style: const TextStyle(color: AppColors.dim, fontSize: 11)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(statusLabel,
                style: TextStyle(color: statusColor,
                    fontSize: 10, fontWeight: FontWeight.w700)),
          ),
          if (hasAnalysis) ...[
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.dim, size: 12),
          ],
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          width: 80, height: 80,
          decoration: const BoxDecoration(color: AppColors.accentLo, shape: BoxShape.circle),
          child: const Icon(Icons.analytics_outlined, color: AppColors.accent, size: 36),
        ),
        const SizedBox(height: 20),
        const Text('No analyses yet', style: TextStyle(
            color: AppColors.text, fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        const Text('Select a team on the home screen\nand analyse a match video.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, fontSize: 13, height: 1.5)),
      ]),
    ),
  );
}
