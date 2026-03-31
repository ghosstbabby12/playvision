import 'package:flutter/foundation.dart';

import '../../../core/store/analysis_store.dart';

class TrainingController extends ChangeNotifier {
  Map<String, dynamic>? get result => AnalysisStore.instance.lastResult;
  List? get players => result?['players'] as List?;
  Map<String, dynamic>? get team => result?['team'] as Map<String, dynamic>?;

  List<String> buildTeamInsights() {
    final insights = <String>[];
    if (team == null || players == null || players!.isEmpty) return insights;

    final avgKm    = (team!['avg_distance_km'] as num?)?.toDouble() ?? 0;
    final possPct  = (team!['possession_pct']  as num?)?.toDouble() ?? 0;
    final mostActive  = team!['most_active'];
    final leastActive = team!['least_active'];
    final mostPoss    = team!['most_possession'];

    if (avgKm < 1.5) {
      insights.add('The team covers little average distance (${avgKm.toStringAsFixed(2)} km). Increase aerobic intensity in endurance sessions.');
    } else if (avgKm > 3.0) {
      insights.add('The team shows high mobility (${avgKm.toStringAsFixed(2)} km/player). Focus on recovery and effort management.');
    }

    if (possPct < 30) {
      insights.add('The team loses possession frequently (${possPct.toStringAsFixed(1)}%). Reinforce positional play in own half.');
    } else if (possPct > 60) {
      insights.add('Good team possession (${possPct.toStringAsFixed(1)}%). Focus on finishing plays and exploiting dominance.');
    }

    if (mostActive != null && leastActive != null && mostActive != leastActive) {
      insights.add('Large gap between most active player (#$mostActive) and least active (#$leastActive). Work on tactical effort distribution.');
    }

    if (mostPoss != null) {
      insights.add('Player #$mostPoss concentrates the most possession. Work on ball circulation to distribute play.');
    }

    if (insights.isEmpty) {
      insights.add('Overall team performance is balanced. Continue with the current tactical plan and reinforce on-field communication.');
    }

    return insights;
  }

  List<String> buildPlayerRecommendations(Map<String, dynamic> player) {
    final recs     = <String>[];
    final km       = (player['distance_km']   as num?)?.toDouble() ?? 0;
    final speed    = (player['speed_ms']      as num?)?.toDouble() ?? 0;
    final poss     = (player['possession_pct'] as num?)?.toDouble() ?? 0;
    final presence = (player['presence_pct']  as num?)?.toDouble() ?? 0;
    final zone     = player['zone'] as String? ?? '';

    if (km < 0.5)       recs.add('Increase endurance: short distance covered. Add interval runs.');
    if (speed < 1.5)    recs.add('Work on explosive speed: low recorded pace.');
    if (poss < 5)       recs.add('Improve ball involvement: participate more in build-up play.');
    if (presence < 50)  recs.add('Increase field presence: player covered less than half the match.');
    if (zone.contains('Defensa')) recs.add('Defensive role: reinforce positioning and anticipation.');
    if (zone.contains('Ataque'))  recs.add('Attacking role: work on finishing and off-ball movement.');

    if (recs.isEmpty) {
      recs.add('Solid performance. Maintain current work rate and tactical discipline.');
    }

    return recs;
  }
}
