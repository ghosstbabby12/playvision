import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_constants.dart';
import 'package:playvision/features/analysis/data/analysis_store.dart';
import '../../../core/supabase/supabase_service.dart';

class AnalysisController extends ChangeNotifier {
  final ImagePicker     _picker  = ImagePicker();
  final SupabaseService _service = SupabaseService.instance;

  XFile?  videoFile;
  String? videoUrl;
  bool    isAnalyzing     = false;
  bool    _isPickingVideo = false;
  bool    _cancelled      = false;
  http.Client? _httpClient;

  Map<String, dynamic>? result;
  String? errorMessage;

  void init() {
    result    = AnalysisStore.instance.lastResult;
    videoFile = AnalysisStore.instance.lastLocalFile;
  }

  Future<void> pickVideo() async {
    if (_isPickingVideo) return;
    _isPickingVideo = true;
    try {
      final file = await _picker.pickVideo(source: ImageSource.gallery);
      if (file == null) return;
      videoFile = file;
      videoUrl  = null;
      result    = null;
      notifyListeners();
    } catch (e) {
      debugPrint('[AnalysisController] Error picker: $e');
    } finally {
      _isPickingVideo = false;
    }
  }

  void setVideoUrl(String url) {
    videoUrl  = url.trim().isEmpty ? null : url.trim();
    videoFile = null;
    result    = null;
    notifyListeners();
  }

  /// Cancela el análisis en curso cerrando la conexión HTTP.
  void cancelAnalysis() {
    _cancelled = true;
    _httpClient?.close();
    _httpClient  = null;
    isAnalyzing  = false;
    errorMessage = null;
    notifyListeners();
  }

  Future<void> analyzeVideo() async {
    if (videoFile == null && videoUrl == null) return;

    final teamId = AnalysisStore.instance.selectedTeamId;
    if (teamId == null) {
      errorMessage = 'No hay equipo seleccionado. Vuelve atrás y elige uno.';
      notifyListeners();
      return;
    }

    isAnalyzing  = true;
    _cancelled   = false;
    errorMessage = null;
    notifyListeners();

    int? matchId;
    try {
      matchId = await _service.createMatchAndReturnId(
        teamId:     teamId,
        opponent:   '',
        matchDate:  DateTime.now(),
        sourceType: AppConstants.sourceUpload,
      );

      _httpClient = http.Client();
      http.StreamedResponse streamed;
      String body;

      if (videoUrl != null) {
        final request = http.MultipartRequest(
          'POST', Uri.parse('${AppConstants.apiBase}/analyze-url'),
        );
        request.fields['team_id']     = teamId.toString();
        request.fields['match_id']    = matchId.toString();
        request.fields['source_type'] = 'url';
        request.fields['video_url']   = videoUrl!;
        streamed = await _httpClient!.send(request)
            .timeout(AppConstants.analysisTimeout);
      } else {
        final bytes   = await videoFile!.readAsBytes();
        final request = http.MultipartRequest(
          'POST', Uri.parse('${AppConstants.apiBase}/analyze'),
        );
        request.fields['team_id']     = teamId.toString();
        request.fields['match_id']    = matchId.toString();
        request.fields['source_type'] = AppConstants.sourceUpload;
        request.files.add(
          http.MultipartFile.fromBytes('file', bytes, filename: videoFile!.name),
        );
        streamed = await _httpClient!.send(request)
            .timeout(AppConstants.analysisTimeout);
      }

      if (_cancelled) return;

      body = await streamed.stream.bytesToString();

      if (streamed.statusCode == 200) {
        result = jsonDecode(body) as Map<String, dynamic>;
        AnalysisStore.instance.save(result!, localFile: videoFile);
        await _service.updateMatchStatus(matchId: matchId, status: 'done');
        final url = result!['video_url'] as String?;
        if (url != null && url.isNotEmpty) {
          await _service.updateMatchVideoUrl(matchId: matchId, videoUrl: url);
        }
      } else {
        if (!_cancelled) {
          errorMessage = 'Error del servidor: ${streamed.statusCode}';
          await _service.updateMatchStatus(matchId: matchId, status: 'error');
        }
      }
    } catch (e) {
      if (!_cancelled) {
        errorMessage = 'Error de conexión: $e';
        if (matchId != null) {
          await _service.updateMatchStatus(matchId: matchId, status: 'error');
        }
      }
    } finally {
      _httpClient?.close();
      _httpClient = null;
      isAnalyzing = false;
      notifyListeners();
    }
  }

  void reset() {
    result          = null;
    videoFile       = null;
    videoUrl        = null;
    errorMessage    = null;
    _isPickingVideo = false;
    _cancelled      = false;
    notifyListeners();
  }

  void consumeError() => errorMessage = null;
}
