import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:playvision/core/theme/app_color_tokens.dart';

import '../../../../../../l10n/generated/app_localizations.dart';

class MatchScheduleSection extends StatelessWidget {
  final bool isLoading;
  final List<dynamic> matches;
  const MatchScheduleSection({super.key, required this.isLoading, required this.matches});

  @override
  Widget build(BuildContext context) {
    final c    = context.colors;
    final l10n = AppLocalizations.of(context)!;

    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator(color: c.accent, strokeWidth: 1.5)),
      );
    }

    if (matches.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.border),
          ),
          child: Center(child: Column(children: [
            Icon(Icons.sports_soccer_outlined, color: c.dim, size: 28),
            const SizedBox(height: 8),
            Text(l10n.noRealMatchesToday, style: TextStyle(color: c.muted, fontSize: 13)),
          ])),
        ),
      );
    }

    final typedMatches = matches.cast<Map<String, dynamic>>();

    final hero = typedMatches.firstWhere(
      (m) {
        final s = m['fixture']?['status']?['short'] as String? ?? '';
        return s == '1H' || s == '2H' || s == 'HT';
      },
      orElse: () => typedMatches.first,
    );

    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final m in typedMatches) {
      final key = m['league']?['name'] as String? ?? 'Others';
      grouped.putIfAbsent(key, () => []).add(m);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: FeaturedMatchCard(match: hero),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Match Schedule',
                style: TextStyle(color: c.textHi, fontSize: 20, fontWeight: FontWeight.w800)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(color: c.accentLo, borderRadius: BorderRadius.circular(20)),
              child: Text('${matches.length} matches',
                  style: TextStyle(color: c.accent, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
      ...grouped.entries.map((entry) => LeagueGroup(
        leagueName: entry.key,
        leagueLogo: entry.value.first['league']?['logo'] as String? ?? '',
        matches: entry.value,
      )),
      const SizedBox(height: 8),
    ]);
  }
}

class FeaturedMatchCard extends StatelessWidget {
  final Map<String, dynamic> match;
  const FeaturedMatchCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    final homeTeam    = match['teams']?['home']?['name'] as String? ?? 'Home';
    final awayTeam    = match['teams']?['away']?['name'] as String? ?? 'Away';
    final homeLogo    = match['teams']?['home']?['logo'] as String? ?? '';
    final awayLogo    = match['teams']?['away']?['logo'] as String? ?? '';
    final homeGoals   = match['goals']?['home'];
    final awayGoals   = match['goals']?['away'];
    final statusShort = match['fixture']?['status']?['short'] as String? ?? 'NS';
    final elapsed     = match['fixture']?['status']?['elapsed'];
    final dateStr     = match['fixture']?['date'] as String? ?? '';
    final leagueName  = match['league']?['name'] as String? ?? '';
    final leagueLogo  = match['league']?['logo'] as String? ?? '';

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
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                if (leagueLogo.isNotEmpty)
                  Image.network(leagueLogo, width: 20, height: 20,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.emoji_events, color: Colors.white70, size: 16))
                else
                  const Icon(Icons.emoji_events, color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(leagueName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600))),
                if (isLive)
                  LiveBadge(time: timeText)
                else if (isFinished)
                  const StatusPill(label: 'FT')
                else if (timeText.isNotEmpty)
                  StatusPill(label: timeText),
              ]),
              const Spacer(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: Column(children: [
                  HeroTeamLogo(logoUrl: homeLogo, name: homeTeam),
                  const SizedBox(height: 8),
                  Text(homeTeam,
                      maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                ])),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: isFinished || isLive
                      ? Row(mainAxisSize: MainAxisSize.min, children: [
                          Text('${homeGoals ?? 0}',
                              style: TextStyle(
                                color: isLive ? c.accent : Colors.white,
                                fontSize: 38, fontWeight: FontWeight.w900, letterSpacing: -1,
                              )),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text('–',
                                style: TextStyle(color: Colors.white38, fontSize: 26, fontWeight: FontWeight.w300)),
                          ),
                          Text('${awayGoals ?? 0}',
                              style: TextStyle(
                                color: isLive ? c.accent : Colors.white,
                                fontSize: 38, fontWeight: FontWeight.w900, letterSpacing: -1,
                              )),
                        ])
                      : const Text('VS',
                          style: TextStyle(
                              color: Colors.white54, fontSize: 22,
                              fontWeight: FontWeight.w800, letterSpacing: 3)),
                ),
                Expanded(child: Column(children: [
                  HeroTeamLogo(logoUrl: awayLogo, name: awayTeam),
                  const SizedBox(height: 8),
                  Text(awayTeam,
                      maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE91E63),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 6, height: 6,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(time.isEmpty ? 'LIVE' : 'LIVE  $time',
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
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
          style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}

class HeroTeamLogo extends StatelessWidget {
  final String logoUrl;
  final String name;
  const HeroTeamLogo({super.key, required this.logoUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    if (logoUrl.isNotEmpty) {
      return Image.network(logoUrl, width: 52, height: 52,
          errorBuilder: (_, __, ___) => _placeholder());
    }
    return _placeholder();
  }

  Widget _placeholder() => Container(
    width: 52, height: 52,
    decoration: const BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
    child: Center(child: Text(
      name.isNotEmpty ? name[0].toUpperCase() : '?',
      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
    )),
  );
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
              child: Image.network(leagueLogo, width: 26, height: 26,
                  errorBuilder: (_, __, ___) => Icon(Icons.emoji_events, color: c.accent, size: 18)),
            )
          else
            Icon(Icons.emoji_events, color: c.accent, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(leagueName,
              style: TextStyle(color: c.text, fontSize: 13, fontWeight: FontWeight.w700))),
          Icon(Icons.chevron_right_rounded, color: c.dim, size: 18),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(children: matches.map((m) => MatchRow(match: m)).toList()),
      ),
    ]);
  }
}

class MatchRow extends StatelessWidget {
  final Map<String, dynamic> match;
  const MatchRow({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    final homeTeam    = match['teams']?['home']?['name'] as String? ?? 'Local';
    final awayTeam    = match['teams']?['away']?['name'] as String? ?? 'Away';
    final homeLogo    = match['teams']?['home']?['logo'] as String? ?? '';
    final awayLogo    = match['teams']?['away']?['logo'] as String? ?? '';
    final homeGoals   = match['goals']?['home'];
    final awayGoals   = match['goals']?['away'];
    final statusShort = match['fixture']?['status']?['short'] as String? ?? 'NS';
    final elapsed     = match['fixture']?['status']?['elapsed'];
    final dateStr     = match['fixture']?['date'] as String? ?? '';

    final isLive     = statusShort == '1H' || statusShort == '2H' || statusShort == 'HT';
    final isFinished = statusShort == 'FT' || statusShort == 'AET' || statusShort == 'PEN';

    String centerTop;
    String centerBottom = '';
    Color  centerColor;

    if (isLive) {
      centerTop    = '${homeGoals ?? 0} – ${awayGoals ?? 0}';
      centerBottom = elapsed != null ? "$elapsed'" : 'LIVE';
      centerColor  = const Color(0xFFE91E63);
    } else if (isFinished) {
      centerTop    = '${homeGoals ?? 0} – ${awayGoals ?? 0}';
      centerBottom = 'FT';
      centerColor  = c.textHi;
    } else {
      if (dateStr.isNotEmpty) {
        try {
          final dt = DateTime.parse(dateStr).toLocal();
          centerTop    = DateFormat('HH:mm').format(dt);
          centerBottom = DateFormat('dd MMM').format(dt);
        } catch (_) { centerTop = '--:--'; }
      } else {
        centerTop = '--:--';
      }
      centerColor = c.accent;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLive ? const Color(0xFFE91E63).withValues(alpha: 0.35) : c.border,
        ),
      ),
      child: Row(children: [
        Expanded(child: Row(children: [
          MatchTeamLogo(logoUrl: homeLogo, name: homeTeam, accentColor: c.accent),
          const SizedBox(width: 8),
          Expanded(child: Text(homeTeam,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(color: c.text, fontSize: 13, fontWeight: FontWeight.w600))),
        ])),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isLive
                ? const Color(0xFFE91E63).withValues(alpha: 0.12)
                : c.elevated,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(centerTop,
                style: TextStyle(color: centerColor, fontSize: 14, fontWeight: FontWeight.w800)),
            if (centerBottom.isNotEmpty)
              Text(centerBottom,
                  style: TextStyle(
                    color: isLive ? const Color(0xFFE91E63) : c.dim,
                    fontSize: 9, fontWeight: FontWeight.w700,
                  )),
          ]),
        ),
        Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          Expanded(child: Text(awayTeam,
              maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.end,
              style: TextStyle(color: c.text, fontSize: 13, fontWeight: FontWeight.w600))),
          const SizedBox(width: 8),
          MatchTeamLogo(logoUrl: awayLogo, name: awayTeam, accentColor: c.accent),
        ])),
      ]),
    );
  }
}

class MatchTeamLogo extends StatelessWidget {
  final String logoUrl;
  final String name;
  final Color  accentColor;
  const MatchTeamLogo({super.key, required this.logoUrl, required this.name, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (logoUrl.isNotEmpty) {
      return Image.network(logoUrl, width: 28, height: 28,
          errorBuilder: (_, __, ___) => _placeholder(c));
    }
    return _placeholder(c);
  }

  Widget _placeholder(AppColorTokens c) => Container(
    width: 28, height: 28,
    decoration: BoxDecoration(color: c.elevated, shape: BoxShape.circle),
    child: Center(child: Text(
      name.isNotEmpty ? name[0].toUpperCase() : '?',
      style: TextStyle(color: accentColor, fontSize: 11, fontWeight: FontWeight.w700),
    )),
  );
}
