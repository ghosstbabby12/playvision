/// Insight estructurado generado por el análisis de entrenamiento.
///
/// [key]   → clave de l10n (ej: 'trainingInsightLowDistance').
///           Clave especial '_raw': el campo args['text'] ya contiene
///           el string traducido que llegó del backend.
/// [args]  → placeholders para la interpolación en la UI.
/// [level] → nivel visual del insight.
class TrainingInsight {
  final String              key;
  final Map<String, String> args;
  final InsightLevel        level;

  const TrainingInsight(
    this.key, {
    this.args  = const {},
    this.level = InsightLevel.info,
  });
}

enum InsightLevel { info, warning, success }