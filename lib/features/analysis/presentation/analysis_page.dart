import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../controller/analysis_controller.dart';
import 'widgets/field_map_tab.dart';
import 'widgets/players_tab.dart';
import 'widgets/summary_tab.dart';
import 'widgets/video_scenes_tab.dart';
import 'widgets/video_upload_view.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage>
    with SingleTickerProviderStateMixin {
  late final AnalysisController _controller;
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _controller = AnalysisController()..init();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (_controller.errorMessage != null) {
          final msg = _controller.errorMessage!;
          _controller.consumeError();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(msg, style: const TextStyle(color: AppColors.text)),
              backgroundColor: AppColors.elevated,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: AppColors.border2),
              ),
            ));
          });
        }

        final hasResult = _controller.result != null;

        return Scaffold(
          backgroundColor: AppColors.bg,
          body: SafeArea(
            child: Column(children: [
              // ── Header ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(children: [
                  const Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Analysis',
                          style: TextStyle(color: AppColors.text, fontSize: 24,
                              fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                      SizedBox(height: 3),
                      Text('AI-powered performance',
                          style: TextStyle(color: AppColors.dim, fontSize: 13)),
                    ]),
                  ),
                  if (!hasResult)
                    GestureDetector(
                      onTap: _controller.isAnalyzing ? null : _controller.pickVideo,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.elevated,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border2),
                        ),
                        child: Row(children: [
                          const Icon(Icons.upload_file_outlined, color: AppColors.accent, size: 16),
                          const SizedBox(width: 6),
                          Text(_controller.videoFile != null ? 'Ready' : 'Upload video',
                              style: const TextStyle(color: AppColors.text, fontSize: 13, fontWeight: FontWeight.w500)),
                        ]),
                      ),
                    ),
                  if (hasResult)
                    GestureDetector(
                      onTap: _controller.reset,
                      child: Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.elevated,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(Icons.refresh_outlined, color: AppColors.accent, size: 18),
                      ),
                    ),
                ]),
              ),

              if (hasResult)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppColors.border)),
                    ),
                    child: TabBar(
                      controller: _tabs,
                      indicatorColor: AppColors.textHi,
                      indicatorWeight: 1,
                      labelColor: AppColors.textHi,
                      unselectedLabelColor: AppColors.dim,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, letterSpacing: 1.5),
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'SUMMARY'),
                        Tab(text: 'FIELD'),
                        Tab(text: 'PLAYERS'),
                        Tab(text: 'VIDEO'),
                      ],
                    ),
                  ),
                )
              else
                const SizedBox(height: 16),

              Expanded(
                child: hasResult
                    ? TabBarView(controller: _tabs, children: [
                        SummaryTab(data: _controller.result!),
                        FieldMapTab(players: _controller.result!['players'] as List),
                        PlayersTab(players: _controller.result!['players'] as List),
                        VideoScenesTab(
                          videoUrl: (_controller.result!['video_url'] as String?) ??
                                    (_controller.result!['videoUrl'] as String?) ??
                                    (_controller.result!['match']?['video_url'] as String?),
                          heatmapVideoUrl: _controller.result!['heatmap_video_url'] as String?,
                          localFile: _controller.videoFile,
                          players: _controller.result!['players'] as List,
                        ),
                      ])
                    : VideoUploadView(
                        videoFile: _controller.videoFile,
                        isAnalyzing: _controller.isAnalyzing,
                        onPickVideo: _controller.pickVideo,
                        onAnalyze: _controller.analyzeVideo,
                      ),
              ),
            ]),
          ),
        );
      },
    );
  }
}