import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../../../../../core/theme/app_colors.dart';

class VideoPlayerTab extends StatefulWidget {
  final String? videoUrl;
  final XFile? localFile;
  const VideoPlayerTab({super.key, this.videoUrl, this.localFile});

  @override
  State<VideoPlayerTab> createState() => _VideoPlayerTabState();
}

class _VideoPlayerTabState extends State<VideoPlayerTab> {
  VideoPlayerController? _ctrl;
  bool _initialized = false;
  bool _hasError    = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // 1. Intentar URL de red (video anotado del backend)
    if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
      final ctrl = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!));
      try {
        await ctrl.initialize();
        if (mounted) setState(() { _ctrl = ctrl; _initialized = true; });
        return;
      } catch (_) {
        await ctrl.dispose();
      }
    }

    // 2. Fallback: archivo local (solo en mobile/desktop, no en web)
    if (!kIsWeb && widget.localFile != null) {
      final ctrl = VideoPlayerController.file(File(widget.localFile!.path));
      try {
        await ctrl.initialize();
        if (mounted) setState(() { _ctrl = ctrl; _initialized = true; });
        return;
      } catch (_) {
        await ctrl.dispose();
      }
    }

    if (mounted) setState(() => _hasError = true);
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError || (_ctrl == null && !_initialized)) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.videocam_off_outlined, color: AppColors.accentLo, size: 48),
          const SizedBox(height: 16),
          const Text('Video not available',
              style: TextStyle(color: AppColors.muted, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Analyse a match to see the annotated video',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.dim, fontSize: 12)),
          if (!_initialized && !_hasError) ...[
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: AppColors.accent, strokeWidth: 1.5),
          ],
        ]),
      );
    }

    if (!_initialized) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2),
      );
    }

    return Column(children: [
      // ── Video ─────────────────────────────────────────────
      Expanded(
        child: GestureDetector(
          onTap: _togglePlay,
          child: Container(
            color: Colors.black,
            child: Center(
              child: AspectRatio(
                aspectRatio: _ctrl!.value.aspectRatio,
                child: VideoPlayer(_ctrl!),
              ),
            ),
          ),
        ),
      ),

      // ── Controls ──────────────────────────────────────────
      Container(
        color: AppColors.surface,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
        child: Column(children: [
          // Progress bar + times
          ValueListenableBuilder(
            valueListenable: _ctrl!,
            builder: (_, value, __) {
              final pos   = value.position;
              final total = value.duration;
              return Column(children: [
                VideoProgressIndicator(
                  _ctrl!,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: AppColors.accent,
                    bufferedColor: AppColors.elevated,
                    backgroundColor: AppColors.accentLo,
                  ),
                ),
                const SizedBox(height: 6),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(_formatDuration(pos),
                      style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                  Text(_formatDuration(total),
                      style: const TextStyle(color: AppColors.dim, fontSize: 11)),
                ]),
              ]);
            },
          ),

          const SizedBox(height: 8),

          // Playback buttons
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            // -10s
            _CtrlButton(
              icon: Icons.replay_10_rounded,
              onTap: () {
                final pos = _ctrl!.value.position - const Duration(seconds: 10);
                _ctrl!.seekTo(pos < Duration.zero ? Duration.zero : pos);
              },
            ),
            const SizedBox(width: 16),
            // Play/Pause
            ValueListenableBuilder(
              valueListenable: _ctrl!,
              builder: (_, value, __) => GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  width: 56, height: 56,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: AppColors.bg, size: 30,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // +10s
            _CtrlButton(
              icon: Icons.forward_10_rounded,
              onTap: () {
                final pos = _ctrl!.value.position + const Duration(seconds: 10);
                final max = _ctrl!.value.duration;
                _ctrl!.seekTo(pos > max ? max : pos);
              },
            ),
          ]),
        ]),
      ),
    ]);
  }

  void _togglePlay() {
    setState(() {
      _ctrl!.value.isPlaying ? _ctrl!.pause() : _ctrl!.play();
    });
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _CtrlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CtrlButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 44, height: 44,
      decoration: BoxDecoration(
        color: AppColors.elevated,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border),
      ),
      child: Icon(icon, color: AppColors.muted, size: 22),
    ),
  );
}
