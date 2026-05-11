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
      'Selecciona un equipo en la pantalla principal\ny analiza un video de partido.';

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
    return 'Hubo un error: $error\n¿Está corriendo el servidor Python?';
  }

  @override
  String get liveNoMatches => 'No hay partidos en vivo en este momento.';

  @override
  String get fieldNoPlayerData => 'Sin datos de jugadores';

  @override
  String get fieldYourTeam => 'TU EQUIPO';

  @override
  String get fieldOpponent => 'RIVAL';

  @override
  String get fieldFormation => 'Formación';

  @override
  String get fieldPlayers => 'Jugadores';

  @override
  String get fieldAvgSpeed => 'Vel. prom.';

  @override
  String get fieldHighActivity => 'Alta';

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
  String get tableZone => 'Zona';

  @override
  String get tableDist => 'Dist.';

  @override
  String get tablePoss => 'Pos.';

  @override
  String get tablePres => 'Pres.';

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
  String get summaryPlayers => 'Jugadores';

  @override
  String get summaryTotalDist => 'Dist. total';

  @override
  String get summaryAvgDist => 'Dist. prom.';

  @override
  String get summaryPossession => 'Posesión';

  @override
  String get summaryAiInsights => 'INFORMACIÓN DE IA';

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
  String summaryPlayerRef(String player) {
    return 'Jugador $player';
  }

  @override
  String insightTotalKm(String km) {
    return 'El equipo recorrió $km km en total durante el partido.';
  }

  @override
  String insightPossession(String pct) {
    return 'Se registró $pct% de posesión promedio del balón.';
  }

  @override
  String insightActivePlayers(String count) {
    return '$count jugadores estuvieron activos en el campo.';
  }

  @override
  String insightFastestPlayer(String rank, String speed) {
    return 'El jugador $rank alcanzó la velocidad más alta con $speed m/s.';
  }

  @override
  String insightTopZone(String zone) {
    return 'La zona más activa fue $zone.';
  }

  @override
  String insightHighActivity(String km, String speed) {
    return 'Jugador con alta actividad: recorrió $km km y alcanzó $speed m/s.';
  }

  @override
  String insightModerateActivity(String zone) {
    return 'Actividad moderada concentrada en la zona $zone.';
  }

  @override
  String get videoErrorTitle => 'Error al cargar el vídeo';

  @override
  String videoErrorNetwork(String error, String url) {
    return 'Error de red: $error\nURL: $url';
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
    return 'P$rank';
  }

  @override
  String get sceneVideoNotAvailable => 'Video no disponible';

  @override
  String sceneNetworkError(String error, String url) {
    return 'Error de red: $error\n$url';
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
      'Video de calor no disponible.\nVuelve a analizar para generarlo.';

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
  String get sceneUnknownZone => 'Desconocida';

  @override
  String scenePlayerCount(int count) {
    return '${count}j';
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
  String get uploadStep1Title => 'Sube tu video';

  @override
  String get uploadStep1Desc => 'Desde tu dispositivo o mediante URL';

  @override
  String get uploadStep2Title => 'Procesamiento IA';

  @override
  String get uploadStep2Desc => 'Detectamos jugadores y eventos en tiempo real';

  @override
  String get uploadStep3Title => 'Obtén resultados';

  @override
  String get uploadStep3Desc => 'Mapa de calor, estadísticas y escenas clave';

  @override
  String get uploadVideoReady => 'Video listo';

  @override
  String get uploadSelectVideo => 'Seleccionar video';

  @override
  String get uploadTapGallery => 'Toca para elegir de la galería';

  @override
  String get uploadUrlLabel => 'URL DEL VIDEO';

  @override
  String get uploadUrlHint => 'https://ejemplo.com/video.mp4';

  @override
  String get uploadUrlSupports =>
      'Soporta enlaces directos a MP4, MOV y URLs de YouTube';

  @override
  String get uploadReqTitle => 'REQUISITOS DEL VIDEO';

  @override
  String get uploadReqFormat => 'Formato';

  @override
  String get uploadReqFormatDesc => 'MP4, MOV';

  @override
  String get uploadReqResolution => 'Resolución';

  @override
  String get uploadReqResolutionDesc => '720p+';

  @override
  String get uploadReqDuration => 'Duración';

  @override
  String get uploadReqDurationDesc => '5-90 min';

  @override
  String get uploadReqAngle => 'Ángulo';

  @override
  String get uploadReqAngleDesc => 'Vista lateral';

  @override
  String get uploadReqSize => 'Tamaño';

  @override
  String get uploadReqSizeDesc => '< 500 MB';

  @override
  String get uploadCancelAnalysis => 'Cancelar análisis';

  @override
  String get loginAiBadge => 'Análisis de Fútbol con IA';

  @override
  String get loginTagline => 'Donde los datos se convierten en estrategia';

  @override
  String get loginDividerOr => 'O';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get logoutErrorDebug => 'Error al cerrar sesión';

  @override
  String get appVersionLabel => 'v1.0.0';

  @override
  String get appVersionNumber => '1.0.0';

  @override
  String get aboutLegalese =>
      '© 2026 PlayVision. Todos los derechos reservados.';

  @override
  String get teamEditTitle => 'Editar equipo';

  @override
  String get teamNewTitle => 'Nuevo equipo';

  @override
  String get teamLogoSelected => 'Logo seleccionado';

  @override
  String get teamLogoTapToAdd => 'Toca para agregar logo';

  @override
  String get teamFieldName => 'Nombre';

  @override
  String get teamFieldCategory => 'Categoría';

  @override
  String get teamFieldClub => 'Club';

  @override
  String get teamDialogCancel => 'Cancelar';

  @override
  String get teamDialogSave => 'Guardar';

  @override
  String get teamDialogCreate => 'Crear';

  @override
  String get teamDeleteTitle => 'Eliminar equipo';

  @override
  String teamDeleteConfirm(String name) {
    return 'Eliminar equipo \"$name\"? Esta acción no se puede deshacer.';
  }

  @override
  String get teamDeleteButton => 'Eliminar';

  @override
  String get featureRivalAnalysisTitle => 'Análisis Rival';

  @override
  String get featureRivalAnalysisDesc => 'Anticipa al oponente';

  @override
  String get featureTacticsTitle => 'Táctica Previa';

  @override
  String get featureTacticsDesc => 'Prepara cada partido';

  @override
  String get featureIndividualStatsTitle => 'Stats Individuales';

  @override
  String get featureIndividualStatsDesc => 'Seguimiento de jugadores';

  @override
  String get matchUnknownOpponent => 'Oponente desconocido';

  @override
  String matchVersusOpponent(String opponent) {
    return 'vs $opponent';
  }

  @override
  String get matchLoadAnalysisFailed =>
      'No se pudo cargar el análisis para este partido.';

  @override
  String get matchNotAnalysedYet => 'Este partido aún no está analizado.';

  @override
  String get heroAiAccuracy => 'Precisión AI';

  @override
  String get heroLatest => 'Último';

  @override
  String get searchTeamHint => 'Buscar equipo...';

  @override
  String get searchTeamButton => 'Buscar equipo';

  @override
  String get searchLast5 => 'Últimos 5';

  @override
  String get searchNoRecentMatches => 'Sin partidos recientes';

  @override
  String get liveLabel => 'EN VIVO';

  @override
  String get todayLabel => 'Hoy';

  @override
  String todayMatchesCount(int count) {
    return '$count partidos';
  }

  @override
  String get matchHomeTeam => 'Local';

  @override
  String get matchAwayTeam => 'Visitante';

  @override
  String get matchStatusFT => 'FT';

  @override
  String get matchLive => 'LIVE';

  @override
  String get matchVS => 'VS';

  @override
  String get matchStatusLive => 'En vivo';

  @override
  String get matchStatusFinished => 'Finalizado';

  @override
  String get matchStatusNotStarted => 'No iniciado';

  @override
  String get newsRefreshButton => 'Actualizar noticias';

  @override
  String get newsErrorTitle => 'No se pudieron cargar las noticias';

  @override
  String get newsErrorSubtitle => 'Verifica tu conexión';

  @override
  String get newsRetryButton => 'Reintentar';

  @override
  String get analysisInProgressTitle => 'Análisis en curso';

  @override
  String get analysisLeaveWarning =>
      'Si sales ahora, el análisis se cancelará y perderás el progreso. ¿Deseas continuar?';

  @override
  String get analysisStayButton => 'Volver';

  @override
  String get analysisExitButton => 'Salir';

  @override
  String get analysisProcessingWithAI => 'Procesando con IA...';

  @override
  String get analysisCancelButton => 'Cancelar';

  @override
  String get analysisProcessingBanner =>
      'Analizando video con inteligencia artificial. Esto puede tardar unos minutos.';

  @override
  String get editPlayerTitle => 'Editar jugador';

  @override
  String get editPlayerNameLabel => 'Nombre';

  @override
  String get editPlayerNumberLabel => 'Número';

  @override
  String get editPlayerPositionLabel => 'Posición';

  @override
  String editPlayerDefaultName(int rank) {
    return 'Jugador $rank';
  }

  @override
  String get cancelBtn => 'Cancelar';

  @override
  String get saveBtn => 'Guardar';

  @override
  String get coachingBoardTitle => 'Coaching Board';

  @override
  String get coachingBoardSubtitle =>
      'Elige un equipo para construir el tablero táctico';

  @override
  String get coachingBoardNoTeams => 'Sin equipos';

  @override
  String get coachingBoardNoTeamsHint => 'Crea un equipo en la pestaña Inicio';

  @override
  String get coachingBoardReset => 'Restablecer';

  @override
  String get coachingBoardSwapHint => 'Mantén pulsado = intercambiar';

  @override
  String get coachingBoardSwapBanner => 'Toca otro jugador para intercambiar';

  @override
  String get coachingBoardSelectTeamTitle => 'Selecciona un equipo';

  @override
  String get coachingBoardSelectTeamSubtitle =>
      'Elige un equipo para construir el tablero táctico';

  @override
  String get coachingBoardSave => 'Guardar';

  @override
  String coachingBoardAnalyzingTitle(String teamName) {
    return 'Analizando $teamName';
  }

  @override
  String get coachingBoardAnalyzingSubtitle =>
      'Construyendo el tablero táctico con IA';

  @override
  String get coachingBoardStepLoadingPlayers => 'Cargando jugadores...';

  @override
  String get coachingBoardStepReadingStats => 'Leyendo estadísticas...';

  @override
  String get coachingBoardStepComputingPositions =>
      'Calculando posiciones óptimas...';

  @override
  String get coachingBoardStepBuildingBoard =>
      'Construyendo tablero táctico...';

  @override
  String get coachingBoardSaveSuccess => 'Formación guardada ✓';

  @override
  String get coachingBoardSaveError => 'Error al guardar la formación';
}
