import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/theme/app_colors.dart';

class VideoUploadView extends StatelessWidget {
  final XFile? videoFile;
  final bool isAnalyzing;
  final VoidCallback onPickVideo;
  final VoidCallback onAnalyze;
  const VideoUploadView({
    super.key,
    required this.videoFile,
    required this.isAnalyzing,
    required this.onPickVideo,
    required this.onAnalyze,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = videoFile != null;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        // Drop zone
        GestureDetector(
          onTap: isAnalyzing ? null : onPickVideo,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: hasFile ? AppColors.border2 : AppColors.border),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                width: 64, height: 64,
                decoration: const BoxDecoration(color: Color(0x1A7C9EBF), shape: BoxShape.circle),
                child: Icon(
                  hasFile ? Icons.check_circle_outline_rounded : Icons.videocam_outlined,
                  color: AppColors.accent, size: 30,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                hasFile ? 'Video ready to analyse' : 'Select match video',
                style: const TextStyle(color: AppColors.text, fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                hasFile ? videoFile!.name : 'Tap to open gallery',
                style: const TextStyle(color: AppColors.dim, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ]),
          ),
        ),
        const SizedBox(height: 14),

        // Analyse button
        GestureDetector(
          onTap: (hasFile && !isAnalyzing) ? onAnalyze : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: hasFile && !isAnalyzing ? AppColors.elevated : AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: hasFile && !isAnalyzing ? AppColors.border2 : AppColors.border),
            ),
            alignment: Alignment.center,
            child: isAnalyzing
                ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 1.5)),
                    SizedBox(width: 12),
                    Text('Analysing with AI...', style: TextStyle(color: AppColors.muted, fontSize: 14)),
                  ])
                : Text(
                    'Start analysis',
                    style: TextStyle(
                      color: hasFile ? AppColors.text : AppColors.dim,
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
        const _HowItWorksCard(n: '1', title: 'Upload video',   desc: 'Select the match video from your gallery'),
        const _HowItWorksCard(n: '2', title: 'AI analyses',    desc: 'YOLO detects and tracks each player in real time'),
        const _HowItWorksCard(n: '3', title: 'View results',   desc: 'Get stats, field map and automatic AI insights'),
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
        decoration: const BoxDecoration(color: Color(0x1A7C9EBF), shape: BoxShape.circle),
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
