import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/store/analysis_store.dart';

class AnalysisController extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();

  XFile? videoFile;
  bool isAnalyzing = false;
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
    result = null;
    notifyListeners();
  }

  Future<void> analyzeVideo() async {
    if (videoFile == null) return;
    isAnalyzing = true;
    errorMessage = null;
    notifyListeners();

    try {
      final bytes = await videoFile!.readAsBytes();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConstants.apiBase}/analyze'),
      );
      request.fields['team_id'] = '1'; 

      request.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: videoFile!.name),
      );
      final streamed = await request.send().timeout(AppConstants.analysisTimeout);
      final body = await streamed.stream.bytesToString();

      if (streamed.statusCode == 200) {
        result = jsonDecode(body) as Map<String, dynamic>;
        AnalysisStore.instance.save(result!, localFile: videoFile);
      } else {
        errorMessage = 'Server error: ${streamed.statusCode} - $body';
      }
    } catch (e) {
      errorMessage = 'No backend connection.\n$e';
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
