import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/supabase/supabase_service.dart';
import 'package:playvision/features/analysis/data/analysis_store.dart';

class HomeController extends ChangeNotifier {
  final SupabaseService _service = SupabaseService.instance;
  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> teams = [];
  List<Map<String, dynamic>> recentMatches = [];
  Map<int, List<Map<String, dynamic>>> teamMatches = {};
  Map<String, dynamic>? selectedTeam;

  final Set<int> _loadingTeamIds = {};
  bool isLoading = false;
  bool isLoadingMatches = false;
  bool isAnalyzing = false;
  String? errorMessage;
  String? successMessage;

  bool _disposed = false;

  Map<String, dynamic>? get lastResult => AnalysisStore.instance.lastResult;
  bool get hasResult => lastResult != null;

  bool isLoadingMatchesForTeam(int teamId) =>
      _loadingTeamIds.contains(teamId);

  List<Map<String, dynamic>> get selectedTeamMatches {
    final id = selectedTeam?['id'] as int?;
    return id != null ? (teamMatches[id] ?? []) : [];
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  // ─── Selección de equipo ──────────────────────────────────────────────────

  void selectTeam(Map<String, dynamic> team) {
    selectedTeam = team;
    AnalysisStore.instance.selectedTeamId = team['id'] as int?;
    _notify();
    loadMatchesForTeam(team['id'] as int);
  }

  void clearTeamSelection() {
    selectedTeam = null;
    _notify();
  }

  // ─── Carga de datos ───────────────────────────────────────────────────────

  Future<void> loadTeams() async {
    isLoading = true;
    errorMessage = null;
    _notify();
    try {
      teams = await _service.getTeams();
      if (selectedTeam != null) {
        final id = selectedTeam!['id'];
        final updated = teams.where((t) => t['id'] == id).firstOrNull;
        if (updated != null) selectedTeam = updated;
      }
    } on TimeoutException {
      errorMessage = 'La conexión tardó demasiado. Verifica tu red.';
    } catch (e) {
      errorMessage = 'No se pudieron cargar los equipos.';
      debugPrint('[HomeController.loadTeams] $e');
    } finally {
      isLoading = false;
      _notify();
    }
  }

  Future<void> loadRecentMatches() async {
    isLoadingMatches = true;
    errorMessage = null;
    _notify();
    try {
      recentMatches = await _service.getMatches();
    } on TimeoutException {
      errorMessage = 'La conexión tardó demasiado. Verifica tu red.';
      recentMatches = [];
    } catch (e) {
      errorMessage = 'No se pudieron cargar los partidos.';
      recentMatches = [];
      debugPrint('[HomeController.loadRecentMatches] $e');
    } finally {
      isLoadingMatches = false;
      _notify();
    }
  }

  Future<void> loadMatchesForTeam(int teamId) async {
    _loadingTeamIds.add(teamId);
    _notify();
    try {
      teamMatches[teamId] = await _service.getMatchesByTeam(teamId);
    } on TimeoutException {
      errorMessage = 'La conexión tardó demasiado. Verifica tu red.';
      teamMatches[teamId] = [];
    } catch (e) {
      errorMessage = 'No se pudieron cargar los partidos del equipo.';
      teamMatches[teamId] = [];
      debugPrint('[HomeController.loadMatchesForTeam] $e');
    } finally {
      _loadingTeamIds.remove(teamId);
      _notify();
    }
  }

  Future<bool> loadAnalysisForMatch(int matchId) async {
    isLoading = true;
    errorMessage = null;
    _notify();
    try {
      final report = await _service.getMatchReport(matchId);
      if (report != null) {
        AnalysisStore.instance.save(report);
        return true;
      }
      errorMessage = 'No se encontraron datos de análisis para este partido.';
      return false;
    } on TimeoutException {
      errorMessage = 'La conexión tardó demasiado. Verifica tu red.';
      return false;
    } catch (e) {
      errorMessage = 'Error al cargar el análisis.';
      debugPrint('[HomeController.loadAnalysisForMatch] $e');
      return false;
    } finally {
      isLoading = false;
      _notify();
    }
  }

  // ─── Análisis de video ────────────────────────────────────────────────────

  Future<void> pickAndAnalyze({String opponent = ''}) async {
    final teamId = selectedTeam?['id'] as int?;
    if (teamId == null) {
      errorMessage = 'Selecciona un equipo antes de analizar.';
      _notify();
      return;
    }

    final file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file == null) return;

    isAnalyzing = true;
    errorMessage = null;
    successMessage = null;
    _notify();

    int? matchId;

    try {
      matchId = await _service.createMatchAndReturnId(
        teamId: teamId,
        opponent: opponent,
        matchDate: DateTime.now(),
        sourceType: AppConstants.sourceUpload,
      );

      final bytes = await file.readAsBytes();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConstants.apiBase}/analyze'),
      );

      request.fields['team_id'] = teamId.toString();
      request.fields['opponent'] = opponent;
      request.fields['source_type'] = AppConstants.sourceUpload;
      request.fields['match_id'] = matchId.toString();
      request.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: file.name),
      );

      final streamed = await request
          .send()
          .timeout(AppConstants.analysisTimeout);
      final body = await streamed.stream.bytesToString();

      if (streamed.statusCode == 200) {
        final result = jsonDecode(body) as Map<String, dynamic>;

        await _service.updateMatchStatus(matchId: matchId, status: 'done');

        final videoUrl = result['video_url'] as String?;
        if (videoUrl != null && videoUrl.isNotEmpty) {
          await _service.updateMatchVideoUrl(
            matchId: matchId,
            videoUrl: videoUrl,
          );
        }

        AnalysisStore.instance.save(result, localFile: file);

        final players = result['players'] as List?;
        if (players != null && players.isNotEmpty) {
          final stats = players.map((p) => {
                'match_id': matchId,
                'player_id': null,
                'distance': p['distance_km'],
                'minutes': 0,
                'passes_ok': 0,
                'passes_bad': 0,
                'losses': 0,
                'recoveries': 0,
                'shots': 0,
                'shots_on_target': 0,
                'rating': 0.0,
              }).toList();
          try {
            await _service.savePlayerStatsBatch(stats);
          } catch (e) {
            debugPrint('[HomeController] Stats insert error: $e');
          }
        }

        successMessage = '¡Análisis completado!';
        await loadMatchesForTeam(teamId);
      } else {
        errorMessage = 'Error del servidor (${streamed.statusCode}).';
        await _service.updateMatchStatus(matchId: matchId, status: 'error');
      }
    } on TimeoutException {
      errorMessage = 'El análisis tardó demasiado. Intenta con un video más corto.';
      if (matchId != null) {
        await _service.updateMatchStatus(matchId: matchId, status: 'error');
      }
    } catch (e) {
      errorMessage = 'Error de conexión al analizar el video.';
      debugPrint('[HomeController.pickAndAnalyze] $e');
      if (matchId != null) {
        await _service.updateMatchStatus(matchId: matchId, status: 'error');
      }
    } finally {
      isAnalyzing = false;
      _notify();
    }
  }

  // ─── CRUD de equipos ──────────────────────────────────────────────────────

  Future<String?> uploadLogo({
    required int teamId,
    required Uint8List bytes,
    required String extension,
  }) =>
      _service.uploadTeamLogo(
        teamId: teamId,
        bytes: bytes,
        extension: extension,
      );

  Future<void> createTeam({
    required String name,
    String? category,
    String? club,
    String? logoUrl,
  }) async {
    try {
      await _service.createTeam(
        name: name,
        category: category,
        club: club,
        logoUrl: logoUrl,
      );
      await loadTeams();
      successMessage = '¡Equipo creado con éxito!';
    } catch (e) {
      errorMessage = 'No se pudo crear el equipo.';
      debugPrint('[HomeController.createTeam] $e');
    }
    _notify();
  }

  Future<void> updateTeam({
    required int id,
    required String name,
    String? category,
    String? club,
    String? logoUrl,
  }) async {
    try {
      await _service.updateTeam(
        id: id,
        name: name,
        category: category,
        club: club,
        logoUrl: logoUrl,
      );
      await loadTeams();
    } catch (e) {
      errorMessage = 'No se pudo actualizar el equipo.';
      debugPrint('[HomeController.updateTeam] $e');
      _notify();
    }
  }

  Future<void> deleteTeam(int id) async {
    try {
      if (selectedTeam?['id'] == id) clearTeamSelection();
      await _service.deleteTeam(id);
      await loadTeams();
    } catch (e) {
      errorMessage = 'No se pudo eliminar el equipo.';
      debugPrint('[HomeController.deleteTeam] $e');
      _notify();
    }
  }

  void consumeMessages() {
    errorMessage = null;
    successMessage = null;
  }
}