import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_color_tokens.dart';
import '../../../../../l10n/generated/app_localizations.dart';

class FieldMapTab extends StatefulWidget {
  final List players;
  const FieldMapTab({super.key, required this.players});

  @override
  State<FieldMapTab> createState() => _FieldMapTabState();
}

class _FieldMapTabState extends State<FieldMapTab> {
  int? _selectedRank;

  @override
  Widget build(BuildContext context) {
    final c    = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final players = widget.players.cast<Map<String, dynamic>>();

    if (players.isEmpty) {
      return Center(child: Text(l10n.fieldNoPlayerData,
          style: TextStyle(color: c.muted)));
    }

    final maxKm    = players.fold<double>(0, (p, e) => math.max(p, (e['distance_km'] as num?)?.toDouble() ?? 0));
    final teamPoss = players.fold<double>(0, (s, p) => s + ((p['possession_pct'] as num?)?.toDouble() ?? 0));
    final oppPoss  = math.max(0.0, 100.0 - teamPoss);
    final formation = _detectFormation(players);
    final selected  = _selectedRank != null
        ? players.firstWhere((p) => p['rank'] == _selectedRank, orElse: () => <String, dynamic>{})
        : null;

    return SingleChildScrollView(
      child: Column(children: [
        _PossessionBar(teamPoss: teamPoss, oppPoss: oppPoss),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AspectRatio(
              aspectRatio: 1.5,
              child: GestureDetector(
                onTapDown: (d) => _handleTap(d.localPosition, players, context),
                child: CustomPaint(
                  painter: _TacticalPitchPainter(
                    players:      players,
                    maxKm:        maxKm,
                    selectedRank: _selectedRank,
                    accentColor:  c.accent,
                  ),
                ),
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(children: [
            _InfoChip(label: l10n.fieldFormation, value: formation),
            const SizedBox(width: 8),
            _InfoChip(label: l10n.fieldPlayers, value: '${players.length}'),
            const SizedBox(width: 8),
            _InfoChip(label: l10n.fieldAvgSpeed, value: '${_avgSpeed(players)} km/h'),
          ]),
        ),

        if (selected != null && selected.isNotEmpty)
          _PlayerDetailCard(
            player: selected,
            onClose: () => setState(() => _selectedRank = null),
          ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _LegendDot(color: const Color(0xFF7CFC00), label: l10n.fieldHighActivity),
            const SizedBox(width: 20),
            _LegendDot(color: c.accent, label: l10n.fieldMedium),
            const SizedBox(width: 20),
            _LegendDot(color: const Color(0xFF2D5A3D), label: l10n.fieldLow),
          ]),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(children: [
            _TableHeader(),
            const SizedBox(height: 6),
            ...players.map((p) => _PlayerRow(
              player: p,
              maxKm: maxKm,
              selected: _selectedRank == (p['rank'] as int),
              onTap: () => setState(() {
                final r = p['rank'] as int;
                _selectedRank = _selectedRank == r ? null : r;
              }),
            )),
          ]),
        ),
      ]),
    );
  }

  void _handleTap(Offset local, List<Map<String, dynamic>> players, BuildContext ctx) {
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null) return;
    final screenW = box.size.width - 32;
    final fieldH  = screenW / 1.5;
    const topOffset  = 68.0;
    const leftOffset = 16.0;
    final fx = (local.dx - leftOffset) / screenW;
    final fy = (local.dy - topOffset) / fieldH;
    if (fx < 0 || fx > 1 || fy < 0 || fy > 1) return;
    double best = double.infinity;
    int? bestRank;
    for (final p in players) {
      final dx = (p['avg_x_norm'] as num).toDouble() - fx;
      final dy = (p['avg_y_norm'] as num).toDouble() - fy;
      final dist = math.sqrt(dx * dx + dy * dy);
      if (dist < best && dist < 0.08) {
        best = dist;
        bestRank = p['rank'] as int;
      }
    }
    setState(() => _selectedRank = bestRank);
  }

  String _detectFormation(List<Map<String, dynamic>> players) {
    if (players.length < 4) return '—';
    final sorted = [...players]..sort(
        (a, b) => (b['avg_y_norm'] as num).compareTo(a['avg_y_norm'] as num));
    final outfield = sorted.skip(1).toList();
    final defs = outfield.where((p) => (p['avg_y_norm'] as num) > 0.62).length;
    final mids = outfield.where((p) {
      final y = (p['avg_y_norm'] as num).toDouble();
      return y >= 0.38 && y <= 0.62;
    }).length;
    final atts = outfield.where((p) => (p['avg_y_norm'] as num) < 0.38).length;
    return '$defs-$mids-$atts';
  }

  String _avgSpeed(List<Map<String, dynamic>> players) {
    if (players.isEmpty) return '—';
    final total = players.fold<double>(
        0, (s, p) => s + ((p['speed_kmh'] as num?)?.toDouble() ?? (p['speed_ms'] as num?)?.toDouble() ?? 0));
    return (total / players.length).toStringAsFixed(1);
  }
}

// ── Possession bar ─────────────────────────────────────────────────────────────
class _PossessionBar extends StatelessWidget {
  final double teamPoss;
  final double oppPoss;
  const _PossessionBar({required this.teamPoss, required this.oppPoss});

  @override
  Widget build(BuildContext context) {
    final c       = context.colors;
    final l10n    = AppLocalizations.of(context)!;
    final teamPct = teamPoss.clamp(0.0, 100.0);
    final oppPct  = oppPoss.clamp(0.0, 100.0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.border),
        ),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l10n.fieldYourTeam, style: TextStyle(
                  color: c.accent, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
              Text('${teamPct.toStringAsFixed(0)}%',
                  style: TextStyle(color: c.textHi, fontSize: 22, fontWeight: FontWeight.w900)),
            ]),
            Text(l10n.possession, style: TextStyle(color: c.muted, fontSize: 11, letterSpacing: 0.5)),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(l10n.fieldOpponent, style: TextStyle(
                  color: c.dim, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
              Text('${oppPct.toStringAsFixed(0)}%',
                  style: TextStyle(color: c.muted, fontSize: 22, fontWeight: FontWeight.w900)),
            ]),
          ]),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Row(children: [
              Flexible(
                flex: teamPct.round(),
                child: Container(height: 6, color: c.accent),
              ),
              Flexible(
                flex: math.max(oppPct.round(), 1),
                child: Container(height: 6, color: c.elevated),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

// ── Tactical pitch painter (sin textos visibles — sin cambios) ─────────────────
class _TacticalPitchPainter extends CustomPainter {
  final List<Map<String, dynamic>> players;
  final double maxKm;
  final int? selectedRank;
  final Color accentColor;

  const _TacticalPitchPainter({
    required this.players,
    required this.maxKm,
    required this.accentColor,
    this.selectedRank,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bgRect = Rect.fromLTWH(0, 0, w, h);
    canvas.drawRect(bgRect, Paint()..color = const Color(0xFF0B1A0D));
    final stripePaint = Paint()..style = PaintingStyle.fill;
    const stripes = 8;
    for (int i = 0; i < stripes; i++) {
      stripePaint.color = i.isEven ? const Color(0xFF0D1F10) : const Color(0xFF0B1A0D);
      canvas.drawRect(Rect.fromLTWH(i * w / stripes, 0, w / stripes, h), stripePaint);
    }
    final vignette = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.25)],
      ).createShader(bgRect);
    canvas.drawRect(bgRect, vignette);
    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    const m = 10.0;
    final fieldRect = Rect.fromLTWH(m, m, w - m * 2, h - m * 2);
    canvas.drawRRect(RRect.fromRectAndRadius(fieldRect, const Radius.circular(3)), line);
    canvas.drawLine(Offset(w / 2, m), Offset(w / 2, h - m), line);
    canvas.drawCircle(Offset(w / 2, h / 2), h * 0.18, line);
    canvas.drawCircle(Offset(w / 2, h / 2), 3, Paint()..color = Colors.white.withValues(alpha: 0.4));
    final pbW = w * 0.15;
    final pbH = h * 0.50;
    final pbT = (h - pbH) / 2;
    canvas.drawRect(Rect.fromLTWH(m, pbT, pbW, pbH), line);
    canvas.drawRect(Rect.fromLTWH(w - m - pbW, pbT, pbW, pbH), line);
    final gbW = w * 0.06;
    final gbH = h * 0.26;
    final gbT = (h - gbH) / 2;
    canvas.drawRect(Rect.fromLTWH(m, gbT, gbW, gbH), line);
    canvas.drawRect(Rect.fromLTWH(w - m - gbW, gbT, gbW, gbH), line);
    final goalH = h * 0.12;
    final goalT = (h - goalH) / 2;
    canvas.drawRect(Rect.fromLTWH(m - 5, goalT, 5, goalH), line..strokeWidth = 1.5);
    canvas.drawRect(Rect.fromLTWH(w - m, goalT, 5, goalH), line..strokeWidth = 1.5);
    final cornerLine = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    const cr = 8.0;
    canvas.drawArc(Rect.fromCircle(center: Offset(m, m), radius: cr), 0, math.pi / 2, false, cornerLine);
    canvas.drawArc(Rect.fromCircle(center: Offset(w - m, m), radius: cr), math.pi / 2, math.pi / 2, false, cornerLine);
    canvas.drawArc(Rect.fromCircle(center: Offset(m, h - m), radius: cr), -math.pi / 2, -math.pi / 2, false, cornerLine);
    canvas.drawArc(Rect.fromCircle(center: Offset(w - m, h - m), radius: cr), -math.pi / 2, math.pi / 2, false, cornerLine);
    canvas.drawCircle(Offset(m + pbW * 0.75, h / 2), 2.5, Paint()..color = Colors.white.withValues(alpha: 0.35));
    canvas.drawCircle(Offset(w - m - pbW * 0.75, h / 2), 2.5, Paint()..color = Colors.white.withValues(alpha: 0.35));
    for (final p in players) {
      final positions = p['positions_sample'] as List?;
      if (positions == null || positions.isEmpty) continue;
      final km    = (p['distance_km'] as num?)?.toDouble() ?? 0;
      final ratio = maxKm > 0 ? km / maxKm : 0.0;
      final color = _playerColor(ratio).withValues(alpha: 0.08);
      for (final pos in positions) {
        final px = (pos['x'] as num).toDouble() * w;
        final py = (pos['y'] as num).toDouble() * h;
        canvas.drawCircle(Offset(px, py), 6,
            Paint()..color = color..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
      }
    }
    for (final p in players) {
      final xN   = (p['avg_x_norm'] as num).toDouble();
      final yN   = (p['avg_y_norm'] as num).toDouble();
      final km   = (p['distance_km'] as num?)?.toDouble() ?? 0;
      final rank = p['rank'] as int;
      final isSelected = selectedRank == rank;
      final px    = xN * w;
      final py    = yN * h;
      final ratio  = maxKm > 0 ? km / maxKm : 0.0;
      final color  = _playerColor(ratio);
      final radius = isSelected ? 16.0 : 13.0;
      if (isSelected || ratio > 0.5) {
        canvas.drawCircle(
          Offset(px, py), radius + 6,
          Paint()
            ..color = color.withValues(alpha: isSelected ? 0.35 : 0.15)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        );
      }
      canvas.drawCircle(Offset(px + 1.5, py + 2), radius,
          Paint()..color = Colors.black.withValues(alpha: 0.5));
      canvas.drawCircle(Offset(px, py), radius, Paint()..color = color);
      canvas.drawCircle(
        Offset(px, py), radius,
        Paint()
          ..color = (isSelected ? Colors.white : Colors.white.withValues(alpha: 0.4))
          ..strokeWidth = isSelected ? 2.0 : 1.0
          ..style = PaintingStyle.stroke,
      );
      final textColor = ratio > 0.45 ? const Color(0xFF0B1A0D) : Colors.white.withValues(alpha: 0.9);
      final tp = TextPainter(
        text: TextSpan(
          text: '$rank',
          style: TextStyle(
            color: textColor,
            fontSize: isSelected ? 11 : 9,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(px - tp.width / 2, py - tp.height / 2));
    }
  }

  Color _playerColor(double ratio) {
    if (ratio > 0.66) return const Color(0xFF7CFC00);
    if (ratio > 0.33) return accentColor;
    return const Color(0xFF2D5A3D);
  }

  @override
  bool shouldRepaint(covariant _TacticalPitchPainter old) =>
      old.selectedRank != selectedRank || old.accentColor != accentColor;
}

// ── Info chips ─────────────────────────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: c.border),
        ),
        child: Column(children: [
          Text(value, style: TextStyle(
              color: c.textHi, fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: c.dim, fontSize: 10)),
        ]),
      ),
    );
  }
}

// ── Selected player detail card ────────────────────────────────────────────────
class _PlayerDetailCard extends StatelessWidget {
  final Map<String, dynamic> player;
  final VoidCallback onClose;
  const _PlayerDetailCard({required this.player, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final c     = context.colors;
    final l10n  = AppLocalizations.of(context)!;
    final rank  = player['rank'] as int;
    final zone  = player['zone'] as String? ?? '—';
    final km    = (player['distance_km'] as num?)?.toStringAsFixed(2) ?? '—';
    final poss  = (player['possession_pct'] as num?)?.toStringAsFixed(1) ?? '—';
    final speed = (player['speed_kmh'] as num?)?.toStringAsFixed(1)
        ?? (player['speed_ms'] as num?)?.toStringAsFixed(1) ?? '—';
    final pres  = (player['presence_pct'] as num?)?.toStringAsFixed(0) ?? '—';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.accentLo,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.borderGreen),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle),
              child: Center(child: Text('$rank', style: const TextStyle(
                  color: Colors.black, fontSize: 14, fontWeight: FontWeight.w900))),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(l10n.fieldPlayerLabel(rank, zone),
                style: TextStyle(color: c.textHi, fontSize: 14, fontWeight: FontWeight.w700))),
            GestureDetector(onTap: onClose,
                child: Icon(Icons.close_rounded, color: c.muted, size: 18)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _StatPill('$km km',   l10n.fieldDistance),
            const SizedBox(width: 8),
            _StatPill('$speed km/h', l10n.fieldSpeed),
            const SizedBox(width: 8),
            _StatPill('$poss%',   l10n.possession),
            const SizedBox(width: 8),
            _StatPill('$pres%',   l10n.fieldPresence),
          ]),
        ]),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String value;
  final String label;
  const _StatPill(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Expanded(
      child: Column(children: [
        Text(value, style: TextStyle(
            color: c.accent, fontSize: 13, fontWeight: FontWeight.w800)),
        Text(label, style: TextStyle(color: c.muted, fontSize: 9)),
      ]),
    );
  }
}

// ── Player list table ──────────────────────────────────────────────────────────
class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    final c    = context.colors;
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(children: [
        SizedBox(width: 28, child: Text('#',
            style: TextStyle(color: c.dim, fontSize: 10, fontWeight: FontWeight.w700))),
        const SizedBox(width: 8),
        Expanded(child: Text(l10n.tableZone,
            style: TextStyle(color: c.dim, fontSize: 10, fontWeight: FontWeight.w700))),
        SizedBox(width: 50, child: Text(l10n.tableDist,
            textAlign: TextAlign.right,
            style: TextStyle(color: c.dim, fontSize: 10, fontWeight: FontWeight.w700))),
        SizedBox(width: 50, child: Text(l10n.tablePoss,
            textAlign: TextAlign.right,
            style: TextStyle(color: c.dim, fontSize: 10, fontWeight: FontWeight.w700))),
        SizedBox(width: 50, child: Text(l10n.tablePres,
            textAlign: TextAlign.right,
            style: TextStyle(color: c.dim, fontSize: 10, fontWeight: FontWeight.w700))),
      ]),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  final Map<String, dynamic> player;
  final double maxKm;
  final bool selected;
  final VoidCallback onTap;
  const _PlayerRow({required this.player, required this.maxKm, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c    = context.colors;
    final rank = player['rank'] as int;
    final zone = player['zone'] as String? ?? '—';
    final km   = (player['distance_km'] as num?)?.toDouble() ?? 0;
    final poss = (player['possession_pct'] as num?)?.toStringAsFixed(1) ?? '—';
    final pres = (player['presence_pct'] as num?)?.toStringAsFixed(0) ?? '—';
    final ratio = maxKm > 0 ? km / maxKm : 0.0;
    final color = ratio > 0.66
        ? const Color(0xFF7CFC00)
        : ratio > 0.33 ? c.accent : const Color(0xFF2D5A3D);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? c.accentLo : c.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? c.borderGreen : c.border),
        ),
        child: Row(children: [
          Container(
            width: 22, height: 22,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Center(child: Text('$rank', style: TextStyle(
                color: ratio > 0.4 ? Colors.black : Colors.white,
                fontSize: 9, fontWeight: FontWeight.w900))),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(zone, style: TextStyle(color: c.text, fontSize: 12))),
          SizedBox(width: 50, child: Text('${km.toStringAsFixed(2)} km',
              textAlign: TextAlign.right,
              style: TextStyle(color: c.text, fontSize: 11, fontWeight: FontWeight.w600))),
          SizedBox(width: 50, child: Text('$poss%',
              textAlign: TextAlign.right,
              style: TextStyle(color: c.muted, fontSize: 11))),
          SizedBox(width: 50, child: Text('$pres%',
              textAlign: TextAlign.right,
              style: TextStyle(color: c.dim, fontSize: 11))),
        ]),
      ),
    );
  }
}

// ── Legend dot ─────────────────────────────────────────────────────────────────
class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 8, height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 6),
    Text(label, style: TextStyle(color: context.colors.dim, fontSize: 11)),
  ]);
}
