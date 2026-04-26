import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:playvision/core/constants/app_constants.dart';
import 'package:playvision/features/analysis/domain/player_profile.dart';

class PlayerService {
  PlayerService._();
  static final instance = PlayerService._();

  Future<PlayerProfile> getProfile(int trackId) async {
    final uri = Uri.parse('${AppConstants.apiBase}/api/player/$trackId');
    final res  = await http.get(uri).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) throw Exception('Player not found');
    return PlayerProfile.fromJson(jsonDecode(res.body));
  }

  Future<Map<String, dynamic>> compareTwo(int matchId, int rankA, int rankB) async {
    final uri = Uri.parse(
      '${AppConstants.apiBase}/api/compare/$matchId?rank_a=$rankA&rank_b=$rankB',
    );
    final res = await http.get(uri).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) throw Exception('Compare failed');
    return jsonDecode(res.body);
  }
}
