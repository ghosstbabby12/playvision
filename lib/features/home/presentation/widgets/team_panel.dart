import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:playvision/core/constants/app_constants.dart';
import 'package:playvision/core/theme/app_color_tokens.dart';
import 'package:playvision/features/home/presentation/home_controller.dart';

import '../../../../../../l10n/generated/app_localizations.dart';

class TeamSelectorSection extends StatelessWidget {
  final HomeController controller;
  final VoidCallback onAdd;
  const TeamSelectorSection({super.key, required this.controller, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final c    = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          l10n.selectOrCreateTeam,
          style: TextStyle(color: c.textHi, fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.chooseTeamSubtitle,
          style: TextStyle(color: c.muted, fontSize: 12),
        ),
        const SizedBox(height: 20),

        if (controller.isLoading)
          Center(child: CircularProgressIndicator(color: c.accent, strokeWidth: 1.5))
        else if (controller.teams.isEmpty)
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: c.borderGreen),
              ),
              child: Column(children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(color: c.accentLo, shape: BoxShape.circle),
                  child: Icon(Icons.groups_outlined, color: c.accent, size: 30),
                ),
                const SizedBox(height: 14),
                Text(l10n.createTeam,
                    style: TextStyle(color: c.text, fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(l10n.tapToAddTeam,
                    style: TextStyle(color: c.muted, fontSize: 12)),
              ]),
            ),
          )
        else ...[
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                TeamCircleItem(label: l10n.newTeam, initial: '+', isAdd: true, onTap: onAdd),
                const SizedBox(width: 14),
                ...controller.teams.map((t) => Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: TeamCircleItem(
                    label: t['name'] as String? ?? '',
                    initial: _initial(t['name'] as String?),
                    logoUrl: t['logo_url'] as String?,
                    isAdd: false,
                    onTap: () => controller.selectTeam(t),
                  ),
                )),
              ],
            ),
          ),
        ],
      ]),
    );
  }

  String _initial(String? name) => name?.isNotEmpty == true ? name![0].toUpperCase() : '?';
}

class TeamCircleItem extends StatelessWidget {
  final String label;
  final String initial;
  final String? logoUrl;
  final bool isAdd;
  final VoidCallback onTap;
  const TeamCircleItem({
    super.key,
    required this.label,
    required this.initial,
    required this.isAdd,
    required this.onTap,
    this.logoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hasLogo = !isAdd && logoUrl != null && logoUrl!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: isAdd ? c.accentLo : c.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: isAdd
                  ? c.accent.withValues(alpha: 0.60)
                  : c.accent.withValues(alpha: 0.45),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: c.accent.withValues(alpha: 0.25),
                blurRadius: 12,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: hasLogo
              ? ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: logoUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Center(
                      child: CircularProgressIndicator(
                          strokeWidth: 1.5, color: c.accent),
                    ),
                    errorWidget: (_, __, ___) => Center(
                      child: Text(
                        initial,
                        style: TextStyle(
                          color: c.accent,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: isAdd ? c.accent : c.text,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 64,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(color: c.muted, fontSize: 11),
          ),
        ),
      ]),
    );
  }
}

class SelectedTeamHeader extends StatelessWidget {
  final HomeController controller;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const SelectedTeamHeader({
    super.key,
    required this.controller,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final c      = context.colors;
    final l10n   = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final team    = controller.selectedTeam!;
    final initial = (team['name'] as String?)?.isNotEmpty == true
        ? (team['name'] as String)[0].toUpperCase() : '?';
    final logoUrl = team['logo_url'] as String?;
    final hasLogo = logoUrl != null && logoUrl.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF07111F).withValues(alpha: 0.50)
                  : Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: c.borderGreen),
              boxShadow: isDark
                  ? [
                      BoxShadow(
                        color: const Color(0xFF32FF88).withValues(alpha: 0.10),
                        blurRadius: 24,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: Row(children: [
              // Logo with accent gradient border
              Container(
                width: 56,
                height: 56,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF32FF88),
                      const Color(0xFF32FF88).withValues(alpha: 0.40),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF32FF88).withValues(alpha: 0.30),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Container(
                    color: c.accentLo,
                    child: hasLogo
                        ? CachedNetworkImage(
                            imageUrl: logoUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Center(
                              child: CircularProgressIndicator(
                                  strokeWidth: 1.5, color: c.accent),
                            ),
                            errorWidget: (_, __, ___) => Center(
                              child: Text(
                                initial,
                                style: TextStyle(
                                  color: c.accent,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              initial,
                              style: TextStyle(
                                color: c.accent,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  team['name'] ?? '',
                  style: TextStyle(
                    color: c.textHi,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${team['club'] ?? ''} ${team['category'] ?? ''}'.trim(),
                  style: TextStyle(color: c.muted, fontSize: 12),
                ),
              ])),
              // "Cambiar" glass pill
              GestureDetector(
                onTap: controller.clearTeamSelection,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: c.accent.withValues(alpha: 0.50),
                    ),
                  ),
                  child: Text(
                    l10n.changeTeam,
                    style: TextStyle(
                      color: c.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onEdit,
                child: Icon(Icons.edit_outlined, color: c.dim, size: 18),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onDelete,
                child: Icon(Icons.delete_outline, color: c.danger, size: 18),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class AnalyseButton extends StatelessWidget {
  final VoidCallback onTap;
  const AnalyseButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c      = context.colors;
    final l10n   = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: isDark
                ? const LinearGradient(
                    colors: [Color(0xFF0A3020), Color(0xFF1A5A35)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: isDark ? null : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: c.borderGreen),
            boxShadow: [
              BoxShadow(
                color: c.accent.withValues(alpha: isDark ? 0.20 : 0.15),
                blurRadius: 20,
                offset: Offset(0, isDark ? 8 : 6),
              ),
            ],
          ),
          child: Row(children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isDark
                    ? c.accent.withValues(alpha: 0.15)
                    : c.accentLo,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.videocam_outlined, color: c.accent, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                l10n.analyseVideo,
                style: TextStyle(
                  color: c.textHi,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.uploadMatchVideo,
                style: TextStyle(color: c.muted, fontSize: 12),
              ),
            ])),
            Icon(Icons.arrow_forward_ios_rounded, color: c.accent, size: 16),
          ]),
        ),
      ),
    );
  }
}

class ViewAnalysisButton extends StatelessWidget {
  final VoidCallback onTap;
  const ViewAnalysisButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF32FF88), Color(0xFF1A8A44)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF32FF88).withValues(alpha: 0.35),
                blurRadius: 24,
              ),
            ],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.analytics_outlined, color: Colors.black, size: 20),
            const SizedBox(width: 8),
            Text(
              l10n.viewAnalysis,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class PreviousAnalysesSection extends StatelessWidget {
  final HomeController controller;
  final VoidCallback onViewAnalysis;
  const PreviousAnalysesSection({super.key, required this.controller, required this.onViewAnalysis});

  @override
  Widget build(BuildContext context) {
    final c    = context.colors;
    final l10n = AppLocalizations.of(context)!;

    final teamId = controller.selectedTeam?['id'] as int?;
    if (teamId == null) return const SizedBox.shrink();

    final isLoading = controller.isLoadingMatchesForTeam(teamId);
    final matches   = controller.selectedTeamMatches;

    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Center(child: CircularProgressIndicator(color: c.accent, strokeWidth: 1.5)),
      );
    }

    if (matches.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l10n.teamMatches,
              style: TextStyle(color: c.textHi, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: c.border),
            ),
            child: Center(child: Text(l10n.noAnalysedMatches,
                style: TextStyle(color: c.muted, fontSize: 13))),
          ),
        ]),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.teamMatches,
              style: TextStyle(color: c.textHi, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ...matches.map((m) => MatchItem(
            match: m,
            controller: controller,
            onTap: onViewAnalysis,
          )),
        ],
      ),
    );
  }
}

class MatchItem extends StatefulWidget {
  final Map<String, dynamic> match;
  final VoidCallback onTap;
  final HomeController controller;
  const MatchItem({super.key, required this.match, required this.onTap, required this.controller});

  @override
  State<MatchItem> createState() => _MatchItemState();
}

class _MatchItemState extends State<MatchItem> {
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    final c          = context.colors;
    final l10n       = AppLocalizations.of(context)!;
    final isDark     = Theme.of(context).brightness == Brightness.dark;
    final controller = widget.controller;
    final opponent   = widget.match['opponent'] as String? ?? l10n.matchUnknownOpponent;
    final dateStr    = widget.match['match_date'] as String? ?? '';
    final status     = widget.match['status'] as String? ?? 'uploaded';
    final matchId    = widget.match['id'] as int;

    DateTime? dt;
    if (dateStr.isNotEmpty) {
      try { dt = DateTime.parse(dateStr).toLocal(); } catch (_) {}
    }
    final formattedDate = dt != null ? DateFormat(AppConstants.dateFormat).format(dt) : '';

    Color statusColor;
    String statusLabel;
    if (status == AppConstants.statusDone) {
      statusColor = c.success;
      statusLabel = l10n.statusAnalysed;
    } else if (status == AppConstants.statusProcessing) {
      statusColor = c.warning;
      statusLabel = l10n.statusProcessing;
    } else {
      statusColor = c.dim;
      statusLabel = l10n.statusUploaded;
    }

    return GestureDetector(
      onTap: () async {
        if (_isDownloading) return;
        if (status == AppConstants.statusDone) {
          setState(() => _isDownloading = true);
          final success = await controller.loadAnalysisForMatch(matchId);
          if (!context.mounted) return;
          setState(() => _isDownloading = false);

          if (success) {
            widget.onTap();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(l10n.matchLoadAnalysisFailed),
              backgroundColor: c.danger,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l10n.matchNotAnalysedYet),
            backgroundColor: c.warning,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: c.elevated,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.sports_soccer_outlined, color: c.dim, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l10n.matchVersusOpponent(opponent),
                style: TextStyle(color: c.text, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Row(children: [
              Text(formattedDate, style: TextStyle(color: c.muted, fontSize: 11)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: statusColor.withValues(alpha: 0.30)),
                ),
                child: Text(statusLabel,
                    style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.w700)),
              ),
            ]),
          ])),
          if (_isDownloading)
            SizedBox(width: 16, height: 16,
                child: CircularProgressIndicator(color: c.accent, strokeWidth: 2))
          else
            Icon(Icons.arrow_forward_ios_rounded, color: c.dim, size: 13),
        ]),
      ),
    );
  }
}
