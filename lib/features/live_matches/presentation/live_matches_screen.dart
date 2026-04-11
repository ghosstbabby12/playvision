// lib/features/live_matches/presentation/live_matches_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../data/match_repository.dart';
import '../data/match_model.dart';

class LiveMatchesScreen extends StatefulWidget {
  const LiveMatchesScreen({super.key});

  @override
  State<LiveMatchesScreen> createState() => _LiveMatchesScreenState();
}

class _LiveMatchesScreenState extends State<LiveMatchesScreen> {
  final MatchRepository _repository = MatchRepository();
  List<MatchModel> _matches = [];
  bool _isLoading = true;
  String _error = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchMatches(); // Carga inicial
    
    // Polling: Pide datos cada 60 segundos
    _timer = Timer.periodic(Duration(seconds: 60), (timer) {
      _fetchMatches();
    });
  }

  Future<void> _fetchMatches() async {
    try {
      final matches = await _repository.getLiveMatches();
      setState(() {
        _matches = matches;
        _isLoading = false;
        _error = '';
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel(); // Limpia el temporizador al salir de la pantalla
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('En Vivo 🔴'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchMatches(); // Botón manual por si el usuario no quiere esperar los 60 seg
            },
          )
        ],
      ),
      body: _isLoading 
          ? Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text('Hubo un error: $_error\n¿Está corriendo el servidor Python?'))
              : _matches.isEmpty 
                  ? Center(child: Text('No hay partidos en vivo en este momento.'))
                  : ListView.builder(
                      itemCount: _matches.length,
                      itemBuilder: (context, index) {
                        final match = _matches[index];
                        return Card(
                          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Equipo Local
                                Column(
                                  children: [
                                    if (match.homeLogo.isNotEmpty)
                                      Image.network(match.homeLogo, width: 40, height: 40,
                                          errorBuilder: (_, __, ___) => const SizedBox(width: 40, height: 40)),
                                    SizedBox(height: 8),
                                    Text(match.homeTeam, style: TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                // Marcador y Minuto
                                Column(
                                  children: [
                                    Text(
                                      '${match.homeGoals} - ${match.awayGoals}',
                                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                    ),
                                    Text('${match.elapsed}\'', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                                // Equipo Visitante
                                Column(
                                  children: [
                                    if (match.awayLogo.isNotEmpty)
                                      Image.network(match.awayLogo, width: 40, height: 40,
                                          errorBuilder: (_, __, ___) => const SizedBox(width: 40, height: 40)),
                                    SizedBox(height: 8),
                                    Text(match.awayTeam, style: TextStyle(fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}