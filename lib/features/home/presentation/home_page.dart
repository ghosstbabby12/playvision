import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:playvision/core/theme/app_color_tokens.dart';
import 'package:playvision/shared/widgets/form_text_field.dart';
import 'package:playvision/features/analysis/presentation/analysis_page.dart';
import 'package:playvision/l10n/generated/app_localizations.dart';

import '../data/live_matches_service.dart';
import 'home_controller.dart';
import 'widgets/ai_insights_section.dart';
import 'widgets/continue_analysis_section.dart';
import 'widgets/hero_section.dart';
import 'widgets/home_tab_bar.dart';
import 'widgets/match_schedule_section.dart';
import 'widgets/news_section.dart';
import 'widgets/quick_actions_section.dart';
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

  Map<String, List<dynamic>> _featuredSections = {};
  bool _isLoadingFeatured = true;

  Map<String, dynamic>? _searchedTeam;
  List<dynamic> _searchedMatches = [];
  bool _isSearching = false;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = HomeController();
    _controller.loadTeams();
    _controller.loadRecentMatches();
    _fetchLiveMatches();
    _fetchFeaturedMatches();
    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) {
        _fetchLiveMatches();
        _fetchFeaturedMatches();
      },
    );
  }

  Future<void> _fetchLiveMatches() async {
    try {
      final matches = await LiveMatchesService.instance.fetchLiveMatches();
      if (mounted) {
        setState(() {
          _liveMatches = matches;
          _isLoadingLiveMatches = false;
        });
      }
    } catch (e) {
      debugPrint('[HomePage._fetchLiveMatches] $e');
      if (mounted) setState(() => _isLoadingLiveMatches = false);
    }
  }

  Future<void> _fetchFeaturedMatches() async {
    try {
      final sections =
          await LiveMatchesService.instance.fetchFeaturedMatches();
      if (mounted) {
        setState(() {
          _featuredSections = sections;
          _isLoadingFeatured = false;
        });
      }
    } catch (e) {
      debugPrint('[HomePage._fetchFeaturedMatches] $e');
      if (mounted) setState(() => _isLoadingFeatured = false);
    }
  }

  Future<void> _searchTeam(String name) async {
    if (name.trim().length < 2) return;
    setState(() => _isSearching = true);
    final result = await LiveMatchesService.instance.searchTeam(name.trim());
    if (mounted) {
      setState(() {
        _searchedTeam = result?['team'] as Map<String, dynamic>?;
        _searchedMatches = (result?['matches'] as List?) ?? [];
        _isSearching = false;
      });
    }
  }

  void _clearSearch() {
    setState(() {
      _searchedTeam = null;
      _searchedMatches = [];
    });
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

    final error = _controller.errorMessage;
    final success = _controller.successMessage;

    if (error != null || success != null) {
      _controller.consumeMessages();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final c = context.colors;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? success!),
            backgroundColor: error != null ? c.danger : c.accentMid,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
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
              // ── 1. Hero (compact + intelligent) ───────────────────────────
              SliverToBoxAdapter(
                child: HeroSection(controller: _controller),
              ),

              // ── 2. Quick Actions ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: QuickActionsSection(
                  onTabChange: widget.onTabChange,
                ),
              ),

              // ── 3. AI Insights ────────────────────────────────────────────
              const SliverToBoxAdapter(child: AiInsightsSection()),

              // ── 4. My Teams ───────────────────────────────────────────────
              if (!hasTeam)
                SliverToBoxAdapter(
                  child: TeamSelectorSection(
                    controller: _controller,
                    onAdd: () => _openTeamDialog(),
                  ),
                ),

              if (hasTeam)
                SliverToBoxAdapter(
                  child: SelectedTeamHeader(
                    controller: _controller,
                    onEdit: () => _openTeamDialog(
                      team: _controller.selectedTeam,
                    ),
                    onDelete: () => _deleteTeam(_controller.selectedTeam!),
                  ),
                ),

              // ── 5. Continue last analysis ─────────────────────────────────
              if (_controller.hasResult)
                SliverToBoxAdapter(
                  child: ContinueAnalysisSection(controller: _controller),
                ),

              // ── 6. Team match history ─────────────────────────────────────
              if (hasTeam)
                SliverToBoxAdapter(
                  child: PreviousAnalysesSection(
                    controller: _controller,
                    onViewAnalysis: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AnalysisPage(),
                      ),
                    ),
                  ),
                ),

              // ── 7. Resultados / Noticias tabs ─────────────────────────────
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
                    featuredSections: _featuredSections,
                    isLoadingFeatured: _isLoadingFeatured,
                    onSearchTeam: _searchTeam,
                    onClearSearch: _clearSearch,
                    isSearching: _isSearching,
                    searchedTeam: _searchedTeam,
                    searchedMatches: _searchedMatches,
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
    final nameCtrl =
        TextEditingController(text: team?['name'] as String? ?? '');
    String? selectedCategory = team?['category'] as String?;
    String? selectedCountry = team?['club'] as String?;
    final isEdit = team != null;

    XFile? pickedLogo;
    Uint8List? logoBytes;
    bool isSaving = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) {
          final c = ctx.colors;
          final l10n = AppLocalizations.of(ctx)!;

          final categories = _categories(l10n);
          final countries = _countries(l10n);

          return AlertDialog(
            backgroundColor: c.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              isEdit ? l10n.teamEditTitle : l10n.teamNewTitle,
              style: TextStyle(
                color: c.text,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final file = await picker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 512,
                        maxHeight: 512,
                        imageQuality: 85,
                      );
                      if (file == null) return;
                      final bytes = await file.readAsBytes();
                      setDlg(() {
                        pickedLogo = file;
                        logoBytes = bytes;
                      });
                    },
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: c.elevated,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: c.borderGreen,
                              width: 2,
                            ),
                            image: logoBytes != null
                                ? DecorationImage(
                                    image: MemoryImage(logoBytes!),
                                    fit: BoxFit.cover,
                                  )
                                : (team?['logo_url'] as String?)?.isNotEmpty ==
                                        true
                                    ? DecorationImage(
                                        image: NetworkImage(
                                          team!['logo_url'] as String,
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                          ),
                          child: logoBytes == null &&
                                  (team?['logo_url'] as String?) == null
                              ? Icon(
                                  Icons.groups_outlined,
                                  color: c.accent,
                                  size: 32,
                                )
                              : null,
                        ),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: c.accent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.black,
                            size: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    pickedLogo != null
                        ? l10n.teamLogoSelected
                        : l10n.teamLogoTapToAdd,
                    style: TextStyle(
                      color: c.muted,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FormTextField(
                    controller: nameCtrl,
                    label: l10n.teamFieldName,
                  ),
                  const SizedBox(height: 10),
                  _DropdownField(
                    label: l10n.teamFieldClub,
                    value: selectedCountry,
                    options: countries,
                    onSelected: (v) => setDlg(() => selectedCountry = v),
                    c: c,
                  ),
                  const SizedBox(height: 10),
                  _DropdownField(
                    label: l10n.teamFieldCategory,
                    value: selectedCategory,
                    options: categories,
                    onSelected: (v) => setDlg(() => selectedCategory = v),
                    c: c,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(ctx),
                child: Text(
                  l10n.teamDialogCancel,
                  style: TextStyle(color: c.muted),
                ),
              ),
              TextButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        if (nameCtrl.text.trim().isEmpty) return;
                        setDlg(() => isSaving = true);

                        String? logoUrl;
                        if (pickedLogo != null && logoBytes != null) {
                          final tmpId = isEdit
                              ? (team['id'] as int)
                              : DateTime.now().millisecondsSinceEpoch;
                          final ext = pickedLogo!.name
                              .split('.')
                              .last
                              .toLowerCase();
                          logoUrl = await _controller.uploadLogo(
                            teamId: tmpId,
                            bytes: logoBytes!,
                            extension: ext,
                          );
                        }

                        if (isEdit) {
                          await _controller.updateTeam(
                            id: team['id'] as int,
                            name: nameCtrl.text.trim(),
                            category: selectedCategory,
                            club: selectedCountry,
                            logoUrl: logoUrl,
                          );
                        } else {
                          await _controller.createTeam(
                            name: nameCtrl.text.trim(),
                            category: selectedCategory,
                            club: selectedCountry,
                            logoUrl: logoUrl,
                          );
                        }
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                      },
                child: isSaving
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: context.colors.accent,
                        ),
                      )
                    : Text(
                        isEdit
                            ? l10n.teamDialogSave
                            : l10n.teamDialogCreate,
                        style: TextStyle(
                          color: context.colors.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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
        final l10n = AppLocalizations.of(ctx)!;
        return AlertDialog(
          backgroundColor: c.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            l10n.teamDeleteTitle,
            style: TextStyle(
              color: c.text,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            l10n.teamDeleteConfirm(team['name'] as String),
            style: TextStyle(
              color: c.muted,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                l10n.teamDialogCancel,
                style: TextStyle(color: c.muted),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                l10n.teamDeleteButton,
                style: TextStyle(color: c.danger),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) await _controller.deleteTeam(team['id'] as int);
  }

  // ── Localized team form options ─────────────────────────────────────────────

  List<String> _categories(AppLocalizations l10n) => [
        l10n.categoryU6,
        l10n.categoryU8,
        l10n.categoryU10,
        l10n.categoryU12,
        l10n.categoryU14,
        l10n.categoryU16,
        l10n.categoryU18,
        l10n.categoryU20,
        l10n.categoryU23,
        l10n.categoryAmateur,
        l10n.categorySemiProfessional,
        l10n.categoryProfessional,
        l10n.categoryFemaleU12,
        l10n.categoryFemaleU16,
        l10n.categoryFemaleU18,
        l10n.categoryFemale,
        l10n.categoryMixed,
      ];

  List<String> _countries(AppLocalizations l10n) => [
        l10n.countryArgentina,
        l10n.countryBolivia,
        l10n.countryBrazil,
        l10n.countryChile,
        l10n.countryColombia,
        l10n.countryCostaRica,
        l10n.countryCuba,
        l10n.countryEcuador,
        l10n.countryElSalvador,
        l10n.countrySpain,
        l10n.countryUnitedStates,
        l10n.countryGuatemala,
        l10n.countryHonduras,
        l10n.countryMexico,
        l10n.countryNicaragua,
        l10n.countryPanama,
        l10n.countryParaguay,
        l10n.countryPeru,
        l10n.countryPuertoRico,
        l10n.countryDominicanRepublic,
        l10n.countryUruguay,
        l10n.countryVenezuela,
        l10n.countryOther,
      ];
}

// ── Dropdown field widget ─────────────────────────────────────────────────────

class _DropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> options;
  final void Function(String) onSelected;
  final AppColorTokens c;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.options,
    required this.onSelected,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: c.elevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasValue
                ? c.accent.withValues(alpha: 0.5)
                : c.border2.withValues(alpha: 0.7),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: hasValue ? c.accent : c.text,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (hasValue) ...[
                    const SizedBox(height: 2),
                    Text(
                      value!,
                      style: TextStyle(
                        color: c.textHi,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.expand_more_rounded,
              color: hasValue ? c.accent : c.muted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(top: BorderSide(color: c.border)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: c.border2,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: c.textHi,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                itemCount: options.length,
                itemBuilder: (_, i) {
                  final opt = options[i];
                  final selected = opt == value;
                  return GestureDetector(
                    onTap: () {
                      onSelected(opt);
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? c.accent.withValues(alpha: 0.12)
                            : c.elevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? c.accent.withValues(alpha: 0.4)
                              : c.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              opt,
                              style: TextStyle(
                                color: selected ? c.accent : c.textHi,
                                fontSize: 14,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (selected)
                            Icon(
                              Icons.check_rounded,
                              color: c.accent,
                              size: 18,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}