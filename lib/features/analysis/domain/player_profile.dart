class PlayerMatchStat {
  final int matchId;
  final double distanceKm;
  final double speedKmh;
  final double possessionPct;
  final String zone;
  final String bestPosition;
  final String date;

  const PlayerMatchStat({
    required this.matchId,
    required this.distanceKm,
    required this.speedKmh,
    required this.possessionPct,
    required this.zone,
    required this.bestPosition,
    required this.date,
  });

  factory PlayerMatchStat.fromJson(Map<String, dynamic> j) => PlayerMatchStat(
        matchId:       j['match_id'] ?? 0,
        distanceKm:    (j['distance_km'] ?? 0).toDouble(),
        speedKmh:      (j['speed_kmh']   ?? 0).toDouble(),
        possessionPct: (j['possession_pct'] ?? 0).toDouble(),
        zone:          j['zone']          ?? '',
        bestPosition:  j['best_position'] ?? '',
        date:          j['date']          ?? '',
      );
}

class PlayerSummary {
  final double avgDistanceKm;
  final double avgSpeedKmh;
  final double avgPossessionPct;
  final double avgPresencePct;
  final String dominantZone;
  final String bestPosition;
  final int matchesAnalyzed;

  const PlayerSummary({
    required this.avgDistanceKm,
    required this.avgSpeedKmh,
    required this.avgPossessionPct,
    required this.avgPresencePct,
    required this.dominantZone,
    required this.bestPosition,
    required this.matchesAnalyzed,
  });

  factory PlayerSummary.fromJson(Map<String, dynamic> j) => PlayerSummary(
        avgDistanceKm:   (j['avg_distance_km']    ?? 0).toDouble(),
        avgSpeedKmh:     (j['avg_speed_kmh']       ?? 0).toDouble(),
        avgPossessionPct:(j['avg_possession_pct']  ?? 0).toDouble(),
        avgPresencePct:  (j['avg_presence_pct']    ?? 0).toDouble(),
        dominantZone:    j['dominant_zone']         ?? '',
        bestPosition:    j['best_position']         ?? '',
        matchesAnalyzed: j['matches_analyzed']      ?? 0,
      );
}

class PlayerProfile {
  final int trackId;
  final PlayerSummary summary;
  final List<String> insights;
  final List<PlayerMatchStat> history;

  const PlayerProfile({
    required this.trackId,
    required this.summary,
    required this.insights,
    required this.history,
  });

  factory PlayerProfile.fromJson(Map<String, dynamic> j) => PlayerProfile(
        trackId:  j['track_id'] ?? 0,
        summary:  PlayerSummary.fromJson(j['summary'] ?? {}),
        insights: List<String>.from(j['insights'] ?? []),
        history:  (j['match_history'] as List? ?? [])
            .map((s) => PlayerMatchStat.fromJson(s))
            .toList(),
      );
}
