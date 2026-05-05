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

  // ── Live matches filtrados por ligas top ──────────────────────────────────
  Future<List<dynamic>> fetchLiveMatches() async {
    try {
      final res = await http
          .get(Uri.parse('${AppConstants.apiBase}/api/live-matches'))
          .timeout(_timeoutLive);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final list = (body is Map)
            ? (body['data'] ?? body['response'] ?? body['matches'] ?? [])
            : body as List;
        debugPrint('[LiveMatchesService] ✓ live → ${(list as List).length}');
        return list;
      }
    } on TimeoutException {
      debugPrint('[LiveMatchesService] Timeout live en Railway');
    } catch (e) {
      debugPrint('[LiveMatchesService] Error live: $e');
    }
    return [];
  }

  // ── Partidos destacados del día agrupados por competición ─────────────────
  Future<Map<String, List<dynamic>>> fetchFeaturedMatches() async {
    try {
      final res = await http
          .get(Uri.parse('${AppConstants.apiBase}/api/featured-matches'))
          .timeout(_timeoutFeatured);   // ← 25s para dar tiempo al backend
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final data = body['data'] as Map<String, dynamic>? ?? {};
        debugPrint('[LiveMatchesService] ✓ featured → ${data.keys.length} secciones');
        return data.map((k, v) => MapEntry(k, v as List));
      }
    } on TimeoutException {
      debugPrint('[LiveMatchesService] Timeout featured en Railway');
    } catch (e) {
      debugPrint('[LiveMatchesService] Error featured: $e');
    }
    return {};
  }

  // ── Buscar equipo + últimos 5 partidos ────────────────────────────────────
  Future<Map<String, dynamic>?> searchTeam(String name) async {
    try {
      final uri = Uri.parse('${AppConstants.apiBase}/api/team-search')
          .replace(queryParameters: {'name': name.trim()});
      final res = await http.get(uri).timeout(_timeoutSearch);
      if (res.statusCode == 200) {
        debugPrint('[LiveMatchesService] ✓ search → $name');
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } on TimeoutException {
      debugPrint('[LiveMatchesService] Timeout search en Railway');
    } catch (e) {
      debugPrint('[LiveMatchesService] Error search: $e');
    }
    return null;
  }
}