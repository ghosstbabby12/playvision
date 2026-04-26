import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:playvision/core/constants/app_constants.dart';

class LiveMatchesService {
  LiveMatchesService._();
  static final instance = LiveMatchesService._();

  static const _timeout = Duration(seconds: 8);

  static List<String> get _candidates => [
        AppConstants.apiBase,
        'http://10.0.2.2:8000',
        'http://127.0.0.1:8000',
      ].toSet().toList();

  Future<List<dynamic>> fetchLiveMatches() async {
    for (final base in _candidates) {
      try {
        final uri = Uri.parse('$base/api/live-matches');
        final res = await http.get(uri).timeout(_timeout);
        if (res.statusCode == 200) {
          final body = jsonDecode(res.body);
          final list = (body is Map)
              ? (body['data'] ?? body['response'] ?? body['matches'] ?? [])
              : body as List;
          debugPrint('[LiveMatchesService] ✓ $base → ${(list as List).length} partidos');
          return list;
        }
      } on TimeoutException {
        debugPrint('[LiveMatchesService] Timeout: $base');
      } catch (e) {
        debugPrint('[LiveMatchesService] Error: $base → $e');
      }
    }
    debugPrint('[LiveMatchesService] Todos fallaron → []');
    return [];
  }
}