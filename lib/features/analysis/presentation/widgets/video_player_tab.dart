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
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // 1. Intentar URL de red (video anotado del backend)
    if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
      String finalUrl = widget.videoUrl!;
      if (!finalUrl.startsWith('http://') && !finalUrl.startsWith('https://')) {
        finalUrl = 'http://$finalUrl';
      }

      final ctrl = VideoPlayerController.networkUrl(Uri.parse(finalUrl));
      try {
        await ctrl.initialize();
        if (mounted) setState(() { _ctrl = ctrl; _initialized = true; });
        return;
      } catch (e) {
        if (mounted) setState(() => _errorMessage = "Error de red: $e \nURL: $finalUrl");
        await ctrl.dispose();
        return;
      }
    }

    // 2. Fallback: archivo local (solo en mobile/desktop, no en web)
    if (!kIsWeb && widget.localFile != null) {
      final ctrl = VideoPlayerController.file(File(widget.localFile!.path));
      try {
        await ctrl.initialize();
        if (mounted) setState(() { _ctrl = ctrl; _initialized = true; });
        return;
      } catch (e) {
        if (mounted) setState(() => _errorMessage = "Error local: $e");
        await ctrl.dispose();
      }
    } else if (kIsWeb && widget.localFile != null) {
      if (mounted) setState(() => _errorMessage = "En web no se pueden reproducir archivos locales directamente.");
    } else {
        if (mounted) setState(() => _errorMessage = "URL o archivo no proporcionado.");
    }
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.error_outline, color: AppColors.danger, size: 48),
            const SizedBox(height: 16),
            const Text('Error al cargar el vídeo',
                style: TextStyle(color: AppColors.danger, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(_errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          ]),
        ),
      );
    }

    if (!_initialized) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2),
      );
    }

    return Column(children: [
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
      Container(
        color: AppColors.surface,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
        child: Column(children: [
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
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _CtrlButton(
              icon: Icons.replay_10_rounded,
              onTap: () {
                final pos = _ctrl!.value.position - const Duration(seconds: 10);
                _ctrl!.seekTo(pos < Duration.zero ? Duration.zero : pos);
              },
            ),
            const SizedBox(width: 16),
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