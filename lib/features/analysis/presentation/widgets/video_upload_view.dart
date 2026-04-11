import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/theme/app_colors.dart';

class VideoUploadView extends StatefulWidget {
  final XFile?       videoFile;
  final String?      videoUrl;
  final bool         isAnalyzing;
  final VoidCallback onPickVideo;
  final VoidCallback onAnalyze;
  final void Function(String) onSetUrl;

  const VideoUploadView({
    super.key,
    required this.videoFile,
    required this.videoUrl,
    required this.isAnalyzing,
    required this.onPickVideo,
    required this.onAnalyze,
    required this.onSetUrl,
  });

  @override
  State<VideoUploadView> createState() => _VideoUploadViewState();
}

class _VideoUploadViewState extends State<VideoUploadView> {
  bool _useUrl = false;
  final _urlCtrl = TextEditingController();

  @override
  void dispose() {
    _urlCtrl.dispose();
    super.dispose();
  }

  bool get _hasInput => _useUrl
      ? (widget.videoUrl != null && widget.videoUrl!.isNotEmpty)
      : widget.videoFile != null;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        // ── Mode toggle ───────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(children: [
            _ModeTab(label: 'From device', selected: !_useUrl, onTap: () => setState(() => _useUrl = false)),
            _ModeTab(label: 'From URL',    selected:  _useUrl, onTap: () => setState(() => _useUrl = true)),
          ]),
        ),
        const SizedBox(height: 14),

        // ── Input area ────────────────────────────────────────────────
        if (!_useUrl)
          _FilePickZone(
            videoFile:   widget.videoFile,
            isAnalyzing: widget.isAnalyzing,
            onTap:       widget.onPickVideo,
          )
        else
          _UrlInputZone(
            controller:  _urlCtrl,
            videoUrl:    widget.videoUrl,
            isAnalyzing: widget.isAnalyzing,
            onSubmit:    widget.onSetUrl,
          ),

        const SizedBox(height: 14),

        // ── Analyse button ────────────────────────────────────────────
        GestureDetector(
          onTap: (_hasInput && !widget.isAnalyzing) ? widget.onAnalyze : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: _hasInput && !widget.isAnalyzing ? AppColors.elevated : AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _hasInput && !widget.isAnalyzing ? AppColors.border2 : AppColors.border),
            ),
            alignment: Alignment.center,
            child: widget.isAnalyzing
                ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 1.5)),
                    SizedBox(width: 12),
                    Text('Analysing with AI...', style: TextStyle(color: AppColors.muted, fontSize: 14)),
                  ])
                : Text(
                    'Start analysis',
                    style: TextStyle(
                      color: _hasInput ? AppColors.text : AppColors.dim,
                      fontSize: 14, fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 32),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('HOW IT WORKS',
              style: TextStyle(color: AppColors.dim, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2)),
        ),
        const SizedBox(height: 14),
        const _HowItWorksCard(n: '1', title: 'Choose source',  desc: 'Upload from device or paste a direct video URL'),
        const _HowItWorksCard(n: '2', title: 'AI analyses',    desc: 'YOLO detects and tracks each player in real time'),
        const _HowItWorksCard(n: '3', title: 'View results',   desc: 'Get stats, field map and automatic AI insights'),
      ]),
    );
  }
}

// ── Mode toggle tab ────────────────────────────────────────────────────────────
class _ModeTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ModeTab({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.elevated : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.text : AppColors.dim,
            fontSize: 13, fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    ),
  );
}

// ── File pick zone ─────────────────────────────────────────────────────────────
class _FilePickZone extends StatelessWidget {
  final XFile? videoFile;
  final bool isAnalyzing;
  final VoidCallback onTap;
  const _FilePickZone({required this.videoFile, required this.isAnalyzing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasFile = videoFile != null;
    return GestureDetector(
      onTap: isAnalyzing ? null : onTap,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: hasFile ? AppColors.border2 : AppColors.border),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 60, height: 60,
            decoration: const BoxDecoration(color: AppColors.accentLo, shape: BoxShape.circle),
            child: Icon(
              hasFile ? Icons.check_circle_outline_rounded : Icons.videocam_outlined,
              color: AppColors.accent, size: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            hasFile ? 'Video ready to analyse' : 'Select match video',
            style: const TextStyle(color: AppColors.text, fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            hasFile ? videoFile!.name : 'Tap to open gallery',
            style: const TextStyle(color: AppColors.dim, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ]),
      ),
    );
  }
}

// ── URL input zone ─────────────────────────────────────────────────────────────
class _UrlInputZone extends StatelessWidget {
  final TextEditingController controller;
  final String? videoUrl;
  final bool isAnalyzing;
  final void Function(String) onSubmit;
  const _UrlInputZone({
    required this.controller,
    required this.videoUrl,
    required this.isAnalyzing,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final hasUrl = videoUrl != null && videoUrl!.isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: hasUrl ? AppColors.border2 : AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Video URL', style: TextStyle(color: AppColors.dim, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1)),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          enabled: !isAnalyzing,
          style: const TextStyle(color: AppColors.text, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'YouTube, direct .mp4, Vimeo…',
            hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
            filled: true,
            fillColor: AppColors.bg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.accent),
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.check_rounded, color: AppColors.accent, size: 20),
              onPressed: isAnalyzing ? null : () => onSubmit(controller.text),
            ),
          ),
          onSubmitted: isAnalyzing ? null : onSubmit,
        ),
        if (hasUrl) ...[
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text(videoUrl!, style: const TextStyle(color: AppColors.dim, fontSize: 11),
                  overflow: TextOverflow.ellipsis),
            ),
          ]),
        ],
        const SizedBox(height: 8),
        const Text('Supports YouTube, Vimeo and direct .mp4/.mov links',
            style: TextStyle(color: AppColors.muted, fontSize: 11)),
      ]),
    );
  }
}

class _HowItWorksCard extends StatelessWidget {
  final String n;
  final String title;
  final String desc;
  const _HowItWorksCard({required this.n, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    ),
    child: Row(children: [
      Container(
        width: 32, height: 32,
        decoration: const BoxDecoration(color: AppColors.accentLo, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Text(n, style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w800, fontSize: 14)),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: AppColors.text, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 3),
        Text(desc,  style: const TextStyle(color: AppColors.dim, fontSize: 12)),
      ])),
    ]),
  );
}
