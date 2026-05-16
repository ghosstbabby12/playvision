import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:playvision/core/constants/app_constants.dart';
import 'package:playvision/core/supabase/supabase_service.dart';
import 'package:playvision/features/analysis/data/analysis_store.dart';
import '../domain/training_insight.dart';
import '../domain/training_session.dart';

class TrainingController extends ChangeNotifier {
  // ── Analysis result ────────────────────────────────────────────────────────
  Map<String, dynamic>? get result  => AnalysisStore.instance.lastResult;
  List?                 get players => result?['players'] as List?;
  Map<String, dynamic>? get team    => result?['team'] as Map<String, dynamic>?;

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
    required int durationMinutes,
    String? description,
    List<Map<String, dynamic>>? exercises,
  }) async {
    final ex = exercises ??
        TrainingSession.defaultExercises(category)
            .map((e) => e.toJson())
            .toList();
    await SupabaseService.instance.createTrainingSession(
      title: title,
      category: category,
      durationMinutes: durationMinutes,
      description: description,
      exercises: ex,
    );
    await loadSessions();
  }

  Future<void> deleteSession(int id) async {
    await SupabaseService.instance.deleteTrainingSession(id);
    _sessions = _sessions.where((s) => s.id != id).toList();
    notifyListeners();
  }

  // ── AI Suggestions (backend) ──────────────────────────────────────────────
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
        _suggestions = List<Map<String, dynamic>>.from(
          data['suggestions'] as List? ?? [],
        );
        _serverFitnessLevel = data['fitness_level'] as String? ?? 'medium';
        _serverInsights     = List<String>.from(data['insights'] as List? ?? []);
      } else {
        _suggestions = kGenericSuggestions;
      }
    } catch (_) {
      _suggestions = kGenericSuggestions;
    }
    _loadingSuggestions = false;
    notifyListeners();
  }

  // ── Fitness computations ──────────────────────────────────────────────────

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
    return p.fold(
          0.0,
          (sum, player) =>
              sum + ((player as Map)['speed_ms'] as num? ?? 0).toDouble(),
        ) /
        p.length;
  }

  /// Returns an internal technical level key: 'low' | 'medium' | 'high'
  /// Never display this directly — resolve it in the UI via l10n.
  String get fitnessLevel {
    final s = fitnessScore;
    if (s > 0) {
      if (s < 35) return 'low';
      if (s < 65) return 'medium';
      return 'high';
    }
    return switch (_serverFitnessLevel) {
      'low'  => 'low',
      'high' => 'high',
      _      => 'medium',
    };
  }

  Color get fitnessStatusColor => switch (fitnessLevel) {
        'low'  => const Color(0xFFFF5252),
        'high' => const Color(0xFF39D353),
        _      => const Color(0xFFFFB300),
      };

  /// Returns a semantic key for the UI to translate.
  /// Possible values: 'trainingFitnessNoVideo' | 'trainingFitnessLow' |
  ///                  'trainingFitnessMedium'  | 'trainingFitnessHigh'
  String get fitnessRecommendationKey {
    if (result == null) return 'trainingFitnessNoVideo';
    return switch (fitnessLevel) {
      'low'  => 'trainingFitnessLow',
      'high' => 'trainingFitnessHigh',
      _      => 'trainingFitnessMedium',
    };
  }

  // ── Auto-insights (structured) ────────────────────────────────────────────

  /// Returns structured insights with keys and interpolation args.
  /// The UI resolves these with AppLocalizations.
  List<TrainingInsight> get autoInsights {
    final out = <TrainingInsight>[];

    // Server insights arrive as raw translated strings from the backend;
    // wrap them in a special passthrough key.
    for (final s in _serverInsights) {
      out.add(TrainingInsight('_raw', args: {'text': s}));
    }

    if (result != null) {
      final t = team;
      if (t != null) {
        final km = (t['avg_distance_km'] as num?)?.toDouble() ?? 0;
        if (km > 0 && out.isEmpty) {
          if (km < 1.5) {
            out.add(TrainingInsight(
              'trainingInsightLowDistance',
              args: {'km': km.toStringAsFixed(1)},
            ));
          } else if (km > 3.0) {
            out.add(TrainingInsight(
              'trainingInsightHighDistance',
              args: {'km': km.toStringAsFixed(1)},
            ));
          }
        }
      }

      final p = players;
      if (p != null && p.isNotEmpty && out.length < 3) {
        out.add(TrainingInsight(
          'trainingInsightPlayersAnalysed',
          args: {'count': p.length.toString()},
        ));
      }
    }

    if (out.isEmpty) {
      out.add(TrainingInsight('trainingInsightNoVideo'));
    }

    return out.take(3).toList();
  }

  // ── Weekly calendar data ──────────────────────────────────────────────────

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

  List<(double, double)> get weeklySpots {
    final byDay = sessionsByWeekday;
    return List.generate(
      7,
      (i) => (i.toDouble(), byDay[i]!.length.toDouble()),
    );
  }

  // ── Team/player insight builders ──────────────────────────────────────────

  List<TrainingInsight> buildTeamInsights() {
    final out = <TrainingInsight>[];
    if (team == null || players == null || players!.isEmpty) return out;

    final avgKm       = (team!['avg_distance_km'] as num?)?.toDouble() ?? 0;
    final possPct     = (team!['possession_pct']  as num?)?.toDouble() ?? 0;
    final mostActive  = team!['most_active'];
    final leastActive = team!['least_active'];
    final mostPoss    = team!['most_possession'];

    if (avgKm < 1.5) {
      out.add(TrainingInsight(
        'trainingTeamLowDistance',
        args: {'km': avgKm.toStringAsFixed(2)},
      ));
    } else if (avgKm > 3.0) {
      out.add(TrainingInsight(
        'trainingTeamHighDistance',
        args: {'km': avgKm.toStringAsFixed(2)},
      ));
    }

    if (possPct < 30) {
      out.add(TrainingInsight(
        'trainingTeamLowPossession',
        args: {'pct': possPct.toStringAsFixed(1)},
      ));
    } else if (possPct > 60) {
      out.add(TrainingInsight(
        'trainingTeamHighPossession',
        args: {'pct': possPct.toStringAsFixed(1)},
      ));
    }

    if (mostActive != null && leastActive != null && mostActive != leastActive) {
      out.add(TrainingInsight(
        'trainingTeamActivityGap',
        args: {
          'most':  mostActive.toString(),
          'least': leastActive.toString(),
        },
      ));
    }

    if (mostPoss != null) {
      out.add(TrainingInsight(
        'trainingTeamConcentratedPossession',
        args: {'player': mostPoss.toString()},
      ));
    }

    if (out.isEmpty) {
      out.add(TrainingInsight('trainingTeamBalanced'));
    }

    return out;
  }

  List<TrainingInsight> buildPlayerRecommendations(
    Map<String, dynamic> player,
  ) {
    final recs     = <TrainingInsight>[];
    final km       = (player['distance_km']    as num?)?.toDouble() ?? 0;
    final speed    = (player['speed_ms']       as num?)?.toDouble() ?? 0;
    final poss     = (player['possession_pct'] as num?)?.toDouble() ?? 0;
    final presence = (player['presence_pct']   as num?)?.toDouble() ?? 0;
    final zone     = player['zone'] as String? ?? '';

    if (km < 0.5)       recs.add(TrainingInsight('trainingPlayerLowDistance'));
    if (speed < 1.5)    recs.add(TrainingInsight('trainingPlayerLowSpeed'));
    if (poss < 5)       recs.add(TrainingInsight('trainingPlayerLowPossession'));
    if (presence < 50)  recs.add(TrainingInsight('trainingPlayerLowPresence'));
    if (zone.contains('Defensa')) recs.add(TrainingInsight('trainingPlayerDefRole'));
    if (zone.contains('Ataque'))  recs.add(TrainingInsight('trainingPlayerAttRole'));
    if (recs.isEmpty)   recs.add(TrainingInsight('trainingPlayerSolid'));

    return recs;
  }

  // ── Fallback suggestions ──────────────────────────────────────────────────
  // Keys only — titles/reasons are resolved in the UI via l10n.
  static const kGenericSuggestions = <Map<String, dynamic>>[
    {
      'titleKey':    'trainingSugTitlePressing',
      'duration_minutes': 90,
      'category':    'Tactical',
      'reasonKey':   'trainingSugReasonPressing',
    },
    {
      'titleKey':    'trainingSugTitlePossession',
      'duration_minutes': 75,
      'category':    'Technical',
      'reasonKey':   'trainingSugReasonPossession',
    },
    {
      'titleKey':    'trainingSugTitlePhysical',
      'duration_minutes': 60,
      'category':    'Physical',
      'reasonKey':   'trainingSugReasonPhysical',
    },
  ];
}