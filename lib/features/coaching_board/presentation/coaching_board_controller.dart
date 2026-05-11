import 'package:flutter/foundation.dart';
import 'package:playvision/core/supabase/supabase_service.dart';
import '../domain/player_token.dart';

enum BoardStep { selectTeam, analyzing, board }

class CoachingBoardController extends ChangeNotifier {
  // ── State ──────────────────────────────────────────────────────────────────
  BoardStep _step = BoardStep.selectTeam;
  List<Map<String, dynamic>> _teams = [];
  Map<String, dynamic>? _selectedTeam;
  bool _loadingTeams = true;

  // Analysis progress
  int _completedSteps = 0;
  static const analysisSteps = [
    'Loading players...',           // <- texto en inglés
    'Reading statistics...',        // <- texto en inglés
    'Computing optimal positions...', // <- texto en inglés
    'Building tactical board...',   // <- texto en inglés
  ];

  // Board state
  String _formation = '4-3-3';
  List<PlayerToken> _players = [];
  PlayerToken? _selectedPlayer;
  PlayerToken? _swapSource;

  // Save state
  bool _isSaving = false;
  String? _savedMessage;

  // ── Getters ────────────────────────────────────────────────────────────────
  BoardStep get step => _step;
  List<Map<String, dynamic>> get teams => List.unmodifiable(_teams);
  Map<String, dynamic>? get selectedTeam => _selectedTeam;
  bool get loadingTeams => _loadingTeams;
  int get completedSteps => _completedSteps;
  String get formation => _formation;
  List<PlayerToken> get players => List.unmodifiable(_players);
  PlayerToken? get selectedPlayer => _selectedPlayer;
  PlayerToken? get swapSource => _swapSource;
  bool get isSaving => _isSaving;
  String? get savedMessage => _savedMessage;

  void consumeSavedMessage() {
    _savedMessage = null;
  }

  static const List<String> availableFormations = [
    '4-3-3',
    '4-4-2',
    '4-2-3-1',
    '3-5-2',
  ];

  // ── Team loading ────────────────────────────────────────────────────────────
  Future<void> loadTeams() async {
    _loadingTeams = true;
    notifyListeners();
    try {
      _teams = await SupabaseService.instance.getTeams();
    } catch (_) {
      _teams = [];
    }
    _loadingTeams = false;
    notifyListeners();
  }

  // ── Step 1 → Step 2 → Step 3 ───────────────────────────────────────────────
  Future<void> selectTeamAndAnalyze(Map<String, dynamic> team) async {
    _selectedTeam = team;
    _completedSteps = 0;
    _step = BoardStep.analyzing;
    notifyListeners();

    final apiFuture = _fetchBoardFromApi(team['id'] as int);

    for (int i = 0; i < analysisSteps.length - 1; i++) {
      await Future.delayed(const Duration(milliseconds: 620));
      _completedSteps = i + 1;
      notifyListeners();
    }

    await apiFuture;
    _completedSteps = analysisSteps.length;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 350));
    _step = BoardStep.board;
    notifyListeners();
  }

  Future<void> _fetchBoardFromApi(int teamId) async {
    // Always try to load real Supabase players first
    List<Map<String, dynamic>> supaPlayers = [];
    try {
      supaPlayers =
          await SupabaseService.instance.getPlayersByTeam(teamId);
    } catch (_) {}

    // Try to restore a previously saved formation (positions only)
    try {
      final saved =
          await SupabaseService.instance.getFormation(teamId);
      if (saved != null) {
        final f = saved['formation'] as String? ?? '4-3-3';
        final rawList = saved['players'] as List?;
        if (rawList != null && rawList.isNotEmpty) {
          _formation = f;
          // Build a map of saved positions keyed by player id
          final posById = <int, (double, double)>{};
          for (final p in rawList) {
            final m = p as Map<String, dynamic>;
            final id = (m['id'] as num).toInt();
            posById[id] = (
              (m['dx'] as num).toDouble(),
              (m['dy'] as num).toDouble(),
            );
          }

          if (supaPlayers.isNotEmpty) {
            // Merge: real player data + saved positions
            _players = _assignRealPlayersWithSavedPos(
              supaPlayers,
              posById,
              _mockFormations[_formation]!,
            );
          } else {
            // No real players → restore saved formation as-is (may be mock names)
            _players = rawList.map((p) {
              final m = p as Map<String, dynamic>;
              return PlayerToken(
                id: (m['id'] as num).toInt(),
                name: m['name'] as String? ?? '',
                number: (m['number'] as num?)?.toInt() ?? 0,
                position: m['position'] as String? ?? 'CM',
                dx: (m['dx'] as num).toDouble(),
                dy: (m['dy'] as num).toDouble(),
                stats: Map<String, dynamic>.from(_defaultStats),
              );
            }).toList();
          }
          return;
        }
      }
    } catch (_) {}

    // No saved formation — place real players in default formation positions
    if (supaPlayers.isNotEmpty) {
      _players = _assignRealPlayers(
        supaPlayers,
        _mockFormations[_formation]!,
      );
      return;
    }

    // Full mock fallback (team has no players)
    _players = _buildMockPlayers(_mockFormations[_formation]!);
  }

  // Real players + saved (dx,dy) positions by player id
  static List<PlayerToken> _assignRealPlayersWithSavedPos(
    List<Map<String, dynamic>> supaPlayers,
    Map<int, (double, double)> posById,
    List<List<dynamic>> defaultSlots,
  ) {
    final available = List<Map<String, dynamic>>.from(supaPlayers);
    final mockStats = List<Map<String, dynamic>>.from(_mockStats);

    // Players with a saved position
    final result = <PlayerToken>[];
    final usedIds = <int>{};

    for (final p in supaPlayers) {
      final pid = (p['id'] as num).toInt();
      if (posById.containsKey(pid)) {
        final (dx, dy) = posById[pid]!;
        final slot = defaultSlots.firstWhere(
          (s) => s[2] == (p['position'] as String? ?? 'CM'),
          orElse: () =>
              defaultSlots[result.length % defaultSlots.length],
        );
        result.add(
          PlayerToken(
            id: pid,
            name: p['name'] as String? ?? '',
            number: (p['shirt_number'] as num?)?.toInt() ?? 0,
            position: slot[2] as String,
            dx: dx,
            dy: dy,
            stats: Map<String, dynamic>.from(
              mockStats[result.length % mockStats.length],
            ),
          ),
        );
        usedIds.add(pid);
      }
    }

    // Remaining players that weren't in the saved formation → assign to empty slots
    final remaining = available
        .where((p) => !usedIds.contains((p['id'] as num).toInt()))
        .toList();
    final usedSlots = result.length;
    for (int i = 0;
        i < remaining.length && (usedSlots + i) < defaultSlots.length;
        i++) {
      final slot = defaultSlots[usedSlots + i];
      final p = remaining[i];
      result.add(
        PlayerToken(
          id: (p['id'] as num).toInt(),
          name: p['name'] as String? ?? '',
          number:
              (p['shirt_number'] as num?)?.toInt() ?? slot[1] as int,
          position: slot[2] as String,
          dx: (slot[3] as num).toDouble(),
          dy: (slot[4] as num).toDouble(),
          stats: Map<String, dynamic>.from(
            mockStats[(usedSlots + i) % mockStats.length],
          ),
        ),
      );
    }

    // Fill remaining slots with mock if fewer than 11 real players
    while (result.length < defaultSlots.length) {
      final i = result.length;
      final slot = defaultSlots[i];
      result.add(
        PlayerToken(
          id: -(i + 1),
          name: slot[0] as String,
          number: slot[1] as int,
          position: slot[2] as String,
          dx: (slot[3] as num).toDouble(),
          dy: (slot[4] as num).toDouble(),
          stats: Map<String, dynamic>.from(
            mockStats[i % mockStats.length],
          ),
        ),
      );
    }

    return result;
  }

  // Maps real Supabase players onto formation positions by matching positions
  static List<PlayerToken> _assignRealPlayers(
    List<Map<String, dynamic>> supaPlayers,
    List<List<dynamic>> positions,
  ) {
    final available = List<Map<String, dynamic>>.from(supaPlayers);
    final mockStats = List<Map<String, dynamic>>.from(_mockStats);

    return List.generate(positions.length, (i) {
      final slot = positions[i];
      final wantPos = slot[2] as String;

      // Try to find a player whose position matches (or is compatible)
      int bestIdx = _findBestPlayer(available, wantPos);

      Map<String, dynamic> chosen;
      if (bestIdx >= 0) {
        chosen = available.removeAt(bestIdx);
      } else if (available.isNotEmpty) {
        chosen = available.removeAt(0);
      } else {
        // No real player available → use mock slot
        return PlayerToken(
          id: i + 1,
          name: slot[0] as String,
          number: slot[1] as int,
          position: wantPos,
          dx: (slot[3] as num).toDouble(),
          dy: (slot[4] as num).toDouble(),
          stats: Map<String, dynamic>.from(
            mockStats[i % mockStats.length],
          ),
        );
      }

      return PlayerToken(
        id: (chosen['id'] as num).toInt(),
        name: chosen['name'] as String? ?? slot[0] as String,
        number:
            (chosen['shirt_number'] as num?)?.toInt() ?? slot[1] as int,
        position: wantPos,
        dx: (slot[3] as num).toDouble(),
        dy: (slot[4] as num).toDouble(),
        stats: Map<String, dynamic>.from(
          mockStats[i % mockStats.length],
        ),
      );
    });
  }

  static int _findBestPlayer(
    List<Map<String, dynamic>> pool,
    String wantPos,
  ) {
    // Exact match first
    for (int i = 0; i < pool.length; i++) {
      if ((pool[i]['position'] as String? ?? '') == wantPos) {
        return i;
      }
    }
    // Group match (GK→GK, DEF→CB/RB/LB, MID→CM/CDM, FWD→ST/RW/LW)
    final group = _posGroup(wantPos);
    for (int i = 0; i < pool.length; i++) {
      if (_posGroup(pool[i]['position'] as String? ?? '') == group) {
        return i;
      }
    }
    return -1;
  }

  static String _posGroup(String pos) {
    if (pos == 'GK') return 'GK';
    if ({'CB', 'RB', 'LB', 'WB', 'RWB', 'LWB'}.contains(pos)) {
      return 'DEF';
    }
    if ({'ST', 'CF', 'RW', 'LW', 'SS'}.contains(pos)) {
      return 'FWD';
    }
    return 'MID';
  }

  void goBack() {
    _step = BoardStep.selectTeam;
    _selectedPlayer = null;
    _swapSource = null;
    notifyListeners();
  }

  // ── Board interactions ─────────────────────────────────────────────────────
  void movePlayer(int id, double dx, double dy) {
    final idx = _players.indexWhere((p) => p.id == id);
    if (idx == -1) return;
    _players = List.of(_players);
    _players[idx] = _players[idx].copyWith(dx: dx, dy: dy);
    notifyListeners();
  }

  void selectPlayer(PlayerToken? player) {
    _selectedPlayer =
        (_selectedPlayer?.id == player?.id) ? null : player;
    notifyListeners();
  }

  void resetFormation() {
    _players = _buildMockPlayers(_mockFormations[_formation]!);
    _selectedPlayer = null;
    _swapSource = null;
    notifyListeners();
  }

  void switchFormation(String newFormation) {
    if (!_mockFormations.containsKey(newFormation)) return;
    _formation = newFormation;
    _players = _buildMockPlayers(_mockFormations[newFormation]!);
    _selectedPlayer = null;
    _swapSource = null;
    notifyListeners();
  }

  void startSwap(PlayerToken player) {
    _swapSource = _swapSource?.id == player.id ? null : player;
    _selectedPlayer = null;
    notifyListeners();
  }

  void finishSwap(PlayerToken target) {
    final src = _swapSource;
    _swapSource = null;
    if (src == null || src.id == target.id) {
      notifyListeners();
      return;
    }
    final srcIdx = _players.indexWhere((p) => p.id == src.id);
    final tgtIdx = _players.indexWhere((p) => p.id == target.id);
    if (srcIdx == -1 || tgtIdx == -1) {
      notifyListeners();
      return;
    }
    final list = List.of(_players);
    final (sx, sy) = (list[srcIdx].dx, list[srcIdx].dy);
    list[srcIdx] =
        list[srcIdx].copyWith(dx: list[tgtIdx].dx, dy: list[tgtIdx].dy);
    list[tgtIdx] = list[tgtIdx].copyWith(dx: sx, dy: sy);
    _players = list;
    notifyListeners();
  }

  // ── Save formation ─────────────────────────────────────────────────────────
  Future<void> saveFormation() async {
    final teamId = _selectedTeam?['id'] as int?;
    if (teamId == null || _isSaving) return;
    _isSaving = true;
    notifyListeners();
    try {
      await SupabaseService.instance.saveFormation(
        teamId: teamId,
        formation: _formation,
        players: _players
            .map(
              (p) => {
                'id': p.id,
                'name': p.name,
                'number': p.number,
                'position': p.position,
                'dx': p.dx,
                'dy': p.dy,
              },
            )
            .toList(),
      );
      _savedMessage = 'Formación guardada ✓'; // <- español
    } catch (_) {
      _savedMessage = 'Error al guardar la formación'; // <- español
    }
    _isSaving = false;
    notifyListeners();
  }

  // ── Mock fallback data ─────────────────────────────────────────────────────
  static const _defaultStats = {
    'rating': 7.0,
    'distance': 9.0,
    'passes': 50,
    'passAccuracy': 82,
    'goals': 0,
    'assists': 0,
    'tackles': 5,
    'minutes': 90,
  };

  static const _mockFormations = <String, List<List<dynamic>>>{
    '4-3-3': [
      ['García', 1, 'GK', 0.50, 0.88],
      ['Pérez', 2, 'RB', 0.82, 0.72],
      ['López', 3, 'CB', 0.62, 0.72],
      ['Rodríguez', 4, 'CB', 0.38, 0.72],
      ['González', 5, 'LB', 0.18, 0.72],
      ['Díaz', 6, 'CM', 0.72, 0.52],
      ['Morales', 7, 'CDM', 0.50, 0.55],
      ['Fernández', 8, 'CM', 0.28, 0.52],
      ['Torres', 9, 'RW', 0.80, 0.28],
      ['Sánchez', 10, 'ST', 0.50, 0.22],
      ['Ramírez', 11, 'LW', 0.20, 0.28],
    ],
    '4-4-2': [
      ['García', 1, 'GK', 0.50, 0.88],
      ['Pérez', 2, 'RB', 0.82, 0.72],
      ['López', 3, 'CB', 0.62, 0.72],
      ['Rodríguez', 4, 'CB', 0.38, 0.72],
      ['González', 5, 'LB', 0.18, 0.72],
      ['Díaz', 6, 'RM', 0.82, 0.52],
      ['Morales', 7, 'CM', 0.60, 0.52],
      ['Fernández', 8, 'CM', 0.40, 0.52],
      ['Torres', 9, 'LM', 0.18, 0.52],
      ['Sánchez', 10, 'ST', 0.62, 0.26],
      ['Ramírez', 11, 'ST', 0.38, 0.26],
    ],
    '4-2-3-1': [
      ['García', 1, 'GK', 0.50, 0.88],
      ['Pérez', 2, 'RB', 0.82, 0.74],
      ['López', 3, 'CB', 0.62, 0.74],
      ['Rodríguez', 4, 'CB', 0.38, 0.74],
      ['González', 5, 'LB', 0.18, 0.74],
      ['Díaz', 6, 'CDM', 0.62, 0.58],
      ['Morales', 7, 'CDM', 0.38, 0.58],
      ['Fernández', 8, 'RAM', 0.78, 0.38],
      ['Torres', 9, 'CAM', 0.50, 0.38],
      ['Sánchez', 10, 'LAM', 0.22, 0.38],
      ['Ramírez', 11, 'ST', 0.50, 0.20],
    ],
    '3-5-2': [
      ['García', 1, 'GK', 0.50, 0.88],
      ['Pérez', 2, 'CB', 0.72, 0.74],
      ['López', 3, 'CB', 0.50, 0.74],
      ['Rodríguez', 4, 'CB', 0.28, 0.74],
      ['González', 5, 'RM', 0.90, 0.52],
      ['Díaz', 6, 'CM', 0.67, 0.52],
      ['Morales', 7, 'CDM', 0.50, 0.56],
      ['Fernández', 8, 'CM', 0.33, 0.52],
      ['Torres', 9, 'LM', 0.10, 0.52],
      ['Sánchez', 10, 'ST', 0.62, 0.26],
      ['Ramírez', 11, 'ST', 0.38, 0.26],
    ],
  };

  static const _mockStats = [
    {
      'rating': 7.2,
      'distance': 5.8,
      'passes': 42,
      'passAccuracy': 91,
      'goals': 0,
      'assists': 0,
      'tackles': 2,
      'minutes': 90
    },
    {
      'rating': 7.0,
      'distance': 10.2,
      'passes': 55,
      'passAccuracy': 84,
      'goals': 0,
      'assists': 2,
      'tackles': 8,
      'minutes': 90
    },
    {
      'rating': 7.5,
      'distance': 9.8,
      'passes': 61,
      'passAccuracy': 88,
      'goals': 1,
      'assists': 0,
      'tackles': 12,
      'minutes': 90
    },
    {
      'rating': 7.1,
      'distance': 9.6,
      'passes': 58,
      'passAccuracy': 86,
      'goals': 0,
      'assists': 0,
      'tackles': 10,
      'minutes': 90
    },
    {
      'rating': 7.3,
      'distance': 10.8,
      'passes': 52,
      'passAccuracy': 83,
      'goals': 0,
      'assists': 3,
      'tackles': 7,
      'minutes': 90
    },
    {
      'rating': 7.8,
      'distance': 11.4,
      'passes': 72,
      'passAccuracy': 87,
      'goals': 1,
      'assists': 2,
      'tackles': 6,
      'minutes': 90
    },
    {
      'rating': 7.6,
      'distance': 12.1,
      'passes': 68,
      'passAccuracy': 89,
      'goals': 0,
      'assists': 1,
      'tackles': 9,
      'minutes': 90
    },
    {
      'rating': 7.4,
      'distance': 11.2,
      'passes': 65,
      'passAccuracy': 86,
      'goals': 1,
      'assists': 1,
      'tackles': 5,
      'minutes': 90
    },
    {
      'rating': 8.1,
      'distance': 10.5,
      'passes': 45,
      'passAccuracy': 79,
      'goals': 2,
      'assists': 3,
      'tackles': 3,
      'minutes': 87
    },
    {
      'rating': 8.5,
      'distance': 9.2,
      'passes': 38,
      'passAccuracy': 74,
      'goals': 3,
      'assists': 1,
      'tackles': 2,
      'minutes': 90
    },
    {
      'rating': 7.9,
      'distance': 10.8,
      'passes': 48,
      'passAccuracy': 81,
      'goals': 2,
      'assists': 2,
      'tackles': 4,
      'minutes': 83
    },
  ];

  static List<PlayerToken> _buildMockPlayers(
    List<List<dynamic>> positions,
  ) {
    return List.generate(positions.length, (i) {
      final p = positions[i];
      return PlayerToken(
        id: i + 1,
        name: p[0] as String,
        number: p[1] as int,
        position: p[2] as String,
        dx: (p[3] as num).toDouble(),
        dy: (p[4] as num).toDouble(),
        stats: Map<String, dynamic>.from(_mockStats[i]),
      );
    });
  }
}