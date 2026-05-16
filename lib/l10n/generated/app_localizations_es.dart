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
  String get deleteBtn => 'Eliminar';

  @override
  String get coachingBoardTitle => 'Coaching Board';

  @override
  String get coachingBoardSubtitle =>
      'Elige un equipo para construir el tablero táctico';

  @override
  String get coachingBoardSelectTeamTitle => 'Selecciona un equipo';

  @override
  String get coachingBoardSelectTeamSubtitle =>
      'Elige un equipo para construir el tablero táctico';

  @override
  String get coachingBoardNoTeams => 'Sin equipos';

  @override
  String get coachingBoardNoTeamsHint => 'Crea un equipo en la pestaña Inicio';

  @override
  String get coachingBoardSave => 'Guardar';

  @override
  String get coachingBoardReset => 'Restablecer';

  @override
  String get coachingBoardSwapHint => 'Mantén pulsado = intercambiar';

  @override
  String get coachingBoardSwapBanner => 'Toca otro jugador para intercambiar';

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

  @override
  String get categoryU6 => 'Sub-6';

  @override
  String get categoryU8 => 'Sub-8';

  @override
  String get categoryU10 => 'Sub-10';

  @override
  String get categoryU12 => 'Sub-12';

  @override
  String get categoryU14 => 'Sub-14';

  @override
  String get categoryU16 => 'Sub-16';

  @override
  String get categoryU18 => 'Sub-18';

  @override
  String get categoryU20 => 'Sub-20';

  @override
  String get categoryU23 => 'Sub-23';

  @override
  String get categoryAmateur => 'Amateur';

  @override
  String get categorySemiProfessional => 'Semiprofesional';

  @override
  String get categoryProfessional => 'Profesional';

  @override
  String get categoryFemaleU12 => 'Femenino Sub-12';

  @override
  String get categoryFemaleU16 => 'Femenino Sub-16';

  @override
  String get categoryFemaleU18 => 'Femenino Sub-18';

  @override
  String get categoryFemale => 'Femenino';

  @override
  String get categoryMixed => 'Mixto';

  @override
  String get countryArgentina => 'Argentina';

  @override
  String get countryBolivia => 'Bolivia';

  @override
  String get countryBrazil => 'Brasil';

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
  String get countrySpain => 'España';

  @override
  String get countryUnitedStates => 'Estados Unidos';

  @override
  String get countryGuatemala => 'Guatemala';

  @override
  String get countryHonduras => 'Honduras';

  @override
  String get countryMexico => 'México';

  @override
  String get countryNicaragua => 'Nicaragua';

  @override
  String get countryPanama => 'Panamá';

  @override
  String get countryParaguay => 'Paraguay';

  @override
  String get countryPeru => 'Perú';

  @override
  String get countryPuertoRico => 'Puerto Rico';

  @override
  String get countryDominicanRepublic => 'República Dominicana';

  @override
  String get countryUruguay => 'Uruguay';

  @override
  String get countryVenezuela => 'Venezuela';

  @override
  String get countryOther => 'Otro';

  @override
  String get greetingMorningCoach => 'Buenos días, DT';

  @override
  String get greetingAfternoonCoach => 'Buenas tardes, DT';

  @override
  String get greetingEveningCoach => 'Buenas noches, DT';

  @override
  String get heroPlatformTagline => 'PlayVision · plataforma táctica IA';

  @override
  String heroTeamReady(String teamName) {
    return '$teamName · listo para analizar';
  }

  @override
  String get searchFieldLabel => 'Buscar equipos o partidos…';

  @override
  String searchNoResults(String query) {
    return 'No hay resultados para \"$query\"';
  }

  @override
  String searchTeamsCount(int count) {
    return 'Equipos ($count)';
  }

  @override
  String searchMatchesCount(int count) {
    return 'Partidos ($count)';
  }

  @override
  String get newsNoDescriptionAvailable => 'Sin descripción disponible';

  @override
  String get quickActionsTitle => 'Acciones rápidas';

  @override
  String get quickActionAnalyzeVideo => 'Analizar\nVideo';

  @override
  String get quickActionTacticalBoard => 'Tablero\nTáctico';

  @override
  String get quickActionMyPlayers => 'Mis\nJugadores';

  @override
  String get quickActionTraining => 'Entrena-\nmiento';

  @override
  String get axisSpeed => 'Velocidad';

  @override
  String get axisPass => 'Pase';

  @override
  String get axisShoot => 'Disparo';

  @override
  String get axisDefend => 'Defensa';

  @override
  String get axisPhysical => 'Físico';

  @override
  String get axisSpeedExplain => 'Distancia cubierta y velocidad de sprints';

  @override
  String get axisPassExplain => 'Precisión y volumen de pases completados';

  @override
  String get axisShootExplain => 'Goles y remates efectivos al arco';

  @override
  String get axisDefendExplain => 'Recuperaciones y entradas defensivas';

  @override
  String get axisPhysicalExplain => 'Resistencia física y duelos ganados';

  @override
  String insightHighRating(String rating) {
    return 'Alto rendimiento · $rating ★';
  }

  @override
  String insightGoodMatch(String rating) {
    return 'Buen partido · $rating ★';
  }

  @override
  String insightLowRating(String rating) {
    return 'Rendimiento bajo · $rating ★';
  }

  @override
  String insightTrendUp(int pct) {
    return '+$pct% vs media reciente';
  }

  @override
  String insightTrendDown(int pct) {
    return '-$pct% vs media reciente';
  }

  @override
  String insightHighOffensive(int goals, int assists) {
    return 'Alta contribución ofensiva · ${goals}G ${assists}A';
  }

  @override
  String get insightNoGoalContribution => 'Sin participación directa en goles';

  @override
  String insightLowDefensive(int tackles) {
    return 'Baja contribución defensiva · $tackles recuperaciones';
  }

  @override
  String insightExcellentDefensive(int tackles) {
    return 'Trabajo defensivo excelente · $tackles recuperaciones';
  }

  @override
  String insightExceptionalDistance(String km) {
    return 'Cobertura excepcional · $km km';
  }

  @override
  String insightLowDistance(String km) {
    return 'Baja cobertura de campo · $km km';
  }

  @override
  String insightElitePass(int pct) {
    return 'Precisión de pase élite · $pct%';
  }

  @override
  String insightLowPass(int pct) {
    return 'Precisión de pase baja · $pct%';
  }

  @override
  String insightAboveIdeal(String axis) {
    return '↑ $axis superior al perfil ideal';
  }

  @override
  String insightBelowIdeal(String axis) {
    return '↓ $axis por debajo del perfil de posición';
  }

  @override
  String insightBestPosition(String position) {
    return 'Posición óptima sugerida: $position';
  }

  @override
  String get insightHintWarning => 'Requiere atención';

  @override
  String get insightHintInfo => 'Sugerencia IA';

  @override
  String get sheetPinned => 'Fijado';

  @override
  String get tabAssistant => '🧠 Asistente';

  @override
  String get tabProfile => '📊 Perfil';

  @override
  String get tabMatch => '⚡ Partido';

  @override
  String get sectionCoachAssistant => 'ASISTENTE DE COACH';

  @override
  String get sectionComparisonRadar => 'RADAR COMPARATIVO';

  @override
  String get toggleVsPosition => 'vs Posición ideal';

  @override
  String get toggleVsTeam => 'vs Promedio equipo';

  @override
  String get legendIdealProfile => 'Perfil ideal';

  @override
  String get legendTeamAverage => 'Media equipo';

  @override
  String get tapAxisForDetail => 'Toca un eje para detalle';

  @override
  String get axisDetailPlayer => 'Jugador';

  @override
  String get quickStatRating => 'Rating';

  @override
  String get quickStatGoals => 'Goles';

  @override
  String get quickStatAssists => 'Asist.';

  @override
  String get quickStatKm => 'Km';

  @override
  String get quickStatPassPct => 'Pases%';

  @override
  String get matchRatingLabel => 'Rating del partido';

  @override
  String get matchStatGoals => 'Goles';

  @override
  String get matchStatAssists => 'Asistencias';

  @override
  String get matchStatDistance => 'Distancia';

  @override
  String get matchStatPasses => 'Pases';

  @override
  String get matchStatAccuracy => 'Precisión';

  @override
  String get matchStatMinutes => 'Minutos';

  @override
  String get matchRatingTrend => 'Tendencia de rating';

  @override
  String get playersLoadingSquad => 'Cargando plantel…';

  @override
  String playersSquadAvailable(int count) {
    return '$count jugadores en el plantel disponibles';
  }

  @override
  String get playersNoSquadHint =>
      'Sin jugadores en el plantel. Agrega jugadores primero.';

  @override
  String get playersLinked => 'Vinculado';

  @override
  String get playersPresenceShort => 'PRES';

  @override
  String playersEditTitle(int rank) {
    return 'Jugador $rank · Editar';
  }

  @override
  String get playersUnlink => 'Desvincular';

  @override
  String get playersLinkToSquad => 'Vincular a jugador del plantel';

  @override
  String get playersOrEditManually => 'o editar manualmente';

  @override
  String get playersNoLinkedTeamHint =>
      'Sin equipo vinculado. Agrega jugadores al plantel para vincularlos.';

  @override
  String get playersLinkAndSave => 'Vincular y guardar';

  @override
  String get analysisNoTeamSelected =>
      'No hay equipo seleccionado. Vuelve atrás y elige uno.';

  @override
  String analysisServerError(String code) {
    return 'Error del servidor: $code';
  }

  @override
  String analysisConnectionError(String error) {
    return 'Error de conexión: $error';
  }

  @override
  String playerProfileTitle(int id) {
    return 'Jugador $id';
  }

  @override
  String get playerSummaryTitle => 'Resumen del jugador';

  @override
  String playerBestPositionTitle(String position) {
    return 'Posición ideal: $position';
  }

  @override
  String get playerMatchesCount => 'Partidos';

  @override
  String get playerCoachInsights => 'Insights del coach';

  @override
  String get playerDominantZone => 'Zona dominante';

  @override
  String get playerLoadError => 'No se pudo cargar el perfil del jugador.';

  @override
  String get matchesTimeoutError =>
      'La conexión tardó demasiado. Verifica tu red.';

  @override
  String get matchesLoadError => 'No se pudieron cargar los datos.';

  @override
  String get matchesSaveError => 'No se pudo guardar el partido.';

  @override
  String get matchesEmptyTitle => 'No hay partidos registrados';

  @override
  String get matchesAddButton => '+ Agregar partido';

  @override
  String get matchesRequireTeamFirst => 'Crea al menos un equipo primero.';

  @override
  String get matchesNewTitle => 'Nuevo partido';

  @override
  String get matchesTeamLabel => 'Equipo';

  @override
  String get matchesOpponentLabel => 'Rival';

  @override
  String get matchesVideoSourceLabel => 'Fuente del video';

  @override
  String get matchesUploadSource => 'Subida';

  @override
  String get matchesYouTubeSource => 'YouTube';

  @override
  String matchesDateLabel(String date) {
    return 'Fecha: $date';
  }

  @override
  String matchesTimeLabel(String time) {
    return 'Hora: $time';
  }

  @override
  String get matchesSaved => 'Partido guardado';

  @override
  String get matchesNoTeam => 'Sin equipo';

  @override
  String get squadLoadError => 'No se pudo cargar la plantilla.';

  @override
  String get playerSaveError => 'No se pudo guardar el jugador.';

  @override
  String get playerUpdateError => 'No se pudo actualizar el jugador.';

  @override
  String get playerDeleteError => 'No se pudo eliminar el jugador.';

  @override
  String get playerPhotoUploadError => 'No se pudo subir la foto del jugador.';

  @override
  String get squadPageTitle => 'Plantilla';

  @override
  String squadPageSubtitle(int count) {
    return '$count jugadores · Temporada 25/26';
  }

  @override
  String get squadSearchHint => 'Buscar jugadores...';

  @override
  String get squadPositionAll => 'All';

  @override
  String squadCountLabel(int count) {
    return '$count jugadores';
  }

  @override
  String get squadAddPlayerTitle => 'Nuevo jugador';

  @override
  String get squadEditPlayerTitle => 'Editar jugador';

  @override
  String get squadDeletePlayerTitle => 'Eliminar jugador';

  @override
  String squadDeletePlayerConfirm(String name) {
    return '¿Eliminar a $name de la plantilla? Esta acción no se puede deshacer.';
  }

  @override
  String get squadDeleteButton => 'Eliminar';

  @override
  String get squadPlayerSaved => 'Jugador guardado';

  @override
  String get squadPlayerUpdated => 'Jugador actualizado';

  @override
  String get squadPlayerDeleted => 'Jugador eliminado';

  @override
  String get squadPlayerSaveFailed => 'Error al guardar';

  @override
  String get squadPlayerUpdateFailed => 'Error al actualizar';

  @override
  String get squadPlayerDeleteFailed => 'Error al eliminar';

  @override
  String get squadNameLabel => 'Nombre completo';

  @override
  String get squadNameHint => 'Ej. Carlos García';

  @override
  String get squadNumberLabel => 'Dorsal';

  @override
  String get squadNumberHint => 'Ej. 10';

  @override
  String get squadPositionLabel => 'Posición';

  @override
  String get squadStatusLabel => 'Estado';

  @override
  String get squadBirthDateLabel => 'Fecha de nacimiento';

  @override
  String get squadBirthDateOptional => 'Fecha de nacimiento (opcional)';

  @override
  String get squadPhotoLabel => 'Agregar foto';

  @override
  String get squadChangePhoto => 'Cambiar';

  @override
  String get squadPosGk => 'Portero GK';

  @override
  String get squadPosDef => 'Defensa DEF';

  @override
  String get squadPosMid => 'Centrocampista MID';

  @override
  String get squadPosFwd => 'Delantero FWD';

  @override
  String get squadStatusActive => 'Activo';

  @override
  String get squadStatusInjured => 'Lesionado';

  @override
  String get squadStatusSuspended => 'Suspendido';

  @override
  String get squadStatusInactive => 'Inactivo';

  @override
  String get squadFormExcellent => 'Excelente';

  @override
  String get squadFormGood => 'Bueno';

  @override
  String get squadFormRegular => 'Regular';

  @override
  String get squadEmptyTitle => 'Sin jugadores';

  @override
  String get squadEmptySubtitle => 'Toca para agregar jugadores';

  @override
  String get squadDefaultTeam => 'Mi equipo';

  @override
  String get squadMyTeam => 'Mi equipo';

  @override
  String get weekdayMon => 'L';

  @override
  String get weekdayTue => 'M';

  @override
  String get weekdayWed => 'X';

  @override
  String get weekdayThu => 'J';

  @override
  String get weekdayFri => 'V';

  @override
  String get weekdaySat => 'S';

  @override
  String get weekdaySun => 'D';

  @override
  String get weekdayMonFull => 'Lunes';

  @override
  String get weekdayTueFull => 'Martes';

  @override
  String get weekdayWedFull => 'Miércoles';

  @override
  String get weekdayThuFull => 'Jueves';

  @override
  String get weekdayFriFull => 'Viernes';

  @override
  String get weekdaySatFull => 'Sábado';

  @override
  String get weekdaySunFull => 'Domingo';

  @override
  String get trainingFitnessNoVideo =>
      'Sube un vídeo de entrenamiento para ver el estado del equipo.';

  @override
  String get trainingFitnessLow =>
      'Aumenta las sesiones de alta intensidad esta semana.';

  @override
  String get trainingFitnessMedium =>
      'Buen estado. Mantén la carga con sesiones técnicas.';

  @override
  String get trainingFitnessHigh =>
      'Excelente forma. Trabaja en recuperación y táctica.';

  @override
  String get trainingFitnessLevelLow => 'Baja';

  @override
  String get trainingFitnessLevelMedium => 'Media';

  @override
  String get trainingFitnessLevelHigh => 'Alta';

  @override
  String trainingInsightLowDistance(String km) {
    return '⚠️ El equipo cubre poca distancia ($km km). Incrementa la intensidad.';
  }

  @override
  String trainingInsightHighDistance(String km) {
    return '💪 Alta movilidad del equipo ($km km/jugador).';
  }

  @override
  String trainingInsightPlayersAnalysed(String count) {
    return '✅ $count jugadores analizados en el último entrenamiento.';
  }

  @override
  String get trainingInsightNoVideo =>
      '📹 Sube un vídeo de entrenamiento para obtener insights automáticos.';

  @override
  String trainingTeamLowDistance(String km) {
    return 'El equipo cubre poca distancia promedio ($km km). Aumenta la intensidad aeróbica.';
  }

  @override
  String trainingTeamHighDistance(String km) {
    return 'Alta movilidad del equipo ($km km/jugador). Prioriza recuperación.';
  }

  @override
  String trainingTeamLowPossession(String pct) {
    return 'Pérdida frecuente de posesión ($pct%). Refuerza el juego posicional.';
  }

  @override
  String trainingTeamHighPossession(String pct) {
    return 'Buena posesión del equipo ($pct%). Trabaja el remate y la explotación del dominio.';
  }

  @override
  String trainingTeamActivityGap(String most, String least) {
    return 'Gran diferencia entre jugador más activo (#$most) y menos activo (#$least).';
  }

  @override
  String trainingTeamConcentratedPossession(String player) {
    return 'El jugador #$player concentra la posesión. Trabaja la circulación del balón.';
  }

  @override
  String get trainingTeamBalanced =>
      'Rendimiento equilibrado. Mantén el plan táctico actual.';

  @override
  String get trainingPlayerLowDistance =>
      'Aumenta la resistencia: distancia corta. Añade series de carrera.';

  @override
  String get trainingPlayerLowSpeed =>
      'Trabaja la velocidad explosiva: ritmo registrado bajo.';

  @override
  String get trainingPlayerLowPossession =>
      'Mejora la participación con el balón.';

  @override
  String get trainingPlayerLowPresence => 'Aumenta la presencia en el campo.';

  @override
  String get trainingPlayerDefRole =>
      'Rol defensivo: refuerza el posicionamiento.';

  @override
  String get trainingPlayerAttRole =>
      'Rol ofensivo: trabaja el remate y el desmarque.';

  @override
  String get trainingPlayerSolid =>
      'Rendimiento sólido. Mantén el ritmo de trabajo.';

  @override
  String get trainingSugTitlePressing => 'Presión alta y transiciones';

  @override
  String get trainingSugReasonPressing => 'Mejorar pressing';

  @override
  String get trainingSugTitlePossession => 'Posesión 4-3-3';

  @override
  String get trainingSugReasonPossession => 'Juego posicional';

  @override
  String get trainingSugTitlePhysical => 'Resistencia y explosividad';

  @override
  String get trainingSugReasonPhysical => 'Mejora física';

  @override
  String get trainingNewSession => 'Nueva sesión';

  @override
  String get trainingSessionTitleHint => 'Título de la sesión';

  @override
  String get trainingSessionDescHint => 'Descripción (opcional)';

  @override
  String get trainingDurationLabel => 'Duración:';

  @override
  String get trainingCreateSession => 'Crear sesión';

  @override
  String get trainingAddOptionsTitle => '¿Qué deseas agregar?';

  @override
  String get trainingOptionAnalyze => 'Analizar partido';

  @override
  String get trainingOptionAnalyzeSubtitle =>
      'Sube un video y genera una sesión automática con IA';

  @override
  String get trainingOptionManual => 'Sesión manual';

  @override
  String get trainingOptionManualSubtitle =>
      'Crea una sesión de entrenamiento personalizada';

  @override
  String get trainingDeleteSessionTitle => 'Eliminar sesión';

  @override
  String trainingDeleteSessionConfirm(String title) {
    return '¿Eliminar \"$title\"?';
  }

  @override
  String trainingSessionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sesiones',
      one: '1 sesión',
      zero: 'Sin sesiones',
    );
    return '$_temp0';
  }

  @override
  String get trainingNoSessionsDay => 'Sin sesiones este día';

  @override
  String get trainingNoSessionsYet => 'Sin sesiones aún';

  @override
  String get trainingNoSessionsHint =>
      'Crea tu primera sesión de entrenamiento';

  @override
  String get trainingNoSuggestions => 'Sin sugerencias disponibles';

  @override
  String get trainingPillFitness => 'fitness';

  @override
  String get trainingPillPlayers => 'jugadores';

  @override
  String get trainingPillSessions => 'sesiones';

  @override
  String get trainingPillStatus => 'estado';

  @override
  String get trainingSmartAnalysisSubtitle =>
      'Genera tu plan de entrenamiento con IA';

  @override
  String get trainingUploadVideoBtn => 'Subir video de partido';

  @override
  String get trainingStepUpload => 'Subir video del partido';

  @override
  String get trainingStepDetect => 'Detectar jugadores';

  @override
  String get trainingStepAnalyze => 'Analizar movimiento';

  @override
  String get trainingStepInsights => 'Generar insights';

  @override
  String get trainingStepExport => 'Exportar informe PDF';

  @override
  String get trainingStepPending => 'pendiente';

  @override
  String get trainingLoadLabel => 'Carga';

  @override
  String get trainingPhysicalStatus => 'estado físico';

  @override
  String get trainingAvgDistance => 'Dist. promedio';

  @override
  String get trainingAvgSpeed => 'Vel. promedio';

  @override
  String get trainingPlayers => 'Jugadores';

  @override
  String get trainingTopPlayers => 'TOP JUGADORES';

  @override
  String get trainingPlayerLabel => 'Jugador';

  @override
  String get trainingStatDistance => 'Distancia';

  @override
  String get trainingStatSpeed => 'Velocidad';

  @override
  String get trainingStatAccuracy => 'Precisión';

  @override
  String get trainingStatRating => 'Valoración';

  @override
  String get trainingAlertsTitle => 'Alertas del equipo';

  @override
  String get trainingAlertFatigue => 'Riesgo de fatiga en 3 jugadores';

  @override
  String get trainingAlertFatigueSub =>
      'Considera reducir la intensidad mañana';

  @override
  String get trainingAlertMobility => '2 jugadores con movilidad reducida';

  @override
  String get trainingAlertMobilitySub => 'Recomienda estiramientos preventivos';

  @override
  String get trainingAlertTactical => 'Baja presión en zona media';

  @override
  String get trainingAlertTacticalSub =>
      'Trabaja el pressing en el próximo entrenamiento';

  @override
  String get trainingTacticalConnections => 'Conexiones tácticas';

  @override
  String get trainingAICoachTitle => 'AI Coach';

  @override
  String get trainingAICoachSubtitle => 'Análisis táctico personalizado';

  @override
  String get trainingCoachTip1 =>
      'Ampliar espacios en fase ofensiva con laterales abiertos';

  @override
  String get trainingCoachTip2 =>
      'Presión alta tras pérdida de balón en zona de construcción';

  @override
  String get trainingCoachTip3 =>
      'Reducir distancia entre líneas en fase defensiva';

  @override
  String get trainingCoachTip4 =>
      'Cambios de orientación rápidos para desestabilizar la defensa rival';

  @override
  String get trainingWeeklyActivity => 'Actividad semanal';

  @override
  String get trainingSessionsPerDay => 'sesiones / día';

  @override
  String get trainingSuggestedByAI => 'SUGERIDO POR IA';

  @override
  String get trainingMySessions => 'MIS SESIONES';

  @override
  String get trainingNewBtn => '+ Nueva';

  @override
  String get trainingDemoDefenseOpen =>
      'Línea defensiva muy abierta en últimas jugadas';

  @override
  String get trainingDemoDefenseOpenSub => 'Riesgo de espacios a la espalda';

  @override
  String get trainingDemoImprovement =>
      'Mejora del 12% en pressing vs semana anterior';

  @override
  String get trainingDemoImprovementSub => 'Mantén la intensidad';

  @override
  String get trainingDemoConnection => 'Conexión Torres-Ramírez muy efectiva';

  @override
  String get trainingDemoConnectionSub => 'Explotar ese pasillo';

  @override
  String get trainingDemoPossession => 'Posesión dominante en zona media';

  @override
  String get trainingDemoPossessionSub => 'Aprovechar para desdoblamientos';

  @override
  String get trainingDemoFatigueRisk => 'Riesgo de fatiga en defensa izquierda';

  @override
  String get trainingDemoFatigueRiskSub => 'Rotar en próximo partido';

  @override
  String get navHome => 'Inicio';

  @override
  String get navAnalysis => 'Análisis';

  @override
  String get navPlayers => 'Jugadores';

  @override
  String get navTraining => 'Entreno';

  @override
  String get navBoard => 'Tablero';

  @override
  String trainingMinutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String trainingExercisesCount(int count) {
    return '$count ejercicios';
  }

  @override
  String get trainingDescriptionTitle => 'Descripción';

  @override
  String get trainingSessionPlanTitle => 'Plan de sesión';

  @override
  String trainingMinutesTotal(int minutes) {
    return '$minutes min total';
  }

  @override
  String get trainingStartSession => 'Iniciar sesión';

  @override
  String get trainingDeleteSessionQuestion => '¿Eliminar sesión?';

  @override
  String trainingDeleteSessionBody(String title) {
    return 'Esto eliminará permanentemente \"$title\".';
  }

  @override
  String trainingExerciseProgress(int current, int total) {
    return 'Ejercicio $current de $total';
  }

  @override
  String get trainingRunning => 'En curso';

  @override
  String get trainingReady => 'Listo';

  @override
  String get trainingPaused => 'Pausado';

  @override
  String get trainingNext => 'Siguiente';

  @override
  String get trainingLastExercise => 'Último ejercicio';

  @override
  String get trainingExitSessionQuestion => '¿Salir de la sesión?';

  @override
  String get trainingExitSessionBody => 'Se perderá el progreso actual.';

  @override
  String get trainingContinue => 'Continuar';

  @override
  String get trainingExit => 'Salir';

  @override
  String get trainingSessionCompleted => 'Sesión completada';

  @override
  String trainingCompletedMinutes(int minutes) {
    return '$minutes min completados';
  }

  @override
  String get trainingBackHome => 'Volver al inicio';
}
