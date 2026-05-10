// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PlayVision';

  @override
  String get loginTitle => 'Log in or sign up to continue';

  @override
  String get emailHint => 'Email';

  @override
  String get passwordHint => 'Password';

  @override
  String get loginButton => 'Log In';

  @override
  String get createAccountButton => 'Create a new account';

  @override
  String get registerTitle => 'Create your account to start analyzing';

  @override
  String get registerButton => 'Sign Up';

  @override
  String get alreadyHaveAccountButton => 'I already have an account';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageItem => 'Language';

  @override
  String get helpItem => 'Help';

  @override
  String get appearanceSection => 'APPEARANCE';

  @override
  String get lightModeItem => 'Light Mode';

  @override
  String get infoSection => 'INFORMATION';

  @override
  String get aboutUsItem => 'About Us';

  @override
  String get aboutAppItem => 'About PlayVision';

  @override
  String get logoutButton => 'Log Out';

  @override
  String get selectOrCreateTeam => 'Select or create a team';

  @override
  String get chooseTeamSubtitle => 'Choose a team to start a new analysis';

  @override
  String get resultsTab => 'Results';

  @override
  String get newsTab => 'News';

  @override
  String get totalMatches => 'Total matches';

  @override
  String get analysed => 'analysed';

  @override
  String get createTeam => 'Create a team';

  @override
  String get tapToAddTeam => 'Tap here to add your first team';

  @override
  String get newTeam => 'New';

  @override
  String get changeTeam => 'Change';

  @override
  String get analyseVideo => 'Analyse video';

  @override
  String get uploadMatchVideo => 'Upload a match video and get AI stats';

  @override
  String get viewAnalysis => 'View analysis';

  @override
  String get teamMatches => 'Team matches';

  @override
  String get noAnalysedMatches => 'No analysed matches yet';

  @override
  String get noRealMatchesToday => 'No real matches today';

  @override
  String get liveStatus => 'Live';

  @override
  String get scheduledStatus => 'Scheduled';

  @override
  String get finishedStatus => 'Finished';

  @override
  String get myAnalysesTitle => 'My Analyses';

  @override
  String get allMatchesGrouped => 'All matches grouped by team';

  @override
  String get noAnalysisData => 'No analysis data for this match yet.';

  @override
  String get matchWord => 'Match';

  @override
  String get statusAnalysed => 'Analysed';

  @override
  String get statusProcessing => 'Processing';

  @override
  String get statusError => 'Error';

  @override
  String get statusUploaded => 'Uploaded';

  @override
  String get noAnalysesYet => 'No analyses yet';

  @override
  String get selectTeamAndAnalyseDesc =>
      'Select a team on the home screen\\nand analyse a match video.';

  @override
  String get analysisTitle => 'Analysis';

  @override
  String get aiPoweredPerformance => 'AI-powered performance';

  @override
  String get uploadVideoBtn => 'Upload video';

  @override
  String get readyBtn => 'Ready';

  @override
  String get tabSummary => 'SUMMARY';

  @override
  String get tabField => 'FIELD';

  @override
  String get tabPlayers => 'PLAYERS';

  @override
  String get tabVideo => 'VIDEO';

  @override
  String get matchesTitle => 'Matches';

  @override
  String get matchHistory => 'Match history';

  @override
  String get trainingTitle => 'Training';

  @override
  String get performanceBasedPlan => 'Performance-based plan';

  @override
  String get aiRecommendationsTeam => 'AI RECOMMENDATIONS - TEAM';

  @override
  String get teamAnalysis => 'Team analysis';

  @override
  String get personalisedPlanByPlayer => 'PERSONALISED PLAN BY PLAYER';

  @override
  String get totalDist => 'Total dist.';

  @override
  String get avgDist => 'Avg. dist.';

  @override
  String get possession => 'POSSESSION';

  @override
  String get aiInsights => 'AI INSIGHTS';

  @override
  String get distanceByPlayer => 'DISTANCE BY PLAYER';

  @override
  String get liveTitle => 'Live 🔴';

  @override
  String get liveRefreshTooltip => 'Refresh';

  @override
  String liveLoadError(String error) {
    return 'An error occurred: $error\\nIs the Python server running?';
  }

  @override
  String get liveNoMatches => 'No live matches at the moment.';

  @override
  String get fieldNoPlayerData => 'No player data';

  @override
  String get fieldYourTeam => 'YOUR TEAM';

  @override
  String get fieldOpponent => 'OPPONENT';

  @override
  String get fieldFormation => 'Formation';

  @override
  String get fieldPlayers => 'Players';

  @override
  String get fieldAvgSpeed => 'Avg speed';

  @override
  String get fieldHighActivity => 'High activity';

  @override
  String get fieldMedium => 'Medium';

  @override
  String get fieldLow => 'Low';

  @override
  String fieldPlayerLabel(int rank, String zone) {
    return 'Player $rank · $zone';
  }

  @override
  String get fieldDistance => 'Distance';

  @override
  String get fieldSpeed => 'Speed';

  @override
  String get fieldPresence => 'Presence';

  @override
  String get tableZone => 'ZONE';

  @override
  String get tableDist => 'DIST';

  @override
  String get tablePoss => 'POSS';

  @override
  String get tablePres => 'PRES';

  @override
  String get playersSection => 'PLAYERS';

  @override
  String playerLabel(int rank) {
    return 'Player $rank';
  }

  @override
  String get detailsBtn => 'Details';

  @override
  String get statDistance => 'DISTANCE';

  @override
  String get statSpeed => 'SPEED';

  @override
  String get statPoss => 'POSS.';

  @override
  String get detailDistanceCovered => 'Distance covered';

  @override
  String get detailAverageSpeed => 'Average speed';

  @override
  String get detailBallPossession => 'Ball possession';

  @override
  String get detailFieldPresence => 'Field presence';

  @override
  String get detailMainZone => 'Main zone';

  @override
  String insightHighActivity(String km, String spd) {
    return 'High-activity player. Covered $km km and reached $spd m/s average speed.';
  }

  @override
  String insightModerateActivity(String zone) {
    return 'Moderate-activity player. Held position in the $zone zone.';
  }

  @override
  String get summaryPlayers => 'Players';

  @override
  String get summaryTotalDist => 'Total dist.';

  @override
  String get summaryAvgDist => 'Avg. dist.';

  @override
  String get summaryPossession => 'Possession';

  @override
  String get summaryAiInsights => 'AI INSIGHTS';

  @override
  String get summaryDistByPlayer => 'DISTANCE BY PLAYER';

  @override
  String get summaryHighlights => 'HIGHLIGHTS';

  @override
  String get summaryMostActive => 'Most active';

  @override
  String get summaryMostPossession => 'Most possession';

  @override
  String get summaryLeastActive => 'Least active';

  @override
  String summaryPlayerRef(String id) {
    return 'Player $id';
  }

  @override
  String insightTotalKm(String km) {
    return 'The team covered $km km in total during the analysis.';
  }

  @override
  String insightPossession(String pct) {
    return 'Ball possession: $pct% of analysed time.';
  }

  @override
  String insightActivePlayers(int count) {
    return '$count active players were detected on the field.';
  }

  @override
  String insightFastestPlayer(String rank, String spd) {
    return 'Player $rank reached the highest speed: $spd m/s.';
  }

  @override
  String insightTopZone(String zone) {
    return 'The team was mainly concentrated in the $zone zone.';
  }

  @override
  String get videoErrorTitle => 'Error loading video';

  @override
  String videoErrorNetwork(String error, String url) {
    return 'Network error: $error\\nURL: $url';
  }

  @override
  String videoErrorLocal(String error) {
    return 'Local error: $error';
  }

  @override
  String get videoErrorWebLocal =>
      'Local files cannot be played directly on web.';

  @override
  String get videoErrorNoSource => 'No URL or file provided.';

  @override
  String get sceneVideo => 'Video';

  @override
  String get sceneHeatVideo => 'Heat Video';

  @override
  String get sceneHeatmap => 'Heatmap';

  @override
  String get scenePlayer => 'Player';

  @override
  String get sceneTeamLabel => 'Team';

  @override
  String scenePlayerShort(int rank) {
    return 'P$rank';
  }

  @override
  String get sceneVideoNotAvailable => 'Video not available';

  @override
  String sceneNetworkError(String error, String url) {
    return 'Network error: $error\\n$url';
  }

  @override
  String sceneLocalError(String error) {
    return 'Local file error: $error';
  }

  @override
  String get sceneWebError =>
      'Local files cannot be played on web. Run the backend to get a network URL.';

  @override
  String get sceneNoSource => 'No video source available.';

  @override
  String get sceneSelectPlayerAbove =>
      'Select a player above to view their heat video.';

  @override
  String get sceneHeatNotAvailable =>
      'Heat video not available.\\nRe-analyse to generate it.';

  @override
  String get sceneTeamHeatmapTitle => 'Team Heatmap';

  @override
  String get sceneTeamHeatmapSub => 'Combined movement of all detected players';

  @override
  String get sceneZoneDensity => 'Zone Density';

  @override
  String get sceneZoneDistribution => 'Zone distribution';

  @override
  String get sceneNoPlayerData => 'No player data';

  @override
  String get sceneLow => 'Low';

  @override
  String get sceneHigh => 'High';

  @override
  String scenePlayerInfo(int rank, String zone) {
    return 'Player $rank · $zone';
  }

  @override
  String scenePlayerKm(String km) {
    return '$km km';
  }

  @override
  String get uploadFromDevice => 'From device';

  @override
  String get uploadFromUrl => 'From URL';

  @override
  String get uploadAnalysing => 'Analysing with AI...';

  @override
  String get uploadStartAnalysis => 'Start analysis';

  @override
  String get uploadHowItWorks => 'HOW IT WORKS';

  @override
  String get uploadStep1Title => 'Choose source';

  @override
  String get uploadStep1Desc =>
      'Upload from device or paste a direct video URL';

  @override
  String get uploadStep2Title => 'AI analyses';

  @override
  String get uploadStep2Desc =>
      'YOLO detects and tracks each player in real time';

  @override
  String get uploadStep3Title => 'View results';

  @override
  String get uploadStep3Desc =>
      'Get stats, field map and automatic AI insights';

  @override
  String get uploadVideoReady => 'Video ready to analyse';

  @override
  String get uploadSelectVideo => 'Select match video';

  @override
  String get uploadTapGallery => 'Tap to open gallery';

  @override
  String get uploadUrlLabel => 'Video URL';

  @override
  String get uploadUrlHint => 'YouTube, direct .mp4, Vimeo…';

  @override
  String get uploadUrlSupports =>
      'Supports YouTube, Vimeo and direct .mp4/.mov links';

  @override
  String get uploadReqTitle => 'VIDEO REQUIREMENTS';

  @override
  String get uploadReqFormat => 'Format';

  @override
  String get uploadReqFormatDesc => 'MP4, MOV or AVI';

  @override
  String get uploadReqResolution => 'Resolution';

  @override
  String get uploadReqResolutionDesc => 'Minimum 720p recommended';

  @override
  String get uploadReqDuration => 'Duration';

  @override
  String get uploadReqDurationDesc => 'Between 30 sec and 10 minutes';

  @override
  String get uploadReqAngle => 'Camera angle';

  @override
  String get uploadReqAngleDesc => 'Full lateral field view';

  @override
  String get uploadReqSize => 'Max size';

  @override
  String get uploadReqSizeDesc => '500 MB per video';
}
