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
  String get deleteBtn => 'Delete';

  @override
  String get coachingBoardTitle => 'Coaching Board';

  @override
  String get coachingBoardSubtitle =>
      'Choose a team to build the tactical board';

  @override
  String get coachingBoardSelectTeamTitle => 'Select a team';

  @override
  String get coachingBoardSelectTeamSubtitle =>
      'Choose a team to build the tactical board';

  @override
  String get coachingBoardNoTeams => 'No teams';

  @override
  String get coachingBoardNoTeamsHint => 'Create a team in the Home tab';

  @override
  String get coachingBoardSave => 'Save';

  @override
  String get coachingBoardReset => 'Reset';

  @override
  String get coachingBoardSwapHint => 'Long press = swap';

  @override
  String get coachingBoardSwapBanner => 'Tap another player to swap';

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

  @override
  String get categoryU6 => 'U6';

  @override
  String get categoryU8 => 'U8';

  @override
  String get categoryU10 => 'U10';

  @override
  String get categoryU12 => 'U12';

  @override
  String get categoryU14 => 'U14';

  @override
  String get categoryU16 => 'U16';

  @override
  String get categoryU18 => 'U18';

  @override
  String get categoryU20 => 'U20';

  @override
  String get categoryU23 => 'U23';

  @override
  String get categoryAmateur => 'Amateur';

  @override
  String get categorySemiProfessional => 'Semi-professional';

  @override
  String get categoryProfessional => 'Professional';

  @override
  String get categoryFemaleU12 => 'Female U12';

  @override
  String get categoryFemaleU16 => 'Female U16';

  @override
  String get categoryFemaleU18 => 'Female U18';

  @override
  String get categoryFemale => 'Female';

  @override
  String get categoryMixed => 'Mixed';

  @override
  String get countryArgentina => 'Argentina';

  @override
  String get countryBolivia => 'Bolivia';

  @override
  String get countryBrazil => 'Brazil';

  @override
  String get countryChile => 'Chile';

  @override
  String get countryColombia => 'Colombia';

  @override
  String get countryCostaRica => 'Costa Rica';

  @override
  String get countryCuba => 'Cuba';

  @override
  String get countryEcuador => 'Ecuador';

  @override
  String get countryElSalvador => 'El Salvador';

  @override
  String get countrySpain => 'Spain';

  @override
  String get countryUnitedStates => 'United States';

  @override
  String get countryGuatemala => 'Guatemala';

  @override
  String get countryHonduras => 'Honduras';

  @override
  String get countryMexico => 'Mexico';

  @override
  String get countryNicaragua => 'Nicaragua';

  @override
  String get countryPanama => 'Panama';

  @override
  String get countryParaguay => 'Paraguay';

  @override
  String get countryPeru => 'Peru';

  @override
  String get countryPuertoRico => 'Puerto Rico';

  @override
  String get countryDominicanRepublic => 'Dominican Republic';

  @override
  String get countryUruguay => 'Uruguay';

  @override
  String get countryVenezuela => 'Venezuela';

  @override
  String get countryOther => 'Other';

  @override
  String get greetingMorningCoach => 'Good morning, Coach';

  @override
  String get greetingAfternoonCoach => 'Good afternoon, Coach';

  @override
  String get greetingEveningCoach => 'Good evening, Coach';

  @override
  String get heroPlatformTagline => 'PlayVision · AI tactical platform';

  @override
  String heroTeamReady(String teamName) {
    return '$teamName · ready to analyze';
  }

  @override
  String get searchFieldLabel => 'Search teams or matches…';

  @override
  String searchNoResults(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String searchTeamsCount(int count) {
    return 'Teams ($count)';
  }

  @override
  String searchMatchesCount(int count) {
    return 'Matches ($count)';
  }

  @override
  String get newsNoDescriptionAvailable => 'No description available';

  @override
  String get quickActionsTitle => 'Quick actions';

  @override
  String get quickActionAnalyzeVideo => 'Analyze\nVideo';

  @override
  String get quickActionTacticalBoard => 'Tactical\nBoard';

  @override
  String get quickActionMyPlayers => 'My\nPlayers';

  @override
  String get quickActionTraining => 'Train-\ning';

  @override
  String get axisSpeed => 'Speed';

  @override
  String get axisPass => 'Pass';

  @override
  String get axisShoot => 'Shoot';

  @override
  String get axisDefend => 'Defend';

  @override
  String get axisPhysical => 'Physical';

  @override
  String get axisSpeedExplain => 'Distance covered and sprint speed';

  @override
  String get axisPassExplain => 'Pass accuracy and volume';

  @override
  String get axisShootExplain => 'Goals and shots on target';

  @override
  String get axisDefendExplain => 'Recoveries and defensive tackles';

  @override
  String get axisPhysicalExplain => 'Physical endurance and duels won';

  @override
  String insightHighRating(String rating) {
    return 'High performance · $rating ★';
  }

  @override
  String insightGoodMatch(String rating) {
    return 'Good match · $rating ★';
  }

  @override
  String insightLowRating(String rating) {
    return 'Low performance · $rating ★';
  }

  @override
  String insightTrendUp(int pct) {
    return '+$pct% vs recent average';
  }

  @override
  String insightTrendDown(int pct) {
    return '-$pct% vs recent average';
  }

  @override
  String insightHighOffensive(int goals, int assists) {
    return 'High offensive contribution · ${goals}G ${assists}A';
  }

  @override
  String get insightNoGoalContribution => 'No direct goal contribution';

  @override
  String insightLowDefensive(int tackles) {
    return 'Low defensive contribution · $tackles recoveries';
  }

  @override
  String insightExcellentDefensive(int tackles) {
    return 'Excellent defensive work · $tackles recoveries';
  }

  @override
  String insightExceptionalDistance(String km) {
    return 'Exceptional coverage · $km km';
  }

  @override
  String insightLowDistance(String km) {
    return 'Low field coverage · $km km';
  }

  @override
  String insightElitePass(int pct) {
    return 'Elite pass accuracy · $pct%';
  }

  @override
  String insightLowPass(int pct) {
    return 'Low pass accuracy · $pct%';
  }

  @override
  String insightAboveIdeal(String axis) {
    return '↑ $axis above ideal profile';
  }

  @override
  String insightBelowIdeal(String axis) {
    return '↓ $axis below position profile';
  }

  @override
  String insightBestPosition(String position) {
    return 'Suggested optimal position: $position';
  }

  @override
  String get insightHintWarning => 'Needs attention';

  @override
  String get insightHintInfo => 'AI suggestion';

  @override
  String get sheetPinned => 'Pinned';

  @override
  String get tabAssistant => '🧠 Assistant';

  @override
  String get tabProfile => '📊 Profile';

  @override
  String get tabMatch => '⚡ Match';

  @override
  String get sectionCoachAssistant => 'COACH ASSISTANT';

  @override
  String get sectionComparisonRadar => 'COMPARISON RADAR';

  @override
  String get toggleVsPosition => 'vs Ideal position';

  @override
  String get toggleVsTeam => 'vs Team average';

  @override
  String get legendIdealProfile => 'Ideal profile';

  @override
  String get legendTeamAverage => 'Team average';

  @override
  String get tapAxisForDetail => 'Tap an axis for details';

  @override
  String get axisDetailPlayer => 'Player';

  @override
  String get quickStatRating => 'Rating';

  @override
  String get quickStatGoals => 'Goals';

  @override
  String get quickStatAssists => 'Ast.';

  @override
  String get quickStatKm => 'Km';

  @override
  String get quickStatPassPct => 'Pass%';

  @override
  String get matchRatingLabel => 'Match rating';

  @override
  String get matchStatGoals => 'Goals';

  @override
  String get matchStatAssists => 'Assists';

  @override
  String get matchStatDistance => 'Distance';

  @override
  String get matchStatPasses => 'Passes';

  @override
  String get matchStatAccuracy => 'Accuracy';

  @override
  String get matchStatMinutes => 'Minutes';

  @override
  String get matchRatingTrend => 'Rating trend';

  @override
  String get playersLoadingSquad => 'Loading squad…';

  @override
  String playersSquadAvailable(int count) {
    return '$count squad players available';
  }

  @override
  String get playersNoSquadHint =>
      'No players in the squad. Add players first.';

  @override
  String get playersLinked => 'Linked';

  @override
  String get playersPresenceShort => 'PRES';

  @override
  String playersEditTitle(int rank) {
    return 'Player $rank · Edit';
  }

  @override
  String get playersUnlink => 'Unlink';

  @override
  String get playersLinkToSquad => 'Link to squad player';

  @override
  String get playersOrEditManually => 'or edit manually';

  @override
  String get playersNoLinkedTeamHint =>
      'No linked team. Add players to the squad to link them.';

  @override
  String get playersLinkAndSave => 'Link and save';

  @override
  String get analysisNoTeamSelected =>
      'No team selected. Go back and choose one.';

  @override
  String analysisServerError(String code) {
    return 'Server error: $code';
  }

  @override
  String analysisConnectionError(String error) {
    return 'Connection error: $error';
  }

  @override
  String playerProfileTitle(int id) {
    return 'Player $id';
  }

  @override
  String get playerSummaryTitle => 'Player summary';

  @override
  String playerBestPositionTitle(String position) {
    return 'Best position: $position';
  }

  @override
  String get playerMatchesCount => 'Matches';

  @override
  String get playerCoachInsights => 'Coach insights';

  @override
  String get playerDominantZone => 'Dominant zone';

  @override
  String get playerLoadError => 'Could not load the player profile.';

  @override
  String get matchesTimeoutError =>
      'The connection took too long. Check your network.';

  @override
  String get matchesLoadError => 'Could not load the data.';

  @override
  String get matchesSaveError => 'Could not save the match.';

  @override
  String get matchesEmptyTitle => 'No matches registered';

  @override
  String get matchesAddButton => '+ Add match';

  @override
  String get matchesRequireTeamFirst => 'Create at least one team first.';

  @override
  String get matchesNewTitle => 'New match';

  @override
  String get matchesTeamLabel => 'Team';

  @override
  String get matchesOpponentLabel => 'Opponent';

  @override
  String get matchesVideoSourceLabel => 'Video source';

  @override
  String get matchesUploadSource => 'Upload';

  @override
  String get matchesYouTubeSource => 'YouTube';

  @override
  String matchesDateLabel(String date) {
    return 'Date: $date';
  }

  @override
  String matchesTimeLabel(String time) {
    return 'Time: $time';
  }

  @override
  String get matchesSaved => 'Match saved';

  @override
  String get matchesNoTeam => 'No team';

  @override
  String get squadLoadError => 'Could not load the squad.';

  @override
  String get playerSaveError => 'Could not save the player.';

  @override
  String get playerUpdateError => 'Could not update the player.';

  @override
  String get playerDeleteError => 'Could not delete the player.';

  @override
  String get playerPhotoUploadError => 'Could not upload the player\'s photo.';

  @override
  String get squadPageTitle => 'Squad';

  @override
  String squadPageSubtitle(int count) {
    return '$count players · Season 25/26';
  }

  @override
  String get squadSearchHint => 'Search players...';

  @override
  String get squadPositionAll => 'All';

  @override
  String squadCountLabel(int count) {
    return '$count players';
  }

  @override
  String get squadAddPlayerTitle => 'New player';

  @override
  String get squadEditPlayerTitle => 'Edit player';

  @override
  String get squadDeletePlayerTitle => 'Delete player';

  @override
  String squadDeletePlayerConfirm(String name) {
    return 'Delete $name from the squad? This cannot be undone.';
  }

  @override
  String get squadDeleteButton => 'Delete';

  @override
  String get squadPlayerSaved => 'Player saved';

  @override
  String get squadPlayerUpdated => 'Player updated';

  @override
  String get squadPlayerDeleted => 'Player deleted';

  @override
  String get squadPlayerSaveFailed => 'Error saving player';

  @override
  String get squadPlayerUpdateFailed => 'Error updating player';

  @override
  String get squadPlayerDeleteFailed => 'Error deleting player';

  @override
  String get squadNameLabel => 'Full name';

  @override
  String get squadNameHint => 'E.g. Carlos García';

  @override
  String get squadNumberLabel => 'Number';

  @override
  String get squadNumberHint => 'E.g. 10';

  @override
  String get squadPositionLabel => 'Position';

  @override
  String get squadStatusLabel => 'Status';

  @override
  String get squadBirthDateLabel => 'Date of birth';

  @override
  String get squadBirthDateOptional => 'Date of birth (optional)';

  @override
  String get squadPhotoLabel => 'Add photo';

  @override
  String get squadChangePhoto => 'Change';

  @override
  String get squadPosGk => 'Goalkeeper GK';

  @override
  String get squadPosDef => 'Defender DEF';

  @override
  String get squadPosMid => 'Midfielder MID';

  @override
  String get squadPosFwd => 'Forward FWD';

  @override
  String get squadStatusActive => 'Active';

  @override
  String get squadStatusInjured => 'Injured';

  @override
  String get squadStatusSuspended => 'Suspended';

  @override
  String get squadStatusInactive => 'Inactive';

  @override
  String get squadFormExcellent => 'Excellent';

  @override
  String get squadFormGood => 'Good';

  @override
  String get squadFormRegular => 'Regular';

  @override
  String get squadEmptyTitle => 'No players';

  @override
  String get squadEmptySubtitle => 'Tap to add players';

  @override
  String get squadDefaultTeam => 'My team';

  @override
  String get squadMyTeam => 'My team';

  @override
  String get weekdayMon => 'M';

  @override
  String get weekdayTue => 'T';

  @override
  String get weekdayWed => 'W';

  @override
  String get weekdayThu => 'T';

  @override
  String get weekdayFri => 'F';

  @override
  String get weekdaySat => 'S';

  @override
  String get weekdaySun => 'S';

  @override
  String get weekdayMonFull => 'Monday';

  @override
  String get weekdayTueFull => 'Tuesday';

  @override
  String get weekdayWedFull => 'Wednesday';

  @override
  String get weekdayThuFull => 'Thursday';

  @override
  String get weekdayFriFull => 'Friday';

  @override
  String get weekdaySatFull => 'Saturday';

  @override
  String get weekdaySunFull => 'Sunday';

  @override
  String get trainingFitnessNoVideo =>
      'Upload a training video to see the team\'s fitness status.';

  @override
  String get trainingFitnessLow =>
      'Increase high-intensity sessions this week.';

  @override
  String get trainingFitnessMedium =>
      'Good shape. Keep the load with technical sessions.';

  @override
  String get trainingFitnessHigh =>
      'Excellent form. Focus on recovery and tactics.';

  @override
  String get trainingFitnessLevelLow => 'Low';

  @override
  String get trainingFitnessLevelMedium => 'Medium';

  @override
  String get trainingFitnessLevelHigh => 'High';

  @override
  String trainingInsightLowDistance(String km) {
    return '⚠️ The team covers little distance ($km km). Increase intensity.';
  }

  @override
  String trainingInsightHighDistance(String km) {
    return '💪 High team mobility ($km km/player).';
  }

  @override
  String trainingInsightPlayersAnalysed(String count) {
    return '✅ $count players analysed in the last training.';
  }

  @override
  String get trainingInsightNoVideo =>
      '📹 Upload a training video to get automatic insights.';

  @override
  String trainingTeamLowDistance(String km) {
    return 'The team covers little average distance ($km km). Increase aerobic intensity.';
  }

  @override
  String trainingTeamHighDistance(String km) {
    return 'High team mobility ($km km/player). Prioritise recovery.';
  }

  @override
  String trainingTeamLowPossession(String pct) {
    return 'Frequent possession loss ($pct%). Reinforce positional play.';
  }

  @override
  String trainingTeamHighPossession(String pct) {
    return 'Good team possession ($pct%). Work on finishing and exploiting dominance.';
  }

  @override
  String trainingTeamActivityGap(String most, String least) {
    return 'Big gap between most active (#$most) and least active (#$least) player.';
  }

  @override
  String trainingTeamConcentratedPossession(String player) {
    return 'Player #$player concentrates possession. Work on ball circulation.';
  }

  @override
  String get trainingTeamBalanced =>
      'Balanced performance. Keep the current tactical plan.';

  @override
  String get trainingPlayerLowDistance =>
      'Increase endurance: short distance recorded. Add running drills.';

  @override
  String get trainingPlayerLowSpeed =>
      'Work on explosive speed: recorded pace is low.';

  @override
  String get trainingPlayerLowPossession =>
      'Improve involvement with the ball.';

  @override
  String get trainingPlayerLowPresence => 'Increase presence on the field.';

  @override
  String get trainingPlayerDefRole => 'Defensive role: reinforce positioning.';

  @override
  String get trainingPlayerAttRole =>
      'Offensive role: work on finishing and off-ball movement.';

  @override
  String get trainingPlayerSolid =>
      'Solid performance. Maintain your work rate.';

  @override
  String get trainingSugTitlePressing => 'High press and transitions';

  @override
  String get trainingSugReasonPressing => 'Improve pressing';

  @override
  String get trainingSugTitlePossession => '4-3-3 possession';

  @override
  String get trainingSugReasonPossession => 'Positional play';

  @override
  String get trainingSugTitlePhysical => 'Endurance and explosiveness';

  @override
  String get trainingSugReasonPhysical => 'Physical improvement';

  @override
  String get trainingNewSession => 'New session';

  @override
  String get trainingSessionTitleHint => 'Session title';

  @override
  String get trainingSessionDescHint => 'Description (optional)';

  @override
  String get trainingDurationLabel => 'Duration:';

  @override
  String get trainingCreateSession => 'Create session';

  @override
  String get trainingAddOptionsTitle => 'What would you like to add?';

  @override
  String get trainingOptionAnalyze => 'Analyse match';

  @override
  String get trainingOptionAnalyzeSubtitle =>
      'Upload a video and auto-generate a session with AI';

  @override
  String get trainingOptionManual => 'Manual session';

  @override
  String get trainingOptionManualSubtitle => 'Create a custom training session';

  @override
  String get trainingDeleteSessionTitle => 'Delete session';

  @override
  String trainingDeleteSessionConfirm(String title) {
    return 'Delete \"$title\"?';
  }

  @override
  String trainingSessionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions',
      one: '1 session',
      zero: 'No sessions',
    );
    return '$_temp0';
  }

  @override
  String get trainingNoSessionsDay => 'No sessions this day';

  @override
  String get trainingNoSessionsYet => 'No sessions yet';

  @override
  String get trainingNoSessionsHint => 'Create your first training session';

  @override
  String get trainingNoSuggestions => 'No suggestions available';

  @override
  String get trainingPillFitness => 'fitness';

  @override
  String get trainingPillPlayers => 'players';

  @override
  String get trainingPillSessions => 'sessions';

  @override
  String get trainingPillStatus => 'status';

  @override
  String get trainingSmartAnalysisSubtitle =>
      'Generate your training plan with AI';

  @override
  String get trainingUploadVideoBtn => 'Upload match video';

  @override
  String get trainingStepUpload => 'Upload match video';

  @override
  String get trainingStepDetect => 'Detect players';

  @override
  String get trainingStepAnalyze => 'Analyse movement';

  @override
  String get trainingStepInsights => 'Generate insights';

  @override
  String get trainingStepExport => 'Export PDF report';

  @override
  String get trainingStepPending => 'pending';

  @override
  String get trainingLoadLabel => 'Load';

  @override
  String get trainingPhysicalStatus => 'physical status';

  @override
  String get trainingAvgDistance => 'Avg. distance';

  @override
  String get trainingAvgSpeed => 'Avg. speed';

  @override
  String get trainingPlayers => 'Players';

  @override
  String get trainingTopPlayers => 'TOP PLAYERS';

  @override
  String get trainingPlayerLabel => 'Player';

  @override
  String get trainingStatDistance => 'Distance';

  @override
  String get trainingStatSpeed => 'Speed';

  @override
  String get trainingStatAccuracy => 'Accuracy';

  @override
  String get trainingStatRating => 'Rating';

  @override
  String get trainingAlertsTitle => 'Team alerts';

  @override
  String get trainingAlertFatigue => 'Fatigue risk in 3 players';

  @override
  String get trainingAlertFatigueSub => 'Consider reducing intensity tomorrow';

  @override
  String get trainingAlertMobility => '2 players with reduced mobility';

  @override
  String get trainingAlertMobilitySub => 'Recommend preventive stretching';

  @override
  String get trainingAlertTactical => 'Low press in the middle zone';

  @override
  String get trainingAlertTacticalSub => 'Work on pressing in the next session';

  @override
  String get trainingTacticalConnections => 'Tactical connections';

  @override
  String get trainingAICoachTitle => 'AI Coach';

  @override
  String get trainingAICoachSubtitle => 'Personalised tactical analysis';

  @override
  String get trainingCoachTip1 =>
      'Widen spaces in the offensive phase with open full-backs';

  @override
  String get trainingCoachTip2 =>
      'High press after losing the ball in the build-up zone';

  @override
  String get trainingCoachTip3 =>
      'Reduce distance between lines in the defensive phase';

  @override
  String get trainingCoachTip4 =>
      'Quick switches of play to destabilise the opponent\'s defence';

  @override
  String get trainingWeeklyActivity => 'Weekly activity';

  @override
  String get trainingSessionsPerDay => 'sessions / day';

  @override
  String get trainingSuggestedByAI => 'SUGGESTED BY AI';

  @override
  String get trainingMySessions => 'MY SESSIONS';

  @override
  String get trainingNewBtn => '+ New';

  @override
  String get trainingDemoDefenseOpen =>
      'Defensive line very open in recent plays';

  @override
  String get trainingDemoDefenseOpenSub => 'Risk of space behind the defence';

  @override
  String get trainingDemoImprovement =>
      '12% improvement in pressing vs last week';

  @override
  String get trainingDemoImprovementSub => 'Keep the intensity up';

  @override
  String get trainingDemoConnection =>
      'Torres-Ramírez connection very effective';

  @override
  String get trainingDemoConnectionSub => 'Exploit that channel';

  @override
  String get trainingDemoPossession => 'Dominant possession in the middle zone';

  @override
  String get trainingDemoPossessionSub => 'Use it for overlapping runs';

  @override
  String get trainingDemoFatigueRisk => 'Fatigue risk in the left defence';

  @override
  String get trainingDemoFatigueRiskSub => 'Rotate in the next match';

  @override
  String get navHome => 'Home';

  @override
  String get navAnalysis => 'Analysis';

  @override
  String get navPlayers => 'Players';

  @override
  String get navTraining => 'Training';

  @override
  String get navBoard => 'Board';

  @override
  String trainingMinutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String trainingExercisesCount(int count) {
    return '$count exercises';
  }

  @override
  String get trainingDescriptionTitle => 'Description';

  @override
  String get trainingSessionPlanTitle => 'Session Plan';

  @override
  String trainingMinutesTotal(int minutes) {
    return '$minutes min total';
  }

  @override
  String get trainingStartSession => 'Start session';

  @override
  String get trainingDeleteSessionQuestion => 'Delete session?';

  @override
  String trainingDeleteSessionBody(String title) {
    return 'This will permanently remove \"$title\".';
  }

  @override
  String trainingExerciseProgress(int current, int total) {
    return 'Exercise $current of $total';
  }

  @override
  String get trainingRunning => 'In progress';

  @override
  String get trainingReady => 'Ready';

  @override
  String get trainingPaused => 'Paused';

  @override
  String get trainingNext => 'Next';

  @override
  String get trainingLastExercise => 'Last exercise';

  @override
  String get trainingExitSessionQuestion => 'Leave session?';

  @override
  String get trainingExitSessionBody => 'Current progress will be lost.';

  @override
  String get trainingContinue => 'Continue';

  @override
  String get trainingExit => 'Exit';

  @override
  String get trainingSessionCompleted => 'Session completed';

  @override
  String trainingCompletedMinutes(int minutes) {
    return '$minutes min completed';
  }

  @override
  String get trainingBackHome => 'Back to home';
}
