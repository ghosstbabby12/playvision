import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:playvision/core/theme/app_color_tokens.dart';
import '../../data/player_profile_service.dart';
import '../../domain/player_profile.dart';
import '../../domain/player_token.dart';

class PlayerStatsSheet extends StatefulWidget {
  final PlayerToken token;
  const PlayerStatsSheet({super.key, required this.token});

  static void show(BuildContext context, PlayerToken token) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PlayerStatsSheet(token: token),
    );
  }

  @override
  State<PlayerStatsSheet> createState() => _PlayerStatsSheetState();
}

class _PlayerStatsSheetState extends State<PlayerStatsSheet> {
  PlayerProfile? _profile;
  bool _loading = true;
  int _tab = 0; // 0=Overview 1=Last Match 2=AI

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await PlayerProfileService.instance.fetch(widget.token.id);
    if (mounted) setState(() { _profile = p; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: c.border2)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Handle
        Center(
          child: Container(width: 40, height: 4,
              decoration: BoxDecoration(color: c.border2, borderRadius: BorderRadius.circular(2))),
        ),
        const SizedBox(height: 18),

        // ── Header ────────────────────────────────────────────────────────────
        _Header(token: widget.token, profile: _profile, c: c),
        const SizedBox(height: 18),

        // ── Tab pills ─────────────────────────────────────────────────────────
        _TabPills(
          selected: _tab,
          labels: const ['Overview', 'Last Match', 'AI Insights'],
          onSelect: (i) => setState(() => _tab = i),
          c: c,
        ),
        const SizedBox(height: 18),

        // ── Body ──────────────────────────────────────────────────────────────
        if (_loading)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator(color: c.accent, strokeWidth: 1.5)),
          )
        else if (_tab == 0)
          _OverviewTab(token: widget.token, profile: _profile, c: c)
        else if (_tab == 1)
          _LastMatchTab(profile: _profile, token: widget.token, c: c)
        else
          _AiTab(profile: _profile, token: widget.token, c: c),
      ]),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final PlayerToken token;
  final PlayerProfile? profile;
  final AppColorTokens c;
  const _Header({required this.token, required this.profile, required this.c});

  @override
  Widget build(BuildContext context) {
    final overall = profile?.overall ?? (token.stats['rating'] as num? ?? 7.0);
    final pos     = profile?.position ?? token.position;
    final photoUrl = profile?.photoUrl;

    return Row(children: [
      // Avatar
      Container(
        width: 58, height: 58,
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
                style: TextStyle(color: _posColor(pos), fontSize: 11, fontWeight: FontWeight.w800)))
            : null,
      ),
      const SizedBox(width: 14),

      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(profile?.name ?? token.name,
            style: TextStyle(color: c.textHi, fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Row(children: [
          _Pill(text: pos, color: _posColor(pos)),
          const SizedBox(width: 6),
          if (profile?.foot != null) _Pill(text: '${profile!.foot} foot', color: c.muted),
          if (profile?.age != null) ...[
            const SizedBox(width: 6),
            _Pill(text: '${profile!.age} yrs', color: c.muted),
          ],
        ]),
      ])),

      // Overall / Rating
      Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Text(
          overall is int ? '$overall' : (overall as double).toStringAsFixed(1),
          style: TextStyle(color: c.accent, fontSize: 34, fontWeight: FontWeight.w900, height: 1),
        ),
        Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.star_rounded, color: c.accent, size: 13),
          const SizedBox(width: 2),
          Text(profile != null ? 'OVR' : 'AVG',
              style: TextStyle(color: c.accent, fontSize: 10, fontWeight: FontWeight.w700)),
        ]),
      ]),
    ]);
  }

  Color _posColor(String pos) {
    if (pos == 'GK') return const Color(0xFFF59E0B);
    if (pos.contains('B') && !pos.contains('A')) return const Color(0xFF3B82F6);
    if (pos.contains('M') || pos.contains('D')) return const Color(0xFF8B5CF6);
    return const Color(0xFF3DCF6E);
  }
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
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}

// ── Tab pills ──────────────────────────────────────────────────────────────────

class _TabPills extends StatelessWidget {
  final int selected;
  final List<String> labels;
  final void Function(int) onSelect;
  final AppColorTokens c;
  const _TabPills({required this.selected, required this.labels, required this.onSelect, required this.c});

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
                  fontSize: 12,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                )),
          ),
        ));
      })),
    );
  }
}

// ── Overview tab ───────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final PlayerToken token;
  final PlayerProfile? profile;
  final AppColorTokens c;
  const _OverviewTab({required this.token, required this.profile, required this.c});

  @override
  Widget build(BuildContext context) {
    final attrs = profile?.attributes;

    if (attrs == null) {
      // Fallback: show radar from PlayerToken
      return SizedBox(
        height: 200,
        child: RadarChart(values: token.radarValues, accentColor: c.accent),
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
      // 2×3 grid of attribute bars
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 3.2,
        children: bars.map((b) => _AttrBar(label: b.$1, value: b.$2, color: b.$3, c: c)).toList(),
      ),
      const SizedBox(height: 16),
      if (profile?.heightCm != null)
        Row(children: [
          Icon(Icons.height_rounded, color: c.dim, size: 16),
          const SizedBox(width: 6),
          Text('${profile!.heightCm} cm', style: TextStyle(color: c.muted, fontSize: 12)),
          const SizedBox(width: 16),
          Icon(Icons.sports_soccer, color: c.dim, size: 14),
          const SizedBox(width: 6),
          Text('${profile!.foot} foot', style: TextStyle(color: c.muted, fontSize: 12)),
        ]),
    ]);
  }
}

class _AttrBar extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final AppColorTokens c;
  const _AttrBar({required this.label, required this.value, required this.color, required this.c});

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
          child: Text(label, style: TextStyle(color: c.muted, fontSize: 10, fontWeight: FontWeight.w700))),
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
        Text('$value',
            style: TextStyle(color: c.textHi, fontSize: 13, fontWeight: FontWeight.w800)),
      ]),
    );
  }
}

// ── Last Match tab ─────────────────────────────────────────────────────────────

class _LastMatchTab extends StatelessWidget {
  final PlayerProfile? profile;
  final PlayerToken token;
  final AppColorTokens c;
  const _LastMatchTab({required this.profile, required this.token, required this.c});

  @override
  Widget build(BuildContext context) {
    final lm = profile?.lastMatch;

    // Build a stat grid from either API data or mock token stats
    final stats = lm != null
        ? [
            ('⚽', 'Goals',    '${lm.goals ?? 0}'),
            ('🅰️', 'Assists',  '${lm.assists ?? 0}'),
            ('📏', 'Distance', '${lm.distanceKm?.toStringAsFixed(1) ?? '—'} km'),
            ('🎯', 'Passes',   '${lm.passes ?? 0}'),
            ('✅', 'Accuracy', '${lm.passAccuracy ?? 0}%'),
            ('⏱', 'Minutes',  '${lm.minutes ?? 90}\''),
          ]
        : [
            ('⚽', 'Goals',    '${token.stats['goals']}'),
            ('🅰️', 'Assists',  '${token.stats['assists']}'),
            ('📏', 'Distance', '${(token.stats['distance'] as num).toStringAsFixed(1)} km'),
            ('🎯', 'Passes',   '${token.stats['passes']}'),
            ('✅', 'Accuracy', '${token.stats['passAccuracy']}%'),
            ('⏱', 'Minutes',  "${token.stats['minutes']}'"),
          ];

    final rating = lm?.rating ?? (token.stats['rating'] as num?)?.toDouble();

    return Column(children: [
      // Big rating
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
                style: TextStyle(color: c.accent, fontSize: 32, fontWeight: FontWeight.w900)),
            const SizedBox(width: 8),
            Text('Match rating', style: TextStyle(color: c.muted, fontSize: 12)),
          ]),
        ),
        const SizedBox(height: 16),
      ],

      // Stats grid 2×3
      GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.6,
        children: stats.map((s) => _StatCell(emoji: s.$1, label: s.$2, value: s.$3, c: c)).toList(),
      ),

      // History sparkline
      if (profile != null && profile!.history.isNotEmpty) ...[
        const SizedBox(height: 20),
        Text('Rating trend', style: TextStyle(color: c.muted, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        SizedBox(
          height: 56,
          child: _Sparkline(
            values: profile!.history.map((h) => h.rating).toList().reversed.toList(),
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
  const _StatCell({required this.emoji, required this.label, required this.value, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: c.elevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.border),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: c.textHi, fontSize: 16, fontWeight: FontWeight.w800)),
        Text(label, style: TextStyle(color: c.muted, fontSize: 9)),
      ]),
    );
  }
}

// ── AI Insights tab ────────────────────────────────────────────────────────────

class _AiTab extends StatelessWidget {
  final PlayerProfile? profile;
  final PlayerToken token;
  final AppColorTokens c;
  const _AiTab({required this.profile, required this.token, required this.c});

  @override
  Widget build(BuildContext context) {
    if (profile == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text(
          'Connect to server to see AI insights.',
          style: TextStyle(color: c.muted, fontSize: 13),
        )),
      );
    }

    final ai = profile!.aiInsights;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Form status
      _InsightCard(
        icon: Icons.trending_up_rounded,
        title: 'Current Form',
        value: ai.form,
        sub: 'Avg ${ai.avgRating.toStringAsFixed(1)} over last matches',
        c: c,
        highlight: true,
      ),
      const SizedBox(height: 10),

      // Best position
      _InsightCard(
        icon: Icons.place_rounded,
        title: 'Best Position',
        value: ai.bestPosition,
        sub: 'Based on heatmap & performance data',
        c: c,
      ),
      const SizedBox(height: 10),

      // Recommendation
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.accentLo,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.borderGreen),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.smart_toy_outlined, color: c.accent, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Coach Recommendation',
                style: TextStyle(color: c.accent, fontSize: 11, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(ai.recommendation,
                style: TextStyle(color: c.text, fontSize: 13, height: 1.5)),
          ])),
        ]),
      ),

      // Radar chart
      const SizedBox(height: 20),
      SizedBox(
        height: 180,
        child: RadarChart(values: token.radarValues, accentColor: c.accent),
      ),
    ]);
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final String title, value, sub;
  final AppColorTokens c;
  final bool highlight;
  const _InsightCard({
    required this.icon, required this.title, required this.value,
    required this.sub, required this.c, this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: c.elevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.border),
      ),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: c.accentLo,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: c.accent, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(color: c.muted, fontSize: 11)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(color: c.textHi, fontSize: 16, fontWeight: FontWeight.w800)),
          Text(sub, style: TextStyle(color: c.muted, fontSize: 10)),
        ])),
      ]),
    );
  }
}

// ── Sparkline ──────────────────────────────────────────────────────────────────

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
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);

    // Dots
    for (int i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final y = size.height * (1 - (values[i] - minV) / range);
      canvas.drawCircle(Offset(x, y), 3.5, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant _SparkPainter old) => false;
}

// ── Radar chart (re-exported from here) ───────────────────────────────────────

class RadarChart extends StatelessWidget {
  final List<double> values;
  final Color accentColor;
  static const _labels = ['Speed', 'Pass', 'Shoot', 'Defend', 'Physical'];

  const RadarChart({super.key, required this.values, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RadarPainter(values: values, accentColor: accentColor),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Stack(children: List.generate(_labels.length, (i) {
          const r = 0.85;
          final angle = (i * 2 * math.pi / _labels.length) - math.pi / 2;
          final tx = 0.5 + (r + 0.08) * math.cos(angle);
          final ty = 0.5 + (r + 0.08) * math.sin(angle);
          return Align(
            alignment: Alignment(tx * 2 - 1, ty * 2 - 1),
            child: Text(_labels[i],
                style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w600)),
          );
        })),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final List<double> values;
  final Color accentColor;
  const _RadarPainter({required this.values, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final n  = values.length;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = math.min(cx, cy) * 0.78;

    final ringP = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (int ring = 1; ring <= 4; ring++) {
      final rr = r * ring / 4;
      final path = Path();
      for (int i = 0; i < n; i++) {
        final a = (i * 2 * math.pi / n) - math.pi / 2;
        final x = cx + rr * math.cos(a);
        final y = cy + rr * math.sin(a);
        i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
      }
      path.close();
      canvas.drawPath(path, ringP);
    }

    final axisP = Paint()..color = Colors.white.withValues(alpha: 0.12)..strokeWidth = 0.8;
    for (int i = 0; i < n; i++) {
      final a = (i * 2 * math.pi / n) - math.pi / 2;
      canvas.drawLine(Offset(cx, cy),
          Offset(cx + r * math.cos(a), cy + r * math.sin(a)), axisP);
    }

    final dataPath = Path();
    for (int i = 0; i < n; i++) {
      final a  = (i * 2 * math.pi / n) - math.pi / 2;
      final rv = r * values[i];
      final x  = cx + rv * math.cos(a);
      final y  = cy + rv * math.sin(a);
      i == 0 ? dataPath.moveTo(x, y) : dataPath.lineTo(x, y);
    }
    dataPath.close();

    canvas.drawPath(dataPath,
        Paint()..color = accentColor.withValues(alpha: 0.22)..style = PaintingStyle.fill);
    canvas.drawPath(dataPath,
        Paint()..color = accentColor..style = PaintingStyle.stroke..strokeWidth = 2.0);

    for (int i = 0; i < n; i++) {
      final a  = (i * 2 * math.pi / n) - math.pi / 2;
      final rv = r * values[i];
      canvas.drawCircle(
        Offset(cx + rv * math.cos(a), cy + rv * math.sin(a)),
        3.5,
        Paint()..color = accentColor,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter old) => true;
}
