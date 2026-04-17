import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  final SupabaseClient client = Supabase.instance.client;

  // Función interna para obtener el usuario actual de forma segura
  String get _currentUserId {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw Exception("Sesión no iniciada. Por favor haz login.");
    return userId;
  }

  // =========================
  // TEAMS
  // =========================

  Future<List<Map<String, dynamic>>> getTeams() async {
    final response = await client
        .from('teams')
        .select()
        .eq('user_id', _currentUserId) // Solo los equipos de este usuario
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getTeamById(int teamId) async {
    final response = await client
        .from('teams')
        .select()
        .eq('id', teamId)
        .eq('user_id', _currentUserId) // Medida extra de seguridad
        .limit(1);

    final list = List<Map<String, dynamic>>.from(response);
    if (list.isEmpty) return null;
    return list.first;
  }

  Future<String?> uploadTeamLogo({
    required int teamId,
    required Uint8List bytes,
    required String extension, 
  }) async {
    try {
      final path = '$_currentUserId/team_$teamId.$extension';
      await client.storage
          .from('team-logos')
          .uploadBinary(path, bytes,
              fileOptions: FileOptions(
                  contentType: 'image/$extension', upsert: true));
      return client.storage.from('team-logos').getPublicUrl(path);
    } catch (e) {
      debugPrint('Logo upload error: $e');
      return null;
    }
  }

  Future<void> createTeam({
    required String name,
    String? category,
    String? club,
    String? logoUrl,
  }) async {
    await client.from('teams').insert({
      'name': name,
      'category': category,
      'club': club,
      if (logoUrl != null) 'logo_url': logoUrl,
      'user_id': _currentUserId, // Guarda el dueño
    });
  }

  Future<void> updateTeam({
    required int id,
    required String name,
    String? category,
    String? club,
    String? logoUrl,
  }) async {
    await client.from('teams').update({
      'name': name,
      'category': category,
      'club': club,
      if (logoUrl != null) 'logo_url': logoUrl,
    }).eq('id', id).eq('user_id', _currentUserId);
  }

  Future<void> deleteTeam(int id) async {
    await client.from('teams').delete().eq('id', id).eq('user_id', _currentUserId);
  }

  // =========================
  // PLAYERS
  // =========================

  Future<List<Map<String, dynamic>>> getPlayers() async {
    // Al pedir todos los jugadores, cruzamos con la tabla teams para asegurar que el equipo sea del usuario actual
    final response = await client
        .from('players')
        .select('*, teams!inner(name, user_id)')
        .eq('teams.user_id', _currentUserId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getPlayersByTeam(int teamId) async {
    final response = await client
        .from('players')
        .select()
        .eq('team_id', teamId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> createPlayer({
    required int teamId,
    required String name,
    required String position,
    int? shirtNumber,
    String? status,
    String? birthDate,
  }) async {
    await client.from('players').insert({
      'team_id': teamId,
      'name': name,
      'position': position,
      'shirt_number': shirtNumber,
      'status': status ?? 'active',
      'birth_date': birthDate,
    });
  }

  // =========================
  // MATCHES
  // =========================

  Future<List<Map<String, dynamic>>> getMatches() async {
    final response = await client
        .from('matches')
        .select('*, teams(name)')
        .eq('user_id', _currentUserId) // Solo sus partidos
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getMatchesByTeam(int teamId) async {
    final response = await client
        .from('matches')
        .select('*, teams(name)')
        .eq('team_id', teamId)
        .eq('user_id', _currentUserId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getMatchById(int matchId) async {
    final response = await client
        .from('matches')
        .select('*, teams(name)')
        .eq('id', matchId)
        .eq('user_id', _currentUserId)
        .limit(1);

    final list = List<Map<String, dynamic>>.from(response);
    if (list.isEmpty) return null;
    return list.first;
  }

  Future<Map<String, dynamic>?> getLatestMatch() async {
    final response = await client
        .from('matches')
        .select('*, teams(name)')
        .eq('user_id', _currentUserId)
        .order('created_at', ascending: false)
        .limit(1);

    final list = List<Map<String, dynamic>>.from(response);
    if (list.isEmpty) return null;
    return list.first;
  }

  Future<void> createMatch({
    required int teamId,
    required String opponent,
    required DateTime matchDate,
    required String sourceType,
    String? videoUrl,
    double? latitude,
    double? longitude,
    String status = 'uploaded',
  }) async {
    await client.from('matches').insert({
      'team_id': teamId,
      'opponent': opponent,
      'match_date': matchDate.toIso8601String(),
      'source_type': sourceType,
      'video_url': videoUrl,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'user_id': _currentUserId, // Guarda el dueño
    });
  }

  Future<int> createMatchAndReturnId({
    required int teamId,
    required String opponent,
    required DateTime matchDate,
    required String sourceType,
    String? videoUrl,
    double? latitude,
    double? longitude,
    String status = 'processing',
  }) async {
    final response = await client.from('matches').insert({
      'team_id': teamId,
      'opponent': opponent,
      'match_date': matchDate.toIso8601String(),
      'source_type': sourceType,
      'video_url': videoUrl,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'user_id': _currentUserId, // Guarda el dueño
    }).select('id');

    final list = List<Map<String, dynamic>>.from(response);
    return list.first['id'] as int;
  }

  Future<void> updateMatchStatus({
    required int matchId,
    required String status,
  }) async {
    await client
        .from('matches')
        .update({'status': status})
        .eq('id', matchId)
        .eq('user_id', _currentUserId);
  }

  Future<void> updateMatchVideoUrl({
    required int matchId,
    required String videoUrl,
  }) async {
    await client
        .from('matches')
        .update({'video_url': videoUrl})
        .eq('id', matchId)
        .eq('user_id', _currentUserId);
  }

  // =========================
  // MATCH REPORTS & OTHERS
  // =========================

  Future<Map<String, dynamic>?> getMatchReport(int matchId) async {
    try {
      final response = await client
          .from('match_reports')
          .select('summary_json')
          .eq('match_id', matchId)
          .limit(1);

      final list = List<Map<String, dynamic>>.from(response);
      if (list.isEmpty) return null;
      return list.first['summary_json'] as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('Error al obtener reporte del partido: $e'); 
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getPlayerMatchStats(int matchId) async {
    final response = await client
        .from('player_match_stats')
        .select('*, players(name, position, shirt_number)')
        .eq('match_id', matchId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> createPlayerMatchStat({
    required int matchId,
    required int playerId,
    int minutes = 0,
    double distance = 0,
    int passesOk = 0,
    int passesBad = 0,
    int losses = 0,
    int recoveries = 0,
    int shots = 0,
    int shotsOnTarget = 0,
    double rating = 0,
  }) async {
    await client.from('player_match_stats').insert({
      'match_id': matchId,
      'player_id': playerId,
      'minutes': minutes,
      'distance': distance,
      'passes_ok': passesOk,
      'passes_bad': passesBad,
      'losses': losses,
      'recoveries': recoveries,
      'shots': shots,
      'shots_on_target': shotsOnTarget,
      'rating': rating,
    });
  }

  Future<void> savePlayerStatsBatch(List<Map<String, dynamic>> statsList) async {
    if (statsList.isEmpty) return;
    await client.from('player_match_stats').insert(statsList);
  }

  Future<List<Map<String, dynamic>>> getRecommendationsByMatch(int matchId) async {
    final response = await client
        .from('recommendations')
        .select()
        .eq('match_id', matchId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> createRecommendation({
    required int matchId,
    int? playerId,
    required String scope,
    required String title,
    required String description,
    String priority = 'media',
  }) async {
    await client.from('recommendations').insert({
      'match_id': matchId,
      'player_id': playerId,
      'scope': scope,
      'title': title,
      'description': description,
      'priority': priority,
    });
  }

  Future<List<Map<String, dynamic>>> getPredictionsByPlayer(int playerId) async {
    final response = await client
        .from('predictions')
        .select()
        .eq('player_id', playerId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> createPrediction({
    required int playerId,
    required int basedOnMatches,
    double? predictedRating,
    String? trend,
    String? nextMatchNotes,
  }) async {
    await client.from('predictions').insert({
      'player_id': playerId,
      'based_on_matches': basedOnMatches,
      'predicted_rating': predictedRating,
      'trend': trend,
      'next_match_notes': nextMatchNotes,
    });
  }
}