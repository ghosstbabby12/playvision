import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:playvision/features/matches/domain/models/match_summary_model.dart';

class MatchSummaryPage extends StatefulWidget {
  const MatchSummaryPage({super.key});

  @override
  State<MatchSummaryPage> createState() => _MatchSummaryPageState();
}

class _MatchSummaryPageState extends State<MatchSummaryPage> {
  late Future<MatchSummary> _future;

  static const Color _background = Color(0xFF0B1020);
  static const Color _surface = Color(0xFF121832);
  static const Color _card = Color(0xFF1B2142);
  static const Color _border = Color(0xFF2A3366);

  static const Color _primary = Color(0xFF6C3BFF);
  static const Color _secondary = Color(0xFF9D4EDD);
  static const Color _accent = Color(0xFF2F6BFF);

  static const Color _green = Color(0xFF22C55E);
  static const Color _red = Color(0xFFEF4444);
  static const Color _warning = Color(0xFFF59E0B);
  static const Color _muted = Color(0xFF7C86B2);
  static const Color _textPrimary = Colors.white;
  static const Color _textSecondary = Color(0xFFAAB3D1);

  @override
  void initState() {
    super.initState();
    _future = _loadSummary();
  }

  Future<MatchSummary> _loadSummary() async {
    final jsonString =
        await rootBundle.loadString('assets/analysis/match_summary.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    return MatchSummary.fromJson(jsonMap);
  }

  Future<void> _reload() async {
    setState(() {
      _future = _loadSummary();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _surface,
        centerTitle: true,
        title: const Text(
          'RESUMEN DEL PARTIDO',
          style: TextStyle(
            color: _textPrimary,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded, color: _accent),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(
            height: 3,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_primary, _secondary, _accent],
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<MatchSummary>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _primary),
            );
          }

          if (snapshot.hasError) {
            return _ErrorState(
              message: 'Error cargando resumen: ${snapshot.error}',
              onRetry: _reload,
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmptySummary) {
            return const _EmptyState(
              message: 'No hay datos disponibles',
            );
          }

          final summary = snapshot.data!;
          final stats = summary.stats;

          return RefreshIndicator(
            color: _primary,
            backgroundColor: _card,
            onRefresh: _reload,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                _HeroCard(summary: summary),
                const SizedBox(height: 20),

                const _SectionTitle('ESTADÍSTICAS'),
                const SizedBox(height: 10),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.22,
                  children: [
                    _StatCard(
                      title: 'Jugadores detectados',
                      value: '${stats.totalPlayersDetected}',
                      color: _accent,
                      icon: Icons.groups_rounded,
                    ),
                    _StatCard(
                      title: 'Jugadores estables',
                      value: '${stats.stablePlayersDetected}',
                      color: _primary,
                      icon: Icons.verified_rounded,
                    ),
                    _StatCard(
                      title: 'Equipo verde',
                      value: '${stats.greenTeamStablePlayers}',
                      color: _green,
                      icon: Icons.shield_rounded,
                    ),
                    _StatCard(
                      title: 'Equipo rojo',
                      value: '${stats.redTeamStablePlayers}',
                      color: _red,
                      icon: Icons.shield_rounded,
                    ),
                    _StatCard(
                      title: 'Sin clasificar',
                      value: '${stats.unknownStablePlayers}',
                      color: _warning,
                      icon: Icons.help_outline_rounded,
                    ),
                    _StatCard(
                      title: 'Frames analizados',
                      value: '${stats.framesWithCounts}',
                      color: _secondary,
                      icon: Icons.movie_creation_outlined,
                    ),
                    _StatCard(
                      title: 'Máx. visibles',
                      value: '${stats.maxTotalVisible}',
                      color: Colors.deepPurpleAccent,
                      icon: Icons.visibility_rounded,
                    ),
                    _StatCard(
                      title: 'Promedio visible',
                      value: stats.avgTotalVisible.toStringAsFixed(2),
                      color: Colors.cyan,
                      icon: Icons.analytics_rounded,
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const _SectionTitle('PROMEDIOS POR EQUIPO'),
                const SizedBox(height: 10),
                _AverageVisibilityCard(stats: stats),

                const SizedBox(height: 20),
                const _SectionTitle('FUENTES'),
                const SizedBox(height: 10),
                _SourceCard(summary: summary),

                const SizedBox(height: 20),
                const _SectionTitle('EQUIPO VERDE'),
                const SizedBox(height: 10),
                if (summary.teams.greenTeam.isEmpty)
                  const _EmptyTeamMessage('No hay jugadores verdes')
                else
                  ...summary.teams.greenTeam.map(
                    (player) => _PlayerCard(
                      player: player,
                      color: _green,
                    ),
                  ),

                const SizedBox(height: 20),
                const _SectionTitle('EQUIPO ROJO'),
                const SizedBox(height: 10),
                if (summary.teams.redTeam.isEmpty)
                  const _EmptyTeamMessage('No hay jugadores rojos')
                else
                  ...summary.teams.redTeam.map(
                    (player) => _PlayerCard(
                      player: player,
                      color: _red,
                    ),
                  ),

                const SizedBox(height: 20),
                const _SectionTitle('SIN CLASIFICAR'),
                const SizedBox(height: 10),
                if (summary.teams.unknown.isEmpty)
                  const _EmptyTeamMessage('No hay jugadores sin clasificar')
                else
                  ...summary.teams.unknown.map(
                    (player) => _PlayerCard(
                      player: player,
                      color: Colors.grey,
                    ),
                  ),

                const SizedBox(height: 20),
                const _SectionTitle('FRAMES'),
                const SizedBox(height: 10),
                _FrameCountPreview(frameCounts: summary.frameCounts),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final MatchSummary summary;

  const _HeroCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final stats = summary.stats;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _MatchSummaryPageState._surface,
            _MatchSummaryPageState._card,
            Color(0xFF24195A),
          ],
        ),
        border: Border.all(color: _MatchSummaryPageState._border),
        boxShadow: [
          BoxShadow(
            color: _MatchSummaryPageState._primary.withOpacity(0.10),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [
                  _MatchSummaryPageState._primary,
                  _MatchSummaryPageState._accent,
                ],
              ),
            ),
            child: const Icon(
              Icons.sports_soccer_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resumen analítico',
                  style: TextStyle(
                    color: _MatchSummaryPageState._textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Estables: ${stats.stablePlayersDetected} · '
                  'Inestables: ${stats.unstablePlayersDetected} · '
                  'Frames: ${stats.framesWithCounts}',
                  style: const TextStyle(
                    color: _MatchSummaryPageState._textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AverageVisibilityCard extends StatelessWidget {
  final MatchStats stats;

  const _AverageVisibilityCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _MatchSummaryPageState._card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _MatchSummaryPageState._border),
      ),
      child: Column(
        children: [
          _MiniProgressRow(
            label: 'Verde',
            value: stats.avgGreenVisible,
            max: stats.maxTotalVisible.toDouble(),
            color: _MatchSummaryPageState._green,
          ),
          const SizedBox(height: 12),
          _MiniProgressRow(
            label: 'Rojo',
            value: stats.avgRedVisible,
            max: stats.maxTotalVisible.toDouble(),
            color: _MatchSummaryPageState._red,
          ),
          const SizedBox(height: 12),
          _MiniProgressRow(
            label: 'Desconocido',
            value: stats.avgUnknownVisible,
            max: stats.maxTotalVisible.toDouble(),
            color: _MatchSummaryPageState._warning,
          ),
        ],
      ),
    );
  }
}

class _MiniProgressRow extends StatelessWidget {
  final String label;
  final double value;
  final double max;
  final Color color;

  const _MiniProgressRow({
    required this.label,
    required this.value,
    required this.max,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = max <= 0 ? 0.0 : (value / max).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: _MatchSummaryPageState._textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              value.toStringAsFixed(2),
              style: const TextStyle(
                color: _MatchSummaryPageState._textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: _MatchSummaryPageState._surface.withOpacity(0.90),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _SourceCard extends StatelessWidget {
  final MatchSummary summary;

  const _SourceCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final source = summary.source;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _MatchSummaryPageState._card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _MatchSummaryPageState._border),
      ),
      child: Column(
        children: [
          _InfoRow(
            label: 'player_summary_csv',
            value: source.playerSummaryCsv.isEmpty
                ? 'No disponible'
                : source.playerSummaryCsv,
          ),
          const SizedBox(height: 10),
          _InfoRow(
            label: 'team_counts_csv',
            value: source.teamCountsCsv.isEmpty
                ? 'No disponible'
                : source.teamCountsCsv,
          ),
          const SizedBox(height: 10),
          _InfoRow(
            label: 'team_summary_csv',
            value: source.teamSummaryCsv.isEmpty
                ? 'No disponible'
                : source.teamSummaryCsv,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: const TextStyle(
              color: _MatchSummaryPageState._muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 6,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: _MatchSummaryPageState._textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _MatchSummaryPageState._card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _MatchSummaryPageState._border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(0.18),
            child: Icon(icon, color: color, size: 18),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: _MatchSummaryPageState._textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: _MatchSummaryPageState._textSecondary,
              fontSize: 12,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  final PlayerSummary player;
  final Color color;

  const _PlayerCard({
    required this.player,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _MatchSummaryPageState._card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _MatchSummaryPageState._border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withOpacity(0.20),
                child: Text(
                  '${player.trackId}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Jugador ID ${player.trackId}',
                  style: const TextStyle(
                    color: _MatchSummaryPageState._textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  player.teamLabel,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _PlayerMetricRow(
            label: 'Frames detectados',
            value: '${player.framesDetected}',
          ),
          _PlayerMetricRow(
            label: 'Máx. frames seguidos',
            value: '${player.maxFramesSeen}',
          ),
          _PlayerMetricRow(
            label: 'Rango visible',
            value: '${player.visibleSpanFrames}',
          ),
          _PlayerMetricRow(
            label: 'Confianza promedio',
            value: player.avgConf.toStringAsFixed(2),
          ),
          _PlayerMetricRow(
            label: 'Score color promedio',
            value: player.avgColorScore.toStringAsFixed(2),
          ),
          _PlayerMetricRow(
            label: 'Votos verdes',
            value: '${player.greenVotes}',
          ),
          _PlayerMetricRow(
            label: 'Votos rojos',
            value: '${player.redVotes}',
          ),
          _PlayerMetricRow(
            label: 'Votos unknown',
            value: '${player.unknownVotes}',
          ),
          _PlayerMetricRow(
            label: 'Votos totales',
            value: '${player.totalVotes}',
          ),
          _PlayerMetricRow(
            label: 'Jugador estable',
            value: player.stablePlayer ? 'Sí' : 'No',
          ),
          _PlayerMetricRow(
            label: 'Caja promedio',
            value:
                '(${player.avgBox.x1}, ${player.avgBox.y1}) - (${player.avgBox.x2}, ${player.avgBox.y2})',
          ),
        ],
      ),
    );
  }
}

class _PlayerMetricRow extends StatelessWidget {
  final String label;
  final String value;

  const _PlayerMetricRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: const TextStyle(
                color: _MatchSummaryPageState._muted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: _MatchSummaryPageState._textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FrameCountPreview extends StatelessWidget {
  final List<FrameCount> frameCounts;

  const _FrameCountPreview({required this.frameCounts});

  @override
  Widget build(BuildContext context) {
    if (frameCounts.isEmpty) {
      return const _EmptyTeamMessage('No hay datos de frames');
    }

    final preview = frameCounts.take(8).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _MatchSummaryPageState._card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _MatchSummaryPageState._border),
      ),
      child: Column(
        children: [
          ...preview.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;

            return Padding(
              padding: EdgeInsets.only(
                bottom: index == preview.length - 1 ? 0 : 10,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Frame ${item.frame}',
                      style: const TextStyle(
                        color: _MatchSummaryPageState._textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'V ${item.greenVisible}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: _MatchSummaryPageState._green,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'R ${item.redVisible}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: _MatchSummaryPageState._red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'U ${item.unknownVisible}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: _MatchSummaryPageState._warning,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'T ${item.totalVisible}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: _MatchSummaryPageState._textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: _MatchSummaryPageState._muted,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.8,
      ),
    );
  }
}

class _EmptyTeamMessage extends StatelessWidget {
  final String text;

  const _EmptyTeamMessage(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _MatchSummaryPageState._card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _MatchSummaryPageState._border),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: _MatchSummaryPageState._textSecondary,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _MatchSummaryPageState._card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _MatchSummaryPageState._border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.redAccent,
                size: 42,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _MatchSummaryPageState._textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _MatchSummaryPageState._primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('REINTENTAR'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(
          color: _MatchSummaryPageState._textSecondary,
        ),
      ),
    );
  }
}
