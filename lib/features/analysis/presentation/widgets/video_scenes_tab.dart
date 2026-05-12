import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../../../../../core/theme/app_color_tokens.dart';
import '../../../../../l10n/generated/app_localizations.dart';

class VideoScenesTab extends StatefulWidget {
  final String? videoUrl;
  final XFile? localFile;
  final List players;

  const VideoScenesTab({
    super.key,
    this.videoUrl,
    this.localFile,
    required this.players,
  });

  @override
  State<VideoScenesTab> createState() => _VideoScenesTabState();
}

class _VideoScenesTabState extends State<VideoScenesTab> {
  int _scene = 0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context)!;
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.border),
          ),
          child: Row(children: [
            _ScenePill(label: l10n.sceneVideo, icon: Icons.play_circle_outline, active: _scene == 0, onTap: () => setState(() => _scene = 0)),
            _ScenePill(label: l10n.sceneHeatmap, icon: Icons.blur_on_rounded, active: _scene == 1, onTap: () => setState(() => _scene = 1)),
            _ScenePill(label: l10n.scenePlayer, icon: Icons.person_pin_circle_outlined, active: _scene == 2, onTap: () => setState(() => _scene = 2)),
          ]),
        ),
      ),
      Expanded(child: IndexedStack(
        index: _scene,
        children: [
          _VideoScene(videoUrl: widget.videoUrl, localFile: widget.localFile),
          _TeamHeatmapScene(players: widget.players),
          _PlayerHeatmapScene(players: widget.players),
        ],
      )),
    ]);
  }
}

class _ScenePill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _ScenePill({required this.label, required this.icon, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: active ? c.accentLo : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            border: active ? Border.all(color: c.borderGreen) : null,
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: active ? c.accent : c.dim, size: 18),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(
              color: active ? c.accent : c.dim,
              fontSize: 10,
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            )),
          ]),
        ),
      ),
    );
  }
}

class _VideoScene extends StatefulWidget {
  final String? videoUrl;
  final XFile? localFile;
  const _VideoScene({this.videoUrl, this.localFile});

  @override
  State<_VideoScene> createState() => _VideoSceneState();
}

class _VideoSceneState extends State<_VideoScene> {
  VideoPlayerController? _ctrl;
  bool _initialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
      String url = widget.videoUrl!;
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'http://$url';
      }
      final ctrl = VideoPlayerController.networkUrl(Uri.parse(url));
      try {
        await ctrl.initialize();
        if (mounted) setState(() { _ctrl = ctrl; _initialized = true; });
        return;
      } catch (e) {
        await ctrl.dispose();
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          setState(() => _error = l10n.sceneNetworkError(e.toString(), url));
        }
        return;
      }
    }

    if (!kIsWeb && widget.localFile != null) {
      final ctrl = VideoPlayerController.file(File(widget.localFile!.path));
      try {
        await ctrl.initialize();
        if (mounted) setState(() { _ctrl = ctrl; _initialized = true; });
        return;
      } catch (e) {
        await ctrl.dispose();
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          setState(() => _error = l10n.sceneLocalError(e.toString()));
        }
        return;
      }
    }

    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      setState(() => _error = kIsWeb ? l10n.sceneWebError : l10n.sceneNoSource);
    }
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_ctrl == null) return;
    _ctrl!.value.isPlaying ? _ctrl!.pause() : _ctrl!.play();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context)!;

    if (_error != null) {
      return Center(child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.videocam_off_outlined, color: c.danger, size: 44),
          const SizedBox(height: 14),
          Text(l10n.sceneVideoNotAvailable, style: TextStyle(color: c.danger, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: c.muted, fontSize: 11, height: 1.5)),
        ]),
      ));
    }

    if (!_initialized) {
      return Center(child: CircularProgressIndicator(color: c.accent, strokeWidth: 2));
    }

    return Column(children: [
      Expanded(
        child: GestureDetector(
          onTap: _togglePlay,
          child: Container(
            color: Colors.black,
            child: Center(child: AspectRatio(
              aspectRatio: _ctrl!.value.aspectRatio,
              child: VideoPlayer(_ctrl!),
            )),
          ),
        ),
      ),
      Container(
        color: c.surface,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
        child: Column(children: [
          ValueListenableBuilder(
            valueListenable: _ctrl!,
            builder: (_, value, __) => Column(children: [
              VideoProgressIndicator(_ctrl!,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                      playedColor: c.accent,
                      bufferedColor: c.accentLo,
                      backgroundColor: c.elevated)),
              const SizedBox(height: 6),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(_fmt(value.position), style: TextStyle(color: c.muted, fontSize: 11)),
                Text(_fmt(value.duration), style: TextStyle(color: c.dim, fontSize: 11)),
              ]),
            ]),
          ),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _CtrlBtn(icon: Icons.replay_10_rounded, onTap: () {
              final p = _ctrl!.value.position - const Duration(seconds: 10);
              _ctrl!.seekTo(p < Duration.zero ? Duration.zero : p);
            }),
            const SizedBox(width: 16),
            ValueListenableBuilder(
              valueListenable: _ctrl!,
              builder: (_, value, __) => GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle),
                  child: Icon(value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: c.bg, size: 28),
                ),
              ),
            ),
            const SizedBox(width: 16),
            _CtrlBtn(icon: Icons.forward_10_rounded, onTap: () {
              final p = _ctrl!.value.position + const Duration(seconds: 10);
              final max = _ctrl!.value.duration;
              _ctrl!.seekTo(p > max ? max : p);
            }),
          ]),
        ]),
      ),
    ]);
  }
}

class _CtrlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CtrlBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: c.elevated, shape: BoxShape.circle,
          border: Border.all(color: c.border),
        ),
        child: Icon(icon, color: c.muted, size: 20),
      ),
    );
  }
}

class _TeamHeatmapScene extends StatelessWidget {
  final List players;
  const _TeamHeatmapScene({required this.players});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final cast = players.cast<Map<String, dynamic>>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l10n.sceneTeamHeatmapTitle, style: TextStyle(
            color: c.text, fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(l10n.sceneTeamHeatmapSub,
            style: TextStyle(color: c.muted, fontSize: 12)),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 1.5,
            child: CustomPaint(
              painter: _HeatmapPainter(players: cast, selectedRank: null, accentColor: c.accent),
            ),
          ),
        ),
        const SizedBox(height: 14),
        _HeatmapLegend(),
        const SizedBox(height: 20),
        Text(l10n.sceneZoneDensity, style: TextStyle(
            color: c.text, fontSize: 13, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        _ZoneDensityGrid(players: cast),
      ]),
    );
  }
}

class _PlayerHeatmapScene extends StatefulWidget {
  final List players;
  const _PlayerHeatmapScene({required this.players});

  @override
  State<_PlayerHeatmapScene> createState() => _PlayerHeatmapSceneState();
}

class _PlayerHeatmapSceneState extends State<_PlayerHeatmapScene> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final cast = widget.players.cast<Map<String, dynamic>>();
    if (cast.isEmpty) return Center(child: Text(l10n.sceneNoPlayerData, style: TextStyle(color: c.muted)));

    final selected = cast[_selectedIndex];
    final rank = selected['rank'] as int;
    final zone = selected['zone'] as String? ?? '—';
    final km = (selected['distance_km'] as num?)?.toStringAsFixed(2) ?? '—';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          height: 64,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: cast.length,
            itemBuilder: (_, i) {
              final p = cast[i];
              final r = p['rank'] as int;
              final isActive = i == _selectedIndex;
              return GestureDetector(
                onTap: () => setState(() => _selectedIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive ? c.accentLo : c.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isActive ? c.borderGreen : c.border),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('P$r', style: TextStyle(
                        color: isActive ? c.accent : c.text,
                        fontSize: 13, fontWeight: FontWeight.w800)),
                    Text(p['zone'] as String? ?? '—',
                        style: TextStyle(color: c.dim, fontSize: 9)),
                  ]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: c.accentLo,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.borderGreen),
          ),
          child: Row(children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle),
              child: Center(child: Text('$rank', style: const TextStyle(
                  color: Colors.black, fontSize: 12, fontWeight: FontWeight.w900))),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(l10n.scenePlayerInfo(rank, zone),
                style: TextStyle(color: c.textHi, fontSize: 13, fontWeight: FontWeight.w700))),
            Text(l10n.scenePlayerKm(km), style: TextStyle(
                color: c.accent, fontSize: 12, fontWeight: FontWeight.w700)),
          ]),
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 1.5,
            child: CustomPaint(
              painter: _HeatmapPainter(
                players: cast,
                selectedRank: rank,
                accentColor: c.accent,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        _HeatmapLegend(),
        if (selected['heatmap_zones'] != null) ...[
          const SizedBox(height: 20),
          Text(l10n.sceneZoneDistribution, style: TextStyle(
              color: c.text, fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          _ZoneBar(zones: Map<String, double>.from(
            (selected['heatmap_zones'] as Map).map((k, v) => MapEntry(k.toString(), (v as num).toDouble()))
          )),
        ],
      ]),
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  final List<Map<String, dynamic>> players;
  final int? selectedRank;
  final Color accentColor;

  const _HeatmapPainter({required this.players, required this.selectedRank, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFF071409));

    for (int i = 0; i < 8; i++) {
      canvas.drawRect(Rect.fromLTWH(i * w / 8, 0, w / 8, h),
          Paint()..color = i.isEven ? const Color(0xFF091B0C) : const Color(0xFF071409));
    }

    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const m = 10.0;
    canvas.drawRect(Rect.fromLTWH(m, m, w - m * 2, h - m * 2), line);
    canvas.drawLine(Offset(w / 2, m), Offset(w / 2, h - m), line);
    canvas.drawCircle(Offset(w / 2, h / 2), h * 0.18, line);

    final pbW = w * 0.15; final pbH = h * 0.5; final pbT = (h - pbH) / 2;
    canvas.drawRect(Rect.fromLTWH(m, pbT, pbW, pbH), line);
    canvas.drawRect(Rect.fromLTWH(w - m - pbW, pbT, pbW, pbH), line);

    final activePlayers = selectedRank == null
        ? players
        : players.where((p) => p['rank'] == selectedRank).toList();

    final allPoints = <Offset>[];
    for (final p in activePlayers) {
      final positions = p['positions_sample'] as List?;
      if (positions == null) continue;
      for (final pos in positions) {
        allPoints.add(Offset(
          (pos['x'] as num).toDouble() * w,
          (pos['y'] as num).toDouble() * h,
        ));
      }
    }

    for (final pt in allPoints) {
      canvas.drawCircle(pt, 22, Paint()
        ..color = const Color(0xFFFF4400).withValues(alpha: 0.04)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14));
      canvas.drawCircle(pt, 10, Paint()
        ..color = const Color(0xFFFFAA00).withValues(alpha: 0.07)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
    }

    for (int i = 0; i < allPoints.length; i++) {
      final pt = allPoints[i];
      int nearby = 0;
      for (int j = 0; j < allPoints.length; j++) {
        if (i == j) continue;
        if ((allPoints[j] - pt).distance < 30) nearby++;
      }
      if (nearby > 2) {
        canvas.drawCircle(pt, 14, Paint()
          ..color = const Color(0xFFFFFF00).withValues(alpha: math.min(0.03 * nearby, 0.18))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
      }
    }

    for (final p in activePlayers) {
      final xN = (p['avg_x_norm'] as num).toDouble();
      final yN = (p['avg_y_norm'] as num).toDouble();
      final r = p['rank'] as int;
      final px = xN * w;
      final py = yN * h;

      canvas.drawCircle(Offset(px, py), 11, Paint()
        ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.15));
      canvas.drawCircle(Offset(px, py), 10, Paint()..color = accentColor);
      canvas.drawCircle(Offset(px, py), 10, Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke);

      final tp = TextPainter(
        text: TextSpan(text: '$r',
            style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.w900)),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(px - tp.width / 2, py - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _HeatmapPainter old) =>
      old.selectedRank != selectedRank || old.accentColor != accentColor;
}

class _HeatmapLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context)!;
    return Row(children: [
      Text(l10n.sceneLow, style: TextStyle(color: c.dim, fontSize: 10)),
      const SizedBox(width: 8),
      Expanded(child: Container(
        height: 6,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          gradient: const LinearGradient(colors: [
            Color(0xFF071409),
            Color(0xFF0D3B1A),
            Color(0xFFFF4400),
            Color(0xFFFFAA00),
            Color(0xFFFFFF00),
          ]),
        ),
      )),
      const SizedBox(width: 8),
      Text(l10n.sceneHigh, style: TextStyle(color: c.dim, fontSize: 10)),
    ]);
  }
}

class _ZoneDensityGrid extends StatelessWidget {
  final List<Map<String, dynamic>> players;
  const _ZoneDensityGrid({required this.players});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final counts = <String, int>{};
    for (final p in players) {
      final z = p['zone'] as String? ?? 'Unknown';
      counts[z] = (counts[z] ?? 0) + 1;
    }
    if (counts.isEmpty) return const SizedBox.shrink();

    final max = counts.values.reduce(math.max).toDouble();

    return Column(
      children: counts.entries.map((e) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          SizedBox(width: 100, child: Text(e.key,
              style: TextStyle(color: c.muted, fontSize: 12))),
          const SizedBox(width: 8),
          Expanded(child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(children: [
              Container(height: 18, color: c.surface),
              FractionallySizedBox(
                widthFactor: max > 0 ? e.value / max : 0,
                child: Container(
                  height: 18,
                  decoration: BoxDecoration(
                    color: c.accent.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ]),
          )),
          const SizedBox(width: 8),
          Text('${e.value}p', style: TextStyle(
              color: c.dim, fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
      )).toList(),
    );
  }
}

class _ZoneBar extends StatelessWidget {
  final Map<String, double> zones;
  const _ZoneBar({required this.zones});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final sorted = zones.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sorted.map((e) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          SizedBox(width: 100, child: Text(e.key,
              style: TextStyle(color: c.muted, fontSize: 11))),
          const SizedBox(width: 8),
          Expanded(child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(children: [
              Container(height: 16, color: c.surface),
              FractionallySizedBox(
                widthFactor: (e.value / 100).clamp(0.0, 1.0),
                child: Container(
                  height: 16,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [c.accentLo, c.accent]),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ]),
          )),
          const SizedBox(width: 8),
          SizedBox(width: 36, child: Text('${e.value.toStringAsFixed(0)}%',
              textAlign: TextAlign.right,
              style: TextStyle(color: c.accent, fontSize: 11, fontWeight: FontWeight.w700))),
        ]),
      )).toList(),
    );
  }
}