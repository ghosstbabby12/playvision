// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'PlayVision';

  @override
  String get loginTitle => 'Inicia sesión o regístrate para continuar';

  @override
  String get emailHint => 'Correo Electrónico';

  @override
  String get passwordHint => 'Contraseña';

  @override
  String get loginButton => 'Iniciar Sesión';

  @override
  String get createAccountButton => 'Crear una cuenta nueva';

  @override
  String get registerTitle => 'Crea tu cuenta para empezar a analizar';

  @override
  String get registerButton => 'Registrarse';

  @override
  String get alreadyHaveAccountButton => 'Ya tengo una cuenta';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get languageItem => 'Idioma';

  @override
  String get helpItem => 'Ayuda';

  @override
  String get appearanceSection => 'APARIENCIA';

  @override
  String get lightModeItem => 'Modo Claro';

  @override
  String get infoSection => 'INFORMACIÓN';

  @override
  String get aboutUsItem => 'Sobre Nosotros';

  @override
  String get aboutAppItem => 'Sobre PlayVision';

  @override
  String get logoutButton => 'Cerrar Sesión';

  @override
  String get selectOrCreateTeam => 'Selecciona o crea un equipo';

  @override
  String get chooseTeamSubtitle =>
      'Elige un equipo para iniciar un nuevo análisis';

  @override
  String get resultsTab => 'Resultados';

  @override
  String get newsTab => 'Noticias';

  @override
  String get totalMatches => 'Partidos totales';

  @override
  String get analysed => 'analizados';

  @override
  String get createTeam => 'Crear un equipo';

  @override
  String get tapToAddTeam => 'Toca aquí para agregar tu primer equipo';

  @override
  String get newTeam => 'Nuevo';

  @override
  String get changeTeam => 'Cambiar';

  @override
  String get analyseVideo => 'Analizar video';

  @override
  String get uploadMatchVideo =>
      'Sube un video de partido y obtén estadísticas de IA';

  @override
  String get viewAnalysis => 'Ver análisis';

  @override
  String get teamMatches => 'Partidos del equipo';

  @override
  String get noAnalysedMatches => 'Aún no hay partidos analizados';

  @override
  String get noRealMatchesToday => 'No hay partidos reales hoy';

  @override
  String get liveStatus => 'En Vivo';

  @override
  String get scheduledStatus => 'Programado';

  @override
  String get finishedStatus => 'Finalizado';

  @override
  String get myAnalysesTitle => 'Mis Análisis';

  @override
  String get allMatchesGrouped => 'Todos los partidos agrupados por equipo';

  @override
  String get noAnalysisData =>
      'Aún no hay datos de análisis para este partido.';

  @override
  String get matchWord => 'Partido';

  @override
  String get statusAnalysed => 'Analizado';

  @override
  String get statusProcessing => 'Procesando';

  @override
  String get statusError => 'Error';

  @override
  String get statusUploaded => 'Subido';

  @override
  String get noAnalysesYet => 'Sin análisis aún';

  @override
  String get selectTeamAndAnalyseDesc =>
      'Selecciona un equipo en la pantalla principal\\ny analiza un video de partido.';

  @override
  String get analysisTitle => 'Análisis';

  @override
  String get aiPoweredPerformance => 'Rendimiento impulsado por IA';

  @override
  String get uploadVideoBtn => 'Subir video';

  @override
  String get readyBtn => 'Listo';

  @override
  String get tabSummary => 'RESUMEN';

  @override
  String get tabField => 'CAMPO';

  @override
  String get tabPlayers => 'JUGADORES';

  @override
  String get tabVideo => 'VIDEO';

  @override
  String get matchesTitle => 'Partidos';

  @override
  String get matchHistory => 'Historial de partidos';

  @override
  String get trainingTitle => 'Entrenamiento';

  @override
  String get performanceBasedPlan => 'Plan basado en rendimiento';

  @override
  String get aiRecommendationsTeam => 'RECOMENDACIONES DE IA - EQUIPO';

  @override
  String get teamAnalysis => 'Análisis del equipo';

  @override
  String get personalisedPlanByPlayer => 'PLAN PERSONALIZADO POR JUGADOR';

  @override
  String get totalDist => 'Dist. Total';

  @override
  String get avgDist => 'Dist. Prom.';

  @override
  String get possession => 'POSESIÓN';

  @override
  String get aiInsights => 'ANÁLISIS DE IA';

  @override
  String get distanceByPlayer => 'DISTANCIA POR JUGADOR';

  @override
  String get liveTitle => 'En Vivo 🔴';

  @override
  String get liveRefreshTooltip => 'Actualizar';

  @override
  String liveLoadError(String error) {
    return 'Hubo un error: $error\\n¿Está corriendo el servidor Python?';
  }

  @override
  String get liveNoMatches => 'No hay partidos en vivo en este momento.';

  @override
  String get fieldNoPlayerData => 'Sin datos de jugadores';

  @override
  String get fieldYourTeam => 'TU EQUIPO';

  @override
  String get fieldOpponent => 'OPONENTE';

  @override
  String get fieldFormation => 'Formación';

  @override
  String get fieldPlayers => 'Jugadores';

  @override
  String get fieldAvgSpeed => 'Vel. promedio';

  @override
  String get fieldHighActivity => 'Alta actividad';

  @override
  String get fieldMedium => 'Media';

  @override
  String get fieldLow => 'Baja';

  @override
  String fieldPlayerLabel(int rank, String zone) {
    return 'Jugador $rank · $zone';
  }

  @override
  String get fieldDistance => 'Distancia';

  @override
  String get fieldSpeed => 'Velocidad';

  @override
  String get fieldPresence => 'Presencia';

  @override
  String get tableZone => 'ZONA';

  @override
  String get tableDist => 'DIST';

  @override
  String get tablePoss => 'POS';

  @override
  String get tablePres => 'PRE';

  @override
  String get playersSection => 'JUGADORES';

  @override
  String playerLabel(int rank) {
    return 'Jugador $rank';
  }

  @override
  String get detailsBtn => 'Detalles';

  @override
  String get statDistance => 'DISTANCIA';

  @override
  String get statSpeed => 'VELOCIDAD';

  @override
  String get statPoss => 'POS.';

  @override
  String get detailDistanceCovered => 'Distancia recorrida';

  @override
  String get detailAverageSpeed => 'Velocidad promedio';

  @override
  String get detailBallPossession => 'Posesión del balón';

  @override
  String get detailFieldPresence => 'Presencia en campo';

  @override
  String get detailMainZone => 'Zona principal';

  @override
  String insightHighActivity(String km, String spd) {
    return 'Jugador de alta actividad. Recorrió $km km y alcanzó $spd m/s de velocidad promedio.';
  }

  @override
  String insightModerateActivity(String zone) {
    return 'Jugador de actividad moderada. Mantuvo posición en la zona $zone.';
  }

  @override
  String get summaryPlayers => 'Jugadores';

  @override
  String get summaryTotalDist => 'Dist. total';

  @override
  String get summaryAvgDist => 'Dist. prom.';

  @override
  String get summaryPossession => 'Posesión';

  @override
  String get summaryAiInsights => 'ANÁLISIS DE IA';

  @override
  String get summaryDistByPlayer => 'DISTANCIA POR JUGADOR';

  @override
  String get summaryHighlights => 'DESTACADOS';

  @override
  String get summaryMostActive => 'Más activo';

  @override
  String get summaryMostPossession => 'Mayor posesión';

  @override
  String get summaryLeastActive => 'Menos activo';

  @override
  String summaryPlayerRef(String id) {
    return 'Jugador $id';
  }

  @override
  String insightTotalKm(String km) {
    return 'El equipo recorrió $km km en total durante el análisis.';
  }

  @override
  String insightPossession(String pct) {
    return 'Posesión del balón: $pct% del tiempo analizado.';
  }

  @override
  String insightActivePlayers(int count) {
    return 'Se detectaron $count jugadores activos en el campo.';
  }

  @override
  String insightFastestPlayer(String rank, String spd) {
    return 'El jugador $rank alcanzó la mayor velocidad: $spd m/s.';
  }

  @override
  String insightTopZone(String zone) {
    return 'El equipo se concentró principalmente en la zona $zone.';
  }

  @override
  String get videoErrorTitle => 'Error al cargar el vídeo';

  @override
  String videoErrorNetwork(String error, String url) {
    return 'Error de red: $error\\nURL: $url';
  }

  @override
  String videoErrorLocal(String error) {
    return 'Error local: $error';
  }

  @override
  String get videoErrorWebLocal =>
      'En web no se pueden reproducir archivos locales directamente.';

  @override
  String get videoErrorNoSource => 'URL o archivo no proporcionado.';

  @override
  String get sceneVideo => 'Video';

  @override
  String get sceneHeatVideo => 'Calor Video';

  @override
  String get sceneHeatmap => 'Mapa Calor';

  @override
  String get scenePlayer => 'Jugador';

  @override
  String get sceneTeamLabel => 'Equipo';

  @override
  String scenePlayerShort(int rank) {
    return 'J$rank';
  }

  @override
  String get sceneVideoNotAvailable => 'Video no disponible';

  @override
  String sceneNetworkError(String error, String url) {
    return 'Error de red: $error\\n$url';
  }

  @override
  String sceneLocalError(String error) {
    return 'Error de archivo local: $error';
  }

  @override
  String get sceneWebError =>
      'No se pueden reproducir archivos locales en web. Ejecuta el backend para obtener una URL.';

  @override
  String get sceneNoSource => 'No hay fuente de video disponible.';

  @override
  String get sceneSelectPlayerAbove =>
      'Selecciona un jugador arriba para ver su video de calor.';

  @override
  String get sceneHeatNotAvailable =>
      'Video de calor no disponible.\\nVuelve a analizar para generarlo.';

  @override
  String get sceneTeamHeatmapTitle => 'Mapa de Calor del Equipo';

  @override
  String get sceneTeamHeatmapSub =>
      'Movimiento combinado de todos los jugadores detectados';

  @override
  String get sceneZoneDensity => 'Densidad por Zona';

  @override
  String get sceneZoneDistribution => 'Distribución por zona';

  @override
  String get sceneNoPlayerData => 'Sin datos de jugadores';

  @override
  String get sceneLow => 'Bajo';

  @override
  String get sceneHigh => 'Alto';

  @override
  String scenePlayerInfo(int rank, String zone) {
    return 'Jugador $rank · $zone';
  }

  @override
  String scenePlayerKm(String km) {
    return '$km km';
  }

  @override
  String get uploadFromDevice => 'Desde dispositivo';

  @override
  String get uploadFromUrl => 'Desde URL';

  @override
  String get uploadAnalysing => 'Analizando con IA...';

  @override
  String get uploadStartAnalysis => 'Iniciar análisis';

  @override
  String get uploadHowItWorks => 'CÓMO FUNCIONA';

  @override
  String get uploadStep1Title => 'Elige la fuente';

  @override
  String get uploadStep1Desc =>
      'Sube desde el dispositivo o pega una URL directa de video';

  @override
  String get uploadStep2Title => 'La IA analiza';

  @override
  String get uploadStep2Desc =>
      'YOLO detecta y rastrea cada jugador en tiempo real';

  @override
  String get uploadStep3Title => 'Ver resultados';

  @override
  String get uploadStep3Desc =>
      'Obtén estadísticas, mapa de campo e insights automáticos de IA';

  @override
  String get uploadVideoReady => 'Video listo para analizar';

  @override
  String get uploadSelectVideo => 'Seleccionar video del partido';

  @override
  String get uploadTapGallery => 'Toca para abrir la galería';

  @override
  String get uploadUrlLabel => 'URL del video';

  @override
  String get uploadUrlHint => 'YouTube, .mp4 directo, Vimeo…';

  @override
  String get uploadUrlSupports =>
      'Compatible con YouTube, Vimeo y enlaces directos .mp4/.mov';
}
