// lib/features/live_matches/data/match_model.dart

class MatchModel {
  final String homeTeam;
  final String awayTeam;
  final int homeGoals;
  final int awayGoals;
  final int elapsed; // Minutos jugados
  final String homeLogo; // ¡La API también nos da los logos!
  final String awayLogo;

  MatchModel({
    required this.homeTeam,
    required this.awayTeam,
    required this.homeGoals,
    required this.awayGoals,
    required this.elapsed,
    required this.homeLogo,
    required this.awayLogo,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      homeTeam: json['teams']['home']['name'] ?? 'Local',
      awayTeam: json['teams']['away']['name'] ?? 'Visitante',
      homeGoals: json['goals']['home'] ?? 0,
      awayGoals: json['goals']['away'] ?? 0,
      elapsed: json['fixture']['status']['elapsed'] ?? 0,
      homeLogo: json['teams']['home']['logo'] ?? '',
      awayLogo: json['teams']['away']['logo'] ?? '',
    );
  }
}