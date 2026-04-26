import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:playvision/core/constants/app_constants.dart';
import 'package:playvision/core/supabase/supabase_service.dart';
import 'package:playvision/features/analysis/data/analysis_store.dart';
import '../domain/training_session.dart';

class TrainingController extends ChangeNotifier {
  // ── Analysis result ────────────────────────────────────────────────────────
  Map<String, dynamic>? get result => AnalysisStore.instance.lastResult;
  List?                  get players => result?['players'] as List?;
  Map<String, dynamic>?  get team    => result?['team']    as Map<String, dynamic>?;

  // ── Saved sessions (Supabase) ─────────────────────────────────────────────
  List<TrainingSession> _sessions       = [];
  bool                  _loadingSessions = false;

  List<TrainingSession> get sessions        => List.unmodifiable(_sessions);
  bool                  get loadingSessions => _loadingSessions;

  Future<void> loadSessions() async {
    _loadingSessions = true;
    notifyListeners();
    try {
      final data = await SupabaseService.instance.getTrainingSessions();
      _sessions = data.map(TrainingSession.fromJson).toList();
    } catch (_) {
      _sessions = [];
    }
    _loadingSessions = false;
    notifyListeners();
  }

  Future<void> createSession({
    required String title,
    required String category,
    required int    durationMinutes,
    String?         description,
  }) async {
    await SupabaseService.instance.createTrainingSession(
      title: title, category: category,
      durationMinutes: durationMinutes, description: description,
    );
    await loadSessions();
  }

  Future<void> deleteSession(int id) async {
    await SupabaseService.instance.deleteTrainingSession(id);
    _sessions = _sessions.where((s) => s.id != id).toList();
    notifyListeners();
  }

  // ── AI Suggestions (backend) ───────────────────────────────────────────────
  List<Map<String, dynamic>> _suggestions       = [];
  bool                       _loadingSuggestions = false;
  String       _serverFitnessLevel = 'medium';
  List<String> _serverInsights     = [];

  List<Map<String, dynamic>> get suggestions       => List.unmodifiable(_suggestions);
  bool                       get loadingSuggestions => _loadingSuggestions;

  Future<void> loadSuggestions({int? teamId}) async {
    _loadingSuggestions = true;
    notifyListeners();
    try {
      final path = teamId != null
          ? '/api/team/$teamId/training-suggestions'
          : '/api/training-suggestions';
      final res = await http
          .get(Uri.parse('${AppConstants.apiBase}$path'))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        _suggestions         = List<Map<String, dynamic>>.from(data['suggestions'] as List? ?? []);
        _serverFitnessLevel  = data['fitness_level'] as String? ?? 'medium';
        _serverInsights      = List<String>.from(data['insights']  as List? ?? []);
      } else {
        _suggestions = _kGenericSuggestions;
      }
    } catch (_) {
      _suggestions = _kGenericSuggestions;
    }
    _loadingSuggestions = false;
    notifyListeners();
  }

  // ── Fitness computations ───────────────────────────────────────────────────
  double get fitnessScore {
    final speed = avgSpeedMs;
    if (speed == 0) return 0.0;
    return ((speed / 8.0) * 100).clamp(0.0, 100.0);
  }

  double get avgDistanceKm {
    final t = team;
    return (t?['avg_distance_km'] as num?)?.toDouble() ?? 0.0;
  }

  double get avgSpeedMs {
    final p = players;
    if (p == null || p.isEmpty) return 0.0;
    return p.fold(0.0, (sum, player) =>
        sum + ((player as Map)['speed_ms'] as num? ?? 0).toDouble()) / p.length;
  }

  String get fitnessStatusLabel {
    final s = fitnessScore;
    if (s > 0) {
      if (s < 35) return 'Baja';
      if (s < 65) return 'Media';
      return 'Alta';
    }
    return switch (_serverFitnessLevel) {
      'low'  => 'Baja',
      'high' => 'Alta',
      _      => 'Media',
    };
  }

  Color get fitnessStatusColor {
    final label = fitnessStatusLabel;
    return switch (label) {
      'Baja'  => const Color(0xFFFF5252),
      'Alta'  => const Color(0xFF3DCF6E),
      'Media' => const Color(0xFFFFB300),
      _       => const Color(0xFF888888),
    };
  }

  String get fitnessRecommendation {
    if (result == null) return 'Sube un vídeo de entrenamiento para ver el estado del equipo.';
    final s = fitnessScore;
    if (s < 35)  return 'Aumenta las sesiones de alta intensidad esta semana.';
    if (s < 65)  return 'Buen estado. Mantén la carga con sesiones técnicas.';
    return 'Excelente forma. Trabaja en recuperación y táctica.';
  }

  // ── Auto-insights (combined: server + local) ───────────────────────────────
  List<String> get autoInsights {
    final out = <String>[..._serverInsights];
    if (result != null) {
      final t = team;
      if (t != null) {
        final km = (t['avg_distance_km'] as num?)?.toDouble() ?? 0;
        if (km > 0 && out.isEmpty) {
          if (km < 1.5) { out.add('⚠️ El equipo cubre poca distancia (${km.toStringAsFixed(1)} km). Incrementa la intensidad.'); }
          else if (km > 3.0) { out.add('💪 Alta movilidad del equipo (${km.toStringAsFixed(1)} km/jugador).'); }
        }
      }
      final p = players;
      if (p != null && p.isNotEmpty && out.length < 3) {
        out.add('✅ ${p.length} jugadores analizados en el último entrenamiento.');
      }
    }
    if (out.isEmpty) {
      out.add('📹 Sube un vídeo de entrenamiento para obtener insights automáticos.');
    }
    return out.take(3).toList();
  }

  // ── Weekly calendar data ───────────────────────────────────────────────────
  Map<int, List<TrainingSession>> get sessionsByWeekday {
    final now    = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return {
      for (var i = 0; i < 7; i++)
        i: _sessions.where((s) {
          final day = monday.add(Duration(days: i));
          return s.createdAt.year  == day.year  &&
                 s.createdAt.month == day.month &&
                 s.createdAt.day   == day.day;
        }).toList(),
    };
  }

  // (double x, double y) records for fl_chart — no fl_chart import in controller
  List<(double, double)> get weeklySpots {
    final byDay = sessionsByWeekday;
    return List.generate(7, (i) => (i.toDouble(), byDay[i]!.length.toDouble()));
  }

  // ── Team/player insight builders ───────────────────────────────────────────
  List<String> buildTeamInsights() {
    final insights = <String>[];
    if (team == null || players == null || players!.isEmpty) return insights;

    final avgKm       = (team!['avg_distance_km'] as num?)?.toDouble() ?? 0;
    final possPct     = (team!['possession_pct']  as num?)?.toDouble() ?? 0;
    final mostActive  = team!['most_active'];
    final leastActive = team!['least_active'];
    final mostPoss    = team!['most_possession'];

    if (avgKm < 1.5) {
      insights.add('El equipo cubre poca distancia promedio (${avgKm.toStringAsFixed(2)} km). Aumenta la intensidad aeróbica.');
    } else if (avgKm > 3.0) {
      insights.add('Alta movilidad del equipo (${avgKm.toStringAsFixed(2)} km/jugador). Prioriza recuperación.');
    }
    if (possPct < 30) {
      insights.add('Pérdida frecuente de posesión (${possPct.toStringAsFixed(1)}%). Refuerza el juego posicional.');
    } else if (possPct > 60) {
      insights.add('Buena posesión del equipo (${possPct.toStringAsFixed(1)}%). Trabaja el remate y la explotación del dominio.');
    }
    if (mostActive != null && leastActive != null && mostActive != leastActive) {
      insights.add('Gran diferencia entre jugador más activo (#$mostActive) y menos activo (#$leastActive).');
    }
    if (mostPoss != null) {
      insights.add('El jugador #$mostPoss concentra la posesión. Trabaja la circulación del balón.');
    }
    if (insights.isEmpty) {
      insights.add('Rendimiento equilibrado. Mantén el plan táctico actual.');
    }
    return insights;
  }

  List<String> buildPlayerRecommendations(Map<String, dynamic> player) {
    final recs     = <String>[];
    final km       = (player['distance_km']    as num?)?.toDouble() ?? 0;
    final speed    = (player['speed_ms']       as num?)?.toDouble() ?? 0;
    final poss     = (player['possession_pct'] as num?)?.toDouble() ?? 0;
    final presence = (player['presence_pct']   as num?)?.toDouble() ?? 0;
    final zone     = player['zone'] as String? ?? '';

    if (km < 0.5)       recs.add('Aumenta la resistencia: distancia corta. Añade series de carrera.');
    if (speed < 1.5)    recs.add('Trabaja la velocidad explosiva: ritmo registrado bajo.');
    if (poss < 5)       recs.add('Mejora la participación con el balón.');
    if (presence < 50)  recs.add('Aumenta la presencia en el campo.');
    if (zone.contains('Defensa')) recs.add('Rol defensivo: refuerza el posicionamiento.');
    if (zone.contains('Ataque'))  recs.add('Rol ofensivo: trabaja el remate y el desmarque.');
    if (recs.isEmpty)   recs.add('Rendimiento sólido. Mantén el ritmo de trabajo.');
    return recs;
  }

  // ── Fallback suggestions ───────────────────────────────────────────────────
  static const _kGenericSuggestions = <Map<String, dynamic>>[
    {'title': 'Presión alta y transiciones', 'duration_minutes': 90, 'category': 'Tactical',  'reason': 'Mejorar pressing'},
    {'title': 'Posesión 4-3-3',              'duration_minutes': 75, 'category': 'Technical', 'reason': 'Juego posicional'},
    {'title': 'Resistencia y explosividad',  'duration_minutes': 60, 'category': 'Physical',  'reason': 'Mejora física'},
  ];
}
