import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/form_text_field.dart';
import '../../../shared/widgets/section_label.dart';
import '../controller/home_controller.dart';
import 'widgets/settings_drawer.dart';
import 'widgets/team_analysis_card.dart';

class HomePage extends StatefulWidget {
  final void Function(int)? onTabChange;
  const HomePage({super.key, this.onTabChange});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HomeController();
    _controller.loadTeams();
    _controller.loadRecentMatches();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleMessages() {
    final error   = _controller.errorMessage;
    final success = _controller.successMessage;
    if (error != null || success != null) {
      _controller.consumeMessages();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error ?? success!),
          backgroundColor: AppColors.elevated,
          behavior: SnackBarBehavior.floating,
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
        return Scaffold(
          backgroundColor: AppColors.bg,
          endDrawer: const SettingsDrawer(),
          appBar: _buildAppBar(context),
          body: Column(
            children: [
              // ── Teams section ──────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Expanded(child: SectionLabel('SELECT A TEAM TO START ANALYSIS')),
                        GestureDetector(
                          onTap: () {
                            _controller.loadTeams();
                            _controller.loadRecentMatches();
                          },
                          child: const Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: Icon(Icons.refresh_outlined, color: AppColors.dim, size: 16),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _openTeamDialog(),
                          child: const Icon(Icons.add, color: AppColors.accent, size: 20),
                        ),
                      ]),
                      const SizedBox(height: 14),

                      if (_controller.isLoading)
                        const Center(child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 1.5),
                        ))
                      else if (_controller.teams.isEmpty)
                        _EmptyTeamsCard(onCreateTap: () => _openTeamDialog())
                      else
                        ..._controller.teams.map((t) => TeamAnalysisCard(
                          team: t,
                          controller: _controller,
                          onEdit: () => _openTeamDialog(team: t),
                          onDelete: () => _deleteTeam(t),
                        )),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // ── Bottom tabs: Resultados | Noticias ──────────
              _BottomTabSection(
                controller: _controller,
                onTabChange: widget.onTabChange,
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) => AppBar(
    backgroundColor: AppColors.elevated,
    elevation: 0,
    titleSpacing: 20,
    title: Row(children: [
      const Icon(Icons.sports_soccer_outlined, color: AppColors.accent, size: 18),
      const SizedBox(width: 8),
      const Text('PlayVision',
          style: TextStyle(color: AppColors.text, fontSize: 18,
              fontWeight: FontWeight.w800, letterSpacing: -0.3)),
    ]),
    actions: [
      IconButton(
        icon: const Icon(Icons.search_rounded, color: AppColors.dim, size: 22),
        onPressed: () {},
      ),
      Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.settings_outlined, color: AppColors.dim, size: 22),
          onPressed: () => Scaffold.of(ctx).openEndDrawer(),
        ),
      ),
      const SizedBox(width: 4),
    ],
  );

  Future<void> _openTeamDialog({Map<String, dynamic>? team}) async {
    final nameCtrl     = TextEditingController(text: team?['name']     as String? ?? '');
    final categoryCtrl = TextEditingController(text: team?['category'] as String? ?? '');
    final clubCtrl     = TextEditingController(text: team?['club']     as String? ?? '');
    final isEdit       = team != null;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isEdit ? 'Edit team' : 'New team',
            style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w700)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          FormTextField(controller: nameCtrl,     label: 'Name'),
          const SizedBox(height: 10),
          FormTextField(controller: categoryCtrl, label: 'Category'),
          const SizedBox(height: 10),
          FormTextField(controller: clubCtrl,     label: 'Club'),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.dim)),
          ),
          GestureDetector(
            onTap: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              if (isEdit) {
                await _controller.updateTeam(
                  id: team['id'] as int,
                  name: nameCtrl.text.trim(),
                  category: categoryCtrl.text.trim().isEmpty ? null : categoryCtrl.text.trim(),
                  club: clubCtrl.text.trim().isEmpty ? null : clubCtrl.text.trim(),
                );
              } else {
                await _controller.createTeam(
                  name: nameCtrl.text.trim(),
                  category: categoryCtrl.text.trim().isEmpty ? null : categoryCtrl.text.trim(),
                  club: clubCtrl.text.trim().isEmpty ? null : clubCtrl.text.trim(),
                );
              }
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.elevated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border2),
              ),
              child: Text(isEdit ? 'Save' : 'Create',
                  style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTeam(Map<String, dynamic> team) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete team',
            style: TextStyle(color: AppColors.text, fontWeight: FontWeight.w700)),
        content: Text('Delete "${team['name']}"? This action cannot be undone.',
            style: const TextStyle(color: AppColors.muted, fontSize: 13, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.dim)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _controller.deleteTeam(team['id'] as int);
    }
  }
}

// ── Empty state ──────────────────────────────────────────────
class _EmptyTeamsCard extends StatelessWidget {
  final VoidCallback onCreateTap;
  const _EmptyTeamsCard({required this.onCreateTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onCreateTap,
    child: Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: [
        Container(
          width: 60, height: 60,
          decoration: const BoxDecoration(
            color: AppColors.accentLo,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.groups_outlined, color: AppColors.accent, size: 28),
        ),
        const SizedBox(height: 14),
        const Text('Create a team',
            style: TextStyle(color: AppColors.text, fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        const Text('Tap here to add your first team\nand start analysing matches',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.dim, fontSize: 12, height: 1.6)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.elevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border2),
          ),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.add, color: AppColors.accent, size: 16),
            SizedBox(width: 6),
            Text('New team', style: TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w600)),
          ]),
        ),
      ]),
    ),
  );
}

// ── Bottom tab section ───────────────────────────────────────
class _BottomTabSection extends StatelessWidget {
  final HomeController controller;
  final void Function(int)? onTabChange;
  const _BottomTabSection({required this.controller, this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              labelColor: AppColors.accent,
              unselectedLabelColor: AppColors.dim,
              indicatorColor: AppColors.accent,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'Resultados'),
                Tab(text: 'Noticias'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _ResultadosTab(controller: controller),
                  const _NoticiasTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Resultados tab ───────────────────────────────────────────
class _ResultadosTab extends StatelessWidget {
  final HomeController controller;
  const _ResultadosTab({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.isLoadingMatches) {
      return const Center(child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 1.5));
    }
    if (controller.recentMatches.isEmpty) {
      return const Center(
        child: Text('No results yet', style: TextStyle(color: AppColors.dim, fontSize: 13)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.recentMatches.length,
      itemBuilder: (_, i) => _ResultRow(match: controller.recentMatches[i]),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final Map<String, dynamic> match;
  const _ResultRow({required this.match});

  @override
  Widget build(BuildContext context) {
    final status   = match['status'] as String? ?? AppConstants.statusUploaded;
    final opponent = match['opponent'] as String? ?? '—';
    final teamName = (match['teams'] as Map?)?['name'] as String? ?? '—';
    final rawDate  = match['match_date'] as String?;
    String dateLabel = '—';
    if (rawDate != null) {
      try {
        dateLabel = DateFormat(AppConstants.dateFormat).format(DateTime.parse(rawDate));
      } catch (_) {}
    }

    final (Color chipColor, Color chipText, String chipLabel) = switch (status) {
      AppConstants.statusDone       => (AppColors.successBg, AppColors.success, AppConstants.labelAnalysed),
      AppConstants.statusProcessing => (AppColors.warningBg, AppColors.warning, AppConstants.labelProcessing),
      _                             => (AppColors.border, AppColors.dim, AppConstants.labelUploaded),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        const Icon(Icons.sports_soccer_outlined, color: AppColors.accentLo, size: 14),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$teamName vs $opponent',
              style: const TextStyle(color: AppColors.text, fontSize: 13, fontWeight: FontWeight.w600)),
          Text(dateLabel, style: const TextStyle(color: AppColors.dim, fontSize: 11)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: chipColor, borderRadius: BorderRadius.circular(6)),
          child: Text(chipLabel,
              style: TextStyle(color: chipText, fontSize: 10, fontWeight: FontWeight.w600)),
        ),
      ]),
    );
  }
}

// ── Noticias tab ─────────────────────────────────────────────
class _NoticiasTab extends StatelessWidget {
  const _NoticiasTab();

  @override
  Widget build(BuildContext context) => const Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.newspaper_outlined, color: AppColors.accentLo, size: 32),
      SizedBox(height: 10),
      Text('News coming soon', style: TextStyle(color: AppColors.dim, fontSize: 13)),
    ]),
  );
}
