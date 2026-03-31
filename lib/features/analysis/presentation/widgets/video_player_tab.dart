import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../../core/theme/app_colors.dart';

class VideoPlayerTab extends StatefulWidget {
  final String? videoUrl;
  const VideoPlayerTab({super.key, required this.videoUrl});

  @override
  State<VideoPlayerTab> createState() => _VideoPlayerTabState();
}

class _VideoPlayerTabState extends State<VideoPlayerTab> {
  VideoPlayerController? _videoCtrl;
  bool _initialized = false;
  bool _hasError    = false;

  @override
  void initState() {
    super.initState();
    if (widget.videoUrl != null) {
      _videoCtrl = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!))
        ..initialize().then((_) {
          if (mounted) setState(() => _initialized = true);
        }).catchError((_) {
          if (mounted) setState(() => _hasError = true);
        });
    }
  }

  @override
  void dispose() {
    _videoCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videoUrl == null || _hasError) {
      return const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.videocam_off_outlined, color: AppColors.accentLo, size: 40),
          SizedBox(height: 12),
          Text('Video not available',
              style: TextStyle(color: AppColors.muted, fontSize: 14)),
        ]),
      );
    }

    if (!_initialized) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2),
      );
    }

    return Column(children: [
      Expanded(
        child: Container(
          color: Colors.black,
          child: Center(
            child: AspectRatio(
              aspectRatio: _videoCtrl!.value.aspectRatio,
              child: VideoPlayer(_videoCtrl!),
            ),
          ),
        ),
      ),
      Container(
        color: AppColors.surface,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(children: [
          VideoProgressIndicator(
            _videoCtrl!,
            allowScrubbing: true,
            colors: const VideoProgressColors(
              playedColor: AppColors.accent,
              bufferedColor: AppColors.elevated,
              backgroundColor: AppColors.accentLo,
            ),
          ),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
              icon: const Icon(Icons.replay_10_rounded, color: AppColors.muted),
              onPressed: () {
                final pos = _videoCtrl!.value.position - const Duration(seconds: 10);
                _videoCtrl!.seekTo(pos < Duration.zero ? Duration.zero : pos);
              },
            ),
            GestureDetector(
              onTap: () => setState(() {
                _videoCtrl!.value.isPlaying ? _videoCtrl!.pause() : _videoCtrl!.play();
              }),
              child: Container(
                width: 52, height: 52,
                decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                child: Icon(
                  _videoCtrl!.value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: AppColors.bg, size: 28,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.forward_10_rounded, color: AppColors.muted),
              onPressed: () {
                final pos = _videoCtrl!.value.position + const Duration(seconds: 10);
                final max = _videoCtrl!.value.duration;
                _videoCtrl!.seekTo(pos > max ? max : pos);
              },
            ),
          ]),
        ]),
      ),
    ]);
  }
}
