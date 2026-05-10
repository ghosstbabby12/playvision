import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/theme/app_color_tokens.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../../shared/widgets/glass_card.dart';

class VideoUploadView extends StatefulWidget {
  final XFile?       videoFile;
  final String?      videoUrl;
  final bool         isAnalyzing;
  final VoidCallback onPickVideo;
  final VoidCallback onAnalyze;
  final void Function(String) onSetUrl;
  final VoidCallback? onCancel;

  const VideoUploadView({
    super.key,
    required this.videoFile,
    required this.videoUrl,
    required this.isAnalyzing,
    required this.onPickVideo,
    required this.onAnalyze,
    required this.onSetUrl,
    this.onCancel,
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
    final c    = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        // Mode tab selector
        Container(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.border),
          ),
          child: Row(children: [
            _ModeTab(label: l10n.uploadFromDevice, selected: !_useUrl,
                onTap: widget.isAnalyzing ? () {} : () => setState(() => _useUrl = false)),
            _ModeTab(label: l10n.uploadFromUrl, selected: _useUrl,
                onTap: widget.isAnalyzing ? () {} : () => setState(() => _useUrl = true)),
          ]),
        ),
        const SizedBox(height: 14),

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

        // Primary CTA — analyze or cancel
        if (widget.isAnalyzing)
          GestureDetector(
            onTap: widget.onCancel,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF8B1A1A).withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFFE53E3E).withValues(alpha: 0.45)),
              ),
              alignment: Alignment.center,
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SizedBox(
                  width: 15, height: 15,
                  child: CircularProgressIndicator(
                      color: const Color(0xFFFC8181), strokeWidth: 1.5),
                ),
                const SizedBox(width: 12),
                const Text('Cancelar análisis',
                    style: TextStyle(
                        color: Color(0xFFFC8181),
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          )
        else
          GestureDetector(
            onTap: _hasInput ? widget.onAnalyze : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: _hasInput
                    ? const LinearGradient(
                        colors: [Color(0xFF1E6B3C), Color(0xFF22C55E)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : null,
                color: _hasInput ? null : c.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: _hasInput
                        ? const Color(0xFF22C55E).withValues(alpha: 0.5)
                        : c.border),
                boxShadow: _hasInput
                    ? [
                        BoxShadow(
                          color: const Color(0xFF22C55E).withValues(alpha: 0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.auto_awesome_rounded,
                    color: _hasInput ? Colors.white : c.dim, size: 16),
                const SizedBox(width: 8),
                Text(
                  l10n.uploadStartAnalysis,
                  style: TextStyle(
                    color: _hasInput ? Colors.white : c.dim,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ]),
            ),
          ),

        const SizedBox(height: 32),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(l10n.uploadReqTitle,
              style: TextStyle(
                  color: c.dim, fontSize: 10,
                  fontWeight: FontWeight.w700, letterSpacing: 2)),
        ),
        const SizedBox(height: 14),
        _VideoRequirementsCard(
          items: [
            (Icons.movie_outlined,    l10n.uploadReqFormat,     l10n.uploadReqFormatDesc),
            (Icons.hd_outlined,       l10n.uploadReqResolution, l10n.uploadReqResolutionDesc),
            (Icons.timer_outlined,    l10n.uploadReqDuration,   l10n.uploadReqDurationDesc),
            (Icons.videocam_outlined, l10n.uploadReqAngle,      l10n.uploadReqAngleDesc),
            (Icons.folder_outlined,   l10n.uploadReqSize,       l10n.uploadReqSizeDesc),
          ],
        ),
        const SizedBox(height: 32),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(l10n.uploadHowItWorks,
              style: TextStyle(
                  color: c.dim, fontSize: 10,
                  fontWeight: FontWeight.w700, letterSpacing: 2)),
        ),
        const SizedBox(height: 14),
        _HowItWorksCard(n: '1', title: l10n.uploadStep1Title, desc: l10n.uploadStep1Desc),
        _HowItWorksCard(n: '2', title: l10n.uploadStep2Title, desc: l10n.uploadStep2Desc),
        _HowItWorksCard(n: '3', title: l10n.uploadStep3Title, desc: l10n.uploadStep3Desc),
      ]),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ModeTab({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? c.elevated : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? c.text : c.dim,
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _FilePickZone extends StatelessWidget {
  final XFile? videoFile;
  final bool isAnalyzing;
  final VoidCallback onTap;
  const _FilePickZone(
      {required this.videoFile, required this.isAnalyzing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c       = context.colors;
    final l10n    = AppLocalizations.of(context)!;
    final hasFile = videoFile != null;

    return GestureDetector(
      onTap: isAnalyzing ? null : onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 180,
            decoration: BoxDecoration(
              color: hasFile
                  ? c.accentLo.withValues(alpha: 0.6)
                  : c.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasFile
                    ? c.accent.withValues(alpha: 0.4)
                    : c.border,
                width: hasFile ? 1.5 : 1,
              ),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: hasFile
                      ? c.accent.withValues(alpha: 0.2)
                      : c.accentLo,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: c.accent.withValues(alpha: hasFile ? 0.4 : 0.2)),
                ),
                child: Icon(
                  hasFile
                      ? Icons.check_circle_outline_rounded
                      : Icons.cloud_upload_outlined,
                  color: c.accent,
                  size: 30,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                hasFile ? l10n.uploadVideoReady : l10n.uploadSelectVideo,
                style: TextStyle(
                    color: c.text, fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                hasFile ? videoFile!.name : l10n.uploadTapGallery,
                style: TextStyle(color: c.dim, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

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
    final c      = context.colors;
    final l10n   = AppLocalizations.of(context)!;
    final hasUrl = videoUrl != null && videoUrl!.isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: hasUrl ? c.border2 : c.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l10n.uploadUrlLabel,
            style: TextStyle(
                color: c.dim, fontSize: 11,
                fontWeight: FontWeight.w600, letterSpacing: 1)),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          enabled: !isAnalyzing,
          style: TextStyle(color: c.text, fontSize: 13),
          decoration: InputDecoration(
            hintText: l10n.uploadUrlHint,
            hintStyle: TextStyle(color: c.muted, fontSize: 13),
            filled: true,
            fillColor: c.bg,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: c.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: c.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: c.accent),
            ),
            suffixIcon: IconButton(
              icon: Icon(Icons.check_rounded, color: c.accent, size: 20),
              onPressed: isAnalyzing ? null : () => onSubmit(controller.text),
            ),
          ),
          onSubmitted: isAnalyzing ? null : onSubmit,
        ),
        if (hasUrl) ...[
          const SizedBox(height: 10),
          Row(children: [
            Icon(Icons.check_circle_rounded, color: c.accent, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text(videoUrl!,
                  style: TextStyle(color: c.dim, fontSize: 11),
                  overflow: TextOverflow.ellipsis),
            ),
          ]),
        ],
        const SizedBox(height: 8),
        Text(l10n.uploadUrlSupports, style: TextStyle(color: c.muted, fontSize: 11)),
      ]),
    );
  }
}

class _VideoRequirementsCard extends StatelessWidget {
  final List<(IconData, String, String)> items;
  const _VideoRequirementsCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        children: List.generate(items.length, (i) {
          final (icon, label, desc) = items[i];
          return Padding(
            padding: EdgeInsets.only(bottom: i < items.length - 1 ? 12 : 0),
            child: Row(children: [
              Icon(icon, color: c.accent, size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label,
                        style: TextStyle(color: c.dim, fontSize: 12,
                            fontWeight: FontWeight.w500)),
                    Text(desc,
                        style: TextStyle(color: c.text, fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ]),
          );
        }),
      ),
    );
  }
}

class _HowItWorksCard extends StatelessWidget {
  final String n;
  final String title;
  final String desc;
  const _HowItWorksCard({required this.n, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: c.accentLo, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(n,
              style: TextStyle(
                  color: c.accent, fontWeight: FontWeight.w800, fontSize: 14)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: TextStyle(
                    color: c.text, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 3),
            Text(desc, style: TextStyle(color: c.dim, fontSize: 12)),
          ]),
        ),
      ]),
    );
  }
}
