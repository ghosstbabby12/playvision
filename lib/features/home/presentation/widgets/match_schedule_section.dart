import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:playvision/core/theme/app_color_tokens.dart';
import '../../../../../../l10n/generated/app_localizations.dart';

// Browser-like User-Agent so CDNs (media.api-sports.io) return images
const _kImgHeaders = <String, String>{
  'User-Agent':
      'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) '
      'AppleWebKit/605.1.15 (KHTML, like Gecko) '
      'Version/17.0 Mobile/15E148 Safari/604.1',
};

const _kTopLeagueKeywords = [
  'premier league', 'la liga', 'serie a', 'bundesliga', 'ligue 1',
  'champions league', 'europa league', 'conference league',
  'copa libertadores', 'mls', 'liga mx', 'eredivisie', 'primeira liga',
  'liga portugal', 'süper lig', 'primera division', 'primera división',
];

bool _isTopLeague(String name) {
  final lower = name.toLowerCase();
  return _kTopLeagueKeywords.any((k) => lower.contains(k));
}

class MatchScheduleSection extends StatefulWidget {
  // Live
  final bool isLoading;
  final List<dynamic> matches;
  // Featured
  final Map<String, List<dynamic>> featuredSections;
  final bool isLoadingFeatured;
  // Search
  final Future<void> Function(String) onSearchTeam;
  final VoidCallback onClearSearch;
  final bool isSearching;
  final Map<String, dynamic>? searchedTeam;
  final List<dynamic> searchedMatches;

  const MatchScheduleSection({
    super.key,
    required this.isLoading,
    required this.matches,
    required this.featuredSections,
    required this.isLoadingFeatured,
    required this.onSearchTeam,
    required this.onClearSearch,
    required this.isSearching,
    this.searchedTeam,
    required this.searchedMatches,
  });

  @override
  State<MatchScheduleSection> createState() => _MatchScheduleSectionState();
}

class _MatchScheduleSectionState extends State<MatchScheduleSection> {
  final _searchCtrl = TextEditingController();
  bool _showSearch  = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _submitSearch() {
    if (_searchCtrl.text.trim().length >= 2) {
      widget.onSearchTeam(_searchCtrl.text.trim());
    }
  }

  void _clearSearch() {
    _searchCtrl.clear();
    widget.onClearSearch();
    setState(() => _showSearch = false);
  }

  @override
  Widget build(BuildContext context) {
    final c    = context.colors;
    final l10n = AppLocalizations.of(context)!;

    // ── Filtrar secciones destacadas a ligas reconocidas ──────────────────
    final filteredSections = Map.fromEntries(
      widget.featuredSections.entries.where((e) => _isTopLeague(e.key)));

    // ── Determinar si hay partidos en vivo ─────────────────────────────────
    final liveStatus  = {'1H', '2H', 'HT', 'ET', 'P'};
    final liveMatches = widget.matches
        .cast<Map<String, dynamic>>()
        .where((m) =>
            liveStatus.contains(m['fixture']?['status']?['short'] as String? ?? ''))
        .toList();
    final hasLive = liveMatches.isNotEmpty;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      // ════════════════════════════════════════════════════════════════════
      // Barra de búsqueda
      // ════════════════════════════════════════════════════════════════════
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: _showSearch
              // Campo de búsqueda expandido
              ? Row(key: const ValueKey('search_open'), children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: c.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: c.border),
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        autofocus: true,
                        style: TextStyle(color: c.text, fontSize: 14),
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _submitSearch(),
                        decoration: InputDecoration(
                          hintText: l10n.searchTeamHint,
                          hintStyle: TextStyle(color: c.muted, fontSize: 14),
                          prefixIcon:
                              Icon(Icons.search, color: c.dim, size: 18),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Botón buscar
                  GestureDetector(
                    onTap: _submitSearch,
                    child: Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: c.accent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: widget.isSearching
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.search,
                              color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Botón cerrar búsqueda
                  GestureDetector(
                    onTap: _clearSearch,
                    child: Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: c.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: c.border),
                      ),
                      child: Icon(Icons.close, color: c.muted, size: 18),
                    ),
                  ),
                ])
              // Botón para abrir búsqueda
              : Row(key: const ValueKey('search_closed'),
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.resultsTab,
                        style: TextStyle(
                            color: c.textHi,
                            fontSize: 20,
                            fontWeight: FontWeight.w800)),
                    GestureDetector(
                      onTap: () => setState(() => _showSearch = true),
                      child: Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: c.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: c.border),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.search, color: c.accent, size: 16),
                          const SizedBox(width: 6),
                          Text(l10n.searchTeamButton,
                              style: TextStyle(
                                  color: c.accent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    ),
                  ]),
        ),
      ),

      // ════════════════════════════════════════════════════════════════════
      // Resultado de búsqueda
      // ════════════════════════════════════════════════════════════════════
      if (widget.isSearching)
        Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
              child: CircularProgressIndicator(
                  color: c.accent, strokeWidth: 1.5)),
        )
      else if (widget.searchedTeam != null) ...[
        // Header del equipo buscado
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: c.surface,
                shape: BoxShape.circle,
                border: Border.all(color: c.border),
              ),
              child: ClipOval(
                child: (widget.searchedTeam!['logo'] as String? ?? '')
                        .isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: widget.searchedTeam!['logo'] as String,
                        httpHeaders: _kImgHeaders,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            Icon(Icons.sports_soccer, color: c.accent, size: 20),
                      )
                    : Icon(Icons.sports_soccer, color: c.accent, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  widget.searchedTeam!['name'] as String? ?? '',
                  style: TextStyle(
                      color: c.textHi,
                      fontSize: 15,
                      fontWeight: FontWeight.w800),
                ),
                Text(
                  widget.searchedTeam!['country'] as String? ?? '',
                  style: TextStyle(color: c.muted, fontSize: 12),
                ),
              ]),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: c.accentLo,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(l10n.searchLast5,
                  style: TextStyle(
                      color: c.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
        if (widget.searchedMatches.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Text(l10n.searchNoRecentMatches,
                style: TextStyle(color: c.muted, fontSize: 13)),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: widget.searchedMatches
                  .cast<Map<String, dynamic>>()
                  .map((m) => MatchRow(match: m))
                  .toList(),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
          child: Divider(color: c.border),
        ),
      ],

      // ════════════════════════════════════════════════════════════════════
      // Sección EN VIVO
      // ════════════════════════════════════════════════════════════════════
      if (widget.isLoading)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Center(
              child: CircularProgressIndicator(
                  color: c.accent, strokeWidth: 1.5)),
        )
      else if (hasLive) ...[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                  color: Color(0xFFE91E63), shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(l10n.liveLabel,
                style: TextStyle(
                    color: c.textHi,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2)),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE91E63).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('${liveMatches.length}',
                  style: const TextStyle(
                      color: Color(0xFFE91E63),
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ),
          ]),
        ),
        // Card destacada del primer partido en vivo
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: FeaturedMatchCard(match: liveMatches.first),
        ),
        // Resto de partidos en vivo agrupados por liga
        ...() {
          final grouped = <String, List<Map<String, dynamic>>>{};
          for (final m in liveMatches.skip(1)) {
            final key =
                m['league']?['name'] as String? ?? 'Others';
            grouped.putIfAbsent(key, () => []).add(m);
          }
          return grouped.entries.map((e) => LeagueGroup(
                leagueName: e.key,
                leagueLogo:
                    e.value.first['league']?['logo'] as String? ?? '',
                matches: e.value,
              ));
        }(),
      ],

      // ════════════════════════════════════════════════════════════════════
      // Secciones destacadas del día (Champions, Premier, etc.)
      // ════════════════════════════════════════════════════════════════════
      if (widget.isLoadingFeatured && filteredSections.isEmpty)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: _SectionSkeleton(c: c),
        )
      else if (filteredSections.isNotEmpty) ...[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.todayLabel,
                  style: TextStyle(
                      color: c.textHi,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                    color: c.accentLo,
                    borderRadius: BorderRadius.circular(20)),
                child: Text(
                    l10n.todayMatchesCount(filteredSections.values.fold(0, (s, l) => s + l.length)),
                    style: TextStyle(
                        color: c.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        ...filteredSections.entries.map((entry) => LeagueGroup(
              leagueName: entry.key,
              leagueLogo: entry.value.isNotEmpty
                  ? (entry.value.first['league']?['logo'] as String? ?? '')
                  : '',
              matches: entry.value.cast<Map<String, dynamic>>(),
            )),
      ] else if (!widget.isLoadingFeatured)
        // Empty state cuando no hay partidos hoy
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.border),
            ),
            child: Center(
              child: Column(children: [
                Icon(Icons.sports_soccer_outlined, color: c.dim, size: 28),
                const SizedBox(height: 8),
                Text(l10n.noRealMatchesToday,
                    style: TextStyle(color: c.muted, fontSize: 13)),
              ]),
            ),
          ),
        ),

      const SizedBox(height: 16),
    ]);
  }
}

// ── Skeleton de carga para secciones ──────────────────────────────────────────
class _SectionSkeleton extends StatelessWidget {
  final AppColorTokens c;
  const _SectionSkeleton({required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(children: List.generate(3, (_) => Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 64,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
    )));
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Widgets reutilizables (sin cambios de lógica, solo están aquí completos)
// ══════════════════════════════════════════════════════════════════════════════

class FeaturedMatchCard extends StatelessWidget {
  final Map<String, dynamic> match;
  const FeaturedMatchCard({super.key, required this.match});

  static String _logo(dynamic team) {
    if (team == null) return '';
    final url = team['logo'] as String? ?? '';
    if (url.isNotEmpty) return url;
    final id = team['id'];
    return id != null ? 'https://media.api-sports.io/football/teams/$id.png' : '';
  }

  static String _leagueLogo(dynamic league) {
    if (league == null) return '';
    final url = league['logo'] as String? ?? '';
    if (url.isNotEmpty) return url;
    final id = league['id'];
    return id != null ? 'https://media.api-sports.io/football/leagues/$id.png' : '';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context)!;

    final homeTeam    = match['teams']?['home']?['name'] as String? ?? l10n.matchHomeTeam;
    final awayTeam    = match['teams']?['away']?['name'] as String? ?? l10n.matchAwayTeam;
    final homeLogo    = _logo(match['teams']?['home']);
    final awayLogo    = _logo(match['teams']?['away']);
    final homeGoals   = match['goals']?['home'];
    final awayGoals   = match['goals']?['away'];
    final statusShort = match['fixture']?['status']?['short'] as String? ?? 'NS';
    final elapsed     = match['fixture']?['status']?['elapsed'];
    final dateStr     = match['fixture']?['date'] as String? ?? '';
    final leagueName  = match['league']?['name'] as String? ?? '';
    final leagueLogo  = _leagueLogo(match['league']);

    final isLive     = statusShort == '1H' || statusShort == '2H' || statusShort == 'HT';
    final isFinished = statusShort == 'FT' || statusShort == 'AET' || statusShort == 'PEN';

    String timeText = '';
    if (!isFinished && !isLive && dateStr.isNotEmpty) {
      try {
        final dt = DateTime.parse(dateStr).toLocal();
        timeText = DateFormat('HH:mm · dd MMM').format(dt);
      } catch (_) {}
    }
    if (isLive && elapsed != null) timeText = "$elapsed'";

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 230,
        child: Stack(fit: StackFit.expand, children: [
          Image.network(
            'https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=800&q=80',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: c.surface),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.45),
                  Colors.black.withValues(alpha: 0.90),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                if (leagueLogo.isNotEmpty)
                  CachedNetworkImage(
                    imageUrl: leagueLogo, width: 20, height: 20,
                    httpHeaders: _kImgHeaders,
                    fit: BoxFit.contain,
                    errorWidget: (_, __, ___) =>
                        const Icon(Icons.emoji_events, color: Colors.white70, size: 16),
                  )
                else
                  const Icon(Icons.emoji_events,
                      color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(leagueName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600))),
                if (isLive)
                  LiveBadge(time: timeText)
                else if (isFinished)
                  StatusPill(label: l10n.matchStatusFT)
                else if (timeText.isNotEmpty)
                  StatusPill(label: timeText),
              ]),
              const Spacer(),
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Column(children: [
                      HeroTeamLogo(logoUrl: homeLogo, name: homeTeam),
                      const SizedBox(height: 8),
                      Text(homeTeam,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700)),
                    ])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: isFinished || isLive
                          ? Row(mainAxisSize: MainAxisSize.min, children: [
                              Text('${homeGoals ?? 0}',
                                  style: TextStyle(
                                    color: isLive ? c.accent : Colors.white,
                                    fontSize: 38,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1,
                                  )),
                              const Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 10),
                                child: Text('–',
                                    style: TextStyle(
                                        color: Colors.white38,
                                        fontSize: 26,
                                        fontWeight: FontWeight.w300)),
                              ),
                              Text('${awayGoals ?? 0}',
                                  style: TextStyle(
                                    color: isLive ? c.accent : Colors.white,
                                    fontSize: 38,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1,
                                  )),
                            ])
                          : Text(l10n.matchVS,
                              style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 3)),
                    ),
                    Expanded(
                        child: Column(children: [
                      HeroTeamLogo(logoUrl: awayLogo, name: awayTeam),
                      const SizedBox(height: 8),
                      Text(awayTeam,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700)),
                    ])),
                  ]),
              const SizedBox(height: 4),
            ]),
          ),
        ]),
      ),
    );
  }
}

class LiveBadge extends StatelessWidget {
  final String time;
  const LiveBadge({super.key, required this.time});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE91E63),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(time.isEmpty ? l10n.matchLive : '${l10n.matchLive}  $time',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800)),
      ]),
    );
  }
}

class StatusPill extends StatelessWidget {
  final String label;
  const StatusPill({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w700)),
    );
  }
}

class HeroTeamLogo extends StatelessWidget {
  final String logoUrl;
  final String name;
  const HeroTeamLogo(
      {super.key, required this.logoUrl, required this.name});

  Widget _placeholder() => Container(
    width: 52, height: 52,
    decoration: const BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
    child: Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (logoUrl.isEmpty) return _placeholder();
    return CachedNetworkImage(
      imageUrl: logoUrl,
      width: 52,
      height: 52,
      httpHeaders: _kImgHeaders,
      fit: BoxFit.contain,
      placeholder: (_, __) => Container(
        width: 52, height: 52,
        decoration: const BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
      ),
      errorWidget: (_, __, ___) => _placeholder(),
    );
  }
}

class LeagueGroup extends StatelessWidget {
  final String leagueName;
  final String leagueLogo;
  final List<Map<String, dynamic>> matches;
  const LeagueGroup({
    super.key,
    required this.leagueName,
    required this.leagueLogo,
    required this.matches,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
        child: Row(children: [
          if (leagueLogo.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: CachedNetworkImage(
                imageUrl: leagueLogo, width: 26, height: 26,
                httpHeaders: _kImgHeaders,
                fit: BoxFit.contain,
                errorWidget: (_, __, ___) =>
                    Icon(Icons.emoji_events, color: c.accent, size: 18),
              ),
            )
          else
            Icon(Icons.emoji_events, color: c.accent, size: 18),
          const SizedBox(width: 10),
          Expanded(
              child: Text(leagueName,
                  style: TextStyle(
                      color: c.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w700))),
          Icon(Icons.chevron_right_rounded, color: c.dim, size: 18),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child:
            Column(children: matches.map((m) => MatchRow(match: m)).toList()),
      ),
    ]);
  }
}

class MatchRow extends StatelessWidget {
  final Map<String, dynamic> match;
  const MatchRow({super.key, required this.match});

  static String _resolveLogoUrl(dynamic team) {
    if (team == null) return '';
    final provided = team['logo'] as String? ?? '';
    if (provided.isNotEmpty) return provided;
    final id = team['id'];
    if (id != null) return 'https://media.api-sports.io/football/teams/$id.png';
    return '';
  }

  static String _resolveLeagueLogoUrl(dynamic league) {
    if (league == null) return '';
    final provided = league['logo'] as String? ?? '';
    if (provided.isNotEmpty) return provided;
    final id = league['id'];
    if (id != null) return 'https://media.api-sports.io/football/leagues/$id.png';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context)!;

    final homeTeam    = match['teams']?['home']?['name'] as String? ?? l10n.matchHomeTeam;
    final awayTeam    = match['teams']?['away']?['name'] as String? ?? l10n.matchAwayTeam;
    final homeLogo    = _resolveLogoUrl(match['teams']?['home']);
    final awayLogo    = _resolveLogoUrl(match['teams']?['away']);
    final homeGoals   = match['goals']?['home'];
    final awayGoals   = match['goals']?['away'];
    final statusShort = match['fixture']?['status']?['short'] as String? ?? 'NS';
    final elapsed     = match['fixture']?['status']?['elapsed'];
    final dateStr     = match['fixture']?['date'] as String? ?? '';
    final leagueName  = match['league']?['name'] as String? ?? '';
    final leagueLogo  = _resolveLeagueLogoUrl(match['league']);

    final isLive     = {'1H', '2H', 'HT', 'ET', 'P'}.contains(statusShort);
    final isFinished = {'FT', 'AET', 'PEN'}.contains(statusShort);
    final hasScore   = isLive || isFinished;

    String timeLabel = '--:--';
    String dateLabel = '';
    String statusLabel = '';
    if (isLive) {
      timeLabel   = elapsed != null ? "$elapsed'" : l10n.matchLive;
      statusLabel = l10n.matchStatusLive;
    } else if (isFinished) {
      timeLabel   = '${homeGoals ?? 0}  –  ${awayGoals ?? 0}';
      statusLabel = l10n.matchStatusFinished;
      if (dateStr.isNotEmpty) {
        try { dateLabel = DateFormat('dd MMM').format(DateTime.parse(dateStr).toLocal()); } catch (_) {}
      }
    } else if (dateStr.isNotEmpty) {
      try {
        final dt  = DateTime.parse(dateStr).toLocal();
        timeLabel   = DateFormat('HH:mm').format(dt);
        dateLabel   = DateFormat('dd MMM').format(dt);
        statusLabel = l10n.matchStatusNotStarted;
      } catch (_) {}
    }

    const liveRed  = Color(0xFFE91E63);
    final timeColor = isLive ? liveRed : isFinished ? c.textHi : c.accent;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isLive ? liveRed.withValues(alpha: 0.30) : c.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── League header ──
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
          child: Row(children: [
            if (leagueLogo.isNotEmpty)
              CachedNetworkImage(
                imageUrl: leagueLogo, width: 15, height: 15,
                httpHeaders: _kImgHeaders,
                fit: BoxFit.contain,
                errorWidget: (_, __, ___) =>
                    Icon(Icons.emoji_events_rounded, color: c.accent, size: 13),
              )
            else
              Icon(Icons.emoji_events_rounded, color: c.accent, size: 13),
            const SizedBox(width: 7),
            Expanded(
              child: Text(leagueName,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: c.dim, fontSize: 10,
                      fontWeight: FontWeight.w600, letterSpacing: 0.3)),
            ),
            if (isLive) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: liveRed.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 5, height: 5,
                      decoration: const BoxDecoration(color: liveRed, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text(l10n.matchLive, style: const TextStyle(color: liveRed, fontSize: 9, fontWeight: FontWeight.w800)),
                ]),
              ),
            ],
          ]),
        ),

        Divider(height: 1, color: c.border),

        // ── Teams + score ──
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              // Home team
              Expanded(
                child: Column(children: [
                  _MatchLogo(url: homeLogo, name: homeTeam, accent: c.accent),
                  const SizedBox(height: 8),
                  Text(homeTeam, maxLines: 1, overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: c.text, fontSize: 12, fontWeight: FontWeight.w700)),
                ]),
              ),

              // Center: score or time
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  if (hasScore && !isFinished)
                    // Live: score side by side
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('${homeGoals ?? 0}',
                          style: TextStyle(color: liveRed, fontSize: 32,
                              fontWeight: FontWeight.w900, letterSpacing: -1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text('–', style: TextStyle(color: c.dim, fontSize: 22,
                            fontWeight: FontWeight.w300)),
                      ),
                      Text('${awayGoals ?? 0}',
                          style: TextStyle(color: liveRed, fontSize: 32,
                              fontWeight: FontWeight.w900, letterSpacing: -1)),
                    ])
                  else
                    Text(timeLabel,
                        style: TextStyle(color: timeColor, fontSize: 20,
                            fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  if (dateLabel.isNotEmpty)
                    Text(dateLabel,
                        style: TextStyle(color: c.muted, fontSize: 10, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(statusLabel,
                      style: TextStyle(color: c.dim, fontSize: 9)),
                ]),
              ),

              // Away team
              Expanded(
                child: Column(children: [
                  _MatchLogo(url: awayLogo, name: awayTeam, accent: c.accent),
                  const SizedBox(height: 8),
                  Text(awayTeam, maxLines: 1, overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: c.text, fontSize: 12, fontWeight: FontWeight.w700)),
                ]),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

class _MatchLogo extends StatelessWidget {
  final String url;
  final String name;
  final Color  accent;
  const _MatchLogo({required this.url, required this.name, required this.accent});

  Widget _fallback() => Container(
    width: 52, height: 52,
    decoration: BoxDecoration(
      color: accent.withValues(alpha: 0.10),
      shape: BoxShape.circle,
      border: Border.all(color: accent.withValues(alpha: 0.25)),
    ),
    child: Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(color: accent, fontSize: 20, fontWeight: FontWeight.w800),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return _fallback();
    return CachedNetworkImage(
      imageUrl: url,
      width: 52,
      height: 52,
      httpHeaders: _kImgHeaders,
      fit: BoxFit.contain,
      placeholder: (_, __) => Container(
        width: 52, height: 52,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.06),
          shape: BoxShape.circle,
        ),
      ),
      errorWidget: (_, __, ___) => _fallback(),
    );
  }
}
