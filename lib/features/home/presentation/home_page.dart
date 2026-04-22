import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:playvision/core/constants/app_constants.dart';
import 'package:playvision/core/theme/app_color_tokens.dart';
import 'package:playvision/shared/widgets/form_text_field.dart';
import 'package:playvision/features/analysis/presentation/analysis_page.dart';

import 'home_controller.dart';
import 'widgets/hero_section.dart';
import 'widgets/home_tab_bar.dart';
import 'widgets/match_schedule_section.dart';
import 'widgets/news_section.dart';
import 'widgets/settings_drawer.dart';
import 'widgets/team_panel.dart';

class HomePage extends StatefulWidget {
  final void Function(int)? onTabChange;
  const HomePage({super.key, this.onTabChange});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController _controller;
  int _selectedTab = 0;

  List<dynamic> _liveMatches = [];
  bool _isLoadingLiveMatches = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = HomeController();
    _controller.loadTeams();
    _controller.loadRecentMatches();
    _fetchLiveMatches();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _fetchLiveMatches());
  }

  Future<void> _fetchLiveMatches() async {
    List<dynamic> matches = [];
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.apiBase}/api/live-matches'),
      );
      if (response.statusCode == 200) {
        matches = (json.decode(response.body) as Map)['data'] ?? [];
      }
    } catch (e) {
      debugPrint('Error API partidos: $e');
    } finally {
      if (mounted) {
        setState(() {
          _liveMatches = matches;
          _isLoadingLiveMatches = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _handleMessages() {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return;

    final error   = _controller.errorMessage;
    final success = _controller.successMessage;

    if (error != null || success != null) {
      _controller.consumeMessages();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final c = context.colors;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error ?? success!),
          backgroundColor: error != null ? c.danger : c.accentMid,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        _handleMessages();
        final hasTeam = _controller.selectedTeam != null;

        return Scaffold(
          backgroundColor: context.colors.bg,
          endDrawer: const SettingsDrawer(),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: HeroSection(controller: _controller)),

              if (!hasTeam)
                SliverToBoxAdapter(
                  child: TeamSelectorSection(
                    controller: _controller,
                    onAdd: () => _openTeamDialog(),
                  ),
                ),

              if (hasTeam) ...[
                SliverToBoxAdapter(
                  child: SelectedTeamHeader(
                    controller: _controller,
                    onEdit: () => _openTeamDialog(team: _controller.selectedTeam),
                    onDelete: () => _deleteTeam(_controller.selectedTeam!),
                  ),
                ),
                SliverToBoxAdapter(
                  child: AnalyseButton(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AnalysisPage()),
                    ),
                  ),
                ),
                if (_controller.hasResult)
                  SliverToBoxAdapter(
                    child: ViewAnalysisButton(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AnalysisPage()),
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: PreviousAnalysesSection(
                    controller: _controller,
                    onViewAnalysis: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AnalysisPage()),
                    ),
                  ),
                ),
              ],

              SliverToBoxAdapter(
                child: HomeTabBar(
                  selected: _selectedTab,
                  onSelect: (i) => setState(() => _selectedTab = i),
                ),
              ),

              if (_selectedTab == 0)
                SliverToBoxAdapter(
                  child: MatchScheduleSection(
                    isLoading: _isLoadingLiveMatches,
                    matches: _liveMatches,
                  ),
                )
              else
                const SliverToBoxAdapter(child: NewsSection()),

              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openTeamDialog({Map<String, dynamic>? team}) async {
    final nameCtrl     = TextEditingController(text: team?['name'] as String? ?? '');
    final categoryCtrl = TextEditingController(text: team?['category'] as String? ?? '');
    final clubCtrl     = TextEditingController(text: team?['club'] as String? ?? '');
    final isEdit = team != null;

    XFile? pickedLogo;
    Uint8List? logoBytes;
    bool isSaving = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) {
          final c = ctx.colors;
          return AlertDialog(
            backgroundColor: c.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(isEdit ? 'Edit team' : 'New team',
                style: TextStyle(color: c.text, fontWeight: FontWeight.w700)),
            content: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final file = await picker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 512,
                        maxHeight: 512,
                        imageQuality: 85);
                    if (file == null) return;
                    final bytes = await file.readAsBytes();
                    setDlg(() { pickedLogo = file; logoBytes = bytes; });
                  },
                  child: Stack(alignment: Alignment.bottomRight, children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: c.elevated,
                        shape: BoxShape.circle,
                        border: Border.all(color: c.borderGreen, width: 2),
                        image: logoBytes != null
                            ? DecorationImage(image: MemoryImage(logoBytes!), fit: BoxFit.cover)
                            : (team?['logo_url'] as String?)?.isNotEmpty == true
                                ? DecorationImage(
                                    image: NetworkImage(team!['logo_url'] as String),
                                    fit: BoxFit.cover)
                                : null,
                      ),
                      child: logoBytes == null && (team?['logo_url'] as String?) == null
                          ? Icon(Icons.groups_outlined, color: c.accent, size: 32)
                          : null,
                    ),
                    Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, color: Colors.black, size: 13),
                    ),
                  ]),
                ),
                const SizedBox(height: 6),
                Text(pickedLogo != null ? 'Logo selected' : 'Tap to add logo',
                    style: TextStyle(color: c.muted, fontSize: 11)),
                const SizedBox(height: 16),
                FormTextField(controller: nameCtrl, label: 'Name'),
                const SizedBox(height: 10),
                FormTextField(controller: categoryCtrl, label: 'Category'),
                const SizedBox(height: 10),
                FormTextField(controller: clubCtrl, label: 'Club'),
              ]),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(ctx),
                child: Text('Cancel', style: TextStyle(color: c.muted)),
              ),
              TextButton(
                onPressed: isSaving ? null : () async {
                  if (nameCtrl.text.trim().isEmpty) return;
                  setDlg(() => isSaving = true);

                  String? logoUrl;
                  if (pickedLogo != null && logoBytes != null) {
                    final tmpId = isEdit
                        ? (team['id'] as int)
                        : DateTime.now().millisecondsSinceEpoch;
                    final ext = pickedLogo!.name.split('.').last.toLowerCase();
                    logoUrl = await _controller.uploadLogo(
                        teamId: tmpId, bytes: logoBytes!, extension: ext);
                  }

                  if (isEdit) {
                    await _controller.updateTeam(
                      id: team['id'] as int,
                      name: nameCtrl.text.trim(),
                      category: categoryCtrl.text.trim().isEmpty ? null : categoryCtrl.text.trim(),
                      club: clubCtrl.text.trim().isEmpty ? null : clubCtrl.text.trim(),
                      logoUrl: logoUrl,
                    );
                  } else {
                    await _controller.createTeam(
                      name: nameCtrl.text.trim(),
                      category: categoryCtrl.text.trim().isEmpty ? null : categoryCtrl.text.trim(),
                      club: clubCtrl.text.trim().isEmpty ? null : clubCtrl.text.trim(),
                      logoUrl: logoUrl,
                    );
                  }
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                },
                child: isSaving
                    ? SizedBox(width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.accent))
                    : Text(isEdit ? 'Save' : 'Create',
                        style: TextStyle(color: context.colors.accent, fontWeight: FontWeight.w700)),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteTeam(Map<String, dynamic> team) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final c = ctx.colors;
        return AlertDialog(
          backgroundColor: c.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Delete team',
              style: TextStyle(color: c.text, fontWeight: FontWeight.w700)),
          content: Text('Delete team "${team['name']}"? This cannot be undone.',
              style: TextStyle(color: c.muted, fontSize: 13, height: 1.5)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancel', style: TextStyle(color: c.muted))),
            TextButton(onPressed: () => Navigator.pop(ctx, true),
                child: Text('Delete', style: TextStyle(color: c.danger))),
          ],
        );
      },
    );

    if (confirm == true) await _controller.deleteTeam(team['id'] as int);
  }
}
