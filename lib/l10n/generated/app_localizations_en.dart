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
      'Select a team on the home screen\nand analyse a match video.';

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
    return 'An error occurred: $error\nIs the Python server running?';
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
  String get fieldAvgSpeed => 'Avg. speed';

  @override
  String get fieldHighActivity => 'High';

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
  String get tableZone => 'Zone';

  @override
  String get tableDist => 'Dist.';

  @override
  String get tablePoss => 'Poss.';

  @override
  String get tablePres => 'Pres.';

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
  String summaryPlayerRef(String player) {
    return 'Player $player';
  }

  @override
  String insightTotalKm(String km) {
    return 'The team covered $km km in total during the match.';
  }

  @override
  String insightPossession(String pct) {
    return 'Recorded $pct% average ball possession.';
  }

  @override
  String insightActivePlayers(String count) {
    return '$count players were active on the field.';
  }

  @override
  String insightFastestPlayer(String rank, String speed) {
    return 'Player $rank reached the highest speed at $speed m/s.';
  }

  @override
  String insightTopZone(String zone) {
    return 'The most active zone was $zone.';
  }

  @override
  String insightHighActivity(String km, String speed) {
    return 'High-activity player: covered $km km and reached $speed m/s.';
  }

  @override
  String insightModerateActivity(String zone) {
    return 'Moderate activity concentrated in zone $zone.';
  }

  @override
  String get videoErrorTitle => 'Error loading video';

  @override
  String videoErrorNetwork(String error, String url) {
    return 'Network error: $error\nURL: $url';
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
    return 'Network error: $error\n$url';
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
      'Heat video not available.\nRe-analyse to generate it.';

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
  String get sceneUnknownZone => 'Unknown';

  @override
  String scenePlayerCount(int count) {
    return '${count}p';
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
  String get uploadStep1Title => 'Upload your video';

  @override
  String get uploadStep1Desc => 'From your device or via URL';

  @override
  String get uploadStep2Title => 'AI Processing';

  @override
  String get uploadStep2Desc => 'We detect players and events in real time';

  @override
  String get uploadStep3Title => 'Get results';

  @override
  String get uploadStep3Desc => 'Heat map, statistics and key scenes';

  @override
  String get uploadVideoReady => 'Video ready';

  @override
  String get uploadSelectVideo => 'Select video';

  @override
  String get uploadTapGallery => 'Tap to choose from gallery';

  @override
  String get uploadUrlLabel => 'VIDEO URL';

  @override
  String get uploadUrlHint => 'https://example.com/video.mp4';

  @override
  String get uploadUrlSupports =>
      'Supports direct MP4, MOV links and YouTube URLs';

  @override
  String get uploadReqTitle => 'VIDEO REQUIREMENTS';

  @override
  String get uploadReqFormat => 'Format';

  @override
  String get uploadReqFormatDesc => 'MP4, MOV';

  @override
  String get uploadReqResolution => 'Resolution';

  @override
  String get uploadReqResolutionDesc => '720p+';

  @override
  String get uploadReqDuration => 'Duration';

  @override
  String get uploadReqDurationDesc => '5-90 min';

  @override
  String get uploadReqAngle => 'Angle';

  @override
  String get uploadReqAngleDesc => 'Side view';

  @override
  String get uploadReqSize => 'Size';

  @override
  String get uploadReqSizeDesc => '< 500 MB';

  @override
  String get uploadCancelAnalysis => 'Cancel analysis';

  @override
  String get loginAiBadge => 'AI Football Analysis';

  @override
  String get loginTagline => 'Where data becomes strategy';

  @override
  String get loginDividerOr => 'OR';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languageEnglish => 'English';

  @override
  String get logoutErrorDebug => 'Error signing out';

  @override
  String get appVersionLabel => 'v1.0.0';

  @override
  String get appVersionNumber => '1.0.0';

  @override
  String get aboutLegalese => '© 2026 PlayVision. All rights reserved.';

  @override
  String get teamEditTitle => 'Edit team';

  @override
  String get teamNewTitle => 'New team';

  @override
  String get teamLogoSelected => 'Logo selected';

  @override
  String get teamLogoTapToAdd => 'Tap to add logo';

  @override
  String get teamFieldName => 'Name';

  @override
  String get teamFieldCategory => 'Category';

  @override
  String get teamFieldClub => 'Club';

  @override
  String get teamDialogCancel => 'Cancel';

  @override
  String get teamDialogSave => 'Save';

  @override
  String get teamDialogCreate => 'Create';

  @override
  String get teamDeleteTitle => 'Delete team';

  @override
  String teamDeleteConfirm(String name) {
    return 'Delete team \"$name\"? This cannot be undone.';
  }

  @override
  String get teamDeleteButton => 'Delete';

  @override
  String get featureRivalAnalysisTitle => 'Rival Analysis';

  @override
  String get featureRivalAnalysisDesc => 'Anticipate the opponent';

  @override
  String get featureTacticsTitle => 'Pre-Match Tactics';

  @override
  String get featureTacticsDesc => 'Prepare each match';

  @override
  String get featureIndividualStatsTitle => 'Individual Stats';

  @override
  String get featureIndividualStatsDesc => 'Player tracking';

  @override
  String get matchUnknownOpponent => 'Unknown opponent';

  @override
  String matchVersusOpponent(String opponent) {
    return 'vs $opponent';
  }

  @override
  String get matchLoadAnalysisFailed =>
      'Failed to load analysis for this match.';

  @override
  String get matchNotAnalysedYet => 'This match is not analysed yet.';

  @override
  String get heroAiAccuracy => 'AI Accuracy';

  @override
  String get heroLatest => 'Latest';

  @override
  String get searchTeamHint => 'Search team...';

  @override
  String get searchTeamButton => 'Search team';

  @override
  String get searchLast5 => 'Last 5';

  @override
  String get searchNoRecentMatches => 'No recent matches';

  @override
  String get liveLabel => 'LIVE';

  @override
  String get todayLabel => 'Today';

  @override
  String todayMatchesCount(int count) {
    return '$count matches';
  }

  @override
  String get matchHomeTeam => 'Home';

  @override
  String get matchAwayTeam => 'Away';

  @override
  String get matchStatusFT => 'FT';

  @override
  String get matchLive => 'LIVE';

  @override
  String get matchVS => 'VS';

  @override
  String get matchStatusLive => 'Live';

  @override
  String get matchStatusFinished => 'Finished';

  @override
  String get matchStatusNotStarted => 'Not started';

  @override
  String get newsRefreshButton => 'Refresh news';

  @override
  String get newsErrorTitle => 'Could not load news';

  @override
  String get newsErrorSubtitle => 'Check your connection';

  @override
  String get newsRetryButton => 'Retry';

  @override
  String get analysisInProgressTitle => 'Analysis in progress';

  @override
  String get analysisLeaveWarning =>
      'If you leave now, the analysis will be canceled and you will lose your progress. Do you want to continue?';

  @override
  String get analysisStayButton => 'Stay';

  @override
  String get analysisExitButton => 'Exit';

  @override
  String get analysisProcessingWithAI => 'Processing with AI...';

  @override
  String get analysisCancelButton => 'Cancel';

  @override
  String get analysisProcessingBanner =>
      'Analyzing video with artificial intelligence. This may take a few minutes.';

  @override
  String get editPlayerTitle => 'Edit player';

  @override
  String get editPlayerNameLabel => 'Name';

  @override
  String get editPlayerNumberLabel => 'Number';

  @override
  String get editPlayerPositionLabel => 'Position';

  @override
  String editPlayerDefaultName(int rank) {
    return 'Player $rank';
  }

  @override
  String get cancelBtn => 'Cancel';

  @override
  String get saveBtn => 'Save';

  @override
  String get coachingBoardTitle => 'Coaching Board';

  @override
  String get coachingBoardSubtitle =>
      'Choose a team to build the tactical board';

  @override
  String get coachingBoardNoTeams => 'No teams';

  @override
  String get coachingBoardNoTeamsHint => 'Create a team in the Home tab';

  @override
  String get coachingBoardReset => 'Reset';

  @override
  String get coachingBoardSwapHint => 'Long press = swap';

  @override
  String get coachingBoardSwapBanner => 'Tap another player to swap';

  @override
  String get coachingBoardSelectTeamTitle => 'Select a team';

  @override
  String get coachingBoardSelectTeamSubtitle =>
      'Choose a team to build the tactical board';

  @override
  String get coachingBoardSave => 'Save';

  @override
  String coachingBoardAnalyzingTitle(String teamName) {
    return 'Analyzing $teamName';
  }

  @override
  String get coachingBoardAnalyzingSubtitle =>
      'Building the tactical board with AI';

  @override
  String get coachingBoardStepLoadingPlayers => 'Loading players...';

  @override
  String get coachingBoardStepReadingStats => 'Reading statistics...';

  @override
  String get coachingBoardStepComputingPositions =>
      'Computing optimal positions...';

  @override
  String get coachingBoardStepBuildingBoard => 'Building tactical board...';

  @override
  String get coachingBoardSaveSuccess => 'Formation saved ✓';

  @override
  String get coachingBoardSaveError => 'Error while saving the formation';
}
