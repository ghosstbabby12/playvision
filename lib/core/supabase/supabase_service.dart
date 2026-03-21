import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
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
  }) async {
    await client.from('teams').insert({
      'name': name,
      'category': category,
      'club': club,
    });
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

  Future<List<Map<String, dynamic>>> getMatchesWithoutVideo() async {
    final response = await client
        .from('matches')
        .select('*, teams(name)')
        .order('created_at', ascending: false);

    final list = List<Map<String, dynamic>>.from(response);

    return list.where((match) {
      final videoUrl = match['video_url'];
      return videoUrl == null || videoUrl.toString().trim().isEmpty;
    }).toList();
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
    await client.from('matches').update({
      'status': status,
    }).eq('id', matchId);
  }

  Future<void> updateMatchVideoUrl({
    required int matchId,
    required String videoUrl,
  }) async {
    await client.from('matches').update({
      'video_url': videoUrl,
    }).eq('id', matchId);
  }

  Future<void> updateMatchVideoSource({
    required int matchId,
    required String sourceType,
    required String videoUrl,
    String status = 'processing',
  }) async {
    await client.from('matches').update({
      'source_type': sourceType,
      'video_url': videoUrl,
      'status': status,
    }).eq('id', matchId);
  }

  Future<String> uploadShortMatchVideoBytes({
    required int matchId,
    required Uint8List bytes,
    required String originalFileName,
  }) async {
    final cleanName = originalFileName.replaceAll(' ', '_');
    final filePath =
        'matches/match_${matchId}_${DateTime.now().millisecondsSinceEpoch}_$cleanName';

    await client.storage.from('match-videos').uploadBinary(
          filePath,
          bytes,
          fileOptions: const FileOptions(
            upsert: false,
            contentType: 'video/mp4',
          ),
        );

    final publicUrl = client.storage.from('match-videos').getPublicUrl(filePath);

    await client.from('matches').update({
      'source_type': 'upload',
      'video_url': publicUrl,
      'status': 'processing',
    }).eq('id', matchId);

    return publicUrl;
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

  Future<List<Map<String, dynamic>>> getRecommendationsByMatch(
    int matchId,
  ) async {
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

  Future<List<Map<String, dynamic>>> getPredictionsByPlayer(
    int playerId,
  ) async {
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

  // =========================
  // FAKE ANALYSIS
  // =========================

  Future<void> insertFakeAnalysisForMatch(int matchId) async {
    await updateMatchStatus(
      matchId: matchId,
      status: 'processing',
    );

    final matchResponse = await client
        .from('matches')
        .select()
        .eq('id', matchId)
        .limit(1);

    final matchList = List<Map<String, dynamic>>.from(matchResponse);

    if (matchList.isEmpty) {
      throw Exception('No se encontró el partido');
    }

    final match = matchList.first;
    final teamId = match['team_id'];

    if (teamId == null) {
      throw Exception('El partido no tiene team_id');
    }

    final existingStats = await client
        .from('player_match_stats')
        .select()
        .eq('match_id', matchId);

    final existingRecommendations = await client
        .from('recommendations')
        .select()
        .eq('match_id', matchId);

    if ((existingStats as List).isNotEmpty ||
        (existingRecommendations as List).isNotEmpty) {
      await updateMatchStatus(
        matchId: matchId,
        status: 'done',
      );
      throw Exception(
        'Ese partido ya tiene estadísticas o recomendaciones guardadas',
      );
    }

    final playersResponse = await client
        .from('players')
        .select()
        .eq('team_id', teamId)
        .order('created_at', ascending: true);

    final players = List<Map<String, dynamic>>.from(playersResponse);

    if (players.isEmpty) {
      await updateMatchStatus(
        matchId: matchId,
        status: 'uploaded',
      );
      throw Exception('No hay jugadores para el equipo de este partido');
    }

    final selectedPlayers = players.take(3).toList();

    final List<Map<String, dynamic>> statsRows = [];

    if (selectedPlayers.isNotEmpty) {
      statsRows.add({
        'match_id': matchId,
        'player_id': selectedPlayers[0]['id'],
        'minutes': 90,
        'distance': 10.8,
        'passes_ok': 42,
        'passes_bad': 8,
        'losses': 6,
        'recoveries': 9,
        'shots': 3,
        'shots_on_target': 2,
        'rating': 8.1,
      });
    }

    if (selectedPlayers.length > 1) {
      statsRows.add({
        'match_id': matchId,
        'player_id': selectedPlayers[1]['id'],
        'minutes': 84,
        'distance': 9.4,
        'passes_ok': 31,
        'passes_bad': 11,
        'losses': 10,
        'recoveries': 7,
        'shots': 2,
        'shots_on_target': 1,
        'rating': 7.3,
      });
    }

    if (selectedPlayers.length > 2) {
      statsRows.add({
        'match_id': matchId,
        'player_id': selectedPlayers[2]['id'],
        'minutes': 76,
        'distance': 8.7,
        'passes_ok': 25,
        'passes_bad': 6,
        'losses': 4,
        'recoveries': 11,
        'shots': 1,
        'shots_on_target': 1,
        'rating': 7.8,
      });
    }

    if (statsRows.isNotEmpty) {
      await client.from('player_match_stats').insert(statsRows);
    }

    final List<Map<String, dynamic>> recommendationRows = [
      {
        'match_id': matchId,
        'player_id': selectedPlayers.first['id'],
        'scope': 'individual',
        'title': 'Mejorar precisión de pase bajo presión',
        'description':
            'Trabajar rondos reducidos y salidas con marca cercana para reducir errores en el primer pase.',
        'priority': 'alta',
      },
      {
        'match_id': matchId,
        'player_id':
            selectedPlayers.length > 1 ? selectedPlayers[1]['id'] : null,
        'scope': 'individual',
        'title': 'Aumentar finalización en zona 14',
        'description':
            'Añadir sesiones de remate tras control orientado y definición rápida con perfil dominante.',
        'priority': 'media',
      },
      {
        'match_id': matchId,
        'player_id': null,
        'scope': 'team',
        'title': 'Ajustar bloque medio tras pérdida',
        'description':
            'El equipo tarda en replegar tras pérdida en carriles interiores; conviene entrenar transición defensiva con superioridad rival.',
        'priority': 'alta',
      },
    ];

    await client.from('recommendations').insert(recommendationRows);

    await updateMatchStatus(
      matchId: matchId,
      status: 'done',
    );
  }
}
