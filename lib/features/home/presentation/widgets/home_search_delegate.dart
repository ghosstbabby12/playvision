import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../controller/home_controller.dart';

class HomeSearchDelegate extends SearchDelegate<void> {
  final HomeController controller;

  HomeSearchDelegate(this.controller);

  @override
  String get searchFieldLabel => 'Search teams or matches…';

  @override
  ThemeData appBarTheme(BuildContext context) => Theme.of(context).copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.muted),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      hintStyle: TextStyle(color: AppColors.dim),
      border: InputBorder.none,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: AppColors.text, fontSize: 16),
    ),
  );

  @override
  List<Widget> buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(
        icon: const Icon(Icons.clear_rounded, color: AppColors.muted),
        onPressed: () => query = '',
      ),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.muted),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) => _buildBody(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildBody(context);

  Widget _buildBody(BuildContext context) {
    final q = query.toLowerCase().trim();

    final teams = q.isEmpty
        ? controller.teams
        : controller.teams.where((t) {
            final name = (t['name'] as String? ?? '').toLowerCase();
            final club = (t['club'] as String? ?? '').toLowerCase();
            return name.contains(q) || club.contains(q);
          }).toList();

    final matches = q.isEmpty
        ? controller.recentMatches
        : controller.recentMatches.where((m) {
            final opp  = (m['opponent'] as String? ?? '').toLowerCase();
            final team = ((m['teams'] as Map?)?['name'] as String? ?? '').toLowerCase();
            return opp.contains(q) || team.contains(q);
          }).toList();

    if (teams.isEmpty && matches.isEmpty) {
      return Center(child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off_rounded, color: AppColors.dim, size: 40),
          const SizedBox(height: 12),
          Text('No results for "$query"',
              style: const TextStyle(color: AppColors.muted, fontSize: 14)),
        ],
      ));
    }

    return Container(
      color: AppColors.bg,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (teams.isNotEmpty) ...[
            _SectionLabel('Teams (${teams.length})'),
            ...teams.map((t) => _TeamResult(
              team: t,
              query: q,
              onTap: () {
                controller.selectTeam(t);
                close(context, null);
              },
            )),
            const SizedBox(height: 8),
          ],
          if (matches.isNotEmpty) ...[
            _SectionLabel('Matches (${matches.length})'),
            ...matches.map((m) => _MatchResult(match: m, query: q)),
          ],
        ],
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10, top: 4),
    child: Text(text.toUpperCase(),
        style: const TextStyle(
            color: AppColors.dim, fontSize: 11,
            fontWeight: FontWeight.w700, letterSpacing: 1.2)),
  );
}

class _TeamResult extends StatelessWidget {
  final Map<String, dynamic> team;
  final String query;
  final VoidCallback onTap;
  const _TeamResult({required this.team, required this.query, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name    = team['name'] as String? ?? '—';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: const BoxDecoration(color: AppColors.accentLo, shape: BoxShape.circle),
            child: Center(child: Text(initial,
                style: const TextStyle(color: AppColors.accent, fontSize: 16, fontWeight: FontWeight.w700))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _Highlight(text: name, query: query),
            Text('${team['club'] ?? '—'} · ${team['category'] ?? '—'}',
                style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          ])),
          const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.dim, size: 13),
        ]),
      ),
    );
  }
}

class _MatchResult extends StatelessWidget {
  final Map<String, dynamic> match;
  final String query;
  const _MatchResult({required this.match, required this.query});

  @override
  Widget build(BuildContext context) {
    final status   = match['status'] as String? ?? AppConstants.statusUploaded;
    final opponent = match['opponent'] as String? ?? '—';
    final teamName = (match['teams'] as Map?)?['name'] as String? ?? '—';
    final rawDate  = match['match_date'] as String?;
    String dateLabel = '—';
    if (rawDate != null) {
      try { dateLabel = DateFormat('d MMM yyyy').format(DateTime.parse(rawDate)); } catch (_) {}
    }

    final (Color col, String lbl) = switch (status) {
      AppConstants.statusDone       => (AppColors.success, 'Finalizado'),
      AppConstants.statusProcessing => (AppColors.warning, 'En curso'),
      _                             => (AppColors.muted,   'Programado'),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: AppColors.elevated, borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.sports_soccer_outlined, color: AppColors.accent, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('$teamName  ', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
            _Highlight(text: 'vs $opponent', query: query),
          ]),
          const SizedBox(height: 2),
          Text(dateLabel, style: const TextStyle(color: AppColors.dim, fontSize: 11)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: col.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(lbl, style: TextStyle(color: col, fontSize: 10, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }
}

/// Highlights the matched portion of [text] in accent color.
class _Highlight extends StatelessWidget {
  final String text;
  final String query;
  const _Highlight({required this.text, required this.query});

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text,
          style: const TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w600));
    }

    final lower = text.toLowerCase();
    final idx   = lower.indexOf(query.toLowerCase());
    if (idx < 0) {
      return Text(text,
          style: const TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w600));
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w600),
        children: [
          TextSpan(text: text.substring(0, idx)),
          TextSpan(text: text.substring(idx, idx + query.length),
              style: const TextStyle(color: AppColors.accent, backgroundColor: AppColors.accentLo)),
          TextSpan(text: text.substring(idx + query.length)),
        ],
      ),
    );
  }
}
