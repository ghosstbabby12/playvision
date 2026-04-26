import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:playvision/core/constants/app_constants.dart';

class LiveMatchesService {
  LiveMatchesService._();
  static final instance = LiveMatchesService._();

  // Timeouts diferenciados por endpoint
  static const _timeoutLive     = Duration(seconds: 8);
  static const _timeoutFeatured = Duration(seconds: 25);
  static const _timeoutSearch   = Duration(seconds: 12);

  static List<String> get _candidates => {
        AppConstants.apiBase,
        'http://10.0.2.2:8000',
        'http://127.0.0.1:8000',
      }.toList();

  // ── Live matches filtrados por ligas top ──────────────────────────────────
  Future<List<dynamic>> fetchLiveMatches() async {
    for (final base in _candidates) {
      try {
        final res = await http
            .get(Uri.parse('$base/api/live-matches'))
            .timeout(_timeoutLive);
        if (res.statusCode == 200) {
          final body = jsonDecode(res.body);
          final list = (body is Map)
              ? (body['data'] ?? body['response'] ?? body['matches'] ?? [])
              : body as List;
          debugPrint('[LiveMatchesService] ✓ live $base → ${(list as List).length}');
          return list;
        }
      } on TimeoutException {
        debugPrint('[LiveMatchesService] Timeout live: $base');
      } catch (e) {
        debugPrint('[LiveMatchesService] Error live: $base → $e');
      }
    }
    return [];
  }

  // ── Partidos destacados del día agrupados por competición ─────────────────
  Future<Map<String, List<dynamic>>> fetchFeaturedMatches() async {
    for (final base in _candidates) {
      try {
        final res = await http
            .get(Uri.parse('$base/api/featured-matches'))
            .timeout(_timeoutFeatured);   // ← 25s para dar tiempo al backend
        if (res.statusCode == 200) {
          final body = jsonDecode(res.body) as Map<String, dynamic>;
          final data = body['data'] as Map<String, dynamic>? ?? {};
          debugPrint('[LiveMatchesService] ✓ featured $base → ${data.keys.length} secciones');
          return data.map((k, v) => MapEntry(k, v as List));
        }
      } on TimeoutException {
        debugPrint('[LiveMatchesService] Timeout featured: $base');
      } catch (e) {
        debugPrint('[LiveMatchesService] Error featured: $base → $e');
      }
    }
    return {};
  }

  // ── Buscar equipo + últimos 5 partidos ────────────────────────────────────
  Future<Map<String, dynamic>?> searchTeam(String name) async {
    for (final base in _candidates) {
      try {
        final uri = Uri.parse('$base/api/team-search')
            .replace(queryParameters: {'name': name.trim()});
        final res = await http.get(uri).timeout(_timeoutSearch);
        if (res.statusCode == 200) {
          debugPrint('[LiveMatchesService] ✓ search $base → $name');
          return jsonDecode(res.body) as Map<String, dynamic>;
        }
      } on TimeoutException {
        debugPrint('[LiveMatchesService] Timeout search: $base');
      } catch (e) {
        debugPrint('[LiveMatchesService] Error search: $base → $e');
      }
    }
    return null;
  }
}