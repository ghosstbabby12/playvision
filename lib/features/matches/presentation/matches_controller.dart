import 'package:flutter/foundation.dart';

import '../../../core/supabase/supabase_service.dart';

class MatchesController extends ChangeNotifier {
  final SupabaseService _service = SupabaseService.instance;

  List<Map<String, dynamic>> matches = [];
  List<Map<String, dynamic>> teams = [];
  bool isLoading = true;
  String? errorMessage;

  Future<void> fetchData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _service.getTeams(),
        _service.getMatches(),
      ]);
      teams = results[0];
      matches = results[1];
    } catch (e) {
      errorMessage = 'Failed to load data: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createMatch({
    required int teamId,
    required String opponent,
    required DateTime matchDate,
    required String sourceType,
  }) async {
    await _service.createMatch(
      teamId: teamId,
      opponent: opponent,
      matchDate: matchDate,
      sourceType: sourceType,
      videoUrl: null,
      latitude: null,
      longitude: null,
    );
    await fetchData();
  }

  void consumeError() {
    errorMessage = null;
  }
}
