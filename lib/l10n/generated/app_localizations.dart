import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'PlayVision'**
  String get appTitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Log in or sign up to continue'**
  String get loginTitle;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordHint;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get loginButton;

  /// No description provided for @createAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create a new account'**
  String get createAccountButton;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account to start analyzing'**
  String get registerTitle;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get registerButton;

  /// No description provided for @alreadyHaveAccountButton.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get alreadyHaveAccountButton;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @languageItem.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageItem;

  /// No description provided for @helpItem.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get helpItem;

  /// No description provided for @appearanceSection.
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE'**
  String get appearanceSection;

  /// No description provided for @lightModeItem.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightModeItem;

  /// No description provided for @infoSection.
  ///
  /// In en, this message translates to:
  /// **'INFORMATION'**
  String get infoSection;

  /// No description provided for @aboutUsItem.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUsItem;

  /// No description provided for @aboutAppItem.
  ///
  /// In en, this message translates to:
  /// **'About PlayVision'**
  String get aboutAppItem;

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logoutButton;

  /// No description provided for @selectOrCreateTeam.
  ///
  /// In en, this message translates to:
  /// **'Select or create a team'**
  String get selectOrCreateTeam;

  /// No description provided for @chooseTeamSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a team to start a new analysis'**
  String get chooseTeamSubtitle;

  /// No description provided for @resultsTab.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get resultsTab;

  /// No description provided for @newsTab.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get newsTab;

  /// No description provided for @totalMatches.
  ///
  /// In en, this message translates to:
  /// **'Total matches'**
  String get totalMatches;

  /// No description provided for @analysed.
  ///
  /// In en, this message translates to:
  /// **'analysed'**
  String get analysed;

  /// No description provided for @createTeam.
  ///
  /// In en, this message translates to:
  /// **'Create a team'**
  String get createTeam;

  /// No description provided for @tapToAddTeam.
  ///
  /// In en, this message translates to:
  /// **'Tap here to add your first team'**
  String get tapToAddTeam;

  /// No description provided for @newTeam.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newTeam;

  /// No description provided for @changeTeam.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeTeam;

  /// No description provided for @analyseVideo.
  ///
  /// In en, this message translates to:
  /// **'Analyse video'**
  String get analyseVideo;

  /// No description provided for @uploadMatchVideo.
  ///
  /// In en, this message translates to:
  /// **'Upload a match video and get AI stats'**
  String get uploadMatchVideo;

  /// No description provided for @viewAnalysis.
  ///
  /// In en, this message translates to:
  /// **'View analysis'**
  String get viewAnalysis;

  /// No description provided for @teamMatches.
  ///
  /// In en, this message translates to:
  /// **'Team matches'**
  String get teamMatches;

  /// No description provided for @noAnalysedMatches.
  ///
  /// In en, this message translates to:
  /// **'No analysed matches yet'**
  String get noAnalysedMatches;

  /// No description provided for @noRealMatchesToday.
  ///
  /// In en, this message translates to:
  /// **'No real matches today'**
  String get noRealMatchesToday;

  /// No description provided for @liveStatus.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get liveStatus;

  /// No description provided for @scheduledStatus.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get scheduledStatus;

  /// No description provided for @finishedStatus.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get finishedStatus;

  /// No description provided for @myAnalysesTitle.
  ///
  /// In en, this message translates to:
  /// **'My Analyses'**
  String get myAnalysesTitle;

  /// No description provided for @allMatchesGrouped.
  ///
  /// In en, this message translates to:
  /// **'All matches grouped by team'**
  String get allMatchesGrouped;

  /// No description provided for @noAnalysisData.
  ///
  /// In en, this message translates to:
  /// **'No analysis data for this match yet.'**
  String get noAnalysisData;

  /// No description provided for @matchWord.
  ///
  /// In en, this message translates to:
  /// **'Match'**
  String get matchWord;

  /// No description provided for @statusAnalysed.
  ///
  /// In en, this message translates to:
  /// **'Analysed'**
  String get statusAnalysed;

  /// No description provided for @statusProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get statusProcessing;

  /// No description provided for @statusError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get statusError;

  /// No description provided for @statusUploaded.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get statusUploaded;

  /// No description provided for @noAnalysesYet.
  ///
  /// In en, this message translates to:
  /// **'No analyses yet'**
  String get noAnalysesYet;

  /// No description provided for @selectTeamAndAnalyseDesc.
  ///
  /// In en, this message translates to:
  /// **'Select a team on the home screen\nand analyse a match video.'**
  String get selectTeamAndAnalyseDesc;

  /// No description provided for @analysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get analysisTitle;

  /// No description provided for @aiPoweredPerformance.
  ///
  /// In en, this message translates to:
  /// **'AI-powered performance'**
  String get aiPoweredPerformance;

  /// No description provided for @uploadVideoBtn.
  ///
  /// In en, this message translates to:
  /// **'Upload video'**
  String get uploadVideoBtn;

  /// No description provided for @readyBtn.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get readyBtn;

  /// No description provided for @tabSummary.
  ///
  /// In en, this message translates to:
  /// **'SUMMARY'**
  String get tabSummary;

  /// No description provided for @tabField.
  ///
  /// In en, this message translates to:
  /// **'FIELD'**
  String get tabField;

  /// No description provided for @tabPlayers.
  ///
  /// In en, this message translates to:
  /// **'PLAYERS'**
  String get tabPlayers;

  /// No description provided for @tabVideo.
  ///
  /// In en, this message translates to:
  /// **'VIDEO'**
  String get tabVideo;

  /// No description provided for @matchesTitle.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get matchesTitle;

  /// No description provided for @matchHistory.
  ///
  /// In en, this message translates to:
  /// **'Match history'**
  String get matchHistory;

  /// No description provided for @trainingTitle.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get trainingTitle;

  /// No description provided for @performanceBasedPlan.
  ///
  /// In en, this message translates to:
  /// **'Performance-based plan'**
  String get performanceBasedPlan;

  /// No description provided for @aiRecommendationsTeam.
  ///
  /// In en, this message translates to:
  /// **'AI RECOMMENDATIONS - TEAM'**
  String get aiRecommendationsTeam;

  /// No description provided for @teamAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Team analysis'**
  String get teamAnalysis;

  /// No description provided for @personalisedPlanByPlayer.
  ///
  /// In en, this message translates to:
  /// **'PERSONALISED PLAN BY PLAYER'**
  String get personalisedPlanByPlayer;

  /// No description provided for @totalDist.
  ///
  /// In en, this message translates to:
  /// **'Total dist.'**
  String get totalDist;

  /// No description provided for @avgDist.
  ///
  /// In en, this message translates to:
  /// **'Avg. dist.'**
  String get avgDist;

  /// No description provided for @possession.
  ///
  /// In en, this message translates to:
  /// **'POSSESSION'**
  String get possession;

  /// No description provided for @aiInsights.
  ///
  /// In en, this message translates to:
  /// **'AI INSIGHTS'**
  String get aiInsights;

  /// No description provided for @distanceByPlayer.
  ///
  /// In en, this message translates to:
  /// **'DISTANCE BY PLAYER'**
  String get distanceByPlayer;

  /// No description provided for @liveTitle.
  ///
  /// In en, this message translates to:
  /// **'Live 🔴'**
  String get liveTitle;

  /// No description provided for @liveRefreshTooltip.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get liveRefreshTooltip;

  /// No description provided for @liveLoadError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}\nIs the Python server running?'**
  String liveLoadError(String error);

  /// No description provided for @liveNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No live matches at the moment.'**
  String get liveNoMatches;

  /// No description provided for @fieldNoPlayerData.
  ///
  /// In en, this message translates to:
  /// **'No player data'**
  String get fieldNoPlayerData;

  /// No description provided for @fieldYourTeam.
  ///
  /// In en, this message translates to:
  /// **'YOUR TEAM'**
  String get fieldYourTeam;

  /// No description provided for @fieldOpponent.
  ///
  /// In en, this message translates to:
  /// **'OPPONENT'**
  String get fieldOpponent;

  /// No description provided for @fieldFormation.
  ///
  /// In en, this message translates to:
  /// **'Formation'**
  String get fieldFormation;

  /// No description provided for @fieldPlayers.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get fieldPlayers;

  /// No description provided for @fieldAvgSpeed.
  ///
  /// In en, this message translates to:
  /// **'Avg. speed'**
  String get fieldAvgSpeed;

  /// No description provided for @fieldHighActivity.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get fieldHighActivity;

  /// No description provided for @fieldMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get fieldMedium;

  /// No description provided for @fieldLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get fieldLow;

  /// No description provided for @fieldPlayerLabel.
  ///
  /// In en, this message translates to:
  /// **'Player {rank} · {zone}'**
  String fieldPlayerLabel(int rank, String zone);

  /// No description provided for @fieldDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get fieldDistance;

  /// No description provided for @fieldSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get fieldSpeed;

  /// No description provided for @fieldPresence.
  ///
  /// In en, this message translates to:
  /// **'Presence'**
  String get fieldPresence;

  /// No description provided for @tableZone.
  ///
  /// In en, this message translates to:
  /// **'Zone'**
  String get tableZone;

  /// No description provided for @tableDist.
  ///
  /// In en, this message translates to:
  /// **'Dist.'**
  String get tableDist;

  /// No description provided for @tablePoss.
  ///
  /// In en, this message translates to:
  /// **'Poss.'**
  String get tablePoss;

  /// No description provided for @tablePres.
  ///
  /// In en, this message translates to:
  /// **'Pres.'**
  String get tablePres;

  /// No description provided for @playersSection.
  ///
  /// In en, this message translates to:
  /// **'PLAYERS'**
  String get playersSection;

  /// No description provided for @playerLabel.
  ///
  /// In en, this message translates to:
  /// **'Player {rank}'**
  String playerLabel(int rank);

  /// No description provided for @detailsBtn.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get detailsBtn;

  /// No description provided for @statDistance.
  ///
  /// In en, this message translates to:
  /// **'DISTANCE'**
  String get statDistance;

  /// No description provided for @statSpeed.
  ///
  /// In en, this message translates to:
  /// **'SPEED'**
  String get statSpeed;

  /// No description provided for @statPoss.
  ///
  /// In en, this message translates to:
  /// **'POSS.'**
  String get statPoss;

  /// No description provided for @detailDistanceCovered.
  ///
  /// In en, this message translates to:
  /// **'Distance covered'**
  String get detailDistanceCovered;

  /// No description provided for @detailAverageSpeed.
  ///
  /// In en, this message translates to:
  /// **'Average speed'**
  String get detailAverageSpeed;

  /// No description provided for @detailBallPossession.
  ///
  /// In en, this message translates to:
  /// **'Ball possession'**
  String get detailBallPossession;

  /// No description provided for @detailFieldPresence.
  ///
  /// In en, this message translates to:
  /// **'Field presence'**
  String get detailFieldPresence;

  /// No description provided for @detailMainZone.
  ///
  /// In en, this message translates to:
  /// **'Main zone'**
  String get detailMainZone;

  /// No description provided for @summaryPlayers.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get summaryPlayers;

  /// No description provided for @summaryTotalDist.
  ///
  /// In en, this message translates to:
  /// **'Total dist.'**
  String get summaryTotalDist;

  /// No description provided for @summaryAvgDist.
  ///
  /// In en, this message translates to:
  /// **'Avg. dist.'**
  String get summaryAvgDist;

  /// No description provided for @summaryPossession.
  ///
  /// In en, this message translates to:
  /// **'Possession'**
  String get summaryPossession;

  /// No description provided for @summaryAiInsights.
  ///
  /// In en, this message translates to:
  /// **'AI INSIGHTS'**
  String get summaryAiInsights;

  /// No description provided for @summaryDistByPlayer.
  ///
  /// In en, this message translates to:
  /// **'DISTANCE BY PLAYER'**
  String get summaryDistByPlayer;

  /// No description provided for @summaryHighlights.
  ///
  /// In en, this message translates to:
  /// **'HIGHLIGHTS'**
  String get summaryHighlights;

  /// No description provided for @summaryMostActive.
  ///
  /// In en, this message translates to:
  /// **'Most active'**
  String get summaryMostActive;

  /// No description provided for @summaryMostPossession.
  ///
  /// In en, this message translates to:
  /// **'Most possession'**
  String get summaryMostPossession;

  /// No description provided for @summaryLeastActive.
  ///
  /// In en, this message translates to:
  /// **'Least active'**
  String get summaryLeastActive;

  /// No description provided for @summaryPlayerRef.
  ///
  /// In en, this message translates to:
  /// **'Player {player}'**
  String summaryPlayerRef(String player);

  /// No description provided for @insightTotalKm.
  ///
  /// In en, this message translates to:
  /// **'The team covered {km} km in total during the match.'**
  String insightTotalKm(String km);

  /// No description provided for @insightPossession.
  ///
  /// In en, this message translates to:
  /// **'Recorded {pct}% average ball possession.'**
  String insightPossession(String pct);

  /// No description provided for @insightActivePlayers.
  ///
  /// In en, this message translates to:
  /// **'{count} players were active on the field.'**
  String insightActivePlayers(String count);

  /// No description provided for @insightFastestPlayer.
  ///
  /// In en, this message translates to:
  /// **'Player {rank} reached the highest speed at {speed} m/s.'**
  String insightFastestPlayer(String rank, String speed);

  /// No description provided for @insightTopZone.
  ///
  /// In en, this message translates to:
  /// **'The most active zone was {zone}.'**
  String insightTopZone(String zone);

  /// No description provided for @insightHighActivity.
  ///
  /// In en, this message translates to:
  /// **'High-activity player: covered {km} km and reached {speed} m/s.'**
  String insightHighActivity(String km, String speed);

  /// No description provided for @insightModerateActivity.
  ///
  /// In en, this message translates to:
  /// **'Moderate activity concentrated in zone {zone}.'**
  String insightModerateActivity(String zone);

  /// No description provided for @videoErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error loading video'**
  String get videoErrorTitle;

  /// No description provided for @videoErrorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network error: {error}\nURL: {url}'**
  String videoErrorNetwork(String error, String url);

  /// No description provided for @videoErrorLocal.
  ///
  /// In en, this message translates to:
  /// **'Local error: {error}'**
  String videoErrorLocal(String error);

  /// No description provided for @videoErrorWebLocal.
  ///
  /// In en, this message translates to:
  /// **'Local files cannot be played directly on web.'**
  String get videoErrorWebLocal;

  /// No description provided for @videoErrorNoSource.
  ///
  /// In en, this message translates to:
  /// **'No URL or file provided.'**
  String get videoErrorNoSource;

  /// No description provided for @sceneVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get sceneVideo;

  /// No description provided for @sceneHeatVideo.
  ///
  /// In en, this message translates to:
  /// **'Heat Video'**
  String get sceneHeatVideo;

  /// No description provided for @sceneHeatmap.
  ///
  /// In en, this message translates to:
  /// **'Heatmap'**
  String get sceneHeatmap;

  /// No description provided for @scenePlayer.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get scenePlayer;

  /// No description provided for @sceneTeamLabel.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get sceneTeamLabel;

  /// No description provided for @scenePlayerShort.
  ///
  /// In en, this message translates to:
  /// **'P{rank}'**
  String scenePlayerShort(int rank);

  /// No description provided for @sceneVideoNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Video not available'**
  String get sceneVideoNotAvailable;

  /// No description provided for @sceneNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Network error: {error}\n{url}'**
  String sceneNetworkError(String error, String url);

  /// No description provided for @sceneLocalError.
  ///
  /// In en, this message translates to:
  /// **'Local file error: {error}'**
  String sceneLocalError(String error);

  /// No description provided for @sceneWebError.
  ///
  /// In en, this message translates to:
  /// **'Local files cannot be played on web. Run the backend to get a network URL.'**
  String get sceneWebError;

  /// No description provided for @sceneNoSource.
  ///
  /// In en, this message translates to:
  /// **'No video source available.'**
  String get sceneNoSource;

  /// No description provided for @sceneSelectPlayerAbove.
  ///
  /// In en, this message translates to:
  /// **'Select a player above to view their heat video.'**
  String get sceneSelectPlayerAbove;

  /// No description provided for @sceneHeatNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Heat video not available.\nRe-analyse to generate it.'**
  String get sceneHeatNotAvailable;

  /// No description provided for @sceneTeamHeatmapTitle.
  ///
  /// In en, this message translates to:
  /// **'Team Heatmap'**
  String get sceneTeamHeatmapTitle;

  /// No description provided for @sceneTeamHeatmapSub.
  ///
  /// In en, this message translates to:
  /// **'Combined movement of all detected players'**
  String get sceneTeamHeatmapSub;

  /// No description provided for @sceneZoneDensity.
  ///
  /// In en, this message translates to:
  /// **'Zone Density'**
  String get sceneZoneDensity;

  /// No description provided for @sceneZoneDistribution.
  ///
  /// In en, this message translates to:
  /// **'Zone distribution'**
  String get sceneZoneDistribution;

  /// No description provided for @sceneNoPlayerData.
  ///
  /// In en, this message translates to:
  /// **'No player data'**
  String get sceneNoPlayerData;

  /// No description provided for @sceneLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get sceneLow;

  /// No description provided for @sceneHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get sceneHigh;

  /// No description provided for @scenePlayerInfo.
  ///
  /// In en, this message translates to:
  /// **'Player {rank} · {zone}'**
  String scenePlayerInfo(int rank, String zone);

  /// No description provided for @scenePlayerKm.
  ///
  /// In en, this message translates to:
  /// **'{km} km'**
  String scenePlayerKm(String km);

  /// No description provided for @sceneUnknownZone.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get sceneUnknownZone;

  /// No description provided for @scenePlayerCount.
  ///
  /// In en, this message translates to:
  /// **'{count}p'**
  String scenePlayerCount(int count);

  /// No description provided for @uploadFromDevice.
  ///
  /// In en, this message translates to:
  /// **'From device'**
  String get uploadFromDevice;

  /// No description provided for @uploadFromUrl.
  ///
  /// In en, this message translates to:
  /// **'From URL'**
  String get uploadFromUrl;

  /// No description provided for @uploadAnalysing.
  ///
  /// In en, this message translates to:
  /// **'Analysing with AI...'**
  String get uploadAnalysing;

  /// No description provided for @uploadStartAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Start analysis'**
  String get uploadStartAnalysis;

  /// No description provided for @uploadHowItWorks.
  ///
  /// In en, this message translates to:
  /// **'HOW IT WORKS'**
  String get uploadHowItWorks;

  /// No description provided for @uploadStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Upload your video'**
  String get uploadStep1Title;

  /// No description provided for @uploadStep1Desc.
  ///
  /// In en, this message translates to:
  /// **'From your device or via URL'**
  String get uploadStep1Desc;

  /// No description provided for @uploadStep2Title.
  ///
  /// In en, this message translates to:
  /// **'AI Processing'**
  String get uploadStep2Title;

  /// No description provided for @uploadStep2Desc.
  ///
  /// In en, this message translates to:
  /// **'We detect players and events in real time'**
  String get uploadStep2Desc;

  /// No description provided for @uploadStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Get results'**
  String get uploadStep3Title;

  /// No description provided for @uploadStep3Desc.
  ///
  /// In en, this message translates to:
  /// **'Heat map, statistics and key scenes'**
  String get uploadStep3Desc;

  /// No description provided for @uploadVideoReady.
  ///
  /// In en, this message translates to:
  /// **'Video ready'**
  String get uploadVideoReady;

  /// No description provided for @uploadSelectVideo.
  ///
  /// In en, this message translates to:
  /// **'Select video'**
  String get uploadSelectVideo;

  /// No description provided for @uploadTapGallery.
  ///
  /// In en, this message translates to:
  /// **'Tap to choose from gallery'**
  String get uploadTapGallery;

  /// No description provided for @uploadUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'VIDEO URL'**
  String get uploadUrlLabel;

  /// No description provided for @uploadUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://example.com/video.mp4'**
  String get uploadUrlHint;

  /// No description provided for @uploadUrlSupports.
  ///
  /// In en, this message translates to:
  /// **'Supports direct MP4, MOV links and YouTube URLs'**
  String get uploadUrlSupports;

  /// No description provided for @uploadReqTitle.
  ///
  /// In en, this message translates to:
  /// **'VIDEO REQUIREMENTS'**
  String get uploadReqTitle;

  /// No description provided for @uploadReqFormat.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get uploadReqFormat;

  /// No description provided for @uploadReqFormatDesc.
  ///
  /// In en, this message translates to:
  /// **'MP4, MOV'**
  String get uploadReqFormatDesc;

  /// No description provided for @uploadReqResolution.
  ///
  /// In en, this message translates to:
  /// **'Resolution'**
  String get uploadReqResolution;

  /// No description provided for @uploadReqResolutionDesc.
  ///
  /// In en, this message translates to:
  /// **'720p+'**
  String get uploadReqResolutionDesc;

  /// No description provided for @uploadReqDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get uploadReqDuration;

  /// No description provided for @uploadReqDurationDesc.
  ///
  /// In en, this message translates to:
  /// **'5-90 min'**
  String get uploadReqDurationDesc;

  /// No description provided for @uploadReqAngle.
  ///
  /// In en, this message translates to:
  /// **'Angle'**
  String get uploadReqAngle;

  /// No description provided for @uploadReqAngleDesc.
  ///
  /// In en, this message translates to:
  /// **'Side view'**
  String get uploadReqAngleDesc;

  /// No description provided for @uploadReqSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get uploadReqSize;

  /// No description provided for @uploadReqSizeDesc.
  ///
  /// In en, this message translates to:
  /// **'< 500 MB'**
  String get uploadReqSizeDesc;

  /// No description provided for @uploadCancelAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Cancel analysis'**
  String get uploadCancelAnalysis;

  /// No description provided for @loginAiBadge.
  ///
  /// In en, this message translates to:
  /// **'AI Football Analysis'**
  String get loginAiBadge;

  /// No description provided for @loginTagline.
  ///
  /// In en, this message translates to:
  /// **'Where data becomes strategy'**
  String get loginTagline;

  /// No description provided for @loginDividerOr.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get loginDividerOr;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @logoutErrorDebug.
  ///
  /// In en, this message translates to:
  /// **'Error signing out'**
  String get logoutErrorDebug;

  /// No description provided for @appVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'v1.0.0'**
  String get appVersionLabel;

  /// No description provided for @appVersionNumber.
  ///
  /// In en, this message translates to:
  /// **'1.0.0'**
  String get appVersionNumber;

  /// No description provided for @aboutLegalese.
  ///
  /// In en, this message translates to:
  /// **'© 2026 PlayVision. All rights reserved.'**
  String get aboutLegalese;

  /// No description provided for @teamEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit team'**
  String get teamEditTitle;

  /// No description provided for @teamNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New team'**
  String get teamNewTitle;

  /// No description provided for @teamLogoSelected.
  ///
  /// In en, this message translates to:
  /// **'Logo selected'**
  String get teamLogoSelected;

  /// No description provided for @teamLogoTapToAdd.
  ///
  /// In en, this message translates to:
  /// **'Tap to add logo'**
  String get teamLogoTapToAdd;

  /// No description provided for @teamFieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get teamFieldName;

  /// No description provided for @teamFieldCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get teamFieldCategory;

  /// No description provided for @teamFieldClub.
  ///
  /// In en, this message translates to:
  /// **'Club'**
  String get teamFieldClub;

  /// No description provided for @teamDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get teamDialogCancel;

  /// No description provided for @teamDialogSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get teamDialogSave;

  /// No description provided for @teamDialogCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get teamDialogCreate;

  /// No description provided for @teamDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete team'**
  String get teamDeleteTitle;

  /// No description provided for @teamDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete team \"{name}\"? This cannot be undone.'**
  String teamDeleteConfirm(String name);

  /// No description provided for @teamDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get teamDeleteButton;

  /// No description provided for @featureRivalAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Rival Analysis'**
  String get featureRivalAnalysisTitle;

  /// No description provided for @featureRivalAnalysisDesc.
  ///
  /// In en, this message translates to:
  /// **'Anticipate the opponent'**
  String get featureRivalAnalysisDesc;

  /// No description provided for @featureTacticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Pre-Match Tactics'**
  String get featureTacticsTitle;

  /// No description provided for @featureTacticsDesc.
  ///
  /// In en, this message translates to:
  /// **'Prepare each match'**
  String get featureTacticsDesc;

  /// No description provided for @featureIndividualStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Individual Stats'**
  String get featureIndividualStatsTitle;

  /// No description provided for @featureIndividualStatsDesc.
  ///
  /// In en, this message translates to:
  /// **'Player tracking'**
  String get featureIndividualStatsDesc;

  /// No description provided for @matchUnknownOpponent.
  ///
  /// In en, this message translates to:
  /// **'Unknown opponent'**
  String get matchUnknownOpponent;

  /// No description provided for @matchVersusOpponent.
  ///
  /// In en, this message translates to:
  /// **'vs {opponent}'**
  String matchVersusOpponent(String opponent);

  /// No description provided for @matchLoadAnalysisFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load analysis for this match.'**
  String get matchLoadAnalysisFailed;

  /// No description provided for @matchNotAnalysedYet.
  ///
  /// In en, this message translates to:
  /// **'This match is not analysed yet.'**
  String get matchNotAnalysedYet;

  /// No description provided for @heroAiAccuracy.
  ///
  /// In en, this message translates to:
  /// **'AI Accuracy'**
  String get heroAiAccuracy;

  /// No description provided for @heroLatest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get heroLatest;

  /// No description provided for @searchTeamHint.
  ///
  /// In en, this message translates to:
  /// **'Search team...'**
  String get searchTeamHint;

  /// No description provided for @searchTeamButton.
  ///
  /// In en, this message translates to:
  /// **'Search team'**
  String get searchTeamButton;

  /// No description provided for @searchLast5.
  ///
  /// In en, this message translates to:
  /// **'Last 5'**
  String get searchLast5;

  /// No description provided for @searchNoRecentMatches.
  ///
  /// In en, this message translates to:
  /// **'No recent matches'**
  String get searchNoRecentMatches;

  /// No description provided for @liveLabel.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get liveLabel;

  /// No description provided for @todayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayLabel;

  /// No description provided for @todayMatchesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} matches'**
  String todayMatchesCount(int count);

  /// No description provided for @matchHomeTeam.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get matchHomeTeam;

  /// No description provided for @matchAwayTeam.
  ///
  /// In en, this message translates to:
  /// **'Away'**
  String get matchAwayTeam;

  /// No description provided for @matchStatusFT.
  ///
  /// In en, this message translates to:
  /// **'FT'**
  String get matchStatusFT;

  /// No description provided for @matchLive.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get matchLive;

  /// No description provided for @matchVS.
  ///
  /// In en, this message translates to:
  /// **'VS'**
  String get matchVS;

  /// No description provided for @matchStatusLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get matchStatusLive;

  /// No description provided for @matchStatusFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get matchStatusFinished;

  /// No description provided for @matchStatusNotStarted.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get matchStatusNotStarted;

  /// No description provided for @newsRefreshButton.
  ///
  /// In en, this message translates to:
  /// **'Refresh news'**
  String get newsRefreshButton;

  /// No description provided for @newsErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not load news'**
  String get newsErrorTitle;

  /// No description provided for @newsErrorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check your connection'**
  String get newsErrorSubtitle;

  /// No description provided for @newsRetryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get newsRetryButton;

  /// No description provided for @analysisInProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Analysis in progress'**
  String get analysisInProgressTitle;

  /// No description provided for @analysisLeaveWarning.
  ///
  /// In en, this message translates to:
  /// **'If you leave now, the analysis will be canceled and you will lose your progress. Do you want to continue?'**
  String get analysisLeaveWarning;

  /// No description provided for @analysisStayButton.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get analysisStayButton;

  /// No description provided for @analysisExitButton.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get analysisExitButton;

  /// No description provided for @analysisProcessingWithAI.
  ///
  /// In en, this message translates to:
  /// **'Processing with AI...'**
  String get analysisProcessingWithAI;

  /// No description provided for @analysisCancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get analysisCancelButton;

  /// No description provided for @analysisProcessingBanner.
  ///
  /// In en, this message translates to:
  /// **'Analyzing video with artificial intelligence. This may take a few minutes.'**
  String get analysisProcessingBanner;

  /// No description provided for @editPlayerTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit player'**
  String get editPlayerTitle;

  /// No description provided for @editPlayerNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get editPlayerNameLabel;

  /// No description provided for @editPlayerNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get editPlayerNumberLabel;

  /// No description provided for @editPlayerPositionLabel.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get editPlayerPositionLabel;

  /// No description provided for @editPlayerDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Player {rank}'**
  String editPlayerDefaultName(int rank);

  /// No description provided for @cancelBtn.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelBtn;

  /// No description provided for @saveBtn.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveBtn;

  /// No description provided for @deleteBtn.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteBtn;

  /// No description provided for @coachingBoardTitle.
  ///
  /// In en, this message translates to:
  /// **'Coaching Board'**
  String get coachingBoardTitle;

  /// No description provided for @coachingBoardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a team to build the tactical board'**
  String get coachingBoardSubtitle;

  /// No description provided for @coachingBoardSelectTeamTitle.
  ///
  /// In en, this message translates to:
  /// **'Select a team'**
  String get coachingBoardSelectTeamTitle;

  /// No description provided for @coachingBoardSelectTeamSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a team to build the tactical board'**
  String get coachingBoardSelectTeamSubtitle;

  /// No description provided for @coachingBoardNoTeams.
  ///
  /// In en, this message translates to:
  /// **'No teams'**
  String get coachingBoardNoTeams;

  /// No description provided for @coachingBoardNoTeamsHint.
  ///
  /// In en, this message translates to:
  /// **'Create a team in the Home tab'**
  String get coachingBoardNoTeamsHint;

  /// No description provided for @coachingBoardSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get coachingBoardSave;

  /// No description provided for @coachingBoardReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get coachingBoardReset;

  /// No description provided for @coachingBoardSwapHint.
  ///
  /// In en, this message translates to:
  /// **'Long press = swap'**
  String get coachingBoardSwapHint;

  /// No description provided for @coachingBoardSwapBanner.
  ///
  /// In en, this message translates to:
  /// **'Tap another player to swap'**
  String get coachingBoardSwapBanner;

  /// No description provided for @coachingBoardAnalyzingTitle.
  ///
  /// In en, this message translates to:
  /// **'Analyzing {teamName}'**
  String coachingBoardAnalyzingTitle(String teamName);

  /// No description provided for @coachingBoardAnalyzingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Building the tactical board with AI'**
  String get coachingBoardAnalyzingSubtitle;

  /// No description provided for @coachingBoardStepLoadingPlayers.
  ///
  /// In en, this message translates to:
  /// **'Loading players...'**
  String get coachingBoardStepLoadingPlayers;

  /// No description provided for @coachingBoardStepReadingStats.
  ///
  /// In en, this message translates to:
  /// **'Reading statistics...'**
  String get coachingBoardStepReadingStats;

  /// No description provided for @coachingBoardStepComputingPositions.
  ///
  /// In en, this message translates to:
  /// **'Computing optimal positions...'**
  String get coachingBoardStepComputingPositions;

  /// No description provided for @coachingBoardStepBuildingBoard.
  ///
  /// In en, this message translates to:
  /// **'Building tactical board...'**
  String get coachingBoardStepBuildingBoard;

  /// No description provided for @coachingBoardSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Formation saved ✓'**
  String get coachingBoardSaveSuccess;

  /// No description provided for @coachingBoardSaveError.
  ///
  /// In en, this message translates to:
  /// **'Error while saving the formation'**
  String get coachingBoardSaveError;

  /// No description provided for @categoryU6.
  ///
  /// In en, this message translates to:
  /// **'U6'**
  String get categoryU6;

  /// No description provided for @categoryU8.
  ///
  /// In en, this message translates to:
  /// **'U8'**
  String get categoryU8;

  /// No description provided for @categoryU10.
  ///
  /// In en, this message translates to:
  /// **'U10'**
  String get categoryU10;

  /// No description provided for @categoryU12.
  ///
  /// In en, this message translates to:
  /// **'U12'**
  String get categoryU12;

  /// No description provided for @categoryU14.
  ///
  /// In en, this message translates to:
  /// **'U14'**
  String get categoryU14;

  /// No description provided for @categoryU16.
  ///
  /// In en, this message translates to:
  /// **'U16'**
  String get categoryU16;

  /// No description provided for @categoryU18.
  ///
  /// In en, this message translates to:
  /// **'U18'**
  String get categoryU18;

  /// No description provided for @categoryU20.
  ///
  /// In en, this message translates to:
  /// **'U20'**
  String get categoryU20;

  /// No description provided for @categoryU23.
  ///
  /// In en, this message translates to:
  /// **'U23'**
  String get categoryU23;

  /// No description provided for @categoryAmateur.
  ///
  /// In en, this message translates to:
  /// **'Amateur'**
  String get categoryAmateur;

  /// No description provided for @categorySemiProfessional.
  ///
  /// In en, this message translates to:
  /// **'Semi-professional'**
  String get categorySemiProfessional;

  /// No description provided for @categoryProfessional.
  ///
  /// In en, this message translates to:
  /// **'Professional'**
  String get categoryProfessional;

  /// No description provided for @categoryFemaleU12.
  ///
  /// In en, this message translates to:
  /// **'Female U12'**
  String get categoryFemaleU12;

  /// No description provided for @categoryFemaleU16.
  ///
  /// In en, this message translates to:
  /// **'Female U16'**
  String get categoryFemaleU16;

  /// No description provided for @categoryFemaleU18.
  ///
  /// In en, this message translates to:
  /// **'Female U18'**
  String get categoryFemaleU18;

  /// No description provided for @categoryFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get categoryFemale;

  /// No description provided for @categoryMixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get categoryMixed;

  /// No description provided for @countryArgentina.
  ///
  /// In en, this message translates to:
  /// **'Argentina'**
  String get countryArgentina;

  /// No description provided for @countryBolivia.
  ///
  /// In en, this message translates to:
  /// **'Bolivia'**
  String get countryBolivia;

  /// No description provided for @countryBrazil.
  ///
  /// In en, this message translates to:
  /// **'Brazil'**
  String get countryBrazil;

  /// No description provided for @countryChile.
  ///
  /// In en, this message translates to:
  /// **'Chile'**
  String get countryChile;

  /// No description provided for @countryColombia.
  ///
  /// In en, this message translates to:
  /// **'Colombia'**
  String get countryColombia;

  /// No description provided for @countryCostaRica.
  ///
  /// In en, this message translates to:
  /// **'Costa Rica'**
  String get countryCostaRica;

  /// No description provided for @countryCuba.
  ///
  /// In en, this message translates to:
  /// **'Cuba'**
  String get countryCuba;

  /// No description provided for @countryEcuador.
  ///
  /// In en, this message translates to:
  /// **'Ecuador'**
  String get countryEcuador;

  /// No description provided for @countryElSalvador.
  ///
  /// In en, this message translates to:
  /// **'El Salvador'**
  String get countryElSalvador;

  /// No description provided for @countrySpain.
  ///
  /// In en, this message translates to:
  /// **'Spain'**
  String get countrySpain;

  /// No description provided for @countryUnitedStates.
  ///
  /// In en, this message translates to:
  /// **'United States'**
  String get countryUnitedStates;

  /// No description provided for @countryGuatemala.
  ///
  /// In en, this message translates to:
  /// **'Guatemala'**
  String get countryGuatemala;

  /// No description provided for @countryHonduras.
  ///
  /// In en, this message translates to:
  /// **'Honduras'**
  String get countryHonduras;

  /// No description provided for @countryMexico.
  ///
  /// In en, this message translates to:
  /// **'Mexico'**
  String get countryMexico;

  /// No description provided for @countryNicaragua.
  ///
  /// In en, this message translates to:
  /// **'Nicaragua'**
  String get countryNicaragua;

  /// No description provided for @countryPanama.
  ///
  /// In en, this message translates to:
  /// **'Panama'**
  String get countryPanama;

  /// No description provided for @countryParaguay.
  ///
  /// In en, this message translates to:
  /// **'Paraguay'**
  String get countryParaguay;

  /// No description provided for @countryPeru.
  ///
  /// In en, this message translates to:
  /// **'Peru'**
  String get countryPeru;

  /// No description provided for @countryPuertoRico.
  ///
  /// In en, this message translates to:
  /// **'Puerto Rico'**
  String get countryPuertoRico;

  /// No description provided for @countryDominicanRepublic.
  ///
  /// In en, this message translates to:
  /// **'Dominican Republic'**
  String get countryDominicanRepublic;

  /// No description provided for @countryUruguay.
  ///
  /// In en, this message translates to:
  /// **'Uruguay'**
  String get countryUruguay;

  /// No description provided for @countryVenezuela.
  ///
  /// In en, this message translates to:
  /// **'Venezuela'**
  String get countryVenezuela;

  /// No description provided for @countryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get countryOther;

  /// Greeting shown in the morning for the coach
  ///
  /// In en, this message translates to:
  /// **'Good morning, Coach'**
  String get greetingMorningCoach;

  /// Greeting shown in the afternoon for the coach
  ///
  /// In en, this message translates to:
  /// **'Good afternoon, Coach'**
  String get greetingAfternoonCoach;

  /// Greeting shown in the evening for the coach
  ///
  /// In en, this message translates to:
  /// **'Good evening, Coach'**
  String get greetingEveningCoach;

  /// Hero secondary text when no team is selected
  ///
  /// In en, this message translates to:
  /// **'PlayVision · AI tactical platform'**
  String get heroPlatformTagline;

  /// Hero secondary text when a team is selected
  ///
  /// In en, this message translates to:
  /// **'{teamName} · ready to analyze'**
  String heroTeamReady(String teamName);

  /// No description provided for @searchFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Search teams or matches…'**
  String get searchFieldLabel;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String searchNoResults(String query);

  /// No description provided for @searchTeamsCount.
  ///
  /// In en, this message translates to:
  /// **'Teams ({count})'**
  String searchTeamsCount(int count);

  /// No description provided for @searchMatchesCount.
  ///
  /// In en, this message translates to:
  /// **'Matches ({count})'**
  String searchMatchesCount(int count);

  /// No description provided for @newsNoDescriptionAvailable.
  ///
  /// In en, this message translates to:
  /// **'No description available'**
  String get newsNoDescriptionAvailable;

  /// No description provided for @quickActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quickActionsTitle;

  /// No description provided for @quickActionAnalyzeVideo.
  ///
  /// In en, this message translates to:
  /// **'Analyze\nVideo'**
  String get quickActionAnalyzeVideo;

  /// No description provided for @quickActionTacticalBoard.
  ///
  /// In en, this message translates to:
  /// **'Tactical\nBoard'**
  String get quickActionTacticalBoard;

  /// No description provided for @quickActionMyPlayers.
  ///
  /// In en, this message translates to:
  /// **'My\nPlayers'**
  String get quickActionMyPlayers;

  /// No description provided for @quickActionTraining.
  ///
  /// In en, this message translates to:
  /// **'Train-\ning'**
  String get quickActionTraining;

  /// No description provided for @axisSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get axisSpeed;

  /// No description provided for @axisPass.
  ///
  /// In en, this message translates to:
  /// **'Pass'**
  String get axisPass;

  /// No description provided for @axisShoot.
  ///
  /// In en, this message translates to:
  /// **'Shoot'**
  String get axisShoot;

  /// No description provided for @axisDefend.
  ///
  /// In en, this message translates to:
  /// **'Defend'**
  String get axisDefend;

  /// No description provided for @axisPhysical.
  ///
  /// In en, this message translates to:
  /// **'Physical'**
  String get axisPhysical;

  /// No description provided for @axisSpeedExplain.
  ///
  /// In en, this message translates to:
  /// **'Distance covered and sprint speed'**
  String get axisSpeedExplain;

  /// No description provided for @axisPassExplain.
  ///
  /// In en, this message translates to:
  /// **'Pass accuracy and volume'**
  String get axisPassExplain;

  /// No description provided for @axisShootExplain.
  ///
  /// In en, this message translates to:
  /// **'Goals and shots on target'**
  String get axisShootExplain;

  /// No description provided for @axisDefendExplain.
  ///
  /// In en, this message translates to:
  /// **'Recoveries and defensive tackles'**
  String get axisDefendExplain;

  /// No description provided for @axisPhysicalExplain.
  ///
  /// In en, this message translates to:
  /// **'Physical endurance and duels won'**
  String get axisPhysicalExplain;

  /// No description provided for @insightHighRating.
  ///
  /// In en, this message translates to:
  /// **'High performance · {rating} ★'**
  String insightHighRating(String rating);

  /// No description provided for @insightGoodMatch.
  ///
  /// In en, this message translates to:
  /// **'Good match · {rating} ★'**
  String insightGoodMatch(String rating);

  /// No description provided for @insightLowRating.
  ///
  /// In en, this message translates to:
  /// **'Low performance · {rating} ★'**
  String insightLowRating(String rating);

  /// No description provided for @insightTrendUp.
  ///
  /// In en, this message translates to:
  /// **'+{pct}% vs recent average'**
  String insightTrendUp(int pct);

  /// No description provided for @insightTrendDown.
  ///
  /// In en, this message translates to:
  /// **'-{pct}% vs recent average'**
  String insightTrendDown(int pct);

  /// No description provided for @insightHighOffensive.
  ///
  /// In en, this message translates to:
  /// **'High offensive contribution · {goals}G {assists}A'**
  String insightHighOffensive(int goals, int assists);

  /// No description provided for @insightNoGoalContribution.
  ///
  /// In en, this message translates to:
  /// **'No direct goal contribution'**
  String get insightNoGoalContribution;

  /// No description provided for @insightLowDefensive.
  ///
  /// In en, this message translates to:
  /// **'Low defensive contribution · {tackles} recoveries'**
  String insightLowDefensive(int tackles);

  /// No description provided for @insightExcellentDefensive.
  ///
  /// In en, this message translates to:
  /// **'Excellent defensive work · {tackles} recoveries'**
  String insightExcellentDefensive(int tackles);

  /// No description provided for @insightExceptionalDistance.
  ///
  /// In en, this message translates to:
  /// **'Exceptional coverage · {km} km'**
  String insightExceptionalDistance(String km);

  /// No description provided for @insightLowDistance.
  ///
  /// In en, this message translates to:
  /// **'Low field coverage · {km} km'**
  String insightLowDistance(String km);

  /// No description provided for @insightElitePass.
  ///
  /// In en, this message translates to:
  /// **'Elite pass accuracy · {pct}%'**
  String insightElitePass(int pct);

  /// No description provided for @insightLowPass.
  ///
  /// In en, this message translates to:
  /// **'Low pass accuracy · {pct}%'**
  String insightLowPass(int pct);

  /// No description provided for @insightAboveIdeal.
  ///
  /// In en, this message translates to:
  /// **'↑ {axis} above ideal profile'**
  String insightAboveIdeal(String axis);

  /// No description provided for @insightBelowIdeal.
  ///
  /// In en, this message translates to:
  /// **'↓ {axis} below position profile'**
  String insightBelowIdeal(String axis);

  /// No description provided for @insightBestPosition.
  ///
  /// In en, this message translates to:
  /// **'Suggested optimal position: {position}'**
  String insightBestPosition(String position);

  /// No description provided for @insightHintWarning.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get insightHintWarning;

  /// No description provided for @insightHintInfo.
  ///
  /// In en, this message translates to:
  /// **'AI suggestion'**
  String get insightHintInfo;

  /// No description provided for @sheetPinned.
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get sheetPinned;

  /// No description provided for @tabAssistant.
  ///
  /// In en, this message translates to:
  /// **'🧠 Assistant'**
  String get tabAssistant;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'📊 Profile'**
  String get tabProfile;

  /// No description provided for @tabMatch.
  ///
  /// In en, this message translates to:
  /// **'⚡ Match'**
  String get tabMatch;

  /// No description provided for @sectionCoachAssistant.
  ///
  /// In en, this message translates to:
  /// **'COACH ASSISTANT'**
  String get sectionCoachAssistant;

  /// No description provided for @sectionComparisonRadar.
  ///
  /// In en, this message translates to:
  /// **'COMPARISON RADAR'**
  String get sectionComparisonRadar;

  /// No description provided for @toggleVsPosition.
  ///
  /// In en, this message translates to:
  /// **'vs Ideal position'**
  String get toggleVsPosition;

  /// No description provided for @toggleVsTeam.
  ///
  /// In en, this message translates to:
  /// **'vs Team average'**
  String get toggleVsTeam;

  /// No description provided for @legendIdealProfile.
  ///
  /// In en, this message translates to:
  /// **'Ideal profile'**
  String get legendIdealProfile;

  /// No description provided for @legendTeamAverage.
  ///
  /// In en, this message translates to:
  /// **'Team average'**
  String get legendTeamAverage;

  /// No description provided for @tapAxisForDetail.
  ///
  /// In en, this message translates to:
  /// **'Tap an axis for details'**
  String get tapAxisForDetail;

  /// No description provided for @axisDetailPlayer.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get axisDetailPlayer;

  /// No description provided for @quickStatRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get quickStatRating;

  /// No description provided for @quickStatGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get quickStatGoals;

  /// No description provided for @quickStatAssists.
  ///
  /// In en, this message translates to:
  /// **'Ast.'**
  String get quickStatAssists;

  /// No description provided for @quickStatKm.
  ///
  /// In en, this message translates to:
  /// **'Km'**
  String get quickStatKm;

  /// No description provided for @quickStatPassPct.
  ///
  /// In en, this message translates to:
  /// **'Pass%'**
  String get quickStatPassPct;

  /// No description provided for @matchRatingLabel.
  ///
  /// In en, this message translates to:
  /// **'Match rating'**
  String get matchRatingLabel;

  /// No description provided for @matchStatGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get matchStatGoals;

  /// No description provided for @matchStatAssists.
  ///
  /// In en, this message translates to:
  /// **'Assists'**
  String get matchStatAssists;

  /// No description provided for @matchStatDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get matchStatDistance;

  /// No description provided for @matchStatPasses.
  ///
  /// In en, this message translates to:
  /// **'Passes'**
  String get matchStatPasses;

  /// No description provided for @matchStatAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get matchStatAccuracy;

  /// No description provided for @matchStatMinutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get matchStatMinutes;

  /// No description provided for @matchRatingTrend.
  ///
  /// In en, this message translates to:
  /// **'Rating trend'**
  String get matchRatingTrend;

  /// No description provided for @playersLoadingSquad.
  ///
  /// In en, this message translates to:
  /// **'Loading squad…'**
  String get playersLoadingSquad;

  /// No description provided for @playersSquadAvailable.
  ///
  /// In en, this message translates to:
  /// **'{count} squad players available'**
  String playersSquadAvailable(int count);

  /// No description provided for @playersNoSquadHint.
  ///
  /// In en, this message translates to:
  /// **'No players in the squad. Add players first.'**
  String get playersNoSquadHint;

  /// No description provided for @playersLinked.
  ///
  /// In en, this message translates to:
  /// **'Linked'**
  String get playersLinked;

  /// No description provided for @playersPresenceShort.
  ///
  /// In en, this message translates to:
  /// **'PRES'**
  String get playersPresenceShort;

  /// No description provided for @playersEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Player {rank} · Edit'**
  String playersEditTitle(int rank);

  /// No description provided for @playersUnlink.
  ///
  /// In en, this message translates to:
  /// **'Unlink'**
  String get playersUnlink;

  /// No description provided for @playersLinkToSquad.
  ///
  /// In en, this message translates to:
  /// **'Link to squad player'**
  String get playersLinkToSquad;

  /// No description provided for @playersOrEditManually.
  ///
  /// In en, this message translates to:
  /// **'or edit manually'**
  String get playersOrEditManually;

  /// No description provided for @playersNoLinkedTeamHint.
  ///
  /// In en, this message translates to:
  /// **'No linked team. Add players to the squad to link them.'**
  String get playersNoLinkedTeamHint;

  /// No description provided for @playersLinkAndSave.
  ///
  /// In en, this message translates to:
  /// **'Link and save'**
  String get playersLinkAndSave;

  /// No description provided for @analysisNoTeamSelected.
  ///
  /// In en, this message translates to:
  /// **'No team selected. Go back and choose one.'**
  String get analysisNoTeamSelected;

  /// No description provided for @analysisServerError.
  ///
  /// In en, this message translates to:
  /// **'Server error: {code}'**
  String analysisServerError(String code);

  /// No description provided for @analysisConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection error: {error}'**
  String analysisConnectionError(String error);

  /// No description provided for @playerProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Player {id}'**
  String playerProfileTitle(int id);

  /// No description provided for @playerSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Player summary'**
  String get playerSummaryTitle;

  /// No description provided for @playerBestPositionTitle.
  ///
  /// In en, this message translates to:
  /// **'Best position: {position}'**
  String playerBestPositionTitle(String position);

  /// No description provided for @playerMatchesCount.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get playerMatchesCount;

  /// No description provided for @playerCoachInsights.
  ///
  /// In en, this message translates to:
  /// **'Coach insights'**
  String get playerCoachInsights;

  /// No description provided for @playerDominantZone.
  ///
  /// In en, this message translates to:
  /// **'Dominant zone'**
  String get playerDominantZone;

  /// No description provided for @playerLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the player profile.'**
  String get playerLoadError;

  /// No description provided for @matchesTimeoutError.
  ///
  /// In en, this message translates to:
  /// **'The connection took too long. Check your network.'**
  String get matchesTimeoutError;

  /// No description provided for @matchesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the data.'**
  String get matchesLoadError;

  /// No description provided for @matchesSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save the match.'**
  String get matchesSaveError;

  /// No description provided for @matchesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No matches registered'**
  String get matchesEmptyTitle;

  /// No description provided for @matchesAddButton.
  ///
  /// In en, this message translates to:
  /// **'+ Add match'**
  String get matchesAddButton;

  /// No description provided for @matchesRequireTeamFirst.
  ///
  /// In en, this message translates to:
  /// **'Create at least one team first.'**
  String get matchesRequireTeamFirst;

  /// No description provided for @matchesNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New match'**
  String get matchesNewTitle;

  /// No description provided for @matchesTeamLabel.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get matchesTeamLabel;

  /// No description provided for @matchesOpponentLabel.
  ///
  /// In en, this message translates to:
  /// **'Opponent'**
  String get matchesOpponentLabel;

  /// No description provided for @matchesVideoSourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Video source'**
  String get matchesVideoSourceLabel;

  /// No description provided for @matchesUploadSource.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get matchesUploadSource;

  /// No description provided for @matchesYouTubeSource.
  ///
  /// In en, this message translates to:
  /// **'YouTube'**
  String get matchesYouTubeSource;

  /// No description provided for @matchesDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String matchesDateLabel(String date);

  /// No description provided for @matchesTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time: {time}'**
  String matchesTimeLabel(String time);

  /// No description provided for @matchesSaved.
  ///
  /// In en, this message translates to:
  /// **'Match saved'**
  String get matchesSaved;

  /// No description provided for @matchesNoTeam.
  ///
  /// In en, this message translates to:
  /// **'No team'**
  String get matchesNoTeam;

  /// No description provided for @squadLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load the squad.'**
  String get squadLoadError;

  /// No description provided for @playerSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save the player.'**
  String get playerSaveError;

  /// No description provided for @playerUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Could not update the player.'**
  String get playerUpdateError;

  /// No description provided for @playerDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the player.'**
  String get playerDeleteError;

  /// No description provided for @playerPhotoUploadError.
  ///
  /// In en, this message translates to:
  /// **'Could not upload the player\'s photo.'**
  String get playerPhotoUploadError;

  /// No description provided for @squadPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Squad'**
  String get squadPageTitle;

  /// No description provided for @squadPageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} players · Season 25/26'**
  String squadPageSubtitle(int count);

  /// No description provided for @squadSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search players...'**
  String get squadSearchHint;

  /// No description provided for @squadPositionAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get squadPositionAll;

  /// No description provided for @squadCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} players'**
  String squadCountLabel(int count);

  /// No description provided for @squadAddPlayerTitle.
  ///
  /// In en, this message translates to:
  /// **'New player'**
  String get squadAddPlayerTitle;

  /// No description provided for @squadEditPlayerTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit player'**
  String get squadEditPlayerTitle;

  /// No description provided for @squadDeletePlayerTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete player'**
  String get squadDeletePlayerTitle;

  /// No description provided for @squadDeletePlayerConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete {name} from the squad? This cannot be undone.'**
  String squadDeletePlayerConfirm(String name);

  /// No description provided for @squadDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get squadDeleteButton;

  /// No description provided for @squadPlayerSaved.
  ///
  /// In en, this message translates to:
  /// **'Player saved'**
  String get squadPlayerSaved;

  /// No description provided for @squadPlayerUpdated.
  ///
  /// In en, this message translates to:
  /// **'Player updated'**
  String get squadPlayerUpdated;

  /// No description provided for @squadPlayerDeleted.
  ///
  /// In en, this message translates to:
  /// **'Player deleted'**
  String get squadPlayerDeleted;

  /// No description provided for @squadPlayerSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Error saving player'**
  String get squadPlayerSaveFailed;

  /// No description provided for @squadPlayerUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Error updating player'**
  String get squadPlayerUpdateFailed;

  /// No description provided for @squadPlayerDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Error deleting player'**
  String get squadPlayerDeleteFailed;

  /// No description provided for @squadNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get squadNameLabel;

  /// No description provided for @squadNameHint.
  ///
  /// In en, this message translates to:
  /// **'E.g. Carlos García'**
  String get squadNameHint;

  /// No description provided for @squadNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get squadNumberLabel;

  /// No description provided for @squadNumberHint.
  ///
  /// In en, this message translates to:
  /// **'E.g. 10'**
  String get squadNumberHint;

  /// No description provided for @squadPositionLabel.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get squadPositionLabel;

  /// No description provided for @squadStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get squadStatusLabel;

  /// No description provided for @squadBirthDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get squadBirthDateLabel;

  /// No description provided for @squadBirthDateOptional.
  ///
  /// In en, this message translates to:
  /// **'Date of birth (optional)'**
  String get squadBirthDateOptional;

  /// No description provided for @squadPhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get squadPhotoLabel;

  /// No description provided for @squadChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get squadChangePhoto;

  /// No description provided for @squadPosGk.
  ///
  /// In en, this message translates to:
  /// **'Goalkeeper GK'**
  String get squadPosGk;

  /// No description provided for @squadPosDef.
  ///
  /// In en, this message translates to:
  /// **'Defender DEF'**
  String get squadPosDef;

  /// No description provided for @squadPosMid.
  ///
  /// In en, this message translates to:
  /// **'Midfielder MID'**
  String get squadPosMid;

  /// No description provided for @squadPosFwd.
  ///
  /// In en, this message translates to:
  /// **'Forward FWD'**
  String get squadPosFwd;

  /// No description provided for @squadStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get squadStatusActive;

  /// No description provided for @squadStatusInjured.
  ///
  /// In en, this message translates to:
  /// **'Injured'**
  String get squadStatusInjured;

  /// No description provided for @squadStatusSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get squadStatusSuspended;

  /// No description provided for @squadStatusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get squadStatusInactive;

  /// No description provided for @squadFormExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get squadFormExcellent;

  /// No description provided for @squadFormGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get squadFormGood;

  /// No description provided for @squadFormRegular.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get squadFormRegular;

  /// No description provided for @squadEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No players'**
  String get squadEmptyTitle;

  /// No description provided for @squadEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap to add players'**
  String get squadEmptySubtitle;

  /// No description provided for @squadDefaultTeam.
  ///
  /// In en, this message translates to:
  /// **'My team'**
  String get squadDefaultTeam;

  /// No description provided for @squadMyTeam.
  ///
  /// In en, this message translates to:
  /// **'My team'**
  String get squadMyTeam;

  /// No description provided for @weekdayMon.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get weekdaySat;

  /// No description provided for @weekdaySun.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get weekdaySun;

  /// No description provided for @weekdayMonFull.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get weekdayMonFull;

  /// No description provided for @weekdayTueFull.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get weekdayTueFull;

  /// No description provided for @weekdayWedFull.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get weekdayWedFull;

  /// No description provided for @weekdayThuFull.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get weekdayThuFull;

  /// No description provided for @weekdayFriFull.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get weekdayFriFull;

  /// No description provided for @weekdaySatFull.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get weekdaySatFull;

  /// No description provided for @weekdaySunFull.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get weekdaySunFull;

  /// No description provided for @trainingFitnessNoVideo.
  ///
  /// In en, this message translates to:
  /// **'Upload a training video to see the team\'s fitness status.'**
  String get trainingFitnessNoVideo;

  /// No description provided for @trainingFitnessLow.
  ///
  /// In en, this message translates to:
  /// **'Increase high-intensity sessions this week.'**
  String get trainingFitnessLow;

  /// No description provided for @trainingFitnessMedium.
  ///
  /// In en, this message translates to:
  /// **'Good shape. Keep the load with technical sessions.'**
  String get trainingFitnessMedium;

  /// No description provided for @trainingFitnessHigh.
  ///
  /// In en, this message translates to:
  /// **'Excellent form. Focus on recovery and tactics.'**
  String get trainingFitnessHigh;

  /// No description provided for @trainingFitnessLevelLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get trainingFitnessLevelLow;

  /// No description provided for @trainingFitnessLevelMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get trainingFitnessLevelMedium;

  /// No description provided for @trainingFitnessLevelHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get trainingFitnessLevelHigh;

  /// No description provided for @trainingInsightLowDistance.
  ///
  /// In en, this message translates to:
  /// **'⚠️ The team covers little distance ({km} km). Increase intensity.'**
  String trainingInsightLowDistance(String km);

  /// No description provided for @trainingInsightHighDistance.
  ///
  /// In en, this message translates to:
  /// **'💪 High team mobility ({km} km/player).'**
  String trainingInsightHighDistance(String km);

  /// No description provided for @trainingInsightPlayersAnalysed.
  ///
  /// In en, this message translates to:
  /// **'✅ {count} players analysed in the last training.'**
  String trainingInsightPlayersAnalysed(String count);

  /// No description provided for @trainingInsightNoVideo.
  ///
  /// In en, this message translates to:
  /// **'📹 Upload a training video to get automatic insights.'**
  String get trainingInsightNoVideo;

  /// No description provided for @trainingTeamLowDistance.
  ///
  /// In en, this message translates to:
  /// **'The team covers little average distance ({km} km). Increase aerobic intensity.'**
  String trainingTeamLowDistance(String km);

  /// No description provided for @trainingTeamHighDistance.
  ///
  /// In en, this message translates to:
  /// **'High team mobility ({km} km/player). Prioritise recovery.'**
  String trainingTeamHighDistance(String km);

  /// No description provided for @trainingTeamLowPossession.
  ///
  /// In en, this message translates to:
  /// **'Frequent possession loss ({pct}%). Reinforce positional play.'**
  String trainingTeamLowPossession(String pct);

  /// No description provided for @trainingTeamHighPossession.
  ///
  /// In en, this message translates to:
  /// **'Good team possession ({pct}%). Work on finishing and exploiting dominance.'**
  String trainingTeamHighPossession(String pct);

  /// No description provided for @trainingTeamActivityGap.
  ///
  /// In en, this message translates to:
  /// **'Big gap between most active (#{most}) and least active (#{least}) player.'**
  String trainingTeamActivityGap(String most, String least);

  /// No description provided for @trainingTeamConcentratedPossession.
  ///
  /// In en, this message translates to:
  /// **'Player #{player} concentrates possession. Work on ball circulation.'**
  String trainingTeamConcentratedPossession(String player);

  /// No description provided for @trainingTeamBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced performance. Keep the current tactical plan.'**
  String get trainingTeamBalanced;

  /// No description provided for @trainingPlayerLowDistance.
  ///
  /// In en, this message translates to:
  /// **'Increase endurance: short distance recorded. Add running drills.'**
  String get trainingPlayerLowDistance;

  /// No description provided for @trainingPlayerLowSpeed.
  ///
  /// In en, this message translates to:
  /// **'Work on explosive speed: recorded pace is low.'**
  String get trainingPlayerLowSpeed;

  /// No description provided for @trainingPlayerLowPossession.
  ///
  /// In en, this message translates to:
  /// **'Improve involvement with the ball.'**
  String get trainingPlayerLowPossession;

  /// No description provided for @trainingPlayerLowPresence.
  ///
  /// In en, this message translates to:
  /// **'Increase presence on the field.'**
  String get trainingPlayerLowPresence;

  /// No description provided for @trainingPlayerDefRole.
  ///
  /// In en, this message translates to:
  /// **'Defensive role: reinforce positioning.'**
  String get trainingPlayerDefRole;

  /// No description provided for @trainingPlayerAttRole.
  ///
  /// In en, this message translates to:
  /// **'Offensive role: work on finishing and off-ball movement.'**
  String get trainingPlayerAttRole;

  /// No description provided for @trainingPlayerSolid.
  ///
  /// In en, this message translates to:
  /// **'Solid performance. Maintain your work rate.'**
  String get trainingPlayerSolid;

  /// No description provided for @trainingSugTitlePressing.
  ///
  /// In en, this message translates to:
  /// **'High press and transitions'**
  String get trainingSugTitlePressing;

  /// No description provided for @trainingSugReasonPressing.
  ///
  /// In en, this message translates to:
  /// **'Improve pressing'**
  String get trainingSugReasonPressing;

  /// No description provided for @trainingSugTitlePossession.
  ///
  /// In en, this message translates to:
  /// **'4-3-3 possession'**
  String get trainingSugTitlePossession;

  /// No description provided for @trainingSugReasonPossession.
  ///
  /// In en, this message translates to:
  /// **'Positional play'**
  String get trainingSugReasonPossession;

  /// No description provided for @trainingSugTitlePhysical.
  ///
  /// In en, this message translates to:
  /// **'Endurance and explosiveness'**
  String get trainingSugTitlePhysical;

  /// No description provided for @trainingSugReasonPhysical.
  ///
  /// In en, this message translates to:
  /// **'Physical improvement'**
  String get trainingSugReasonPhysical;

  /// No description provided for @trainingNewSession.
  ///
  /// In en, this message translates to:
  /// **'New session'**
  String get trainingNewSession;

  /// No description provided for @trainingSessionTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Session title'**
  String get trainingSessionTitleHint;

  /// No description provided for @trainingSessionDescHint.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get trainingSessionDescHint;

  /// No description provided for @trainingDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration:'**
  String get trainingDurationLabel;

  /// No description provided for @trainingCreateSession.
  ///
  /// In en, this message translates to:
  /// **'Create session'**
  String get trainingCreateSession;

  /// No description provided for @trainingAddOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'What would you like to add?'**
  String get trainingAddOptionsTitle;

  /// No description provided for @trainingOptionAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Analyse match'**
  String get trainingOptionAnalyze;

  /// No description provided for @trainingOptionAnalyzeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload a video and auto-generate a session with AI'**
  String get trainingOptionAnalyzeSubtitle;

  /// No description provided for @trainingOptionManual.
  ///
  /// In en, this message translates to:
  /// **'Manual session'**
  String get trainingOptionManual;

  /// No description provided for @trainingOptionManualSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a custom training session'**
  String get trainingOptionManualSubtitle;

  /// No description provided for @trainingDeleteSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete session'**
  String get trainingDeleteSessionTitle;

  /// No description provided for @trainingDeleteSessionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"?'**
  String trainingDeleteSessionConfirm(String title);

  /// No description provided for @trainingSessionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No sessions} =1{1 session} other{{count} sessions}}'**
  String trainingSessionCount(int count);

  /// No description provided for @trainingNoSessionsDay.
  ///
  /// In en, this message translates to:
  /// **'No sessions this day'**
  String get trainingNoSessionsDay;

  /// No description provided for @trainingNoSessionsYet.
  ///
  /// In en, this message translates to:
  /// **'No sessions yet'**
  String get trainingNoSessionsYet;

  /// No description provided for @trainingNoSessionsHint.
  ///
  /// In en, this message translates to:
  /// **'Create your first training session'**
  String get trainingNoSessionsHint;

  /// No description provided for @trainingNoSuggestions.
  ///
  /// In en, this message translates to:
  /// **'No suggestions available'**
  String get trainingNoSuggestions;

  /// No description provided for @trainingPillFitness.
  ///
  /// In en, this message translates to:
  /// **'fitness'**
  String get trainingPillFitness;

  /// No description provided for @trainingPillPlayers.
  ///
  /// In en, this message translates to:
  /// **'players'**
  String get trainingPillPlayers;

  /// No description provided for @trainingPillSessions.
  ///
  /// In en, this message translates to:
  /// **'sessions'**
  String get trainingPillSessions;

  /// No description provided for @trainingPillStatus.
  ///
  /// In en, this message translates to:
  /// **'status'**
  String get trainingPillStatus;

  /// No description provided for @trainingSmartAnalysisSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Generate your training plan with AI'**
  String get trainingSmartAnalysisSubtitle;

  /// No description provided for @trainingUploadVideoBtn.
  ///
  /// In en, this message translates to:
  /// **'Upload match video'**
  String get trainingUploadVideoBtn;

  /// No description provided for @trainingStepUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload match video'**
  String get trainingStepUpload;

  /// No description provided for @trainingStepDetect.
  ///
  /// In en, this message translates to:
  /// **'Detect players'**
  String get trainingStepDetect;

  /// No description provided for @trainingStepAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Analyse movement'**
  String get trainingStepAnalyze;

  /// No description provided for @trainingStepInsights.
  ///
  /// In en, this message translates to:
  /// **'Generate insights'**
  String get trainingStepInsights;

  /// No description provided for @trainingStepExport.
  ///
  /// In en, this message translates to:
  /// **'Export PDF report'**
  String get trainingStepExport;

  /// No description provided for @trainingStepPending.
  ///
  /// In en, this message translates to:
  /// **'pending'**
  String get trainingStepPending;

  /// No description provided for @trainingLoadLabel.
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get trainingLoadLabel;

  /// No description provided for @trainingPhysicalStatus.
  ///
  /// In en, this message translates to:
  /// **'physical status'**
  String get trainingPhysicalStatus;

  /// No description provided for @trainingAvgDistance.
  ///
  /// In en, this message translates to:
  /// **'Avg. distance'**
  String get trainingAvgDistance;

  /// No description provided for @trainingAvgSpeed.
  ///
  /// In en, this message translates to:
  /// **'Avg. speed'**
  String get trainingAvgSpeed;

  /// No description provided for @trainingPlayers.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get trainingPlayers;

  /// No description provided for @trainingTopPlayers.
  ///
  /// In en, this message translates to:
  /// **'TOP PLAYERS'**
  String get trainingTopPlayers;

  /// No description provided for @trainingPlayerLabel.
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get trainingPlayerLabel;

  /// No description provided for @trainingStatDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get trainingStatDistance;

  /// No description provided for @trainingStatSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get trainingStatSpeed;

  /// No description provided for @trainingStatAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get trainingStatAccuracy;

  /// No description provided for @trainingStatRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get trainingStatRating;

  /// No description provided for @trainingAlertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Team alerts'**
  String get trainingAlertsTitle;

  /// No description provided for @trainingAlertFatigue.
  ///
  /// In en, this message translates to:
  /// **'Fatigue risk in 3 players'**
  String get trainingAlertFatigue;

  /// No description provided for @trainingAlertFatigueSub.
  ///
  /// In en, this message translates to:
  /// **'Consider reducing intensity tomorrow'**
  String get trainingAlertFatigueSub;

  /// No description provided for @trainingAlertMobility.
  ///
  /// In en, this message translates to:
  /// **'2 players with reduced mobility'**
  String get trainingAlertMobility;

  /// No description provided for @trainingAlertMobilitySub.
  ///
  /// In en, this message translates to:
  /// **'Recommend preventive stretching'**
  String get trainingAlertMobilitySub;

  /// No description provided for @trainingAlertTactical.
  ///
  /// In en, this message translates to:
  /// **'Low press in the middle zone'**
  String get trainingAlertTactical;

  /// No description provided for @trainingAlertTacticalSub.
  ///
  /// In en, this message translates to:
  /// **'Work on pressing in the next session'**
  String get trainingAlertTacticalSub;

  /// No description provided for @trainingTacticalConnections.
  ///
  /// In en, this message translates to:
  /// **'Tactical connections'**
  String get trainingTacticalConnections;

  /// No description provided for @trainingAICoachTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Coach'**
  String get trainingAICoachTitle;

  /// No description provided for @trainingAICoachSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Personalised tactical analysis'**
  String get trainingAICoachSubtitle;

  /// No description provided for @trainingCoachTip1.
  ///
  /// In en, this message translates to:
  /// **'Widen spaces in the offensive phase with open full-backs'**
  String get trainingCoachTip1;

  /// No description provided for @trainingCoachTip2.
  ///
  /// In en, this message translates to:
  /// **'High press after losing the ball in the build-up zone'**
  String get trainingCoachTip2;

  /// No description provided for @trainingCoachTip3.
  ///
  /// In en, this message translates to:
  /// **'Reduce distance between lines in the defensive phase'**
  String get trainingCoachTip3;

  /// No description provided for @trainingCoachTip4.
  ///
  /// In en, this message translates to:
  /// **'Quick switches of play to destabilise the opponent\'s defence'**
  String get trainingCoachTip4;

  /// No description provided for @trainingWeeklyActivity.
  ///
  /// In en, this message translates to:
  /// **'Weekly activity'**
  String get trainingWeeklyActivity;

  /// No description provided for @trainingSessionsPerDay.
  ///
  /// In en, this message translates to:
  /// **'sessions / day'**
  String get trainingSessionsPerDay;

  /// No description provided for @trainingSuggestedByAI.
  ///
  /// In en, this message translates to:
  /// **'SUGGESTED BY AI'**
  String get trainingSuggestedByAI;

  /// No description provided for @trainingMySessions.
  ///
  /// In en, this message translates to:
  /// **'MY SESSIONS'**
  String get trainingMySessions;

  /// No description provided for @trainingNewBtn.
  ///
  /// In en, this message translates to:
  /// **'+ New'**
  String get trainingNewBtn;

  /// No description provided for @trainingDemoDefenseOpen.
  ///
  /// In en, this message translates to:
  /// **'Defensive line very open in recent plays'**
  String get trainingDemoDefenseOpen;

  /// No description provided for @trainingDemoDefenseOpenSub.
  ///
  /// In en, this message translates to:
  /// **'Risk of space behind the defence'**
  String get trainingDemoDefenseOpenSub;

  /// No description provided for @trainingDemoImprovement.
  ///
  /// In en, this message translates to:
  /// **'12% improvement in pressing vs last week'**
  String get trainingDemoImprovement;

  /// No description provided for @trainingDemoImprovementSub.
  ///
  /// In en, this message translates to:
  /// **'Keep the intensity up'**
  String get trainingDemoImprovementSub;

  /// No description provided for @trainingDemoConnection.
  ///
  /// In en, this message translates to:
  /// **'Torres-Ramírez connection very effective'**
  String get trainingDemoConnection;

  /// No description provided for @trainingDemoConnectionSub.
  ///
  /// In en, this message translates to:
  /// **'Exploit that channel'**
  String get trainingDemoConnectionSub;

  /// No description provided for @trainingDemoPossession.
  ///
  /// In en, this message translates to:
  /// **'Dominant possession in the middle zone'**
  String get trainingDemoPossession;

  /// No description provided for @trainingDemoPossessionSub.
  ///
  /// In en, this message translates to:
  /// **'Use it for overlapping runs'**
  String get trainingDemoPossessionSub;

  /// No description provided for @trainingDemoFatigueRisk.
  ///
  /// In en, this message translates to:
  /// **'Fatigue risk in the left defence'**
  String get trainingDemoFatigueRisk;

  /// No description provided for @trainingDemoFatigueRiskSub.
  ///
  /// In en, this message translates to:
  /// **'Rotate in the next match'**
  String get trainingDemoFatigueRiskSub;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get navAnalysis;

  /// No description provided for @navPlayers.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get navPlayers;

  /// No description provided for @navTraining.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get navTraining;

  /// No description provided for @navBoard.
  ///
  /// In en, this message translates to:
  /// **'Board'**
  String get navBoard;

  /// No description provided for @trainingMinutesShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String trainingMinutesShort(int minutes);

  /// No description provided for @trainingExercisesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} exercises'**
  String trainingExercisesCount(int count);

  /// No description provided for @trainingDescriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get trainingDescriptionTitle;

  /// No description provided for @trainingSessionPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Session Plan'**
  String get trainingSessionPlanTitle;

  /// No description provided for @trainingMinutesTotal.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min total'**
  String trainingMinutesTotal(int minutes);

  /// No description provided for @trainingStartSession.
  ///
  /// In en, this message translates to:
  /// **'Start session'**
  String get trainingStartSession;

  /// No description provided for @trainingDeleteSessionQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete session?'**
  String get trainingDeleteSessionQuestion;

  /// No description provided for @trainingDeleteSessionBody.
  ///
  /// In en, this message translates to:
  /// **'This will permanently remove \"{title}\".'**
  String trainingDeleteSessionBody(String title);

  /// No description provided for @trainingExerciseProgress.
  ///
  /// In en, this message translates to:
  /// **'Exercise {current} of {total}'**
  String trainingExerciseProgress(int current, int total);

  /// No description provided for @trainingRunning.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get trainingRunning;

  /// No description provided for @trainingReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get trainingReady;

  /// No description provided for @trainingPaused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get trainingPaused;

  /// No description provided for @trainingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get trainingNext;

  /// No description provided for @trainingLastExercise.
  ///
  /// In en, this message translates to:
  /// **'Last exercise'**
  String get trainingLastExercise;

  /// No description provided for @trainingExitSessionQuestion.
  ///
  /// In en, this message translates to:
  /// **'Leave session?'**
  String get trainingExitSessionQuestion;

  /// No description provided for @trainingExitSessionBody.
  ///
  /// In en, this message translates to:
  /// **'Current progress will be lost.'**
  String get trainingExitSessionBody;

  /// No description provided for @trainingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get trainingContinue;

  /// No description provided for @trainingExit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get trainingExit;

  /// No description provided for @trainingSessionCompleted.
  ///
  /// In en, this message translates to:
  /// **'Session completed'**
  String get trainingSessionCompleted;

  /// No description provided for @trainingCompletedMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min completed'**
  String trainingCompletedMinutes(int minutes);

  /// No description provided for @trainingBackHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get trainingBackHome;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
