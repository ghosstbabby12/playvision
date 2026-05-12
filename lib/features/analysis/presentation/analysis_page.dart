import 'package:flutter/material.dart';

import '../../../core/theme/app_color_tokens.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/pv_back_button.dart';
import '../../../features/analysis/data/analysis_store.dart';
import 'analysis_controller.dart';
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

  Future<bool> _onWillPop() async {
    if (!_controller.isAnalyzing) return true;
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final dc = ctx.colors;
        return AlertDialog(
          backgroundColor: dc.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: dc.border2),
          ),
          title: Row(children: [
            Icon(Icons.warning_amber_rounded, color: dc.accent, size: 22),
            const SizedBox(width: 10),
            Text(l10n.analysisInProgressTitle,
                style: TextStyle(color: dc.text, fontWeight: FontWeight.w700, fontSize: 17)),
          ]),
          content: Text(
            l10n.analysisLeaveWarning,
            style: TextStyle(color: dc.dim, fontSize: 14, height: 1.5),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.analysisStayButton, style: TextStyle(color: dc.dim)),
            ),
            GestureDetector(
              onTap: () {
                _controller.cancelAnalysis();
                Navigator.pop(ctx, true);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B1A1A).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE53E3E).withValues(alpha: 0.5)),
                ),
                child: Text(l10n.analysisExitButton,
                    style: const TextStyle(
                        color: Color(0xFFFC8181),
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) Navigator.pop(this.context);
      },
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.errorMessage != null) {
            final msg = _controller.errorMessage!;
            _controller.consumeError();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(
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

          final hasResult    = _controller.result != null;
          final isAnalyzing  = _controller.isAnalyzing;

          return Scaffold(
            backgroundColor: c.bg,
            body: SafeArea(
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(children: [
                    PvBackButton(onTap: () async {
                      final should = await _onWillPop();
                      if (should && mounted) Navigator.pop(this.context);
                    }),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(l10n.analysisTitle,
                            style: TextStyle(color: c.text, fontSize: 24,
                                fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                        const SizedBox(height: 3),
                        Text(
                          isAnalyzing ? l10n.analysisProcessingWithAI : l10n.aiPoweredPerformance,
                          style: TextStyle(
                            color: isAnalyzing ? c.accent : c.dim,
                            fontSize: 13,
                          ),
                        ),
                      ]),
                    ),

                    // Cancel button during analysis
                    if (isAnalyzing)
                      GestureDetector(
                        onTap: _controller.cancelAnalysis,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B1A1A).withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: const Color(0xFFE53E3E).withValues(alpha: 0.45)),
                          ),
                          child: Row(children: [
                            Icon(Icons.stop_circle_outlined,
                                color: const Color(0xFFFC8181), size: 16),
                            const SizedBox(width: 6),
                            Text(l10n.analysisCancelButton,
                                style: const TextStyle(
                                    color: Color(0xFFFC8181),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500)),
                          ]),
                        ),
                      )

                    // Upload button (no result, not analyzing)
                    else if (!hasResult)
                      GestureDetector(
                        onTap: _controller.pickVideo,
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
                            Text(
                              _controller.videoFile != null ? l10n.readyBtn : l10n.uploadVideoBtn,
                              style: TextStyle(
                                  color: c.text, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ]),
                        ),
                      )

                    // Reset button (has result)
                    else
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

                // Analyzing status banner
                if (isAnalyzing)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: c.accentLo,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: c.accent.withValues(alpha: 0.25)),
                      ),
                      child: Row(children: [
                        SizedBox(
                          width: 14, height: 14,
                          child: CircularProgressIndicator(
                              color: c.accent, strokeWidth: 1.5),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.analysisProcessingBanner,
                            style: TextStyle(color: c.accent, fontSize: 12, height: 1.4),
                          ),
                        ),
                      ]),
                    ),
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
                        labelStyle: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 11, letterSpacing: 1.5),
                        dividerColor: Colors.transparent,
                        tabs: [
                          Tab(text: l10n.tabSummary),
                          Tab(text: l10n.tabField),
                          Tab(text: l10n.tabPlayers),
                          Tab(text: l10n.tabVideo),
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
                          PlayersTab(
                            players: _controller.result!['players'] as List,
                            teamId:  AnalysisStore.instance.selectedTeamId,
                            matchId: _controller.result!['match_id'] as int?
                                  ?? _controller.result!['match']?['id'] as int?,
                          ),
                          VideoScenesTab(
                            videoUrl: (_controller.result!['video_url'] as String?) ??
                                      (_controller.result!['videoUrl'] as String?) ??
                                      (_controller.result!['match']?['video_url'] as String?),
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
                          onCancel:    _controller.cancelAnalysis,
                        ),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }
}
