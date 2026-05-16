import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/supabase/supabase_service.dart';

class MatchesController extends ChangeNotifier {
  final SupabaseService _service = SupabaseService.instance;

  List<Map<String, dynamic>> matches = [];
  List<Map<String, dynamic>> teams = [];
  bool isLoading = true;
  String? errorKey;

  bool _disposed = false;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> fetchData() async {
    isLoading = true;
    errorKey = null;
    _notify();

    try {
      final results = await Future.wait<List<Map<String, dynamic>>>([
        _service.getTeams(),
        _service.getMatches(),
      ]).timeout(const Duration(seconds: 15));

      teams = results[0];
      matches = results[1];
    } on TimeoutException {
      errorKey = 'matchesTimeoutError';
      teams = [];
      matches = [];
    } catch (e) {
      errorKey = 'matchesLoadError';
      teams = [];
      matches = [];
      debugPrint('[MatchesController.fetchData] $e');
    } finally {
      isLoading = false;
      _notify();
    }
  }

  Future<void> createMatch({
    required int teamId,
    required String opponent,
    required DateTime matchDate,
    required String sourceType,
  }) async {
    try {
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
    } catch (e) {
      errorKey = 'matchesSaveError';
      debugPrint('[MatchesController.createMatch] $e');
      _notify();
    }
  }

  void consumeError() {
    errorKey = null;
  }
}