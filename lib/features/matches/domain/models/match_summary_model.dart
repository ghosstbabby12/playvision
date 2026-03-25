class MatchSummary {
  final SourceInfo source;
  final MatchStats stats;
  final TeamGroup teams;
  final List<PlayerSummary> allPlayers;
  final List<FrameCount> frameCounts;

  const MatchSummary({
    required this.source,
    required this.stats,
    required this.teams,
    required this.allPlayers,
    required this.frameCounts,
  });

  factory MatchSummary.fromJson(Map<String, dynamic> json) {
    return MatchSummary(
      source: SourceInfo.fromJson(_Parser.map(json['source'])),
      stats: MatchStats.fromJson(_Parser.map(json['stats'])),
      teams: TeamGroup.fromJson(_Parser.map(json['teams'])),
      allPlayers: _Parser.list(json['all_players'])
          .map((e) => PlayerSummary.fromJson(_Parser.map(e)))
          .toList(),
      frameCounts: _Parser.list(json['frame_counts'])
          .map((e) => FrameCount.fromJson(_Parser.map(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': source.toJson(),
      'stats': stats.toJson(),
      'teams': teams.toJson(),
      'all_players': allPlayers.map((e) => e.toJson()).toList(),
      'frame_counts': frameCounts.map((e) => e.toJson()).toList(),
    };
  }

  MatchSummary copyWith({
    SourceInfo? source,
    MatchStats? stats,
    TeamGroup? teams,
    List<PlayerSummary>? allPlayers,
    List<FrameCount>? frameCounts,
  }) {
    return MatchSummary(
      source: source ?? this.source,
      stats: stats ?? this.stats,
      teams: teams ?? this.teams,
      allPlayers: allPlayers ?? this.allPlayers,
      frameCounts: frameCounts ?? this.frameCounts,
    );
  }

  bool get isEmptySummary =>
      allPlayers.isEmpty &&
      frameCounts.isEmpty &&
      stats.totalPlayersDetected == 0 &&
      stats.stablePlayersDetected == 0;

  bool get hasUnknownPlayers => teams.unknown.isNotEmpty;

  bool get hasFrameCounts => frameCounts.isNotEmpty;

  List<PlayerSummary> get stablePlayers =>
      allPlayers.where((player) => player.stablePlayer).toList();

  List<PlayerSummary> get unstablePlayers =>
      allPlayers.where((player) => !player.stablePlayer).toList();

  int get totalGroupedPlayers =>
      teams.greenTeam.length + teams.redTeam.length + teams.unknown.length;
}

class SourceInfo {
  final String playerSummaryCsv;
  final String teamCountsCsv;
  final String teamSummaryCsv;

  const SourceInfo({
    required this.playerSummaryCsv,
    required this.teamCountsCsv,
    required this.teamSummaryCsv,
  });

  factory SourceInfo.fromJson(Map<String, dynamic> json) {
    return SourceInfo(
      playerSummaryCsv: _Parser.string(json['player_summary_csv']),
      teamCountsCsv: _Parser.string(json['team_counts_csv']),
      teamSummaryCsv: _Parser.string(json['team_summary_csv']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'player_summary_csv': playerSummaryCsv,
      'team_counts_csv': teamCountsCsv,
      'team_summary_csv': teamSummaryCsv,
    };
  }

  SourceInfo copyWith({
    String? playerSummaryCsv,
    String? teamCountsCsv,
    String? teamSummaryCsv,
  }) {
    return SourceInfo(
      playerSummaryCsv: playerSummaryCsv ?? this.playerSummaryCsv,
      teamCountsCsv: teamCountsCsv ?? this.teamCountsCsv,
      teamSummaryCsv: teamSummaryCsv ?? this.teamSummaryCsv,
    );
  }

  bool get hasAnySource =>
      playerSummaryCsv.isNotEmpty ||
      teamCountsCsv.isNotEmpty ||
      teamSummaryCsv.isNotEmpty;
}

class MatchStats {
  final int totalPlayersDetected;
  final int stablePlayersDetected;
  final int unstablePlayersDetected;
  final int greenTeamStablePlayers;
  final int redTeamStablePlayers;
  final int unknownStablePlayers;
  final int framesWithCounts;
  final int maxGreenVisible;
  final int maxRedVisible;
  final int maxUnknownVisible;
  final int maxTotalVisible;
  final double avgGreenVisible;
  final double avgRedVisible;
  final double avgUnknownVisible;

  const MatchStats({
    required this.totalPlayersDetected,
    required this.stablePlayersDetected,
    required this.unstablePlayersDetected,
    required this.greenTeamStablePlayers,
    required this.redTeamStablePlayers,
    required this.unknownStablePlayers,
    required this.framesWithCounts,
    required this.maxGreenVisible,
    required this.maxRedVisible,
    required this.maxUnknownVisible,
    required this.maxTotalVisible,
    required this.avgGreenVisible,
    required this.avgRedVisible,
    required this.avgUnknownVisible,
  });

  factory MatchStats.fromJson(Map<String, dynamic> json) {
    return MatchStats(
      totalPlayersDetected: _Parser.intValue(json['total_players_detected']),
      stablePlayersDetected: _Parser.intValue(json['stable_players_detected']),
      unstablePlayersDetected: _Parser.intValue(
        json['unstable_players_detected'],
      ),
      greenTeamStablePlayers: _Parser.intValue(
        json['green_team_stable_players'],
      ),
      redTeamStablePlayers: _Parser.intValue(json['red_team_stable_players']),
      unknownStablePlayers: _Parser.intValue(json['unknown_stable_players']),
      framesWithCounts: _Parser.intValue(json['frames_with_counts']),
      maxGreenVisible: _Parser.intValue(json['max_green_visible']),
      maxRedVisible: _Parser.intValue(json['max_red_visible']),
      maxUnknownVisible: _Parser.intValue(json['max_unknown_visible']),
      maxTotalVisible: _Parser.intValue(json['max_total_visible']),
      avgGreenVisible: _Parser.doubleValue(json['avg_green_visible']),
      avgRedVisible: _Parser.doubleValue(json['avg_red_visible']),
      avgUnknownVisible: _Parser.doubleValue(json['avg_unknown_visible']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_players_detected': totalPlayersDetected,
      'stable_players_detected': stablePlayersDetected,
      'unstable_players_detected': unstablePlayersDetected,
      'green_team_stable_players': greenTeamStablePlayers,
      'red_team_stable_players': redTeamStablePlayers,
      'unknown_stable_players': unknownStablePlayers,
      'frames_with_counts': framesWithCounts,
      'max_green_visible': maxGreenVisible,
      'max_red_visible': maxRedVisible,
      'max_unknown_visible': maxUnknownVisible,
      'max_total_visible': maxTotalVisible,
      'avg_green_visible': avgGreenVisible,
      'avg_red_visible': avgRedVisible,
      'avg_unknown_visible': avgUnknownVisible,
    };
  }

  MatchStats copyWith({
    int? totalPlayersDetected,
    int? stablePlayersDetected,
    int? unstablePlayersDetected,
    int? greenTeamStablePlayers,
    int? redTeamStablePlayers,
    int? unknownStablePlayers,
    int? framesWithCounts,
    int? maxGreenVisible,
    int? maxRedVisible,
    int? maxUnknownVisible,
    int? maxTotalVisible,
    double? avgGreenVisible,
    double? avgRedVisible,
    double? avgUnknownVisible,
  }) {
    return MatchStats(
      totalPlayersDetected: totalPlayersDetected ?? this.totalPlayersDetected,
      stablePlayersDetected: stablePlayersDetected ?? this.stablePlayersDetected,
      unstablePlayersDetected:
          unstablePlayersDetected ?? this.unstablePlayersDetected,
      greenTeamStablePlayers:
          greenTeamStablePlayers ?? this.greenTeamStablePlayers,
      redTeamStablePlayers: redTeamStablePlayers ?? this.redTeamStablePlayers,
      unknownStablePlayers: unknownStablePlayers ?? this.unknownStablePlayers,
      framesWithCounts: framesWithCounts ?? this.framesWithCounts,
      maxGreenVisible: maxGreenVisible ?? this.maxGreenVisible,
      maxRedVisible: maxRedVisible ?? this.maxRedVisible,
      maxUnknownVisible: maxUnknownVisible ?? this.maxUnknownVisible,
      maxTotalVisible: maxTotalVisible ?? this.maxTotalVisible,
      avgGreenVisible: avgGreenVisible ?? this.avgGreenVisible,
      avgRedVisible: avgRedVisible ?? this.avgRedVisible,
      avgUnknownVisible: avgUnknownVisible ?? this.avgUnknownVisible,
    );
  }

  double get avgTotalVisible =>
      avgGreenVisible + avgRedVisible + avgUnknownVisible;

  bool get hasStablePlayers => stablePlayersDetected > 0;
}

class TeamGroup {
  final List<PlayerSummary> greenTeam;
  final List<PlayerSummary> redTeam;
  final List<PlayerSummary> unknown;

  const TeamGroup({
    required this.greenTeam,
    required this.redTeam,
    required this.unknown,
  });

  factory TeamGroup.fromJson(Map<String, dynamic> json) {
    return TeamGroup(
      greenTeam: _Parser.list(json['green_team'])
          .map((e) => PlayerSummary.fromJson(_Parser.map(e)))
          .toList(),
      redTeam: _Parser.list(json['red_team'])
          .map((e) => PlayerSummary.fromJson(_Parser.map(e)))
          .toList(),
      unknown: _Parser.list(json['unknown'])
          .map((e) => PlayerSummary.fromJson(_Parser.map(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'green_team': greenTeam.map((e) => e.toJson()).toList(),
      'red_team': redTeam.map((e) => e.toJson()).toList(),
      'unknown': unknown.map((e) => e.toJson()).toList(),
    };
  }

  TeamGroup copyWith({
    List<PlayerSummary>? greenTeam,
    List<PlayerSummary>? redTeam,
    List<PlayerSummary>? unknown,
  }) {
    return TeamGroup(
      greenTeam: greenTeam ?? this.greenTeam,
      redTeam: redTeam ?? this.redTeam,
      unknown: unknown ?? this.unknown,
    );
  }

  int get totalPlayers => greenTeam.length + redTeam.length + unknown.length;

  bool get hasUnknown => unknown.isNotEmpty;

  List<PlayerSummary> get all => [
        ...greenTeam,
        ...redTeam,
        ...unknown,
      ];
}

class PlayerSummary {
  final int trackId;
  final int firstFrame;
  final int lastFrame;
  final int framesDetected;
  final int maxFramesSeen;
  final double avgConf;
  final double avgColorScore;
  final int greenVotes;
  final int redVotes;
  final int unknownVotes;
  final String finalTeamPlayer;
  final bool stablePlayer;
  final AvgBox avgBox;

  const PlayerSummary({
    required this.trackId,
    required this.firstFrame,
    required this.lastFrame,
    required this.framesDetected,
    required this.maxFramesSeen,
    required this.avgConf,
    required this.avgColorScore,
    required this.greenVotes,
    required this.redVotes,
    required this.unknownVotes,
    required this.finalTeamPlayer,
    required this.stablePlayer,
    required this.avgBox,
  });

  factory PlayerSummary.fromJson(Map<String, dynamic> json) {
    return PlayerSummary(
      trackId: _Parser.intValue(json['track_id']),
      firstFrame: _Parser.intValue(json['first_frame']),
      lastFrame: _Parser.intValue(json['last_frame']),
      framesDetected: _Parser.intValue(json['frames_detected']),
      maxFramesSeen: _Parser.intValue(json['max_frames_seen']),
      avgConf: _Parser.doubleValue(json['avg_conf']),
      avgColorScore: _Parser.doubleValue(json['avg_color_score']),
      greenVotes: _Parser.intValue(json['green_votes']),
      redVotes: _Parser.intValue(json['red_votes']),
      unknownVotes: _Parser.intValue(json['unknown_votes']),
      finalTeamPlayer: _Parser.string(
        json['final_team_player'],
        fallback: 'unknown',
      ),
      stablePlayer: _Parser.boolValue(json['stable_player']),
      avgBox: AvgBox.fromJson(_Parser.map(json['avg_box'])),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'track_id': trackId,
      'first_frame': firstFrame,
      'last_frame': lastFrame,
      'frames_detected': framesDetected,
      'max_frames_seen': maxFramesSeen,
      'avg_conf': avgConf,
      'avg_color_score': avgColorScore,
      'green_votes': greenVotes,
      'red_votes': redVotes,
      'unknown_votes': unknownVotes,
      'final_team_player': finalTeamPlayer,
      'stable_player': stablePlayer,
      'avg_box': avgBox.toJson(),
    };
  }

  PlayerSummary copyWith({
    int? trackId,
    int? firstFrame,
    int? lastFrame,
    int? framesDetected,
    int? maxFramesSeen,
    double? avgConf,
    double? avgColorScore,
    int? greenVotes,
    int? redVotes,
    int? unknownVotes,
    String? finalTeamPlayer,
    bool? stablePlayer,
    AvgBox? avgBox,
  }) {
    return PlayerSummary(
      trackId: trackId ?? this.trackId,
      firstFrame: firstFrame ?? this.firstFrame,
      lastFrame: lastFrame ?? this.lastFrame,
      framesDetected: framesDetected ?? this.framesDetected,
      maxFramesSeen: maxFramesSeen ?? this.maxFramesSeen,
      avgConf: avgConf ?? this.avgConf,
      avgColorScore: avgColorScore ?? this.avgColorScore,
      greenVotes: greenVotes ?? this.greenVotes,
      redVotes: redVotes ?? this.redVotes,
      unknownVotes: unknownVotes ?? this.unknownVotes,
      finalTeamPlayer: finalTeamPlayer ?? this.finalTeamPlayer,
      stablePlayer: stablePlayer ?? this.stablePlayer,
      avgBox: avgBox ?? this.avgBox,
    );
  }

  String get normalizedTeam {
    final value = finalTeamPlayer.trim().toLowerCase();

    switch (value) {
      case 'green':
      case 'greenteam':
      case 'green_team':
        return 'green';

      case 'red':
      case 'redteam':
      case 'red_team':
        return 'red';

      case 'unknown':
      case 'unknownteam':
      case 'unknown_team':
        return 'unknown';

      default:
        return 'unknown';
    }
  }

  String get teamLabel {
    switch (normalizedTeam) {
      case 'green':
        return 'Verde';
      case 'red':
        return 'Rojo';
      default:
        return 'Desconocido';
    }
  }

  int get totalVotes => greenVotes + redVotes + unknownVotes;

  int get visibleSpanFrames => (lastFrame - firstFrame + 1).clamp(0, 1 << 30);

  bool get isGreen => normalizedTeam == 'green';
  bool get isRed => normalizedTeam == 'red';
  bool get isUnknown => normalizedTeam == 'unknown';
}

class AvgBox {
  final int x1;
  final int y1;
  final int x2;
  final int y2;

  const AvgBox({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
  });

  factory AvgBox.fromJson(Map<String, dynamic> json) {
    return AvgBox(
      x1: _Parser.intValue(json['x1']),
      y1: _Parser.intValue(json['y1']),
      x2: _Parser.intValue(json['x2']),
      y2: _Parser.intValue(json['y2']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x1': x1,
      'y1': y1,
      'x2': x2,
      'y2': y2,
    };
  }

  AvgBox copyWith({
    int? x1,
    int? y1,
    int? x2,
    int? y2,
  }) {
    return AvgBox(
      x1: x1 ?? this.x1,
      y1: y1 ?? this.y1,
      x2: x2 ?? this.x2,
      y2: y2 ?? this.y2,
    );
  }

  int get width => (x2 - x1).clamp(0, 1 << 30);
  int get height => (y2 - y1).clamp(0, 1 << 30);
  int get area => width * height;

  bool get isEmpty => width == 0 || height == 0;
}

class FrameCount {
  final int frame;
  final int greenVisible;
  final int redVisible;
  final int unknownVisible;
  final int totalVisible;

  const FrameCount({
    required this.frame,
    required this.greenVisible,
    required this.redVisible,
    required this.unknownVisible,
    required this.totalVisible,
  });

  factory FrameCount.fromJson(Map<String, dynamic> json) {
    return FrameCount(
      frame: _Parser.intValue(json['frame']),
      greenVisible: _Parser.intValue(json['green_visible']),
      redVisible: _Parser.intValue(json['red_visible']),
      unknownVisible: _Parser.intValue(json['unknown_visible']),
      totalVisible: _Parser.intValue(json['total_visible']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'frame': frame,
      'green_visible': greenVisible,
      'red_visible': redVisible,
      'unknown_visible': unknownVisible,
      'total_visible': totalVisible,
    };
  }

  FrameCount copyWith({
    int? frame,
    int? greenVisible,
    int? redVisible,
    int? unknownVisible,
    int? totalVisible,
  }) {
    return FrameCount(
      frame: frame ?? this.frame,
      greenVisible: greenVisible ?? this.greenVisible,
      redVisible: redVisible ?? this.redVisible,
      unknownVisible: unknownVisible ?? this.unknownVisible,
      totalVisible: totalVisible ?? this.totalVisible,
    );
  }

  bool get hasUnknown => unknownVisible > 0;
}

class _Parser {
  static Map<String, dynamic> map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  static List<dynamic> list(dynamic value) {
    if (value is List) return value;
    return <dynamic>[];
  }

  static String string(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    return value.toString();
  }

  static int intValue(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static double doubleValue(dynamic value, {double fallback = 0.0}) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  static bool boolValue(dynamic value, {bool fallback = false}) {
    if (value is bool) return value;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
    }
    return fallback;
  }
}
