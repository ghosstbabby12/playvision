import 'package:flutter/material.dart';

import '../../../core/theme/app_color_tokens.dart';
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
    final c = context.colors;
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        if (_controller.errorMessage != null) {
          final msg = _controller.errorMessage!;
          _controller.consumeError();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(msg, style: TextStyle(color: c.text)),
              backgroundColor: c.elevated,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: c.border2),
              ),
            ));
          });
        }

        final hasResult = _controller.result != null;

        return Scaffold(
          backgroundColor: c.bg,
          body: SafeArea(
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Analysis',
                          style: TextStyle(color: c.text, fontSize: 24,
                              fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                      const SizedBox(height: 3),
                      Text('AI-powered performance',
                          style: TextStyle(color: c.dim, fontSize: 13)),
                    ]),
                  ),
                  if (!hasResult)
                    GestureDetector(
                      onTap: _controller.isAnalyzing ? null : _controller.pickVideo,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: c.elevated,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: c.border2),
                        ),
                        child: Row(children: [
                          Icon(Icons.upload_file_outlined, color: c.accent, size: 16),
                          const SizedBox(width: 6),
                          Text(_controller.videoFile != null ? 'Ready' : 'Upload video',
                              style: TextStyle(color: c.text, fontSize: 13, fontWeight: FontWeight.w500)),
                        ]),
                      ),
                    ),
                  if (hasResult)
                    GestureDetector(
                      onTap: _controller.reset,
                      child: Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: c.elevated,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: c.border),
                        ),
                        child: Icon(Icons.refresh_outlined, color: c.accent, size: 18),
                      ),
                    ),
                ]),
              ),

              if (hasResult)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: c.border)),
                    ),
                    child: TabBar(
                      controller: _tabs,
                      indicatorColor: c.textHi,
                      indicatorWeight: 1,
                      labelColor: c.textHi,
                      unselectedLabelColor: c.dim,
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
                        videoFile:   _controller.videoFile,
                        videoUrl:    _controller.videoUrl,
                        isAnalyzing: _controller.isAnalyzing,
                        onPickVideo: _controller.pickVideo,
                        onAnalyze:   _controller.analyzeVideo,
                        onSetUrl:    _controller.setVideoUrl,
                      ),
              ),
            ]),
          ),
        );
      },
    );
  }
}
