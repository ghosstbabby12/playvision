import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:playvision/core/constants/app_constants.dart';
import '../domain/player_profile.dart';

class PlayerProfileService {
  PlayerProfileService._();
  static final instance = PlayerProfileService._();

  Future<PlayerProfile?> fetch(int playerId) async {
    try {
      final res = await http
          .get(Uri.parse('${AppConstants.apiBase}/api/player/$playerId'))
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        return PlayerProfile.fromJson(
            jsonDecode(res.body) as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }
}
