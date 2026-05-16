import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../../../../../core/theme/app_color_tokens.dart';
import '../../../../../l10n/generated/app_localizations.dart';

class VideoPlayerTab extends StatefulWidget {
  final String? videoUrl;
  final XFile? localFile;

  const VideoPlayerTab({
    super.key,
    this.videoUrl,
    this.localFile,
  });

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
    if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
      String finalUrl = widget.videoUrl!;
      if (!finalUrl.startsWith('http://') && !finalUrl.startsWith('https://')) {
        finalUrl = 'http://$finalUrl';
      }

      final ctrl = VideoPlayerController.networkUrl(Uri.parse(finalUrl));

      try {
        await ctrl.initialize();
        if (mounted) {
          setState(() {
            _ctrl = ctrl;
            _initialized = true;
          });
        }
        return;
      } catch (e) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          setState(() {
            _errorMessage = l10n.videoErrorNetwork(e.toString(), finalUrl);
          });
        }
        await ctrl.dispose();
        return;
      }
    }

    if (!kIsWeb && widget.localFile != null) {
      final ctrl = VideoPlayerController.file(File(widget.localFile!.path));

      try {
        await ctrl.initialize();
        if (mounted) {
          setState(() {
            _ctrl = ctrl;
            _initialized = true;
          });
        }
        return;
      } catch (e) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          setState(() {
            _errorMessage = l10n.videoErrorLocal(e.toString());
          });
        }
        await ctrl.dispose();
      }
    } else if (kIsWeb && widget.localFile != null) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() => _errorMessage = l10n.videoErrorWebLocal);
      }
    } else {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() => _errorMessage = l10n.videoErrorNoSource);
      }
    }
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context)!;

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: c.danger, size: 48),
              const SizedBox(height: 16),
              Text(
                l10n.videoErrorTitle,
                style: TextStyle(
                  color: c.danger,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: c.muted, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    if (!_initialized) {
      return Center(
        child: CircularProgressIndicator(
          color: c.accent,
          strokeWidth: 2,
        ),
      );
    }

    return Column(
      children: [
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
          color: c.surface,
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
          child: Column(
            children: [
              ValueListenableBuilder(
                valueListenable: _ctrl!,
                builder: (_, value, __) {
                  final pos = value.position;
                  final total = value.duration;

                  return Column(
                    children: [
                      VideoProgressIndicator(
                        _ctrl!,
                        allowScrubbing: true,
                        colors: VideoProgressColors(
                          playedColor: c.accent,
                          bufferedColor: c.elevated,
                          backgroundColor: c.accentLo,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(pos),
                            style: TextStyle(color: c.muted, fontSize: 11),
                          ),
                          Text(
                            _formatDuration(total),
                            style: TextStyle(color: c.dim, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CtrlButton(
                    icon: Icons.replay_10_rounded,
                    onTap: () {
                      final pos =
                          _ctrl!.value.position - const Duration(seconds: 10);
                      _ctrl!.seekTo(pos < Duration.zero ? Duration.zero : pos);
                    },
                  ),
                  const SizedBox(width: 16),
                  ValueListenableBuilder(
                    valueListenable: _ctrl!,
                    builder: (_, value, __) => GestureDetector(
                      onTap: _togglePlay,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: c.accent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          value.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: c.bg,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  _CtrlButton(
                    icon: Icons.forward_10_rounded,
                    onTap: () {
                      final pos =
                          _ctrl!.value.position + const Duration(seconds: 10);
                      final max = _ctrl!.value.duration;
                      _ctrl!.seekTo(pos > max ? max : pos);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
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

  const _CtrlButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: c.elevated,
          shape: BoxShape.circle,
          border: Border.all(color: c.border),
        ),
        child: Icon(icon, color: c.muted, size: 22),
      ),
    );
  }
}