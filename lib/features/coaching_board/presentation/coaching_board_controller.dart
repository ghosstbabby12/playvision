import 'package:flutter/foundation.dart';
import '../domain/player_token.dart';

class CoachingBoardController extends ChangeNotifier {
  String _formation = '4-3-3';
  late List<PlayerToken> _players;
  PlayerToken? _selectedPlayer;

  CoachingBoardController() {
    _players = _buildPlayers(_formations['4-3-3']!);
  }

  String get formation => _formation;
  List<PlayerToken> get players => List.unmodifiable(_players);
  PlayerToken? get selectedPlayer => _selectedPlayer;

  void applyFormation(String f) {
    if (!_formations.containsKey(f)) return;
    _formation = f;
    _players = _buildPlayers(_formations[f]!);
    _selectedPlayer = null;
    notifyListeners();
  }

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

  void resetFormation() => applyFormation(_formation);

  // ── Formations ─────────────────────────────────────────────────────────────
  // Each entry: [name, number, position, dx, dy]
  static const _formations = <String, List<List<dynamic>>>{
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
      ['Díaz',      6,  'RM',  0.82, 0.50],
      ['Morales',   7,  'CM',  0.62, 0.50],
      ['Fernández', 8,  'CM',  0.38, 0.50],
      ['Torres',    9,  'LM',  0.18, 0.50],
      ['Sánchez',   10, 'ST',  0.62, 0.22],
      ['Ramírez',   11, 'ST',  0.38, 0.22],
    ],
    '3-5-2': [
      ['García',    1,  'GK',  0.50, 0.88],
      ['López',     3,  'CB',  0.72, 0.73],
      ['Rodríguez', 4,  'CB',  0.50, 0.73],
      ['González',  5,  'CB',  0.28, 0.73],
      ['Pérez',     2,  'RM',  0.90, 0.50],
      ['Díaz',      6,  'CM',  0.68, 0.53],
      ['Morales',   7,  'CDM', 0.50, 0.57],
      ['Fernández', 8,  'CM',  0.32, 0.53],
      ['Torres',    9,  'LM',  0.10, 0.50],
      ['Sánchez',   10, 'ST',  0.62, 0.22],
      ['Ramírez',   11, 'ST',  0.38, 0.22],
    ],
    '4-2-3-1': [
      ['García',    1,  'GK',  0.50, 0.88],
      ['Pérez',     2,  'RB',  0.82, 0.72],
      ['López',     3,  'CB',  0.62, 0.72],
      ['Rodríguez', 4,  'CB',  0.38, 0.72],
      ['González',  5,  'LB',  0.18, 0.72],
      ['Díaz',      6,  'CDM', 0.65, 0.57],
      ['Morales',   7,  'CDM', 0.35, 0.57],
      ['Fernández', 8,  'RAM', 0.78, 0.38],
      ['Torres',    9,  'CAM', 0.50, 0.35],
      ['Ramírez',   11, 'LAM', 0.22, 0.38],
      ['Sánchez',   10, 'ST',  0.50, 0.19],
    ],
  };

  static const _stats = [
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

  static List<PlayerToken> _buildPlayers(List<List<dynamic>> positions) {
    return List.generate(positions.length, (i) {
      final p = positions[i];
      return PlayerToken(
        id:       i + 1,
        name:     p[0] as String,
        number:   p[1] as int,
        position: p[2] as String,
        dx:       (p[3] as num).toDouble(),
        dy:       (p[4] as num).toDouble(),
        stats:    Map<String, dynamic>.from(_stats[i]),
      );
    });
  }
}
