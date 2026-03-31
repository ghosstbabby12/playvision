import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/section_label.dart';

class FieldMapTab extends StatelessWidget {
  final List players;
  const FieldMapTab({super.key, required this.players});

  @override
  Widget build(BuildContext context) {
    final maxKm = players.fold<double>(0, (p, e) {
      final d = (e['distance_km'] as num?)?.toDouble() ?? 0;
      return d > p ? d : p;
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionLabel('AVERAGE FIELD POSITION'),
        const SizedBox(height: 14),
        AspectRatio(
          aspectRatio: 1.55,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: CustomPaint(
              painter: PitchPainter(players: players.cast(), maxKm: maxKm),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          LegendDot(color: AppColors.textHi,   label: 'High activity'),
          SizedBox(width: 20),
          LegendDot(color: AppColors.accent,   label: 'Medium'),
          SizedBox(width: 20),
          LegendDot(color: AppColors.accentLo, label: 'Low'),
        ]),
        const SizedBox(height: 30),
        const SectionLabel('ZONES'),
        const SizedBox(height: 12),
        ...players.map((p) => PlayerZoneRow(player: p as Map<String, dynamic>)),
      ]),
    );
  }
}

class LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const LegendDot({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 6),
    Text(label, style: const TextStyle(color: AppColors.dim, fontSize: 11)),
  ]);
}

class PlayerZoneRow extends StatelessWidget {
  final Map<String, dynamic> player;
  const PlayerZoneRow({super.key, required this.player});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(children: [
      SizedBox(width: 28,
          child: Text('${player['rank']}',
              style: const TextStyle(color: AppColors.muted, fontSize: 13, fontWeight: FontWeight.w700))),
      const SizedBox(width: 4),
      Text(player['zone'] as String? ?? '—',
          style: const TextStyle(color: AppColors.text, fontSize: 13)),
      const Spacer(),
      Text('${player['presence_pct']}%',
          style: const TextStyle(color: AppColors.dim, fontSize: 12)),
    ]),
  );
}

class PitchPainter extends CustomPainter {
  final List<Map<String, dynamic>> players;
  final double maxKm;
  const PitchPainter({required this.players, required this.maxKm});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFF0E1A0E));
    for (int i = 0; i < 10; i++) {
      if (i.isEven) {
        canvas.drawRect(Rect.fromLTWH(i * w / 10, 0, w / 10, h),
            Paint()..color = const Color(0xFF0C180C));
      }
    }

    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawRect(Rect.fromLTWH(8, 8, w - 16, h - 16), line);
    canvas.drawLine(Offset(w / 2, 8), Offset(w / 2, h - 8), line);
    canvas.drawCircle(Offset(w / 2, h / 2), h * 0.17, line);
    canvas.drawCircle(Offset(w / 2, h / 2), 2.5,
        Paint()..color = Colors.white.withValues(alpha: 0.3));

    final paW = w * 0.14; final paH = h * 0.52; final paT = (h - paH) / 2;
    canvas.drawRect(Rect.fromLTWH(8, paT, paW, paH), line);
    canvas.drawRect(Rect.fromLTWH(w - 8 - paW, paT, paW, paH), line);
    final gaW = w * 0.055; final gaH = h * 0.27; final gaT = (h - gaH) / 2;
    canvas.drawRect(Rect.fromLTWH(8, gaT, gaW, gaH), line);
    canvas.drawRect(Rect.fromLTWH(w - 8 - gaW, gaT, gaW, gaH), line);

    for (final p in players) {
      final xN   = (p['avg_x_norm'] as num).toDouble();
      final yN   = (p['avg_y_norm'] as num).toDouble();
      final km   = (p['distance_km'] as num?)?.toDouble() ?? 0;
      final rank = p['rank'] as int;
      final px = xN * w; final py = yN * h;
      final ratio = maxKm > 0 ? km / maxKm : 0.0;
      final color = ratio > 0.66 ? AppColors.textHi
          : ratio > 0.33 ? AppColors.accent
          : AppColors.accentLo;

      canvas.drawCircle(Offset(px + 1, py + 2), 14,
          Paint()..color = Colors.black.withValues(alpha: 0.4));
      canvas.drawCircle(Offset(px, py), 13, Paint()..color = color);
      canvas.drawCircle(Offset(px, py), 13,
          Paint()..color = Colors.white.withValues(alpha: 0.2)..strokeWidth = 1..style = PaintingStyle.stroke);

      final tp = TextPainter(
        text: TextSpan(text: '$rank', style: TextStyle(
          color: ratio > 0.4 ? Colors.black : Colors.white,
          fontSize: 10, fontWeight: FontWeight.w800,
        )),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(px - tp.width / 2, py - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}
