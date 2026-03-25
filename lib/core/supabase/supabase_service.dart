import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService();

  final SupabaseClient client = Supabase.instance.client;

  static const String _teamsTable = 'teams';
  static const String _playersTable = 'players';
  static const String _matchesTable = 'matches';
  static const String _playerMatchStatsTable = 'player_match_stats';
  static const String _recommendationsTable = 'recommendations';
  static const String _predictionsTable = 'predictions';
  static const String _matchVideosBucket = 'match-videos';

  static const String statusUploaded = 'uploaded';
  static const String statusProcessing = 'processing';
  static const String statusDone = 'done';

  List<Map<String, dynamic>> _asMapList(dynamic response) {
    return List<Map<String, dynamic>>.from(response as List);
  }

  Map<String, dynamic>? _firstOrNull(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) return null;
    return rows.first;
  }

  String _sanitizeFileName(String value) {
    return value
        .trim()
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '');
  }

  // =========================
  // TEAMS
  // =========================

  Future<List<Map<String, dynamic>>> getTeams() async {
    final response = await client
        .from(_teamsTable)
        .select()
        .order('created_at', ascending: false);

    return _asMapList(response);
  }

  Future<Map<String, dynamic>?> getTeamById(int teamId) async {
    final response = await client
        .from(_teamsTable)
        .select()
        .eq('id', teamId)
        .limit(1);

    final rows = _asMapList(response);
    return _firstOrNull(rows);
  }

  Future<void> createTeam({
    required String name,
    String? category,
    String? club,
  }) async {
    await client.from(_teamsTable).insert({
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
        .from(_playersTable)
        .select('*, teams(name)')
        .order('created_at', ascending: false);

    return _asMapList(response);
  }

  Future<List<Map<String, dynamic>>> getPlayersByTeam(int teamId) async {
    final response = await client
        .from(_playersTable)
        .select()
        .eq('team_id', teamId)
        .order('created_at', ascending: false);

    return _asMapList(response);
  }

  Future<void> createPlayer({
    required int teamId,
    required String name,
    required String position,
    int? shirtNumber,
    String? status,
    String? birthDate,
  }) async {
    await client.from(_playersTable).insert({
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
        .from(_matchesTable)
        .select('*, teams(name)')
        .order('created_at', ascending: false);

    return _asMapList(response);
  }

  Future<List<Map<String, dynamic>>> getMatchesByTeam(int teamId) async {
    final response = await client
        .from(_matchesTable)
        .select('*, teams(name)')
        .eq('team_id', teamId)
        .order('created_at', ascending: false);

    return _asMapList(response);
  }

  Future<List<Map<String, dynamic>>> getMatchesWithoutVideo() async {
    final response = await client
        .from(_matchesTable)
        .select('*, teams(name)')
        .order('created_at', ascending: false);

    final rows = _asMapList(response);

    return rows.where((match) {
      final videoUrl = (match['video_url'] ?? '').toString().trim();
      final sourceUrl = (match['source_url'] ?? '').toString().trim();
      return videoUrl.isEmpty && sourceUrl.isEmpty;
    }).toList();
  }

  Future<Map<String, dynamic>?> getMatchById(int matchId) async {
    final response = await client
        .from(_matchesTable)
        .select('*, teams(name)')
        .eq('id', matchId)
        .limit(1);

    final rows = _asMapList(response);
    return _firstOrNull(rows);
  }

  Future<Map<String, dynamic>?> getLatestMatch() async {
    final response = await client
        .from(_matchesTable)
        .select('*, teams(name)')
        .order('created_at', ascending: false)
        .limit(1);

    final rows = _asMapList(response);
    return _firstOrNull(rows);
  }

  Future<void> createMatch({
    required int teamId,
    required String opponent,
    required DateTime matchDate,
    required String sourceType,
    String? videoUrl,
    String? sourceUrl,
    double? latitude,
    double? longitude,
    String status = statusUploaded,
  }) async {
    await client.from(_matchesTable).insert({
      'team_id': teamId,
      'opponent': opponent,
      'match_date': matchDate.toIso8601String(),
      'source_type': sourceType,
      'video_url': videoUrl,
      'source_url': sourceUrl,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
    });
  }

  Future<void> updateMatchStatus({
    required int matchId,
    required String status,
  }) async {
    await client.from(_matchesTable).update({
      'status': status,
    }).eq('id', matchId);
  }

  Future<void> updateMatchVideoUrl({
    required int matchId,
    String? videoUrl,
  }) async {
    await client.from(_matchesTable).update({
      'video_url': videoUrl,
    }).eq('id', matchId);
  }

  Future<void> updateMatchSourceUrl({
    required int matchId,
    String? sourceUrl,
  }) async {
    await client.from(_matchesTable).update({
      'source_url': sourceUrl,
    }).eq('id', matchId);
  }

  Future<void> updateMatchVideoSource({
    required int matchId,
    required String sourceType,
    String? videoUrl,
    String? sourceUrl,
    String status = statusProcessing,
  }) async {
    await client.from(_matchesTable).update({
      'source_type': sourceType,
      'video_url': videoUrl,
      'source_url': sourceUrl,
      'status': status,
    }).eq('id', matchId);
  }

  Future<String> uploadShortMatchVideoBytes({
    required int matchId,
    required Uint8List bytes,
    required String originalFileName,
  }) async {
    final safeName = _sanitizeFileName(originalFileName);
    final filePath =
        'matches/match_${matchId}_${DateTime.now().millisecondsSinceEpoch}_$safeName';

    await client.storage.from(_matchVideosBucket).uploadBinary(
      filePath,
      bytes,
      fileOptions: const FileOptions(
        upsert: false,
        contentType: 'video/mp4',
      ),
    );

    final publicUrl =
        client.storage.from(_matchVideosBucket).getPublicUrl(filePath);

    await client.from(_matchesTable).update({
      'source_type': 'upload',
      'video_url': publicUrl,
      'source_url': null,
      'status': statusProcessing,
    }).eq('id', matchId);

    return publicUrl;
  }

  // =========================
  // PLAYER MATCH STATS
  // =========================

  Future<List<Map<String, dynamic>>> getPlayerMatchStats(int matchId) async {
    final response = await client
        .from(_playerMatchStatsTable)
        .select('*, players(name, position, shirt_number)')
        .eq('match_id', matchId)
        .order('created_at', ascending: false);

    return _asMapList(response);
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
    await client.from(_playerMatchStatsTable).insert({
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
        .from(_recommendationsTable)
        .select()
        .eq('match_id', matchId)
        .order('created_at', ascending: false);

    return _asMapList(response);
  }

  Future<void> createRecommendation({
    required int matchId,
    int? playerId,
    required String scope,
    required String title,
    required String description,
    String priority = 'media',
  }) async {
    await client.from(_recommendationsTable).insert({
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
        .from(_predictionsTable)
        .select()
        .eq('player_id', playerId)
        .order('created_at', ascending: false);

    return _asMapList(response);
  }

  Future<void> createPrediction({
    required int playerId,
    required int basedOnMatches,
    double? predictedRating,
    String? trend,
    String? nextMatchNotes,
  }) async {
    await client.from(_predictionsTable).insert({
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
      status: statusProcessing,
    );

    final matchResponse = await client
        .from(_matchesTable)
        .select()
        .eq('id', matchId)
        .limit(1);

    final matchRows = _asMapList(matchResponse);

    if (matchRows.isEmpty) {
      throw Exception('No se encontró el partido');
    }

    final currentMatch = matchRows.first;
    final teamId = currentMatch['team_id'];

    if (teamId == null) {
      throw Exception('El partido no tiene team_id');
    }

    final existingStatsResponse = await client
        .from(_playerMatchStatsTable)
        .select()
        .eq('match_id', matchId);

    final existingRecommendationsResponse = await client
        .from(_recommendationsTable)
        .select()
        .eq('match_id', matchId);

    final existingStats = _asMapList(existingStatsResponse);
    final existingRecommendations = _asMapList(existingRecommendationsResponse);

    if (existingStats.isNotEmpty || existingRecommendations.isNotEmpty) {
      await updateMatchStatus(
        matchId: matchId,
        status: statusDone,
      );
      throw Exception(
        'Ese partido ya tiene estadísticas o recomendaciones guardadas',
      );
    }

    final playersResponse = await client
        .from(_playersTable)
        .select()
        .eq('team_id', teamId)
        .order('created_at', ascending: true);

    final players = _asMapList(playersResponse);

    if (players.isEmpty) {
      await updateMatchStatus(
        matchId: matchId,
        status: statusUploaded,
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
      await client.from(_playerMatchStatsTable).insert(statsRows);
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

    await client.from(_recommendationsTable).insert(recommendationRows);

    await updateMatchStatus(
      matchId: matchId,
      status: statusDone,
    );
  }
}
