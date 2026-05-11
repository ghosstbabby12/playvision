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

  /// No description provided for @coachingBoardSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get coachingBoardSave;

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
