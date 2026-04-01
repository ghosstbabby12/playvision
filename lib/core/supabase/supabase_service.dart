import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  final SupabaseClient client = Supabase.instance.client;

  // =========================
  // TEAMS
  // =========================

  Future<List<Map<String, dynamic>>> getTeams() async {
    final response = await client
        .from('teams')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getTeamById(int teamId) async {
    final response = await client
        .from('teams')
        .select()
        .eq('id', teamId)
        .limit(1);

    final list = List<Map<String, dynamic>>.from(response);
    if (list.isEmpty) return null;
    return list.first;
  }

  Future<void> createTeam({
    required String name,
    String? category,
    String? club,
    String? userId,
  }) async {
    await client.from('teams').insert({
      'name': name,
      'category': category,
      'club': club,
      if (userId != null) 'user_id': userId, 
    });
  }

  Future<void> updateTeam({
    required int id,
    required String name,
    String? category,
    String? club,
  }) async {
    await client.from('teams').update({
      'name': name,
      'category': category,
      'club': club,
    }).eq('id', id);
  }

  Future<void> deleteTeam(int id) async {
    await client.from('teams').delete().eq('id', id);
  }

  // =========================
  // PLAYERS
  // =========================

  Future<List<Map<String, dynamic>>> getPlayers() async {
    final response = await client
        .from('players')
        .select('*, teams(name)')
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
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getMatchesByTeam(int teamId) async {
    final response = await client
        .from('matches')
        .select('*, teams(name)')
        .eq('team_id', teamId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getMatchById(int matchId) async {
    final response = await client
        .from('matches')
        .select('*, teams(name)')
        .eq('id', matchId)
        .limit(1);

    final list = List<Map<String, dynamic>>.from(response);
    if (list.isEmpty) return null;
    return list.first;
  }

  Future<Map<String, dynamic>?> getLatestMatch() async {
    final response = await client
        .from('matches')
        .select('*, teams(name)')
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
    });
  }

  Future<void> updateMatchStatus({
    required int matchId,
    required String status,
  }) async {
    await client
        .from('matches')
        .update({'status': status})
        .eq('id', matchId);
  }

  Future<void> updateMatchVideoUrl({
    required int matchId,
    required String videoUrl,
  }) async {
    await client
        .from('matches')
        .update({'video_url': videoUrl})
        .eq('id', matchId);
  }

  // =========================
  // PLAYER MATCH STATS
  // =========================

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

  // =========================
  // RECOMMENDATIONS
  // =========================

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

  // =========================
  // PREDICTIONS
  // =========================

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
