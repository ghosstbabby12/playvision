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

  // ── Load specific match analysis ─────────────────────────
  Future<bool> loadAnalysisForMatch(int matchId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final report = await _service.getMatchReport(matchId);
      if (report != null) {
        // Guardamos el reporte ESPECÍFICO de este partido en memoria
        AnalysisStore.instance.save(report);
        return true; // Éxito
      } else {
        errorMessage = 'Analysis data not found for this match.';
        return false;
      }
    } catch (e) {
      errorMessage = 'Error loading analysis: $e';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Analyse video ────────────────────────────────────────
  Future<void> pickAndAnalyze({String opponent = ''}) async {
    final teamId = selectedTeam?['id'] as int?;
    if (teamId == null) {
      errorMessage = 'Please select a team first.';
      notifyListeners();
      return;
    }

    final file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file == null) return;

    isAnalyzing = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    int? matchId;

    try {
      // 1. Crear el partido en Supabase en estado "processing"
      matchId = await _service.createMatchAndReturnId(
        teamId: teamId,
        opponent: opponent,
        matchDate: DateTime.now(),
        sourceType: AppConstants.sourceUpload,
      );

      // 2. Preparar y enviar el video a la API de Python
      final bytes   = await file.readAsBytes();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConstants.apiBase}/analyze'),
      );

      // Enviamos IDs exactos en formato String sin variables nulas
      request.fields['team_id']     = teamId.toString();
      request.fields['opponent']    = opponent;
      request.fields['source_type'] = AppConstants.sourceUpload;
      
      request.fields['match_id'] = matchId.toString();

      request.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: file.name),
      );

      final streamed = await request.send().timeout(AppConstants.analysisTimeout);
      final body     = await streamed.stream.bytesToString();

      if (streamed.statusCode == 200) {
        // 3. Recibir resultado JSON
        final result = jsonDecode(body) as Map<String, dynamic>;

        // 4. Actualizar estado y URL del video en Supabase
        await _service.updateMatchStatus(matchId: matchId, status: 'done');
        final videoUrl = result['video_url'] as String?;
        if (videoUrl != null && videoUrl.isNotEmpty) {
          await _service.updateMatchVideoUrl(matchId: matchId, videoUrl: videoUrl);
        }

        // 5. Guardar en Store PRIMERO para que el video esté disponible
        AnalysisStore.instance.save(result, localFile: file);

        // 6. Guardar estadísticas de jugadores (solo columnas existentes en DB)
        final players = result['players'] as List?;
        if (players != null && players.isNotEmpty) {
          final statsToInsert = players.map((p) => {
            'match_id': matchId,
            'player_id': null,
            'distance': p['distance_km'],
            'minutes': 0, 'passes_ok': 0, 'passes_bad': 0,
            'losses': 0, 'recoveries': 0, 'shots': 0,
            'shots_on_target': 0, 'rating': 0.0,
          }).toList();

          try {
            await _service.savePlayerStatsBatch(statsToInsert);
          } catch (e) {
            // Stats insert failed but analysis result is already saved
            debugPrint('Stats insert error: $e');
          }
        }
        successMessage = 'Analysis complete!';
        
        // 7. Recargar los partidos de este equipo para que aparezca el nuevo
        await loadMatchesForTeam(teamId);
        
      } else {
        errorMessage = 'Server error: ${streamed.statusCode} - $body';
        // Si el backend falla, marcamos el partido como error
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
    errorMessage   = null;
    successMessage = null;
  }
}