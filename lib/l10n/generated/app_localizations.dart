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
  /// In es, this message translates to:
  /// **'PlayVision'**
  String get appTitle;

  /// No description provided for @loginTitle.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión o regístrate para continuar'**
  String get loginTitle;

  /// No description provided for @emailHint.
  ///
  /// In es, this message translates to:
  /// **'Correo Electrónico'**
  String get emailHint;

  /// No description provided for @passwordHint.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get passwordHint;

  /// No description provided for @loginButton.
  ///
  /// In es, this message translates to:
  /// **'Iniciar Sesión'**
  String get loginButton;

  /// No description provided for @createAccountButton.
  ///
  /// In es, this message translates to:
  /// **'Crear una cuenta nueva'**
  String get createAccountButton;

  /// No description provided for @registerTitle.
  ///
  /// In es, this message translates to:
  /// **'Crea tu cuenta para empezar a analizar'**
  String get registerTitle;

  /// No description provided for @registerButton.
  ///
  /// In es, this message translates to:
  /// **'Registrarse'**
  String get registerButton;

  /// No description provided for @alreadyHaveAccountButton.
  ///
  /// In es, this message translates to:
  /// **'Ya tengo una cuenta'**
  String get alreadyHaveAccountButton;

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get settingsTitle;

  /// No description provided for @languageItem.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get languageItem;

  /// No description provided for @helpItem.
  ///
  /// In es, this message translates to:
  /// **'Ayuda'**
  String get helpItem;

  /// No description provided for @appearanceSection.
  ///
  /// In es, this message translates to:
  /// **'APARIENCIA'**
  String get appearanceSection;

  /// No description provided for @lightModeItem.
  ///
  /// In es, this message translates to:
  /// **'Modo Claro'**
  String get lightModeItem;

  /// No description provided for @infoSection.
  ///
  /// In es, this message translates to:
  /// **'INFORMACIÓN'**
  String get infoSection;

  /// No description provided for @aboutUsItem.
  ///
  /// In es, this message translates to:
  /// **'Sobre Nosotros'**
  String get aboutUsItem;

  /// No description provided for @aboutAppItem.
  ///
  /// In es, this message translates to:
  /// **'Sobre PlayVision'**
  String get aboutAppItem;

  /// No description provided for @logoutButton.
  ///
  /// In es, this message translates to:
  /// **'Cerrar Sesión'**
  String get logoutButton;

  /// No description provided for @selectOrCreateTeam.
  ///
  /// In es, this message translates to:
  /// **'Selecciona o crea un equipo'**
  String get selectOrCreateTeam;

  /// No description provided for @chooseTeamSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Elige un equipo para iniciar un nuevo análisis'**
  String get chooseTeamSubtitle;

  /// No description provided for @resultsTab.
  ///
  /// In es, this message translates to:
  /// **'Resultados'**
  String get resultsTab;

  /// No description provided for @newsTab.
  ///
  /// In es, this message translates to:
  /// **'Noticias'**
  String get newsTab;

  /// No description provided for @totalMatches.
  ///
  /// In es, this message translates to:
  /// **'Partidos totales'**
  String get totalMatches;

  /// No description provided for @analysed.
  ///
  /// In es, this message translates to:
  /// **'analizados'**
  String get analysed;

  /// No description provided for @createTeam.
  ///
  /// In es, this message translates to:
  /// **'Crear un equipo'**
  String get createTeam;

  /// No description provided for @tapToAddTeam.
  ///
  /// In es, this message translates to:
  /// **'Toca aquí para agregar tu primer equipo'**
  String get tapToAddTeam;

  /// No description provided for @newTeam.
  ///
  /// In es, this message translates to:
  /// **'Nuevo'**
  String get newTeam;

  /// No description provided for @changeTeam.
  ///
  /// In es, this message translates to:
  /// **'Cambiar'**
  String get changeTeam;

  /// No description provided for @analyseVideo.
  ///
  /// In es, this message translates to:
  /// **'Analizar video'**
  String get analyseVideo;

  /// No description provided for @uploadMatchVideo.
  ///
  /// In es, this message translates to:
  /// **'Sube un video de partido y obtén estadísticas de IA'**
  String get uploadMatchVideo;

  /// No description provided for @viewAnalysis.
  ///
  /// In es, this message translates to:
  /// **'Ver análisis'**
  String get viewAnalysis;

  /// No description provided for @teamMatches.
  ///
  /// In es, this message translates to:
  /// **'Partidos del equipo'**
  String get teamMatches;

  /// No description provided for @noAnalysedMatches.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay partidos analizados'**
  String get noAnalysedMatches;

  /// No description provided for @noRealMatchesToday.
  ///
  /// In es, this message translates to:
  /// **'No hay partidos reales hoy'**
  String get noRealMatchesToday;

  /// No description provided for @liveStatus.
  ///
  /// In es, this message translates to:
  /// **'En Vivo'**
  String get liveStatus;

  /// No description provided for @scheduledStatus.
  ///
  /// In es, this message translates to:
  /// **'Programado'**
  String get scheduledStatus;

  /// No description provided for @finishedStatus.
  ///
  /// In es, this message translates to:
  /// **'Finalizado'**
  String get finishedStatus;

  /// No description provided for @myAnalysesTitle.
  ///
  /// In es, this message translates to:
  /// **'Mis Análisis'**
  String get myAnalysesTitle;

  /// No description provided for @allMatchesGrouped.
  ///
  /// In es, this message translates to:
  /// **'Todos los partidos agrupados por equipo'**
  String get allMatchesGrouped;

  /// No description provided for @noAnalysisData.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay datos de análisis para este partido.'**
  String get noAnalysisData;

  /// No description provided for @matchWord.
  ///
  /// In es, this message translates to:
  /// **'Partido'**
  String get matchWord;

  /// No description provided for @statusAnalysed.
  ///
  /// In es, this message translates to:
  /// **'Analizado'**
  String get statusAnalysed;

  /// No description provided for @statusProcessing.
  ///
  /// In es, this message translates to:
  /// **'Procesando'**
  String get statusProcessing;

  /// No description provided for @statusError.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get statusError;

  /// No description provided for @statusUploaded.
  ///
  /// In es, this message translates to:
  /// **'Subido'**
  String get statusUploaded;

  /// No description provided for @noAnalysesYet.
  ///
  /// In es, this message translates to:
  /// **'Sin análisis aún'**
  String get noAnalysesYet;

  /// No description provided for @selectTeamAndAnalyseDesc.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un equipo en la pantalla principal\\ny analiza un video de partido.'**
  String get selectTeamAndAnalyseDesc;

  /// No description provided for @analysisTitle.
  ///
  /// In es, this message translates to:
  /// **'Análisis'**
  String get analysisTitle;

  /// No description provided for @aiPoweredPerformance.
  ///
  /// In es, this message translates to:
  /// **'Rendimiento impulsado por IA'**
  String get aiPoweredPerformance;

  /// No description provided for @uploadVideoBtn.
  ///
  /// In es, this message translates to:
  /// **'Subir video'**
  String get uploadVideoBtn;

  /// No description provided for @readyBtn.
  ///
  /// In es, this message translates to:
  /// **'Listo'**
  String get readyBtn;

  /// No description provided for @tabSummary.
  ///
  /// In es, this message translates to:
  /// **'RESUMEN'**
  String get tabSummary;

  /// No description provided for @tabField.
  ///
  /// In es, this message translates to:
  /// **'CAMPO'**
  String get tabField;

  /// No description provided for @tabPlayers.
  ///
  /// In es, this message translates to:
  /// **'JUGADORES'**
  String get tabPlayers;

  /// No description provided for @tabVideo.
  ///
  /// In es, this message translates to:
  /// **'VIDEO'**
  String get tabVideo;

  /// No description provided for @matchesTitle.
  ///
  /// In es, this message translates to:
  /// **'Partidos'**
  String get matchesTitle;

  /// No description provided for @matchHistory.
  ///
  /// In es, this message translates to:
  /// **'Historial de partidos'**
  String get matchHistory;

  /// No description provided for @trainingTitle.
  ///
  /// In es, this message translates to:
  /// **'Entrenamiento'**
  String get trainingTitle;

  /// No description provided for @performanceBasedPlan.
  ///
  /// In es, this message translates to:
  /// **'Plan basado en rendimiento'**
  String get performanceBasedPlan;

  /// No description provided for @aiRecommendationsTeam.
  ///
  /// In es, this message translates to:
  /// **'RECOMENDACIONES DE IA - EQUIPO'**
  String get aiRecommendationsTeam;

  /// No description provided for @teamAnalysis.
  ///
  /// In es, this message translates to:
  /// **'Análisis del equipo'**
  String get teamAnalysis;

  /// No description provided for @personalisedPlanByPlayer.
  ///
  /// In es, this message translates to:
  /// **'PLAN PERSONALIZADO POR JUGADOR'**
  String get personalisedPlanByPlayer;

  /// No description provided for @totalDist.
  ///
  /// In es, this message translates to:
  /// **'Dist. Total'**
  String get totalDist;

  /// No description provided for @avgDist.
  ///
  /// In es, this message translates to:
  /// **'Dist. Prom.'**
  String get avgDist;

  /// No description provided for @possession.
  ///
  /// In es, this message translates to:
  /// **'POSESIÓN'**
  String get possession;

  /// No description provided for @aiInsights.
  ///
  /// In es, this message translates to:
  /// **'ANÁLISIS DE IA'**
  String get aiInsights;

  /// No description provided for @distanceByPlayer.
  ///
  /// In es, this message translates to:
  /// **'DISTANCIA POR JUGADOR'**
  String get distanceByPlayer;

  /// No description provided for @liveTitle.
  ///
  /// In es, this message translates to:
  /// **'En Vivo 🔴'**
  String get liveTitle;

  /// No description provided for @liveRefreshTooltip.
  ///
  /// In es, this message translates to:
  /// **'Actualizar'**
  String get liveRefreshTooltip;

  /// No description provided for @liveLoadError.
  ///
  /// In es, this message translates to:
  /// **'Hubo un error: {error}\\n¿Está corriendo el servidor Python?'**
  String liveLoadError(String error);

  /// No description provided for @liveNoMatches.
  ///
  /// In es, this message translates to:
  /// **'No hay partidos en vivo en este momento.'**
  String get liveNoMatches;

  /// No description provided for @fieldNoPlayerData.
  ///
  /// In es, this message translates to:
  /// **'Sin datos de jugadores'**
  String get fieldNoPlayerData;

  /// No description provided for @fieldYourTeam.
  ///
  /// In es, this message translates to:
  /// **'TU EQUIPO'**
  String get fieldYourTeam;

  /// No description provided for @fieldOpponent.
  ///
  /// In es, this message translates to:
  /// **'OPONENTE'**
  String get fieldOpponent;

  /// No description provided for @fieldFormation.
  ///
  /// In es, this message translates to:
  /// **'Formación'**
  String get fieldFormation;

  /// No description provided for @fieldPlayers.
  ///
  /// In es, this message translates to:
  /// **'Jugadores'**
  String get fieldPlayers;

  /// No description provided for @fieldAvgSpeed.
  ///
  /// In es, this message translates to:
  /// **'Vel. promedio'**
  String get fieldAvgSpeed;

  /// No description provided for @fieldHighActivity.
  ///
  /// In es, this message translates to:
  /// **'Alta actividad'**
  String get fieldHighActivity;

  /// No description provided for @fieldMedium.
  ///
  /// In es, this message translates to:
  /// **'Media'**
  String get fieldMedium;

  /// No description provided for @fieldLow.
  ///
  /// In es, this message translates to:
  /// **'Baja'**
  String get fieldLow;

  /// No description provided for @fieldPlayerLabel.
  ///
  /// In es, this message translates to:
  /// **'Jugador {rank} · {zone}'**
  String fieldPlayerLabel(int rank, String zone);

  /// No description provided for @fieldDistance.
  ///
  /// In es, this message translates to:
  /// **'Distancia'**
  String get fieldDistance;

  /// No description provided for @fieldSpeed.
  ///
  /// In es, this message translates to:
  /// **'Velocidad'**
  String get fieldSpeed;

  /// No description provided for @fieldPresence.
  ///
  /// In es, this message translates to:
  /// **'Presencia'**
  String get fieldPresence;

  /// No description provided for @tableZone.
  ///
  /// In es, this message translates to:
  /// **'ZONA'**
  String get tableZone;

  /// No description provided for @tableDist.
  ///
  /// In es, this message translates to:
  /// **'DIST'**
  String get tableDist;

  /// No description provided for @tablePoss.
  ///
  /// In es, this message translates to:
  /// **'POS'**
  String get tablePoss;

  /// No description provided for @tablePres.
  ///
  /// In es, this message translates to:
  /// **'PRE'**
  String get tablePres;

  /// No description provided for @playersSection.
  ///
  /// In es, this message translates to:
  /// **'JUGADORES'**
  String get playersSection;

  /// No description provided for @playerLabel.
  ///
  /// In es, this message translates to:
  /// **'Jugador {rank}'**
  String playerLabel(int rank);

  /// No description provided for @detailsBtn.
  ///
  /// In es, this message translates to:
  /// **'Detalles'**
  String get detailsBtn;

  /// No description provided for @statDistance.
  ///
  /// In es, this message translates to:
  /// **'DISTANCIA'**
  String get statDistance;

  /// No description provided for @statSpeed.
  ///
  /// In es, this message translates to:
  /// **'VELOCIDAD'**
  String get statSpeed;

  /// No description provided for @statPoss.
  ///
  /// In es, this message translates to:
  /// **'POS.'**
  String get statPoss;

  /// No description provided for @detailDistanceCovered.
  ///
  /// In es, this message translates to:
  /// **'Distancia recorrida'**
  String get detailDistanceCovered;

  /// No description provided for @detailAverageSpeed.
  ///
  /// In es, this message translates to:
  /// **'Velocidad promedio'**
  String get detailAverageSpeed;

  /// No description provided for @detailBallPossession.
  ///
  /// In es, this message translates to:
  /// **'Posesión del balón'**
  String get detailBallPossession;

  /// No description provided for @detailFieldPresence.
  ///
  /// In es, this message translates to:
  /// **'Presencia en campo'**
  String get detailFieldPresence;

  /// No description provided for @detailMainZone.
  ///
  /// In es, this message translates to:
  /// **'Zona principal'**
  String get detailMainZone;

  /// No description provided for @insightHighActivity.
  ///
  /// In es, this message translates to:
  /// **'Jugador de alta actividad. Recorrió {km} km y alcanzó {spd} m/s de velocidad promedio.'**
  String insightHighActivity(String km, String spd);

  /// No description provided for @insightModerateActivity.
  ///
  /// In es, this message translates to:
  /// **'Jugador de actividad moderada. Mantuvo posición en la zona {zone}.'**
  String insightModerateActivity(String zone);

  /// No description provided for @summaryPlayers.
  ///
  /// In es, this message translates to:
  /// **'Jugadores'**
  String get summaryPlayers;

  /// No description provided for @summaryTotalDist.
  ///
  /// In es, this message translates to:
  /// **'Dist. total'**
  String get summaryTotalDist;

  /// No description provided for @summaryAvgDist.
  ///
  /// In es, this message translates to:
  /// **'Dist. prom.'**
  String get summaryAvgDist;

  /// No description provided for @summaryPossession.
  ///
  /// In es, this message translates to:
  /// **'Posesión'**
  String get summaryPossession;

  /// No description provided for @summaryAiInsights.
  ///
  /// In es, this message translates to:
  /// **'ANÁLISIS DE IA'**
  String get summaryAiInsights;

  /// No description provided for @summaryDistByPlayer.
  ///
  /// In es, this message translates to:
  /// **'DISTANCIA POR JUGADOR'**
  String get summaryDistByPlayer;

  /// No description provided for @summaryHighlights.
  ///
  /// In es, this message translates to:
  /// **'DESTACADOS'**
  String get summaryHighlights;

  /// No description provided for @summaryMostActive.
  ///
  /// In es, this message translates to:
  /// **'Más activo'**
  String get summaryMostActive;

  /// No description provided for @summaryMostPossession.
  ///
  /// In es, this message translates to:
  /// **'Mayor posesión'**
  String get summaryMostPossession;

  /// No description provided for @summaryLeastActive.
  ///
  /// In es, this message translates to:
  /// **'Menos activo'**
  String get summaryLeastActive;

  /// No description provided for @summaryPlayerRef.
  ///
  /// In es, this message translates to:
  /// **'Jugador {id}'**
  String summaryPlayerRef(String id);

  /// No description provided for @insightTotalKm.
  ///
  /// In es, this message translates to:
  /// **'El equipo recorrió {km} km en total durante el análisis.'**
  String insightTotalKm(String km);

  /// No description provided for @insightPossession.
  ///
  /// In es, this message translates to:
  /// **'Posesión del balón: {pct}% del tiempo analizado.'**
  String insightPossession(String pct);

  /// No description provided for @insightActivePlayers.
  ///
  /// In es, this message translates to:
  /// **'Se detectaron {count} jugadores activos en el campo.'**
  String insightActivePlayers(int count);

  /// No description provided for @insightFastestPlayer.
  ///
  /// In es, this message translates to:
  /// **'El jugador {rank} alcanzó la mayor velocidad: {spd} m/s.'**
  String insightFastestPlayer(String rank, String spd);

  /// No description provided for @insightTopZone.
  ///
  /// In es, this message translates to:
  /// **'El equipo se concentró principalmente en la zona {zone}.'**
  String insightTopZone(String zone);

  /// No description provided for @videoErrorTitle.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar el vídeo'**
  String get videoErrorTitle;

  /// No description provided for @videoErrorNetwork.
  ///
  /// In es, this message translates to:
  /// **'Error de red: {error}\\nURL: {url}'**
  String videoErrorNetwork(String error, String url);

  /// No description provided for @videoErrorLocal.
  ///
  /// In es, this message translates to:
  /// **'Error local: {error}'**
  String videoErrorLocal(String error);

  /// No description provided for @videoErrorWebLocal.
  ///
  /// In es, this message translates to:
  /// **'En web no se pueden reproducir archivos locales directamente.'**
  String get videoErrorWebLocal;

  /// No description provided for @videoErrorNoSource.
  ///
  /// In es, this message translates to:
  /// **'URL o archivo no proporcionado.'**
  String get videoErrorNoSource;

  /// No description provided for @sceneVideo.
  ///
  /// In es, this message translates to:
  /// **'Video'**
  String get sceneVideo;

  /// No description provided for @sceneHeatVideo.
  ///
  /// In es, this message translates to:
  /// **'Calor Video'**
  String get sceneHeatVideo;

  /// No description provided for @sceneHeatmap.
  ///
  /// In es, this message translates to:
  /// **'Mapa Calor'**
  String get sceneHeatmap;

  /// No description provided for @scenePlayer.
  ///
  /// In es, this message translates to:
  /// **'Jugador'**
  String get scenePlayer;

  /// No description provided for @sceneTeamLabel.
  ///
  /// In es, this message translates to:
  /// **'Equipo'**
  String get sceneTeamLabel;

  /// No description provided for @scenePlayerShort.
  ///
  /// In es, this message translates to:
  /// **'J{rank}'**
  String scenePlayerShort(int rank);

  /// No description provided for @sceneVideoNotAvailable.
  ///
  /// In es, this message translates to:
  /// **'Video no disponible'**
  String get sceneVideoNotAvailable;

  /// No description provided for @sceneNetworkError.
  ///
  /// In es, this message translates to:
  /// **'Error de red: {error}\\n{url}'**
  String sceneNetworkError(String error, String url);

  /// No description provided for @sceneLocalError.
  ///
  /// In es, this message translates to:
  /// **'Error de archivo local: {error}'**
  String sceneLocalError(String error);

  /// No description provided for @sceneWebError.
  ///
  /// In es, this message translates to:
  /// **'No se pueden reproducir archivos locales en web. Ejecuta el backend para obtener una URL.'**
  String get sceneWebError;

  /// No description provided for @sceneNoSource.
  ///
  /// In es, this message translates to:
  /// **'No hay fuente de video disponible.'**
  String get sceneNoSource;

  /// No description provided for @sceneSelectPlayerAbove.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un jugador arriba para ver su video de calor.'**
  String get sceneSelectPlayerAbove;

  /// No description provided for @sceneHeatNotAvailable.
  ///
  /// In es, this message translates to:
  /// **'Video de calor no disponible.\\nVuelve a analizar para generarlo.'**
  String get sceneHeatNotAvailable;

  /// No description provided for @sceneTeamHeatmapTitle.
  ///
  /// In es, this message translates to:
  /// **'Mapa de Calor del Equipo'**
  String get sceneTeamHeatmapTitle;

  /// No description provided for @sceneTeamHeatmapSub.
  ///
  /// In es, this message translates to:
  /// **'Movimiento combinado de todos los jugadores detectados'**
  String get sceneTeamHeatmapSub;

  /// No description provided for @sceneZoneDensity.
  ///
  /// In es, this message translates to:
  /// **'Densidad por Zona'**
  String get sceneZoneDensity;

  /// No description provided for @sceneZoneDistribution.
  ///
  /// In es, this message translates to:
  /// **'Distribución por zona'**
  String get sceneZoneDistribution;

  /// No description provided for @sceneNoPlayerData.
  ///
  /// In es, this message translates to:
  /// **'Sin datos de jugadores'**
  String get sceneNoPlayerData;

  /// No description provided for @sceneLow.
  ///
  /// In es, this message translates to:
  /// **'Bajo'**
  String get sceneLow;

  /// No description provided for @sceneHigh.
  ///
  /// In es, this message translates to:
  /// **'Alto'**
  String get sceneHigh;

  /// No description provided for @scenePlayerInfo.
  ///
  /// In es, this message translates to:
  /// **'Jugador {rank} · {zone}'**
  String scenePlayerInfo(int rank, String zone);

  /// No description provided for @scenePlayerKm.
  ///
  /// In es, this message translates to:
  /// **'{km} km'**
  String scenePlayerKm(String km);

  /// No description provided for @uploadFromDevice.
  ///
  /// In es, this message translates to:
  /// **'Desde dispositivo'**
  String get uploadFromDevice;

  /// No description provided for @uploadFromUrl.
  ///
  /// In es, this message translates to:
  /// **'Desde URL'**
  String get uploadFromUrl;

  /// No description provided for @uploadAnalysing.
  ///
  /// In es, this message translates to:
  /// **'Analizando con IA...'**
  String get uploadAnalysing;

  /// No description provided for @uploadStartAnalysis.
  ///
  /// In es, this message translates to:
  /// **'Iniciar análisis'**
  String get uploadStartAnalysis;

  /// No description provided for @uploadHowItWorks.
  ///
  /// In es, this message translates to:
  /// **'CÓMO FUNCIONA'**
  String get uploadHowItWorks;

  /// No description provided for @uploadStep1Title.
  ///
  /// In es, this message translates to:
  /// **'Elige la fuente'**
  String get uploadStep1Title;

  /// No description provided for @uploadStep1Desc.
  ///
  /// In es, this message translates to:
  /// **'Sube desde el dispositivo o pega una URL directa de video'**
  String get uploadStep1Desc;

  /// No description provided for @uploadStep2Title.
  ///
  /// In es, this message translates to:
  /// **'La IA analiza'**
  String get uploadStep2Title;

  /// No description provided for @uploadStep2Desc.
  ///
  /// In es, this message translates to:
  /// **'YOLO detecta y rastrea cada jugador en tiempo real'**
  String get uploadStep2Desc;

  /// No description provided for @uploadStep3Title.
  ///
  /// In es, this message translates to:
  /// **'Ver resultados'**
  String get uploadStep3Title;

  /// No description provided for @uploadStep3Desc.
  ///
  /// In es, this message translates to:
  /// **'Obtén estadísticas, mapa de campo e insights automáticos de IA'**
  String get uploadStep3Desc;

  /// No description provided for @uploadVideoReady.
  ///
  /// In es, this message translates to:
  /// **'Video listo para analizar'**
  String get uploadVideoReady;

  /// No description provided for @uploadSelectVideo.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar video del partido'**
  String get uploadSelectVideo;

  /// No description provided for @uploadTapGallery.
  ///
  /// In es, this message translates to:
  /// **'Toca para abrir la galería'**
  String get uploadTapGallery;

  /// No description provided for @uploadUrlLabel.
  ///
  /// In es, this message translates to:
  /// **'URL del video'**
  String get uploadUrlLabel;

  /// No description provided for @uploadUrlHint.
  ///
  /// In es, this message translates to:
  /// **'YouTube, .mp4 directo, Vimeo…'**
  String get uploadUrlHint;

  /// No description provided for @uploadUrlSupports.
  ///
  /// In es, this message translates to:
  /// **'Compatible con YouTube, Vimeo y enlaces directos .mp4/.mov'**
  String get uploadUrlSupports;
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
