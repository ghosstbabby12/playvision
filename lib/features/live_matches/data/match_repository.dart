// lib/features/live_matches/data/match_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'match_model.dart';

class MatchRepository {
  // NOTA IMPORTANTE: 
  // Si usas el Emulador de Android, usa "http://10.0.2.2:8000/api/live-matches"
  // Si usas tu celular físico por USB/WiFi, usa la IP local de tu PC (ej. "http://192.168.1.X:8000/api/live-matches")
  // Si usas Windows/Web/iOS Simulator, usa "http://127.0.0.1:8000/api/live-matches"
  final String baseUrl = "http://10.0.2.2:8000/api/live-matches";

  Future<List<MatchModel>> getLiveMatches() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        final List data = decodedData['data']; // Accedemos a la llave 'data' que envía nuestro Python
        
        return data.map((json) => MatchModel.fromJson(json)).toList();
      } else {
        throw Exception('Error al conectar con el servidor');
      }
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }
}