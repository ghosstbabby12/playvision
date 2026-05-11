import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:playvision/core/theme/app_color_tokens.dart';
import '../../data/player_profile_service.dart';
import '../../domain/player_profile.dart';
import '../../domain/player_token.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Insight model
// ─────────────────────────────────────────────────────────────────────────────

enum _Level { positive, warning, neutral, info }

class _Insight {
  final String emoji, text;
  final _Level level;
  const _Insight(this.emoji, this.text, this.level);
}

// ─────────────────────────────────────────────────────────────────────────────
// Position ideals  [Speed, Pass, Shoot, Defend, Physical] — normalized 0-1
// ─────────────────────────────────────────────────────────────────────────────

const _positionIdeals = <String, List<double>>{
  'GK':  [0.25, 0.55, 0.05, 0.75, 0.80],
  'CB':  [0.60, 0.65, 0.15, 0.92, 0.85],
  'RB':  [0.82, 0.70, 0.22, 0.80, 0.72],
  'LB':  [0.82, 0.70, 0.22, 0.80, 0.72],
  'WB':  [0.86, 0.68, 0.28, 0.72, 0.75],
  'RWB': [0.86, 0.68, 0.28, 0.72, 0.75],
  'LWB': [0.86, 0.68, 0.28, 0.72, 0.75],
  'CDM': [0.70, 0.80, 0.35, 0.82, 0.78],
  'CM':  [0.72, 0.88, 0.50, 0.65, 0.72],
  'CAM': [0.76, 0.85, 0.70, 0.45, 0.65],
  'RAM': [0.80, 0.80, 0.70, 0.38, 0.65],
  'LAM': [0.80, 0.80, 0.70, 0.38, 0.65],
  'RM':  [0.87, 0.75, 0.67, 0.42, 0.68],
  'LM':  [0.87, 0.75, 0.67, 0.42, 0.68],
  'RW':  [0.92, 0.70, 0.80, 0.28, 0.68],
  'LW':  [0.92, 0.70, 0.80, 0.28, 0.68],
  'ST':  [0.83, 0.65, 0.90, 0.22, 0.80],
  'CF':  [0.80, 0.72, 0.87, 0.25, 0.75],
  'SS':  [0.85, 0.75, 0.82, 0.28, 0.72],
};

List<double> _idealFor(String position) =>
    _positionIdeals[position] ?? const [0.70, 0.75, 0.55, 0.60, 0.70];

List<double> _teamAvg(List<PlayerToken> players) {
  if (players.isEmpty) return List.filled(5, 0.5);
  final sum = List.filled(5, 0.0);
  for (final p in players) {
    final v = p.radarValues;
    for (int i = 0; i < 5; i++) {
      sum[i] += v[i];
    }
  }
  return sum.map((s) => s / players.length).toList();
}

// ─────────────────────────────────────────────────────────────────────────────
// Insight generator
// ─────────────────────────────────────────────────────────────────────────────

const _axisLabels = ['Velocidad', 'Pase', 'Disparo', 'Defensa', 'Físico'];
const _axisExplains = [
  'Distancia cubierta y velocidad de sprints',
  'Precisión y volumen de pases completados',
  'Goles y remates efectivos al arco',
  'Recuperaciones y entradas defensivas',
  'Resistencia física y duelos ganados',
];

List<_Insight> _generateInsights(
    PlayerToken token, PlayerProfile? profile, List<PlayerToken> allPlayers) {
  final out = <_Insight>[];
  final s   = token.stats;

  final rating   = (s['rating']       as num?)?.toDouble() ?? 7.0;
  final goals    = (s['goals']        as num?)?.toInt()    ?? 0;
  final assists  = (s['assists']      as num?)?.toInt()    ?? 0;
  final distance = (s['distance']     as num?)?.toDouble() ?? 9.0;
  final passAcc  = (s['passAccuracy'] as num?)?.toInt()    ?? 80;
  final tackles  = (s['tackles']      as num?)?.toInt()    ?? 5;

  final pos   = token.position;
  final isDef = {'CB', 'RB', 'LB', 'WB', 'RWB', 'LWB'}.contains(pos);
  final isAtk = {'ST', 'CF', 'RW', 'LW', 'SS'}.contains(pos);
  final isGK  = pos == 'GK';

  // Rating
  if (rating >= 8.5) {
    out.add(_Insight('🔥', 'Alto rendimiento · ${rating.toStringAsFixed(1)} ★', _Level.positive));
  } else if (rating >= 7.5) {
    out.add(_Insight('✅', 'Buen partido · ${rating.toStringAsFixed(1)} ★', _Level.positive));
  } else if (rating < 6.5) {
    out.add(_Insight('⚠️', 'Rendimiento bajo · ${rating.toStringAsFixed(1)} ★', _Level.warning));
  }

  // Trend from profile history
  if (profile != null && profile.history.length >= 3) {
    final avg = profile.history.take(3)
        .map((h) => h.rating).reduce((a, b) => a + b) / 3;
    final pct = ((rating - avg) / avg * 100).round();
    if (pct >= 10) {
      out.add(_Insight('📈', '+$pct% vs media reciente', _Level.positive));
    } else if (pct <= -10) {
      out.add(_Insight('📉', '$pct% vs media reciente', _Level.warning));
    }
  }

  // Offensive contribution
  if (!isGK) {
    if (goals >= 2 || assists >= 2 || (goals >= 1 && assists >= 1)) {
      out.add(_Insight('⚡', 'Alta contribución ofensiva · ${goals}G ${assists}A', _Level.positive));
    } else if (isAtk && goals == 0 && assists == 0) {
      out.add(_Insight('📉', 'Sin participación directa en goles', _Level.warning));
    }
  }

  // Defensive work
  if (!isGK) {
    if (isDef && tackles <= 2) {
      out.add(_Insight('🛡️', 'Baja contribución defensiva · $tackles recuperaciones', _Level.warning));
    } else if (tackles >= 12) {
      out.add(_Insight('🏆', 'Trabajo defensivo excelente · $tackles recuperaciones', _Level.positive));
    }
  }

  // Distance
  if (!isGK) {
    if (distance >= 12.0) {
      out.add(_Insight('🏃', 'Cobertura excepcional · ${distance.toStringAsFixed(1)} km', _Level.positive));
    } else if (distance < 7.5) {
      out.add(_Insight('⚠️', 'Baja cobertura de campo · ${distance.toStringAsFixed(1)} km', _Level.warning));
    }
  }

  // Pass accuracy
  if (passAcc >= 90) {
    out.add(_Insight('🎯', 'Precisión de pase élite · $passAcc%', _Level.positive));
  } else if (passAcc < 68) {
    out.add(_Insight('⚠️', 'Precisión de pase baja · $passAcc%', _Level.warning));
  }

  // vs Position ideal
  final ideal = _idealFor(pos);
  final vals  = token.radarValues;
  for (int i = 0; i < 5; i++) {
    final diff = vals[i] - ideal[i];
    if (diff >= 0.22) {
      out.add(_Insight('📈', '↑ ${_axisLabels[i]} superior al perfil ideal', _Level.positive));
    } else if (diff <= -0.22) {
      out.add(_Insight('📉', '↓ ${_axisLabels[i]} por debajo del perfil de posición', _Level.warning));
    }
  }

  // AI insights
  if (profile != null) {
    final ai = profile.aiInsights;
    if (ai.recommendation.isNotEmpty) {
      out.add(_Insight('🧠', ai.recommendation, _Level.info));
    }
    if (ai.bestPosition.isNotEmpty && ai.bestPosition != pos) {
      out.add(_Insight('🔄', 'Posición óptima sugerida: ${ai.bestPosition}', _Level.neutral));
    }
  }

  return out.take(6).toList();
}

// ─────────────────────────────────────────────────────────────────────────────
// PlayerStatsSheet
// ─────────────────────────────────────────────────────────────────────────────

class PlayerStatsSheet extends StatefulWidget {
  final PlayerToken initialToken;
  final List<PlayerToken> allPlayers;

  const PlayerStatsSheet({
    super.key,
    required this.initialToken,
    this.allPlayers = const [],
  });

  static void show(
    BuildContext context,
    PlayerToken token, {
    List<PlayerToken> allPlayers = const [],
  }) {
    final players = allPlayers.isEmpty ? [token] : allPlayers;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PlayerStatsSheet(
        initialToken: token,
        allPlayers: players,
      ),
    );
  }

  @override
  State<PlayerStatsSheet> createState() => _PlayerStatsSheetState();
}

class _PlayerStatsSheetState extends State<PlayerStatsSheet> {
  late int _idx;
  PlayerProfile? _profile;
  bool _loading = true;
  int  _tab        = 0; // 0=Asistente  1=Perfil  2=Partido
  int  _radarMode  = 0; // 0=Posición   1=Equipo
  int? _axisDetail;     // tapped axis index
  bool _pinned     = false;

  List<PlayerToken> get _players =>
      widget.allPlayers.isEmpty ? [widget.initialToken] : widget.allPlayers;

  PlayerToken get _current => _players[_idx];

  @override
  void initState() {
    super.initState();
    _idx = _players.indexWhere((p) => p.id == widget.initialToken.id);
    if (_idx < 0) _idx = 0;
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() { _loading = true; _profile = null; _axisDetail = null; });
    final p = await PlayerProfileService.instance.fetch(_current.id);
    if (mounted) setState(() { _profile = p; _loading = false; });
  }

  void _navigate(int delta) {
    final next = (_idx + delta).clamp(0, _players.length - 1);
    if (next == _idx) return;
    setState(() => _idx = next);
    _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return GestureDetector(
      onHorizontalDragEnd: (d) {
        if ((d.primaryVelocity ?? 0) < -400) _navigate(1);
        if ((d.primaryVelocity ?? 0) >  400) _navigate(-1);
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.90,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(top: BorderSide(color: _pinned ? c.accent : c.border2)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          child: Column(children: [

            // ── Handle centrado + botón cerrar a la derecha ─────────────
            Row(children: [
              const SizedBox(width: 36),
              Expanded(
                child: GestureDetector(
                  onLongPress: () => setState(() => _pinned = !_pinned),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: _pinned ? 20 : 40, height: 4,
                        decoration: BoxDecoration(
                          color: _pinned ? c.accent : c.border2,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    if (_pinned) ...[
                      const SizedBox(height: 5),
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.push_pin_rounded, color: c.accent, size: 11),
                        const SizedBox(width: 4),
                        Text('Fijado', style: TextStyle(
                            color: c.accent, fontSize: 10, fontWeight: FontWeight.w600)),
                      ]),
                    ],
                  ]),
                ),
              ),
              // Botón cerrar / minimizar
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: c.elevated,
                    shape: BoxShape.circle,
                    border: Border.all(color: c.border2),
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: c.muted, size: 22,
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 16),

            // ── Navigation header ─────────────────────────────────────────
            _NavHeader(
              token: _current, profile: _profile,
              idx: _idx, total: _players.length,
              onPrev: () => _navigate(-1),
              onNext: () => _navigate(1),
              c: c,
            ),
            const SizedBox(height: 12),

            // ── Quick stats row ───────────────────────────────────────────
            _QuickStatsRow(token: _current, profile: _profile, c: c),
            const SizedBox(height: 14),

            // ── Tab pills ─────────────────────────────────────────────────
            _TabPills(
              selected: _tab,
              labels: const ['🧠 Asistente', '📊 Perfil', '⚡ Partido'],
              onSelect: (i) => setState(() { _tab = i; _axisDetail = null; }),
              c: c,
            ),
            const SizedBox(height: 16),

            // ── Body scrollable (fix overflow) ────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 32),
                child: _loading
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: CircularProgressIndicator(
                            color: c.accent, strokeWidth: 1.5)),
                      )
                    : _tab == 0
                        ? _CoachTab(
                            token: _current, profile: _profile,
                            allPlayers: _players,
                            radarMode: _radarMode,
                            axisDetail: _axisDetail,
                            onRadarMode: (m) => setState(() { _radarMode = m; _axisDetail = null; }),
                            onAxisTap: (i) => setState(() =>
                                _axisDetail = _axisDetail == i ? null : i),
                            c: c,
                          )
                        : _tab == 1
                            ? _ProfileTab(token: _current, profile: _profile, c: c)
                            : _MatchTab(token: _current, profile: _profile, c: c),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick stats row (4 pills below the header)
// ─────────────────────────────────────────────────────────────────────────────

class _QuickStatsRow extends StatelessWidget {
  final PlayerToken token;
  final PlayerProfile? profile;
  final AppColorTokens c;
  const _QuickStatsRow({required this.token, required this.profile, required this.c});

  @override
  Widget build(BuildContext context) {
    final s        = token.stats;
    final rating   = (profile?.overall?.toDouble() ?? (s['rating'] as num?)?.toDouble() ?? 7.0);
    final goals    = (s['goals']        as num?)?.toInt()    ?? 0;
    final assists  = (s['assists']      as num?)?.toInt()    ?? 0;
    final distance = (s['distance']     as num?)?.toDouble() ?? 0.0;
    final passAcc  = (s['passAccuracy'] as num?)?.toInt()    ?? 0;

    return Row(children: [
      _QStat(label: 'Rating',  value: rating.toStringAsFixed(1), icon: Icons.star_rounded,            color: c.accent,                 c: c),
      const SizedBox(width: 8),
      _QStat(label: 'Goles',   value: '$goals',                  icon: Icons.sports_soccer_rounded,   color: const Color(0xFF10B981),  c: c),
      const SizedBox(width: 8),
      _QStat(label: 'Asist.',  value: '$assists',                icon: Icons.assistant_rounded,        color: const Color(0xFF3B82F6),  c: c),
      const SizedBox(width: 8),
      _QStat(label: 'Km',      value: distance.toStringAsFixed(1), icon: Icons.directions_run_rounded, color: const Color(0xFF8B5CF6), c: c),
      const SizedBox(width: 8),
      _QStat(label: 'Pases%',  value: '$passAcc%',               icon: Icons.track_changes_rounded,   color: const Color(0xFFF59E0B),  c: c),
    ]);
  }
}

class _QStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final AppColorTokens c;
  const _QStat({required this.label, required this.value, required this.icon,
      required this.color, required this.c});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 13),
        const SizedBox(height: 3),
        Text(value, style: TextStyle(
            color: color, fontSize: 13, fontWeight: FontWeight.w900)),
        Text(label, style: TextStyle(color: c.dim, fontSize: 8, fontWeight: FontWeight.w500)),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Navigation header
// ─────────────────────────────────────────────────────────────────────────────

class _NavHeader extends StatelessWidget {
  final PlayerToken token;
  final PlayerProfile? profile;
  final int idx, total;
  final VoidCallback onPrev, onNext;
  final AppColorTokens c;
  const _NavHeader({
    required this.token, required this.profile,
    required this.idx, required this.total,
    required this.onPrev, required this.onNext,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    final rating   = profile?.overall?.toDouble()
        ?? (token.stats['rating'] as num?)?.toDouble() ?? 7.0;
    final pos      = profile?.position ?? token.position;
    final photoUrl = profile?.photoUrl;

    return Row(children: [
      // Prev arrow
      if (total > 1)
        GestureDetector(
          onTap: onPrev,
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(Icons.chevron_left_rounded,
                color: idx > 0 ? c.text : c.dim, size: 22),
          ),
        ),

      // Avatar
      Container(
        width: 52, height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _posColor(pos).withValues(alpha: 0.15),
          border: Border.all(color: _posColor(pos).withValues(alpha: 0.5), width: 1.5),
          image: photoUrl != null
              ? DecorationImage(image: NetworkImage(photoUrl), fit: BoxFit.cover)
              : null,
        ),
        child: photoUrl == null
            ? Center(child: Text(pos,
                style: TextStyle(color: _posColor(pos), fontSize: 11,
                    fontWeight: FontWeight.w800)))
            : null,
      ),
      const SizedBox(width: 12),

      // Name + badges
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(profile?.name ?? token.name,
            style: TextStyle(color: c.textHi, fontSize: 19,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        Row(children: [
          _Pill(text: '#${token.number}  $pos', color: _posColor(pos)),
          if (total > 1) ...[
            const SizedBox(width: 6),
            Text('${idx + 1} / $total',
                style: TextStyle(color: c.dim, fontSize: 10)),
          ],
        ]),
      ])),

      // Rating badge
      Column(mainAxisSize: MainAxisSize.min, children: [
        Text(
          rating is int ? '$rating' : rating.toStringAsFixed(1),
          style: TextStyle(color: c.accent, fontSize: 32,
              fontWeight: FontWeight.w900, height: 1),
        ),
        Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.star_rounded, color: c.accent, size: 12),
          const SizedBox(width: 2),
          Text(profile != null ? 'OVR' : 'AVG',
              style: TextStyle(color: c.accent, fontSize: 10,
                  fontWeight: FontWeight.w700)),
        ]),
      ]),

      // Next arrow
      if (total > 1)
        GestureDetector(
          onTap: onNext,
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Icon(Icons.chevron_right_rounded,
                color: idx < total - 1 ? c.text : c.dim, size: 22),
          ),
        ),
    ]);
  }

  Color _posColor(String pos) {
    if (pos == 'GK') return const Color(0xFFF59E0B);
    if (pos.contains('B') && !pos.contains('A')) return const Color(0xFF3B82F6);
    if (pos.contains('M') || pos.contains('D')) return const Color(0xFF8B5CF6);
    return const Color(0xFF39D353);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 🧠 Coach Assistant tab
// ─────────────────────────────────────────────────────────────────────────────

class _CoachTab extends StatelessWidget {
  final PlayerToken token;
  final PlayerProfile? profile;
  final List<PlayerToken> allPlayers;
  final int radarMode;
  final int? axisDetail;
  final void Function(int) onRadarMode;
  final void Function(int) onAxisTap;
  final AppColorTokens c;

  const _CoachTab({
    required this.token, required this.profile,
    required this.allPlayers, required this.radarMode,
    required this.axisDetail,
    required this.onRadarMode, required this.onAxisTap,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    final insights = _generateInsights(token, profile, allPlayers);
    final ideal    = _idealFor(token.position);
    final compVals = radarMode == 0 ? ideal : _teamAvg(allPlayers);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // ── Insight cards ─────────────────────────────────────────────────────
      _SectionLabel('ASISTENTE DE COACH', c),
      const SizedBox(height: 10),

      ...insights.map((ins) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _InsightRow(insight: ins, c: c),
      )),

      const SizedBox(height: 20),

      // ── Comparison radar ──────────────────────────────────────────────────
      _SectionLabel('RADAR COMPARATIVO', c),
      const SizedBox(height: 10),

      // Toggle: Posición / Equipo
      Row(children: [
        _ToggleChip(
          label: 'vs Posición ideal',
          active: radarMode == 0,
          onTap: () => onRadarMode(0),
          c: c,
        ),
        const SizedBox(width: 8),
        _ToggleChip(
          label: 'vs Promedio equipo',
          active: radarMode == 1,
          onTap: () => onRadarMode(1),
          c: c,
        ),
      ]),
      const SizedBox(height: 12),

      // Legend row
      Row(children: [
        _RadarLegendDot(color: c.accent, label: token.name.split(' ').last),
        const SizedBox(width: 14),
        _RadarLegendDot(
          color: Colors.white54,
          label: radarMode == 0 ? 'Perfil ideal' : 'Media equipo',
          dashed: true,
        ),
        const Spacer(),
        Text('Toca un eje para detalle',
            style: TextStyle(color: c.dim, fontSize: 9)),
      ]),
      const SizedBox(height: 10),

      // Interactive radar
      GestureDetector(
        onTapUp: (details) => _handleRadarTap(details.localPosition, onAxisTap),
        child: SizedBox(
          height: 220,
          child: DualRadarChart(
            values: token.radarValues,
            compValues: compVals,
            highlightAxis: axisDetail,
            accentColor: c.accent,
          ),
        ),
      ),

      // Axis detail card
      AnimatedSize(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: axisDetail != null
            ? Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _AxisDetailCard(
                  axisIndex: axisDetail!,
                  playerVal: token.radarValues[axisDetail!],
                  compVal: compVals[axisDetail!],
                  radarMode: radarMode,
                  c: c,
                ),
              )
            : const SizedBox.shrink(),
      ),

      // Comparison bars
      const SizedBox(height: 16),
      ...List.generate(5, (i) => _CompBar(
        label:     _axisLabels[i],
        player:    token.radarValues[i],
        reference: compVals[i],
        isHighlight: i == axisDetail,
        c: c,
      )),
    ]);
  }

  void _handleRadarTap(Offset localPos, void Function(int) onAxisTap) {
    const size = 180.0;
    final center = Offset(size / 2, size / 2);
    final dx = localPos.dx - center.dx;
    final dy = localPos.dy - center.dy;
    final tapAngle = math.atan2(dy, dx);

    double minDiff = double.infinity;
    int nearest = 0;
    for (int i = 0; i < 5; i++) {
      final axisAngle = (i * 2 * math.pi / 5) - math.pi / 2;
      var diff = (tapAngle - axisAngle).abs();
      if (diff > math.pi) diff = 2 * math.pi - diff;
      if (diff < minDiff) {
        minDiff = diff;
        nearest = i;
      }
    }
    onAxisTap(nearest);
  }
}

class _InsightRow extends StatelessWidget {
  final _Insight insight;
  final AppColorTokens c;
  const _InsightRow({required this.insight, required this.c});

  static (Color, IconData) _meta(_Level level) => switch (level) {
    _Level.positive => (const Color(0xFF32FF88), Icons.trending_up_rounded),
    _Level.warning  => (const Color(0xFFF59E0B), Icons.warning_amber_rounded),
    _Level.neutral  => (const Color(0xFF8B5CF6), Icons.swap_horiz_rounded),
    _Level.info     => (const Color(0xFF3B82F6), Icons.lightbulb_outline_rounded),
  };

  // Extract trailing metric token (e.g. "7.2 ★", "9.8 km", "82%")
  static (String, String) _splitText(String text) {
    final patterns = [
      RegExp(r'^(.*?)\s*·\s*(.+)$'),
    ];
    for (final rx in patterns) {
      final m = rx.firstMatch(text);
      if (m != null) return (m.group(1)!.trim(), m.group(2)!.trim());
    }
    return (text, '');
  }

  @override
  Widget build(BuildContext context) {
    final (color, iconData) = _meta(insight.level);
    final (mainText, metric) = _splitText(insight.text);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Left accent bar
          Container(
            width: 4,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
            ),
          ),
          const SizedBox(width: 10),
          // Icon
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 11),
            child: Icon(iconData, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          // Main text
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, children: [
                Text(mainText, style: TextStyle(
                    color: c.text, fontSize: 12, fontWeight: FontWeight.w600, height: 1.2)),
                if (insight.level == _Level.warning || insight.level == _Level.info)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(_levelHint(insight.level),
                        style: TextStyle(color: c.dim, fontSize: 9)),
                  ),
              ]),
            ),
          ),
          // Metric badge on right
          if (metric.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(metric, style: TextStyle(
                    color: color, fontSize: 11, fontWeight: FontWeight.w800)),
              ),
            ),
        ]),
      ),
    );
  }

  String _levelHint(_Level l) => switch (l) {
    _Level.warning => 'Requiere atención',
    _Level.info    => 'Sugerencia IA',
    _            => '',
  };
}

class _AxisDetailCard extends StatelessWidget {
  final int axisIndex;
  final double playerVal, compVal;
  final int radarMode;
  final AppColorTokens c;
  const _AxisDetailCard({
    required this.axisIndex, required this.playerVal,
    required this.compVal, required this.radarMode, required this.c,
  });

  @override
  Widget build(BuildContext context) {
    final diff     = playerVal - compVal;
    final isAbove  = diff > 0;
    final pct      = (diff * 100).round().abs();
    final refLabel = radarMode == 0 ? 'Perfil ideal' : 'Media equipo';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.elevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.accent.withValues(alpha: 0.35)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(_axisLabels[axisIndex],
              style: TextStyle(color: c.accent, fontSize: 13,
                  fontWeight: FontWeight.w800)),
          const SizedBox(width: 8),
          Text(_axisExplains[axisIndex],
              style: TextStyle(color: c.muted, fontSize: 10)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          _StatBadge(label: 'Jugador',  val: (playerVal * 100).round(), color: c.accent, c: c),
          const SizedBox(width: 8),
          _StatBadge(label: refLabel,   val: (compVal   * 100).round(), color: Colors.white54, c: c),
          const Spacer(),
          Icon(
            isAbove ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            color: isAbove ? c.accent : const Color(0xFFF59E0B),
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '${isAbove ? '+' : '-'}$pct%',
            style: TextStyle(
              color: isAbove ? c.accent : const Color(0xFFF59E0B),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ]),
      ]),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final int val;
  final Color color;
  final AppColorTokens c;
  const _StatBadge({required this.label, required this.val,
      required this.color, required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('$val', style: TextStyle(color: color, fontSize: 20,
          fontWeight: FontWeight.w900)),
      Text(label, style: TextStyle(color: c.muted, fontSize: 9)),
    ]);
  }
}

class _CompBar extends StatelessWidget {
  final String label;
  final double player, reference;
  final bool isHighlight;
  final AppColorTokens c;
  const _CompBar({
    required this.label, required this.player,
    required this.reference, required this.isHighlight, required this.c,
  });

  @override
  Widget build(BuildContext context) {
    final isAbove    = player >= reference;
    final playerVal  = (player * 100).round();
    final refVal     = (reference * 100).round();
    final diff       = playerVal - refVal;
    final diffStr    = diff >= 0 ? '+$diff' : '$diff';
    final diffColor  = isAbove ? c.accent : const Color(0xFFF59E0B);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        SizedBox(width: 58,
          child: Text(label, style: TextStyle(
            color: isHighlight ? c.accent : c.dim,
            fontSize: 10, fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
          )),
        ),
        Expanded(
          child: Stack(children: [
            ClipRRect(borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: reference, backgroundColor: c.border,
                valueColor: const AlwaysStoppedAnimation(Colors.white12), minHeight: 8,
              )),
            ClipRRect(borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: player, backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation(
                    c.accent.withValues(alpha: isHighlight ? 1.0 : 0.70)),
                minHeight: 8,
              )),
          ]),
        ),
        const SizedBox(width: 8),
        // Player score
        SizedBox(width: 26,
          child: Text('$playerVal', textAlign: TextAlign.right,
              style: TextStyle(color: c.textHi, fontSize: 11, fontWeight: FontWeight.w800))),
        const SizedBox(width: 4),
        // Diff badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: diffColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(diffStr, style: TextStyle(
              color: diffColor, fontSize: 9, fontWeight: FontWeight.w800)),
        ),
      ]),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final AppColorTokens c;
  const _ToggleChip({required this.label, required this.active,
      required this.onTap, required this.c});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? c.accentLo : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? c.borderGreen : c.border),
        ),
        child: Text(label,
            style: TextStyle(
              color: active ? c.accent : c.muted,
              fontSize: 10,
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            )),
      ),
    );
  }
}

class _RadarLegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final bool dashed;
  const _RadarLegendDot({required this.color, required this.label,
      this.dashed = false});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: dashed ? 14 : 8, height: dashed ? 2 : 8,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(dashed ? 1 : 4),
        ),
      ),
      const SizedBox(width: 5),
      Text(label, style: TextStyle(color: color, fontSize: 10)),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 📊 Profile tab (attribute bars)
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileTab extends StatelessWidget {
  final PlayerToken token;
  final PlayerProfile? profile;
  final AppColorTokens c;
  const _ProfileTab({required this.token, required this.profile, required this.c});

  @override
  Widget build(BuildContext context) {
    final attrs = profile?.attributes;

    if (attrs == null) {
      return SizedBox(
        height: 200,
        child: DualRadarChart(
          values: token.radarValues,
          accentColor: c.accent,
        ),
      );
    }

    final bars = [
      ('PAC', attrs.pace,      const Color(0xFF10B981)),
      ('SHO', attrs.shooting,  const Color(0xFFEF4444)),
      ('PAS', attrs.passing,   const Color(0xFF3B82F6)),
      ('DRI', attrs.dribbling, const Color(0xFFF59E0B)),
      ('DEF', attrs.defending, const Color(0xFF8B5CF6)),
      ('PHY', attrs.physical,  const Color(0xFF6B7280)),
    ];

    return Column(children: [
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8, crossAxisSpacing: 8,
        childAspectRatio: 3.2,
        children: bars
            .map((b) => _AttrBar(label: b.$1, value: b.$2, color: b.$3, c: c))
            .toList(),
      ),
      const SizedBox(height: 16),
      if (profile?.heightCm != null)
        Row(children: [
          Icon(Icons.height_rounded, color: c.dim, size: 16),
          const SizedBox(width: 6),
          Text('${profile!.heightCm} cm',
              style: TextStyle(color: c.muted, fontSize: 12)),
          const SizedBox(width: 16),
          Icon(Icons.sports_soccer, color: c.dim, size: 14),
          const SizedBox(width: 6),
          Text('${profile!.foot} foot',
              style: TextStyle(color: c.muted, fontSize: 12)),
        ]),
    ]);
  }
}

class _AttrBar extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final AppColorTokens c;
  const _AttrBar({required this.label, required this.value,
      required this.color, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: c.elevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border),
      ),
      child: Row(children: [
        SizedBox(width: 30,
          child: Text(label, style: TextStyle(
              color: c.muted, fontSize: 10, fontWeight: FontWeight.w700))),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: c.border,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('$value', style: TextStyle(
            color: c.textHi, fontSize: 13, fontWeight: FontWeight.w800)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ⚡ Match tab
// ─────────────────────────────────────────────────────────────────────────────

class _MatchTab extends StatelessWidget {
  final PlayerToken token;
  final PlayerProfile? profile;
  final AppColorTokens c;
  const _MatchTab({required this.token, required this.profile, required this.c});

  @override
  Widget build(BuildContext context) {
    final lm = profile?.lastMatch;

    final stats = lm != null
        ? [
            ('⚽', 'Goles',     '${lm.goals ?? 0}'),
            ('🅰️', 'Asistencias', '${lm.assists ?? 0}'),
            ('📏', 'Distancia', '${lm.distanceKm?.toStringAsFixed(1) ?? '—'} km'),
            ('🎯', 'Pases',     '${lm.passes ?? 0}'),
            ('✅', 'Precisión', '${lm.passAccuracy ?? 0}%'),
            ('⏱',  'Minutos',  '${lm.minutes ?? 90}\''),
          ]
        : [
            ('⚽', 'Goles',     '${token.stats['goals']}'),
            ('🅰️', 'Asistencias', '${token.stats['assists']}'),
            ('📏', 'Distancia', '${(token.stats['distance'] as num).toStringAsFixed(1)} km'),
            ('🎯', 'Pases',     '${token.stats['passes']}'),
            ('✅', 'Precisión', '${token.stats['passAccuracy']}%'),
            ('⏱',  'Minutos',  "${token.stats['minutes']}'"),
          ];

    final rating = lm?.rating ?? (token.stats['rating'] as num?)?.toDouble();

    return Column(children: [
      if (rating != null) ...[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: c.accentLo,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.borderGreen),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.star_rounded, color: c.accent, size: 20),
            const SizedBox(width: 8),
            Text(rating.toStringAsFixed(1),
                style: TextStyle(color: c.accent, fontSize: 32,
                    fontWeight: FontWeight.w900)),
            const SizedBox(width: 8),
            Text('Rating del partido',
                style: TextStyle(color: c.muted, fontSize: 12)),
          ]),
        ),
        const SizedBox(height: 16),
      ],

      GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8, crossAxisSpacing: 8,
        childAspectRatio: 1.6,
        children: stats
            .map((s) => _StatCell(emoji: s.$1, label: s.$2, value: s.$3, c: c))
            .toList(),
      ),

      if (profile != null && profile!.history.isNotEmpty) ...[
        const SizedBox(height: 20),
        Text('Tendencia de rating',
            style: TextStyle(color: c.muted, fontSize: 11,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        SizedBox(
          height: 56,
          child: _Sparkline(
            values: profile!.history.map((h) => h.rating)
                .toList().reversed.toList(),
            color: c.accent,
          ),
        ),
      ],
    ]);
  }
}

class _StatCell extends StatelessWidget {
  final String emoji, label, value;
  final AppColorTokens c;
  const _StatCell({required this.emoji, required this.label,
      required this.value, required this.c});

  static Color _emojiColor(String emoji) => switch (emoji) {
    '⚽'  => const Color(0xFF10B981),
    '🅰️' => const Color(0xFF3B82F6),
    '📏'  => const Color(0xFF8B5CF6),
    '🎯'  => const Color(0xFFF59E0B),
    '✅'  => const Color(0xFF32FF88),
    _     => const Color(0xFF6B7280),
  };

  @override
  Widget build(BuildContext context) {
    final color = _emojiColor(emoji);
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 14))),
          ),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: c.textHi, fontSize: 17,
              fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: c.muted, fontSize: 9,
              fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dual Radar Chart
// ─────────────────────────────────────────────────────────────────────────────

class DualRadarChart extends StatelessWidget {
  final List<double> values;
  final List<double>? compValues;
  final int? highlightAxis;
  final Color accentColor;

  static const _labels = ['Speed', 'Pass', 'Shoot', 'Defend', 'Physical'];

  const DualRadarChart({
    super.key,
    required this.values,
    this.compValues,
    this.highlightAxis,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DualRadarPainter(
        values: values,
        compValues: compValues,
        highlightAxis: highlightAxis,
        accentColor: accentColor,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Stack(children: List.generate(_labels.length, (i) {
          const r = 0.85;
          final angle = (i * 2 * math.pi / _labels.length) - math.pi / 2;
          final highlighted = i == highlightAxis;
          final tx = 0.5 + (r + 0.10) * math.cos(angle);
          final ty = 0.5 + (r + 0.10) * math.sin(angle);
          return Align(
            alignment: Alignment(tx * 2 - 1, ty * 2 - 1),
            child: Text(_labels[i],
                style: TextStyle(
                  color: highlighted ? accentColor : Colors.white54,
                  fontSize: 10,
                  fontWeight: highlighted
                      ? FontWeight.w800
                      : FontWeight.w600,
                )),
          );
        })),
      ),
    );
  }
}

class _DualRadarPainter extends CustomPainter {
  final List<double> values;
  final List<double>? compValues;
  final int? highlightAxis;
  final Color accentColor;

  const _DualRadarPainter({
    required this.values,
    this.compValues,
    this.highlightAxis,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final n  = values.length;
    final cx = size.width  / 2;
    final cy = size.height / 2;
    final r  = math.min(cx, cy) * 0.76;

    // Rings
    final ringP = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    for (int ring = 1; ring <= 4; ring++) {
      final path = Path();
      for (int i = 0; i < n; i++) {
        final a = (i * 2 * math.pi / n) - math.pi / 2;
        final rr = r * ring / 4;
        final pt = Offset(cx + rr * math.cos(a), cy + rr * math.sin(a));
        if (i == 0) {
          path.moveTo(pt.dx, pt.dy);
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
      }
      path.close();
      canvas.drawPath(path, ringP);
    }

    // Axis lines
    for (int i = 0; i < n; i++) {
      final a     = (i * 2 * math.pi / n) - math.pi / 2;
      final hlt   = i == highlightAxis;
      canvas.drawLine(
        Offset(cx, cy),
        Offset(cx + r * math.cos(a), cy + r * math.sin(a)),
        Paint()
          ..color = hlt
              ? accentColor.withValues(alpha: 0.55)
              : Colors.white.withValues(alpha: 0.12)
          ..strokeWidth = hlt ? 1.6 : 0.8,
      );
    }

    // Comparison polygon
    if (compValues != null && compValues!.length == n) {
      final compPath = Path();
      for (int i = 0; i < n; i++) {
        final a  = (i * 2 * math.pi / n) - math.pi / 2;
        final rv = r * compValues![i];
        final pt = Offset(cx + rv * math.cos(a), cy + rv * math.sin(a));
        if (i == 0) {
          compPath.moveTo(pt.dx, pt.dy);
        } else {
          compPath.lineTo(pt.dx, pt.dy);
        }
      }
      compPath.close();
      canvas.drawPath(compPath,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.06)
            ..style = PaintingStyle.fill);
      canvas.drawPath(compPath,
          Paint()
            ..color = Colors.white.withValues(alpha: 0.30)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4
            ..strokeJoin = StrokeJoin.round);
    }

    // Player polygon fill + stroke
    final dataPath = Path();
    for (int i = 0; i < n; i++) {
      final a  = (i * 2 * math.pi / n) - math.pi / 2;
      final rv = r * values[i];
      final pt = Offset(cx + rv * math.cos(a), cy + rv * math.sin(a));
      if (i == 0) {
        dataPath.moveTo(pt.dx, pt.dy);
      } else {
        dataPath.lineTo(pt.dx, pt.dy);
      }
    }
    dataPath.close();
    canvas.drawPath(dataPath,
        Paint()
          ..color = accentColor.withValues(alpha: 0.20)
          ..style = PaintingStyle.fill);
    canvas.drawPath(dataPath,
        Paint()
          ..color = accentColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..strokeJoin = StrokeJoin.round);

    // Dots on player polygon
    for (int i = 0; i < n; i++) {
      final a    = (i * 2 * math.pi / n) - math.pi / 2;
      final rv   = r * values[i];
      final hlt  = i == highlightAxis;
      canvas.drawCircle(
        Offset(cx + rv * math.cos(a), cy + rv * math.sin(a)),
        hlt ? 5.0 : 3.5,
        Paint()..color = accentColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DualRadarPainter old) =>
      old.values != values ||
      old.compValues != compValues ||
      old.highlightAxis != highlightAxis;
}

// ─────────────────────────────────────────────────────────────────────────────
// Sparkline
// ─────────────────────────────────────────────────────────────────────────────

class _Sparkline extends StatelessWidget {
  final List<double> values;
  final Color color;
  const _Sparkline({required this.values, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _SparkPainter(values, color));
  }
}

class _SparkPainter extends CustomPainter {
  final List<double> values;
  final Color color;
  const _SparkPainter(this.values, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final minV = values.reduce(math.min);
    final maxV = values.reduce(math.max);
    final range = (maxV - minV).clamp(0.5, double.infinity);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final y = size.height * (1 - (values[i] - minV) / range);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);

    for (int i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final y = size.height * (1 - (values[i] - minV) / range);
      canvas.drawCircle(Offset(x, y), 3.5, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant _SparkPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Small shared widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  final AppColorTokens c;
  const _SectionLabel(this.text, this.c);

  @override
  Widget build(BuildContext context) => Text(text,
      style: TextStyle(
          color: c.dim, fontSize: 10,
          fontWeight: FontWeight.w700, letterSpacing: 2));
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  const _Pill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: TextStyle(
          color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}

class _TabPills extends StatelessWidget {
  final int selected;
  final List<String> labels;
  final void Function(int) onSelect;
  final AppColorTokens c;
  const _TabPills({required this.selected, required this.labels,
      required this.onSelect, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: c.elevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Row(children: List.generate(labels.length, (i) {
        final active = i == selected;
        return Expanded(child: GestureDetector(
          onTap: () => onSelect(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: active ? c.accent : Colors.transparent,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Text(labels[i],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: active ? Colors.black : c.muted,
                  fontSize: 11,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                )),
          ),
        ));
      })),
    );
  }
}
