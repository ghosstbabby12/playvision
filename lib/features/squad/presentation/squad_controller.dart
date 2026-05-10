import 'package:flutter/foundation.dart';
import '../../../core/supabase/supabase_service.dart';

class SquadController extends ChangeNotifier {
  final _service = SupabaseService.instance;

  List<Map<String, dynamic>> _teams   = [];
  List<Map<String, dynamic>> _players = [];
  // player_id → aggregated stats
  Map<int, Map<String, dynamic>> _statsMap = {};

  bool   isLoading     = false;
  String? errorMessage;

  int?   selectedTeamId;
  String selectedPosition = 'All';
  String searchQuery       = '';

  List<Map<String, dynamic>> get teams => List.unmodifiable(_teams);

  List<Map<String, dynamic>> get filtered {
    var list = _players;
    if (selectedTeamId != null) {
      list = list.where((p) => p['team_id'] == selectedTeamId).toList();
    }
    if (selectedPosition != 'All') {
      list = list.where((p) =>
          (p['position'] as String? ?? '').toUpperCase() == selectedPosition)
          .toList();
    }
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list.where((p) =>
          (p['name'] as String? ?? '').toLowerCase().contains(q)).toList();
    }
    return list;
  }

  int countByPosition(String pos) {
    var base = selectedTeamId == null
        ? _players
        : _players.where((p) => p['team_id'] == selectedTeamId).toList();
    if (pos == 'All') return base.length;
    return base
        .where((p) =>
            (p['position'] as String? ?? '').toUpperCase() == pos)
        .length;
  }

  Map<String, dynamic> statsFor(int playerId) =>
      _statsMap[playerId] ?? {};

  Future<void> fetchData() async {
    isLoading    = true;
    errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _service.getTeams(),
        _service.getPlayers(),
      ]);
      _teams   = results[0];
      _players = results[1];

      if (_teams.isNotEmpty && selectedTeamId == null) {
        selectedTeamId = _teams.first['id'] as int;
      }

      await _loadStats();
    } catch (e) {
      errorMessage = 'Error al cargar plantilla: $e';
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> _loadStats() async {
    if (_players.isEmpty) return;
    final ids = _players.map((p) => p['id'] as int).toList();
    try {
      final rows = await _service.client
          .from('player_match_stats')
          .select('player_id, rating, passes_ok, recoveries, shots, shots_on_target, minutes')
          .inFilter('player_id', ids);

      final Map<int, List<Map<String, dynamic>>> grouped = {};
      for (final r in rows) {
        final pid = r['player_id'] as int;
        grouped.putIfAbsent(pid, () => []).add(Map<String, dynamic>.from(r));
      }

      _statsMap = {};
      for (final entry in grouped.entries) {
        final list = entry.value;
        final n    = list.length;
        double avgRating   = 0;
        double avgPasses   = 0;
        double avgRec      = 0;
        double avgShots    = 0;
        double avgSot      = 0;
        double avgMinutes  = 0;
        for (final s in list) {
          avgRating  += (s['rating']          as num? ?? 0).toDouble();
          avgPasses  += (s['passes_ok']       as num? ?? 0).toDouble();
          avgRec     += (s['recoveries']      as num? ?? 0).toDouble();
          avgShots   += (s['shots']           as num? ?? 0).toDouble();
          avgSot     += (s['shots_on_target'] as num? ?? 0).toDouble();
          avgMinutes += (s['minutes']         as num? ?? 0).toDouble();
        }
        _statsMap[entry.key] = {
          'matches':     n,
          'avg_rating':  avgRating  / n,
          'avg_passes':  avgPasses  / n,
          'avg_rec':     avgRec     / n,
          'avg_shots':   avgShots   / n,
          'avg_sot':     avgSot     / n,
          'avg_minutes': avgMinutes / n,
        };
      }
    } catch (e) {
      debugPrint('[SquadController] stats error: $e');
    }
  }

  void selectTeam(int? id) {
    selectedTeamId = id;
    selectedPosition = 'All';
    notifyListeners();
  }

  void selectPosition(String pos) {
    selectedPosition = pos;
    notifyListeners();
  }

  void setSearch(String q) {
    searchQuery = q;
    notifyListeners();
  }

  // Returns the new player ID (null on error).
  Future<int?> addPlayer({
    required String name,
    required String position,
    int? shirtNumber,
    String? birthDate,
  }) async {
    if (selectedTeamId == null) return null;
    try {
      final id = await _service.createPlayer(
        teamId:      selectedTeamId!,
        name:        name,
        position:    position,
        shirtNumber: shirtNumber,
        birthDate:   birthDate,
      );
      await fetchData();
      return id;
    } catch (e) {
      errorMessage = 'Error al guardar jugador: $e';
      notifyListeners();
      return null;
    }
  }

  Future<bool> editPlayer({
    required int id,
    required String name,
    required String position,
    int? shirtNumber,
    String? birthDate,
    String? status,
  }) async {
    try {
      await _service.updatePlayer(
        id:          id,
        name:        name,
        position:    position,
        shirtNumber: shirtNumber,
        birthDate:   birthDate,
        status:      status,
      );
      await fetchData();
      return true;
    } catch (e) {
      errorMessage = 'Error al actualizar jugador: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> removePlayer(int id) async {
    try {
      await _service.deletePlayer(id);
      await fetchData();
      return true;
    } catch (e) {
      errorMessage = 'Error al eliminar jugador: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> uploadPhoto({
    required int playerId,
    required List<int> bytes,
    required String extension,
  }) async {
    try {
      await _service.uploadPlayerPhoto(
        playerId:  playerId,
        bytes:     Uint8List.fromList(bytes),
        extension: extension,
      );
      await fetchData();
      return true;
    } catch (e) {
      debugPrint('[SquadController] photo upload error: $e');
      return false;
    }
  }

  void consumeError() => errorMessage = null;
}
