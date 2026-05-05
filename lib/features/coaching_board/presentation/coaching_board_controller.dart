import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:playvision/core/constants/app_constants.dart';
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
    'Loading players...',
    'Reading statistics...',
    'Computing optimal positions...',
    'Building tactical board...',
  ];

  // Board state
  String _formation = '4-3-3';
  List<PlayerToken> _players = [];
  PlayerToken? _selectedPlayer;
  PlayerToken? _swapSource;

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

  static const List<String> availableFormations = ['4-3-3', '4-4-2', '4-2-3-1', '3-5-2'];

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
    try {
      final res = await http
          .get(Uri.parse('${AppConstants.apiBase}/api/team/$teamId/board'))
          .timeout(const Duration(seconds: 12));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        _formation = data['formation'] as String? ?? '4-3-3';
        _players = (data['players'] as List).map((p) {
          final m = p as Map<String, dynamic>;
          return PlayerToken(
            id:       m['id'] as int,
            name:     m['name'] as String? ?? '',
            number:   m['number'] as int? ?? 0,
            position: m['position'] as String? ?? 'CM',
            dx:       (m['dx'] as num).toDouble(),
            dy:       (m['dy'] as num).toDouble(),
            stats:    Map<String, dynamic>.from(
                (m['stats'] as Map<String, dynamic>?) ?? _defaultStats),
          );
        }).toList();
        return;
      }
    } catch (_) {}

    _players = _buildMockPlayers(_mockFormations[_formation]!);
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
    _selectedPlayer = (_selectedPlayer?.id == player?.id) ? null : player;
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
    if (src == null || src.id == target.id) { notifyListeners(); return; }
    final srcIdx = _players.indexWhere((p) => p.id == src.id);
    final tgtIdx = _players.indexWhere((p) => p.id == target.id);
    if (srcIdx == -1 || tgtIdx == -1) { notifyListeners(); return; }
    final list = List.of(_players);
    final (sx, sy) = (list[srcIdx].dx, list[srcIdx].dy);
    list[srcIdx] = list[srcIdx].copyWith(dx: list[tgtIdx].dx, dy: list[tgtIdx].dy);
    list[tgtIdx] = list[tgtIdx].copyWith(dx: sx, dy: sy);
    _players = list;
    notifyListeners();
  }

  // ── Mock fallback data ─────────────────────────────────────────────────────
  static const _defaultStats = {
    'rating': 7.0, 'distance': 9.0, 'passes': 50,
    'passAccuracy': 82, 'goals': 0, 'assists': 0, 'tackles': 5, 'minutes': 90,
  };

  static const _mockFormations = <String, List<List<dynamic>>>{
    '4-3-3': [
      ['García',    1,  'GK',  0.50, 0.88],
      ['Pérez',     2,  'RB',  0.82, 0.72],
      ['López',     3,  'CB',  0.62, 0.72],
      ['Rodríguez', 4,  'CB',  0.38, 0.72],
      ['González',  5,  'LB',  0.18, 0.72],
      ['Díaz',      6,  'CM',  0.72, 0.52],
      ['Morales',   7,  'CDM', 0.50, 0.55],
      ['Fernández', 8,  'CM',  0.28, 0.52],
      ['Torres',    9,  'RW',  0.80, 0.28],
      ['Sánchez',   10, 'ST',  0.50, 0.22],
      ['Ramírez',   11, 'LW',  0.20, 0.28],
    ],
    '4-4-2': [
      ['García',    1,  'GK',  0.50, 0.88],
      ['Pérez',     2,  'RB',  0.82, 0.72],
      ['López',     3,  'CB',  0.62, 0.72],
      ['Rodríguez', 4,  'CB',  0.38, 0.72],
      ['González',  5,  'LB',  0.18, 0.72],
      ['Díaz',      6,  'RM',  0.82, 0.52],
      ['Morales',   7,  'CM',  0.60, 0.52],
      ['Fernández', 8,  'CM',  0.40, 0.52],
      ['Torres',    9,  'LM',  0.18, 0.52],
      ['Sánchez',   10, 'ST',  0.62, 0.26],
      ['Ramírez',   11, 'ST',  0.38, 0.26],
    ],
    '4-2-3-1': [
      ['García',    1,  'GK',  0.50, 0.88],
      ['Pérez',     2,  'RB',  0.82, 0.74],
      ['López',     3,  'CB',  0.62, 0.74],
      ['Rodríguez', 4,  'CB',  0.38, 0.74],
      ['González',  5,  'LB',  0.18, 0.74],
      ['Díaz',      6,  'CDM', 0.62, 0.58],
      ['Morales',   7,  'CDM', 0.38, 0.58],
      ['Fernández', 8,  'RAM', 0.78, 0.38],
      ['Torres',    9,  'CAM', 0.50, 0.38],
      ['Sánchez',   10, 'LAM', 0.22, 0.38],
      ['Ramírez',   11, 'ST',  0.50, 0.20],
    ],
    '3-5-2': [
      ['García',    1,  'GK',  0.50, 0.88],
      ['Pérez',     2,  'CB',  0.72, 0.74],
      ['López',     3,  'CB',  0.50, 0.74],
      ['Rodríguez', 4,  'CB',  0.28, 0.74],
      ['González',  5,  'RM',  0.90, 0.52],
      ['Díaz',      6,  'CM',  0.67, 0.52],
      ['Morales',   7,  'CDM', 0.50, 0.56],
      ['Fernández', 8,  'CM',  0.33, 0.52],
      ['Torres',    9,  'LM',  0.10, 0.52],
      ['Sánchez',   10, 'ST',  0.62, 0.26],
      ['Ramírez',   11, 'ST',  0.38, 0.26],
    ],
  };

  static const _mockStats = [
    {'rating': 7.2, 'distance': 5.8,  'passes': 42, 'passAccuracy': 91, 'goals': 0, 'assists': 0, 'tackles': 2,  'minutes': 90},
    {'rating': 7.0, 'distance': 10.2, 'passes': 55, 'passAccuracy': 84, 'goals': 0, 'assists': 2, 'tackles': 8,  'minutes': 90},
    {'rating': 7.5, 'distance': 9.8,  'passes': 61, 'passAccuracy': 88, 'goals': 1, 'assists': 0, 'tackles': 12, 'minutes': 90},
    {'rating': 7.1, 'distance': 9.6,  'passes': 58, 'passAccuracy': 86, 'goals': 0, 'assists': 0, 'tackles': 10, 'minutes': 90},
    {'rating': 7.3, 'distance': 10.8, 'passes': 52, 'passAccuracy': 83, 'goals': 0, 'assists': 3, 'tackles': 7,  'minutes': 90},
    {'rating': 7.8, 'distance': 11.4, 'passes': 72, 'passAccuracy': 87, 'goals': 1, 'assists': 2, 'tackles': 6,  'minutes': 90},
    {'rating': 7.6, 'distance': 12.1, 'passes': 68, 'passAccuracy': 89, 'goals': 0, 'assists': 1, 'tackles': 9,  'minutes': 90},
    {'rating': 7.4, 'distance': 11.2, 'passes': 65, 'passAccuracy': 86, 'goals': 1, 'assists': 1, 'tackles': 5,  'minutes': 90},
    {'rating': 8.1, 'distance': 10.5, 'passes': 45, 'passAccuracy': 79, 'goals': 2, 'assists': 3, 'tackles': 3,  'minutes': 87},
    {'rating': 8.5, 'distance': 9.2,  'passes': 38, 'passAccuracy': 74, 'goals': 3, 'assists': 1, 'tackles': 2,  'minutes': 90},
    {'rating': 7.9, 'distance': 10.8, 'passes': 48, 'passAccuracy': 81, 'goals': 2, 'assists': 2, 'tackles': 4,  'minutes': 83},
  ];

  static List<PlayerToken> _buildMockPlayers(List<List<dynamic>> positions) {
    return List.generate(positions.length, (i) {
      final p = positions[i];
      return PlayerToken(
        id:       i + 1,
        name:     p[0] as String,
        number:   p[1] as int,
        position: p[2] as String,
        dx:       (p[3] as num).toDouble(),
        dy:       (p[4] as num).toDouble(),
        stats:    Map<String, dynamic>.from(_mockStats[i]),
      );
    });
  }
}
