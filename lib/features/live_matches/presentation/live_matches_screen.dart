import 'dart:async';
import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart'; // IMPORTANTE
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
    _fetchMatches();
    _timer = Timer.periodic(const Duration(seconds: 60), (_) => _fetchMatches());
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
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.liveTitle),
        actions: [
          IconButton(
            tooltip: l10n.liveRefreshTooltip,
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchMatches();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(l10n.liveLoadError(_error)))
              : _matches.isEmpty
                  ? Center(child: Text(l10n.liveNoMatches))
                  : ListView.builder(
                      itemCount: _matches.length,
                      itemBuilder: (context, index) {
                        final match = _matches[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Equipo Local
                                Column(children: [
                                  if (match.homeLogo.isNotEmpty)
                                    Image.network(
                                      match.homeLogo,
                                      width: 40, height: 40,
                                      errorBuilder: (_, __, ___) =>
                                          const SizedBox(width: 40, height: 40),
                                    ),
                                  const SizedBox(height: 8),
                                  Text(match.homeTeam,
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                ]),
                                // Marcador y Minuto
                                Column(children: [
                                  Text(
                                    '${match.homeGoals} - ${match.awayGoals}',
                                    style: const TextStyle(
                                        fontSize: 24, fontWeight: FontWeight.bold),
                                  ),
                                  Text("${match.elapsed}'",
                                      style: const TextStyle(color: Colors.red)),
                                ]),
                                // Equipo Visitante
                                Column(children: [
                                  if (match.awayLogo.isNotEmpty)
                                    Image.network(
                                      match.awayLogo,
                                      width: 40, height: 40,
                                      errorBuilder: (_, __, ___) =>
                                          const SizedBox(width: 40, height: 40),
                                    ),
                                  const SizedBox(height: 8),
                                  Text(match.awayTeam,
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                ]),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}