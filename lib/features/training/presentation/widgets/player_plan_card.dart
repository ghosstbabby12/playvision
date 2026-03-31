import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class PlayerPlanCard extends StatelessWidget {
  final Map<String, dynamic> player;
  final List<String> recommendations;
  const PlayerPlanCard({
    super.key,
    required this.player,
    required this.recommendations,
  });

  @override
  Widget build(BuildContext context) {
    final rank = player['rank'] as int;
    final km   = (player['distance_km'] as num?)?.toDouble() ?? 0;
    final spd  = (player['speed_ms']    as num?)?.toDouble() ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          leading: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: const Color(0x1A7C9EBF),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text('$rank',
                style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w900, fontSize: 16)),
          ),
          title: Text('Player $rank',
              style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600, fontSize: 14)),
          subtitle: Text('${km.toStringAsFixed(2)} km · ${spd.toStringAsFixed(1)} m/s',
              style: const TextStyle(color: AppColors.dim, fontSize: 11)),
          iconColor: AppColors.accent,
          collapsedIconColor: AppColors.dim,
          children: recommendations.map((rec) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(Icons.arrow_right_rounded, color: AppColors.accent, size: 16),
              ),
              const SizedBox(width: 6),
              Expanded(child: Text(rec,
                  style: const TextStyle(color: AppColors.muted, fontSize: 13, height: 1.4))),
            ]),
          )).toList(),
        ),
      ),
    );
  }
}
