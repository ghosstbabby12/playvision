class PlayerAttributes {
  final int pace, shooting, passing, dribbling, defending, physical;
  const PlayerAttributes({
    required this.pace,
    required this.shooting,
    required this.passing,
    required this.dribbling,
    required this.defending,
    required this.physical,
  });
  factory PlayerAttributes.fromJson(Map<String, dynamic> j) => PlayerAttributes(
        pace:      j['pace']      ?? 70,
        shooting:  j['shooting']  ?? 70,
        passing:   j['passing']   ?? 70,
        dribbling: j['dribbling'] ?? 70,
        defending: j['defending'] ?? 40,
        physical:  j['physical']  ?? 70,
      );
}

class MatchStatLine {
  final double? rating;
  final int? goals, assists, passes, minutes;
  final double? distanceKm;
  final int? passAccuracy;
  const MatchStatLine({
    this.rating, this.goals, this.assists,
    this.passes, this.minutes, this.distanceKm, this.passAccuracy,
  });
  factory MatchStatLine.fromJson(Map<String, dynamic> j) => MatchStatLine(
        rating:       (j['rating']        as num?)?.toDouble(),
        goals:         j['goals']         as int?,
        assists:       j['assists']       as int?,
        passes:        j['passes']        as int?,
        minutes:       j['minutes']       as int?,
        distanceKm:   (j['distance_km']  as num?)?.toDouble(),
        passAccuracy:  j['pass_accuracy'] as int?,
      );
}

class HistoryPoint {
  final double rating;
  final int goals, assists;
  final String date;
  const HistoryPoint({required this.rating, required this.goals, required this.assists, required this.date});
  factory HistoryPoint.fromJson(Map<String, dynamic> j) => HistoryPoint(
        rating:  (j['rating']  as num?)?.toDouble() ?? 7.0,
        goals:    j['goals']   as int? ?? 0,
        assists:  j['assists'] as int? ?? 0,
        date:     j['date']    as String? ?? '',
      );
}

class AiInsights {
  final String form, bestPosition, recommendation;
  final double avgRating;
  const AiInsights({
    required this.form,
    required this.bestPosition,
    required this.recommendation,
    required this.avgRating,
  });
  factory AiInsights.fromJson(Map<String, dynamic> j) => AiInsights(
        form:           j['form']           ?? 'Good',
        bestPosition:   j['best_position']  ?? '',
        recommendation: j['recommendation'] ?? '',
        avgRating:      (j['avg_rating'] as num?)?.toDouble() ?? 7.0,
      );
}

class PlayerProfile {
  final int id;
  final String name;
  final int? number;
  final String? position, foot, photoUrl;
  final int? overall, age, heightCm;
  final PlayerAttributes attributes;
  final MatchStatLine lastMatch;
  final List<HistoryPoint> history;
  final AiInsights aiInsights;

  const PlayerProfile({
    required this.id,
    required this.name,
    required this.attributes,
    required this.lastMatch,
    required this.history,
    required this.aiInsights,
    this.number,
    this.position,
    this.foot,
    this.photoUrl,
    this.overall,
    this.age,
    this.heightCm,
  });

  factory PlayerProfile.fromJson(Map<String, dynamic> j) => PlayerProfile(
        id:         j['id'],
        name:       j['name'] ?? '',
        number:     j['number']   as int?,
        position:   j['position'] as String?,
        foot:       j['foot']     as String?,
        photoUrl:   j['photo_url'] as String?,
        overall:    j['overall']  as int?,
        age:        j['age']      as int?,
        heightCm:   j['height_cm'] as int?,
        attributes: PlayerAttributes.fromJson(
            (j['attributes'] as Map<String, dynamic>?) ?? {}),
        lastMatch:  MatchStatLine.fromJson(
            (j['last_match'] as Map<String, dynamic>?) ?? {}),
        history: ((j['history'] as List?) ?? [])
            .map((e) => HistoryPoint.fromJson(e as Map<String, dynamic>))
            .toList(),
        aiInsights: AiInsights.fromJson(
            (j['ai_insights'] as Map<String, dynamic>?) ?? {}),
      );
}
