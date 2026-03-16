import 'package:flutter/material.dart';

class MatchesPage extends StatelessWidget {
  const MatchesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        title: const Text(
          'PARTIDOS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFFE84C1E)),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: const Color(0xFFE84C1E)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 4),
          const _SectionLabel('PRÓXIMOS PARTIDOS'),
          const SizedBox(height: 12),
          _MatchCard(
            rival: 'FC Barcelona B',
            date: '18 Mar 2026',
            time: '19:00',
            location: 'Estadio Municipal',
            status: MatchStatus.upcoming,
          ),
          _MatchCard(
            rival: 'Deportivo Alavés',
            date: '25 Mar 2026',
            time: '17:30',
            location: 'Campo Norte',
            status: MatchStatus.upcoming,
          ),
          const SizedBox(height: 24),
          const _SectionLabel('PARTIDOS RECIENTES'),
          const SizedBox(height: 12),
          _MatchCard(
            rival: 'Real Sociedad B',
            date: '10 Mar 2026',
            time: '20:00',
            location: 'Estadio Municipal',
            status: MatchStatus.won,
            score: '2 - 1',
          ),
          _MatchCard(
            rival: 'Athletic Club B',
            date: '3 Mar 2026',
            time: '18:00',
            location: 'Campo Sur',
            status: MatchStatus.lost,
            score: '0 - 1',
          ),
          _MatchCard(
            rival: 'Osasuna B',
            date: '24 Feb 2026',
            time: '19:30',
            location: 'Estadio Municipal',
            status: MatchStatus.draw,
            score: '1 - 1',
          ),
        ],
      ),
    );
  }
}

enum MatchStatus { upcoming, won, lost, draw }

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF888888),
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final String rival;
  final String date;
  final String time;
  final String location;
  final MatchStatus status;
  final String? score;

  const _MatchCard({
    required this.rival,
    required this.date,
    required this.time,
    required this.location,
    required this.status,
    this.score,
  });

  Color get _statusColor {
    switch (status) {
      case MatchStatus.won:
        return const Color(0xFF2ECC71);
      case MatchStatus.lost:
        return const Color(0xFFE84C1E);
      case MatchStatus.draw:
        return const Color(0xFFFFAA00);
      case MatchStatus.upcoming:
        return const Color(0xFF4A90D9);
    }
  }

  String get _statusLabel {
    switch (status) {
      case MatchStatus.won:
        return 'Victoria';
      case MatchStatus.lost:
        return 'Derrota';
      case MatchStatus.draw:
        return 'Empate';
      case MatchStatus.upcoming:
        return 'Próximo';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF222222)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rival,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 12, color: Color(0xFF888888)),
                    const SizedBox(width: 4),
                    Text(
                      '$date · $time',
                      style: const TextStyle(
                          color: Color(0xFF888888), fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 12, color: Color(0xFF888888)),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: const TextStyle(
                          color: Color(0xFF888888), fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (score != null)
                Text(
                  score!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _statusLabel,
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
