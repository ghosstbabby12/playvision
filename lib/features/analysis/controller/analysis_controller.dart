import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/store/analysis_store.dart';
import '../../../core/supabase/supabase_service.dart';

class AnalysisController extends ChangeNotifier {
  final ImagePicker      _picker  = ImagePicker();
  final SupabaseService  _service = SupabaseService.instance;

  XFile? videoFile;
  bool   isAnalyzing = false;
  Map<String, dynamic>? result;
  String? errorMessage;

  void init() {
    result    = AnalysisStore.instance.lastResult;
    videoFile = AnalysisStore.instance.lastLocalFile;
  }

  Future<void> pickVideo() async {
    final file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file == null) return;
    videoFile = file;
    result    = null;
    notifyListeners();
  }

  Future<void> analyzeVideo() async {
    if (videoFile == null) return;

    final teamId = AnalysisStore.instance.selectedTeamId;
    if (teamId == null) {
      errorMessage = 'No team selected. Go back and select a team first.';
      notifyListeners();
      return;
    }

    isAnalyzing  = true;
    errorMessage = null;
    notifyListeners();

    int? matchId;
    try {
      // 1. Create match in Supabase
      matchId = await _service.createMatchAndReturnId(
        teamId:     teamId,
        opponent:   '',
        matchDate:  DateTime.now(),
        sourceType: AppConstants.sourceUpload,
      );

      // 2. Send video to backend
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

      final streamed = await request.send().timeout(AppConstants.analysisTimeout);
      final body     = await streamed.stream.bytesToString();

      if (streamed.statusCode == 200) {
        result = jsonDecode(body) as Map<String, dynamic>;
        AnalysisStore.instance.save(result!, localFile: videoFile);

        // 3. Update match status + video URL
        await _service.updateMatchStatus(matchId: matchId, status: 'done');
        final videoUrl = result!['video_url'] as String?;
        if (videoUrl != null && videoUrl.isNotEmpty) {
          await _service.updateMatchVideoUrl(matchId: matchId, videoUrl: videoUrl);
        }
      } else {
        errorMessage = 'Server error: ${streamed.statusCode}';
        await _service.updateMatchStatus(matchId: matchId, status: 'error');
      }
    } catch (e) {
      errorMessage = 'Connection error: $e';
      if (matchId != null) {
        await _service.updateMatchStatus(matchId: matchId, status: 'error');
      }
    } finally {
      isAnalyzing = false;
      notifyListeners();
    }
  }

  void reset() {
    result = null;
    videoFile = null;
    errorMessage = null;
    notifyListeners();
  }

  void consumeError() {
    errorMessage = null;
  }
}
