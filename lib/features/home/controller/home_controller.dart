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
    AnalysisStore.instance.selectedTeamId = team['id'] as int?;
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
      // Keep selectedTeam in sync with refreshed data
      if (selectedTeam != null) {
        final id = selectedTeam!['id'];
        final updated = teams.where((t) => t['id'] == id).firstOrNull;
        if (updated != null) selectedTeam = updated;
      }
    } catch (e) {
      errorMessage = 'No se pudieron cargar los equipos: $e';
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
      errorMessage = 'No se pudieron cargar los partidos: $e';
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
      errorMessage = 'Fallo al cargar los partidos de este equipo: $e';
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
        AnalysisStore.instance.save(report);
        return true; 
      } else {
        errorMessage = 'Datos de análisis no encontrados para este partido.';
        return false;
      }
    } catch (e) {
      errorMessage = 'Error cargando análisis: $e';
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
      errorMessage = 'Por favor selecciona un equipo primero.';
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
        final result = jsonDecode(body) as Map<String, dynamic>;

        await _service.updateMatchStatus(matchId: matchId, status: 'done');
        final videoUrl = result['video_url'] as String?;
        if (videoUrl != null && videoUrl.isNotEmpty) {
          await _service.updateMatchVideoUrl(matchId: matchId, videoUrl: videoUrl);
        }

        AnalysisStore.instance.save(result, localFile: file);

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
            debugPrint('Stats insert error: $e');
          }
        }
        successMessage = '¡Análisis completo!';
        await loadMatchesForTeam(teamId);
        
      } else {
        errorMessage = 'Error del servidor: ${streamed.statusCode} - $body';
        await _service.updateMatchStatus(matchId: matchId, status: 'error');
      }
    } catch (e) {
      errorMessage = 'Error de conexión: $e';
      if (matchId != null) {
        await _service.updateMatchStatus(matchId: matchId, status: 'error');
      }
    } finally {
      isAnalyzing = false;
      notifyListeners();
    }
  }

  // ── Team CRUD ────────────────────────────────────────────
  Future<String?> uploadLogo({
    required int teamId,
    required Uint8List bytes,
    required String extension,
  }) async {
    return _service.uploadTeamLogo(
      teamId: teamId,
      bytes: bytes,
      extension: extension,
    );
  }

  Future<void> createTeam({
    required String name,
    String? category,
    String? club,
    String? logoUrl,
  }) async {
    try {
      await _service.createTeam(name: name, category: category, club: club, logoUrl: logoUrl);
      await loadTeams();
      successMessage = "¡Equipo creado con éxito!";
    } catch(e) {
      errorMessage = "No se pudo crear el equipo: $e";
    }
    notifyListeners();
  }

  Future<void> updateTeam({
    required int id, required String name, String? category, String? club, String? logoUrl,
  }) async {
    await _service.updateTeam(id: id, name: name, category: category, club: club, logoUrl: logoUrl);
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