/// Almacena el último resultado de análisis en memoria para compartir entre páginas.
class AnalysisStore {
  AnalysisStore._();
  static final AnalysisStore instance = AnalysisStore._();

  Map<String, dynamic>? lastResult;

  void save(Map<String, dynamic> result) => lastResult = result;
  void clear() => lastResult = null;
}
