import 'package:image_picker/image_picker.dart';

/// Almacena el último resultado de análisis en memoria para compartir entre páginas.
class AnalysisStore {
  AnalysisStore._();
  static final AnalysisStore instance = AnalysisStore._();

  Map<String, dynamic>? lastResult;
  XFile? lastLocalFile;
  int? selectedTeamId;

  void save(Map<String, dynamic> result, {XFile? localFile}) {
    lastResult    = result;
    lastLocalFile = localFile;
  }

  void clear() {
    lastResult    = null;
    lastLocalFile = null;
  }
}
