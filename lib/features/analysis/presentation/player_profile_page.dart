import 'package:flutter/material.dart';
import 'package:playvision/features/analysis/data/player_service.dart';
import 'package:playvision/features/analysis/domain/player_profile.dart';

class PlayerProfileScreen extends StatefulWidget {
  final int trackId;
  const PlayerProfileScreen({super.key, required this.trackId});

  @override
  State<PlayerProfileScreen> createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends State<PlayerProfileScreen> {
  late Future<PlayerProfile> _future;

  @override
  void initState() {
    super.initState();
    _future = PlayerService.instance.getProfile(widget.trackId);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFF0A0E1A),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text('Player #${widget.trackId}',
              style: const TextStyle(color: Colors.white)),
        ),
        body: FutureBuilder<PlayerProfile>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(child: Text('${snap.error}',
                  style: const TextStyle(color: Colors.red)));
            }
            return _Body(profile: snap.data!);
          },
        ),
      );
}

class _Body extends StatelessWidget {
  final PlayerProfile profile;
  const _Body({required this.profile});

  @override
  Widget build(BuildContext context) {
    final s = profile.summary;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SummaryCard(summary: s),
        const SizedBox(height: 16),
        _InsightsCard(insights: profile.insights),
        const SizedBox(height: 16),
        _HistoryCard(history: profile.history),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final PlayerSummary summary;
  const _SummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) => _Card(
        title: '📍 ${summary.bestPosition}',
        child: Column(
          children: [
            _Row('Distance',    '${summary.avgDistanceKm} km'),
            _Row('Speed',       '${summary.avgSpeedKmh} km/h'),
            _Row('Possession',  '${summary.avgPossessionPct}%'),
            _Row('Dominant zone', summary.dominantZone),
            _Row('Matches',     '${summary.matchesAnalyzed}'),
          ],
        ),
      );
}

class _InsightsCard extends StatelessWidget {
  final List<String> insights;
  const _InsightsCard({required this.insights});

  @override
  Widget build(BuildContext context) => _Card(
        title: '🧠 Coach Insights',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: insights
              .map((i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(color: Color(0xFF4CAF50))),
                        Expanded(child: Text(i,
                            style: const TextStyle(color: Colors.white70, fontSize: 13))),
                      ],
                    ),
                  ))
              .toList(),
        ),
      );
}

class _HistoryCard extends StatelessWidget {
  final List<PlayerMatchStat> history;
  const _HistoryCard({required this.history});

  @override
  Widget build(BuildContext context) => _Card(
        title: '📅 Match History',
        child: Column(
          children: history
              .map((s) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Match ${s.matchId}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        Text('${s.distanceKm} km · ${s.speedKmh} km/h',
                            style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        Text(s.date,
                            style: const TextStyle(color: Colors.white38, fontSize: 11)),
                      ],
                    ),
                  ))
              .toList(),
        ),
      );
}

// ── Shared UI helpers ─────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final String title;
  final Widget child;
  const _Card({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF131929),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      );
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white54)),
            Text(value,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      );
}
