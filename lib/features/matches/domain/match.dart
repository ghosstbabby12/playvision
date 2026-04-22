class Match {
  final String homeTeam;
  final String awayTeam;
  final String? homeLogo;
  final String? awayLogo;
  final int? homeGoals;
  final int? awayGoals;
  final String statusShort;
  final int? elapsed;
  final String? date;
  final String? leagueName;
  final String? leagueLogo;

  const Match({
    required this.homeTeam,
    required this.awayTeam,
    required this.statusShort,
    this.homeLogo,
    this.awayLogo,
    this.homeGoals,
    this.awayGoals,
    this.elapsed,
    this.date,
    this.leagueName,
    this.leagueLogo,
  });

  bool get isLive =>
      statusShort == '1H' || statusShort == '2H' || statusShort == 'HT';

  bool get isFinished =>
      statusShort == 'FT' || statusShort == 'AET' || statusShort == 'PEN';
}
