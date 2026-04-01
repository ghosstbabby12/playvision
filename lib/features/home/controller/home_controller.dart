import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/store/analysis_store.dart';
import '../../../core/supabase/supabase_service.dart';

class HomeController extends ChangeNotifier {
  final SupabaseService _service = SupabaseService.instance;
  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> teams = [];
  List<Map<String, dynamic>> recentMatches = [];
  Map<int, List<Map<String, dynamic>>> teamMatches = {};
  Map<String, dynamic>? selectedTeam;

  final Set<int> _loadingMatches = {};
  bool isLoading          = false;
  bool isLoadingMatches   = false;
  bool isAnalyzing        = false;
  String? errorMessage;
  String? successMessage;

  Map<String, dynamic>? get lastResult => AnalysisStore.instance.lastResult;
  bool get hasResult => lastResult != null;

  bool isLoadingMatchesForTeam(int teamId) => _loadingMatches.contains(teamId);

  List<Map<String, dynamic>> get selectedTeamMatches {
    final id = selectedTeam?['id'] as int?;
    if (id == null) return [];
    return teamMatches[id] ?? [];
  }

  // ── Team selection ───────────────────────────────────────
  void selectTeam(Map<String, dynamic> team) {
    selectedTeam = team;
    notifyListeners();
    loadMatchesForTeam(team['id'] as int);
  }

  void clearTeamSelection() {
    selectedTeam = null;
    notifyListeners();
  }

  // ── Data loading ─────────────────────────────────────────
  Future<void> loadTeams() async {
    isLoading = true;
    notifyListeners();
    try {
      teams = await _service.getTeams();
    } catch (e) {
      errorMessage = 'Failed to load teams: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRecentMatches() async {
    isLoadingMatches = true;
    notifyListeners();
    try {
      recentMatches = await _service.getMatches();
    } catch (e) {
      errorMessage = 'Failed to load matches: $e';
    } finally {
      isLoadingMatches = false;
      notifyListeners();
    }
  }

  Future<void> loadMatchesForTeam(int teamId) async {
    _loadingMatches.add(teamId);
    notifyListeners();
    try {
      teamMatches[teamId] = await _service.getMatchesByTeam(teamId);
    } catch (e) {
      errorMessage = 'Failed to load matches: $e';
    } finally {
      _loadingMatches.remove(teamId);
      notifyListeners();
    }
  }

  // ── Analyse video ────────────────────────────────────────
  Future<void> pickAndAnalyze({String opponent = ''}) async {
    final file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file == null) return;

    isAnalyzing = true;
    notifyListeners();

    try {
      final bytes   = await file.readAsBytes();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConstants.apiBase}/analyze'),
      );

      // Send team_id if a team is selected
      final teamId = selectedTeam?['id'];
      if (teamId != null) request.fields['team_id'] = teamId.toString();
      request.fields['opponent']    = opponent;
      request.fields['source_type'] = AppConstants.sourceUpload;

      request.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: file.name),
      );

      final streamed = await request.send().timeout(AppConstants.analysisTimeout);
      final body     = await streamed.stream.bytesToString();

      if (streamed.statusCode == 200) {
        final result = jsonDecode(body) as Map<String, dynamic>;
        AnalysisStore.instance.save(result);
        successMessage = 'Analysis complete!';
        // Refresh matches for selected team
        if (teamId != null) await loadMatchesForTeam(teamId as int);
      } else {
        errorMessage = 'Server error: ${streamed.statusCode}';
      }
    } catch (e) {
      errorMessage = 'Connection error: $e';
    } finally {
      isAnalyzing = false;
      notifyListeners();
    }
  }

  // ── Team CRUD ────────────────────────────────────────────
  Future<void> createTeam({required String name, String? category, String? club}) async {
    await _service.createTeam(name: name, category: category, club: club);
    await loadTeams();
  }

  Future<void> updateTeam({
    required int id, required String name, String? category, String? club,
  }) async {
    await _service.updateTeam(id: id, name: name, category: category, club: club);
    await loadTeams();
  }

  Future<void> deleteTeam(int id) async {
    if (selectedTeam?['id'] == id) clearTeamSelection();
    await _service.deleteTeam(id);
    await loadTeams();
  }

  void consumeMessages() {
    errorMessage  = null;
    successMessage = null;
  }
}
