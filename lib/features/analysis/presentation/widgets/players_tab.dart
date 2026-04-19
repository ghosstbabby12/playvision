import 'package:flutter/material.dart';

import '../../../../../core/theme/app_color_tokens.dart';
import '../../../../../shared/widgets/section_label.dart';

class PlayersTab extends StatelessWidget {
  final List players;
  const PlayersTab({super.key, required this.players});

  @override
  Widget build(BuildContext context) => ListView.builder(
    padding: const EdgeInsets.all(20),
    itemCount: players.length + 1,
    itemBuilder: (ctx, i) {
      if (i == 0) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: SectionLabel('PLAYERS'),
        );
      }
      return PlayerCard(player: players[i - 1] as Map<String, dynamic>);
    },
  );
}

class PlayerCard extends StatelessWidget {
  final Map<String, dynamic> player;
  const PlayerCard({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    final c        = context.colors;
    final rank     = player['rank'] as int;
    final km       = (player['distance_km']    as num?)?.toDouble() ?? 0;
    final spd      = (player['speed_ms']       as num?)?.toDouble() ?? 0;
    final poss     = (player['possession_pct'] as num).toDouble();
    final presence = (player['presence_pct']   as num).toDouble();

    return GestureDetector(
      onTap: () => _showPlayerDetail(context, player),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.border),
        ),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: c.accentLo,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text('$rank',
                    style: TextStyle(color: c.accent, fontWeight: FontWeight.w900, fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Player $rank',
                    style: TextStyle(color: c.text, fontWeight: FontWeight.w700, fontSize: 14)),
                Text(player['zone'] as String? ?? '—',
                    style: TextStyle(color: c.dim, fontSize: 12)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: c.elevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: c.border2),
                ),
                child: Text('Details',
                    style: TextStyle(color: c.accent, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: presence / 100,
                backgroundColor: c.border,
                valueColor: AlwaysStoppedAnimation<Color>(c.accentLo),
                minHeight: 3,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(border: Border(top: BorderSide(color: c.border))),
            child: Row(children: [
              _StatColumn('DISTANCE', '${km.toStringAsFixed(2)} km'),
              Container(width: 1, height: 36, color: c.border),
              _StatColumn('SPEED',    '${spd.toStringAsFixed(1)} m/s'),
              Container(width: 1, height: 36, color: c.border),
              _StatColumn('POSS.',    '$poss%'),
            ]),
          ),
        ]),
      ),
    );
  }

  void _showPlayerDetail(BuildContext context, Map<String, dynamic> p) {
    final c        = context.colors;
    final rank     = p['rank'] as int;
    final km       = (p['distance_km']    as num?)?.toDouble() ?? 0;
    final spd      = (p['speed_ms']       as num?)?.toDouble() ?? 0;
    final poss     = (p['possession_pct'] as num).toDouble();
    final presence = (p['presence_pct']   as num).toDouble();

    showModalBottomSheet(
      context: context,
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: c.accentLo,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text('$rank',
                  style: TextStyle(color: c.accent, fontWeight: FontWeight.w900, fontSize: 22)),
            ),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Player $rank',
                  style: TextStyle(color: c.text, fontSize: 18, fontWeight: FontWeight.w700)),
              Text(p['zone'] as String? ?? '—',
                  style: TextStyle(color: c.dim, fontSize: 13)),
            ]),
          ]),
          const SizedBox(height: 24),
          PlayerDetailRow('Distance covered', '${km.toStringAsFixed(2)} km'),
          PlayerDetailRow('Average speed',    '${spd.toStringAsFixed(1)} m/s'),
          PlayerDetailRow('Ball possession',  '$poss%'),
          PlayerDetailRow('Field presence',   '$presence%'),
          PlayerDetailRow('Main zone',        p['zone'] as String? ?? '—'),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.accentLo,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.accentLo),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.auto_awesome_outlined, color: c.accent, size: 16),
              const SizedBox(width: 10),
              Expanded(child: Text(
                km > 0.5
                    ? 'High-activity player. Covered ${km.toStringAsFixed(2)} km and reached ${spd.toStringAsFixed(1)} m/s average speed.'
                    : 'Moderate-activity player. Held position in the ${p['zone'] ?? '—'} zone.',
                style: TextStyle(color: c.text, fontSize: 13, height: 1.5),
              )),
            ]),
          ),
          const SizedBox(height: 10),
        ]),
      ),
    );
  }
}

class PlayerDetailRow extends StatelessWidget {
  final String label;
  final String value;
  const PlayerDetailRow(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Text(label, style: TextStyle(color: c.muted, fontSize: 13)),
        const Spacer(),
        Text(value, style: TextStyle(color: c.text, fontSize: 13, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  const _StatColumn(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(children: [
          Text(label, style: TextStyle(color: c.dim, fontSize: 9, letterSpacing: 0.8)),
          const SizedBox(height: 3),
          Text(value, style: TextStyle(color: c.text, fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}
