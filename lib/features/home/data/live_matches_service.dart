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
          .timeout(_timeoutFeatured);
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);

        // Caso 1: body['data'] es un Map de competiciones → formato ideal
        if (body is Map<String, dynamic>) {
          final inner = body['data'];

          if (inner is Map<String, dynamic>) {
            debugPrint('[LiveMatchesService] ✓ featured → ${inner.keys.length} secciones');
            return inner.map((k, v) => MapEntry(k, v as List<dynamic>));
          }

          // Caso 2: body['data'] es una List plana
          if (inner is List) {
            debugPrint('[LiveMatchesService] ✓ featured → ${inner.length} partidos (lista plana)');
            return {'Featured': inner};
          }

          // Caso 3: el propio body es el Map de competiciones (sin wrapper 'data')
          final firstValue = body.values.isNotEmpty ? body.values.first : null;
          if (firstValue is List) {
            debugPrint('[LiveMatchesService] ✓ featured → ${body.keys.length} secciones (sin wrapper)');
            return body.map((k, v) => MapEntry(k, v as List<dynamic>));
          }
        }

        // Caso 4: el body es directamente una List
        if (body is List) {
          debugPrint('[LiveMatchesService] ✓ featured → ${body.length} partidos (root list)');
          return {'Featured': body};
        }
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