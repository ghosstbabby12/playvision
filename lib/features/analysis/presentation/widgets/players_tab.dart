import 'package:flutter/material.dart';

import '../../../../../core/supabase/supabase_service.dart';
import '../../../../../core/theme/app_color_tokens.dart';
import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../../shared/widgets/section_label.dart';

class PlayersTab extends StatefulWidget {
  final List players;
  final int? teamId;
  final int? matchId;

  const PlayersTab({
    super.key,
    required this.players,
    this.teamId,
    this.matchId,
  });

  @override
  State<PlayersTab> createState() => _PlayersTabState();
}

class _PlayersTabState extends State<PlayersTab> {
  late List<Map<String, dynamic>> _players;
  List<Map<String, dynamic>> _squadPlayers = [];
  bool _loadingSquad = false;

  @override
  void initState() {
    super.initState();
    _players = widget.players
        .map((p) => Map<String, dynamic>.from(p as Map))
        .toList();
    _loadSquad();
  }

  Future<void> _loadSquad() async {
    final tid = widget.teamId;
    if (tid == null) return;
    setState(() => _loadingSquad = true);
    try {
      final data = await SupabaseService.instance.getPlayersByTeam(tid);
      if (mounted) setState(() => _squadPlayers = data);
    } catch (_) {}
    if (mounted) setState(() => _loadingSquad = false);
  }

  void _updatePlayer(int index, Map<String, dynamic> updated) {
    setState(() => _players[index] = updated);
    final matchId = widget.matchId;
    final trackId = updated['rank'] as int?;
    if (matchId != null && trackId != null) {
      _persistPlayerData(matchId: matchId, trackId: trackId, data: updated);
    }
  }

  Future<void> _persistPlayerData({
    required int matchId,
    required int trackId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final playerId = data['linked_player_id'] as int?;
      final row = <String, dynamic>{
        'match_id': matchId,
        'track_id': trackId,
        'distance': (data['distance_km'] as num?)?.toDouble() ?? 0,
        'velocity': (data['speed_ms'] as num?)?.toDouble() ?? 0,
        'possession': (data['possession_pct'] as num?)?.toDouble() ?? 0,
        'presence': (data['presence_pct'] as num?)?.toDouble() ?? 0,
        'zone': data['zone'] as String? ?? '',
        'best_position': data['best_position'] as String? ?? '',
        'custom_name': data['custom_name'] as String?,
        'custom_number': data['custom_number'] as int?,
      };
      if (playerId != null) row['player_id'] = playerId;
      await SupabaseService.instance.savePlayerStatsBatch([row]);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.colors;

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _players.length + 1,
      itemBuilder: (ctx, i) {
        if (i == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel(l10n.playersSection),
              if (_loadingSquad)
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: c.accent,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.playersLoadingSquad,
                        style: TextStyle(color: c.muted, fontSize: 11),
                      ),
                    ],
                  ),
                )
              else if (_squadPlayers.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.link_rounded, color: c.accent, size: 13),
                      const SizedBox(width: 5),
                      Text(
                        l10n.playersSquadAvailable(_squadPlayers.length),
                        style: TextStyle(color: c.muted, fontSize: 11),
                      ),
                    ],
                  ),
                )
              else if (widget.teamId != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 4),
                  child: Text(
                    l10n.playersNoSquadHint,
                    style: TextStyle(color: c.dim, fontSize: 11),
                  ),
                ),
              const SizedBox(height: 12),
            ],
          );
        }

        final idx = i - 1;
        return PlayerCard(
          player: _players[idx],
          squadPlayers: _squadPlayers,
          onEdit: (updated) => _updatePlayer(idx, updated),
        );
      },
    );
  }
}

class PlayerCard extends StatelessWidget {
  final Map<String, dynamic> player;
  final List<Map<String, dynamic>> squadPlayers;
  final void Function(Map<String, dynamic>) onEdit;

  const PlayerCard({
    super.key,
    required this.player,
    required this.squadPlayers,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final rank = player['rank'] as int;
    final isLinked = player['linked_player_id'] != null;

    final number = isLinked
        ? (player['linked_shirt'] as int? ?? rank)
        : (player['custom_number'] as int? ?? rank);

    final name = isLinked
        ? (player['linked_name'] as String? ?? l10n.playerLabel(rank))
        : ((player['custom_name'] as String?)?.isNotEmpty == true
            ? player['custom_name'] as String
            : l10n.playerLabel(rank));

    final position = isLinked
        ? (player['linked_position'] as String? ?? '')
        : '';

    final zone = player['zone'] as String? ?? '—';
    final km = (player['distance_km'] as num?)?.toDouble() ?? 0;
    final spd = (player['speed_ms'] as num?)?.toDouble() ?? 0;
    final poss = (player['possession_pct'] as num?)?.toDouble() ?? 0.0;
    final presence = (player['presence_pct'] as num?)?.toDouble() ?? 0.0;

    return GestureDetector(
      onTap: () => _showPlayerDetail(
        context,
        name,
        zone,
        km,
        spd,
        poss,
        presence,
        number,
        isLinked,
        position,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isLinked ? c.accent.withValues(alpha: 0.06) : c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isLinked ? c.accent.withValues(alpha: 0.30) : c.border,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isLinked
                          ? c.accent.withValues(alpha: 0.18)
                          : c.accentLo,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$number',
                      style: TextStyle(
                        color: c.accent,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                name,
                                style: TextStyle(
                                  color: c.textHi,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isLinked) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: c.accent.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.link_rounded,
                                      color: c.accent,
                                      size: 10,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      l10n.playersLinked,
                                      style: TextStyle(
                                        color: c.accent,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          position.isNotEmpty ? '$position · $zone' : zone,
                          style: TextStyle(color: c.muted, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showEditDialog(context),
                    child: Container(
                      width: 34,
                      height: 34,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: isLinked
                            ? c.accent.withValues(alpha: 0.12)
                            : c.elevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isLinked
                              ? c.accent.withValues(alpha: 0.35)
                              : c.border2,
                        ),
                      ),
                      child: Icon(
                        isLinked ? Icons.edit_rounded : Icons.link_rounded,
                        color: isLinked ? c.accent : c.dim,
                        size: 15,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: c.elevated,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: c.border2),
                    ),
                    child: Text(
                      l10n.detailsBtn,
                      style: TextStyle(
                        color: c.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: presence / 100,
                  backgroundColor: c.border,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isLinked ? c.accent : c.accentLo,
                  ),
                  minHeight: 3,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: c.border)),
              ),
              child: Row(
                children: [
                  _StatCol(l10n.statDistance, '${km.toStringAsFixed(2)} km'),
                  Container(width: 1, height: 36, color: c.border),
                  _StatCol(l10n.statSpeed, '${spd.toStringAsFixed(1)} m/s'),
                  Container(width: 1, height: 36, color: c.border),
                  _StatCol(l10n.statPoss, '${poss.toStringAsFixed(1)}%'),
                  Container(width: 1, height: 36, color: c.border),
                  _StatCol(l10n.playersPresenceShort, '${presence.toStringAsFixed(0)}%'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _LinkPlayerSheet(
        player: player,
        squadPlayers: squadPlayers,
        onSave: onEdit,
      ),
    );
  }

  void _showPlayerDetail(
    BuildContext context,
    String name,
    String zone,
    double km,
    double spd,
    double poss,
    double presence,
    int number,
    bool isLinked,
    String position,
  ) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: c.accentLo,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$number',
                    style: TextStyle(
                      color: c.accent,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: c.textHi,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        position.isNotEmpty ? '$position · $zone' : zone,
                        style: TextStyle(color: c.muted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                if (isLinked)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: c.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.link_rounded, color: c.accent, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          l10n.playersLinked,
                          style: TextStyle(
                            color: c.accent,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            _DetailRow(l10n.detailDistanceCovered, '${km.toStringAsFixed(2)} km'),
            _DetailRow(l10n.detailAverageSpeed, '${spd.toStringAsFixed(1)} m/s'),
            _DetailRow(l10n.detailBallPossession, '${poss.toStringAsFixed(1)}%'),
            _DetailRow(l10n.detailFieldPresence, '${presence.toStringAsFixed(0)}%'),
            _DetailRow(l10n.detailMainZone, zone),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: c.accentLo,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.auto_awesome_outlined, color: c.accent, size: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      km > 0.5
                          ? l10n.insightHighActivity(
                              km.toStringAsFixed(2),
                              spd.toStringAsFixed(1),
                            )
                          : l10n.insightModerateActivity(zone),
                      style: TextStyle(color: c.text, fontSize: 13, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _LinkPlayerSheet extends StatefulWidget {
  final Map<String, dynamic> player;
  final List<Map<String, dynamic>> squadPlayers;
  final void Function(Map<String, dynamic>) onSave;

  const _LinkPlayerSheet({
    required this.player,
    required this.squadPlayers,
    required this.onSave,
  });

  @override
  State<_LinkPlayerSheet> createState() => _LinkPlayerSheetState();
}

class _LinkPlayerSheetState extends State<_LinkPlayerSheet> {
  int? _selectedSquadId;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _numberCtrl;

  @override
  void initState() {
    super.initState();
    _selectedSquadId = widget.player['linked_player_id'] as int?;
    final rank = widget.player['rank'] as int;
    _nameCtrl = TextEditingController(
      text: widget.player['custom_name'] as String? ?? '',
    );
    _numberCtrl = TextEditingController(
      text: '${widget.player['custom_number'] ?? rank}',
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _numberCtrl.dispose();
    super.dispose();
  }

  void _selectSquadPlayer(Map<String, dynamic> sp) {
    setState(() {
      _selectedSquadId = sp['id'] as int;
      _nameCtrl.text = sp['name'] as String? ?? '';
      _numberCtrl.text = '${sp['shirt_number'] ?? ''}';
    });
  }

  void _clearLink() {
    setState(() {
      _selectedSquadId = null;
    });
  }

  void _save() {
    final rank = widget.player['rank'] as int;
    final updated = Map<String, dynamic>.from(widget.player);

    if (_selectedSquadId != null) {
      final sp = widget.squadPlayers.firstWhere(
        (p) => p['id'] == _selectedSquadId,
        orElse: () => <String, dynamic>{},
      );
      updated['linked_player_id'] = _selectedSquadId;
      updated['linked_name'] = sp['name'] as String? ?? _nameCtrl.text.trim();
      updated['linked_shirt'] =
          sp['shirt_number'] as int? ?? int.tryParse(_numberCtrl.text) ?? rank;
      updated['linked_position'] = sp['position'] as String? ?? '';
      updated['custom_name'] = updated['linked_name'];
      updated['custom_number'] = updated['linked_shirt'];
    } else {
      updated['linked_player_id'] = null;
      updated['linked_name'] = null;
      updated['linked_shirt'] = null;
      updated['linked_position'] = null;
      final name = _nameCtrl.text.trim();
      updated['custom_name'] = name.isEmpty ? null : name;
      updated['custom_number'] = int.tryParse(_numberCtrl.text.trim()) ?? rank;
    }

    widget.onSave(updated);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final rank = widget.player['rank'] as int;
    final hasSquad = widget.squadPlayers.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: c.border)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: c.border2,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: c.accentLo,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$rank',
                      style: TextStyle(
                        color: c.accent,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.playersEditTitle(rank),
                    style: TextStyle(
                      color: c.textHi,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  if (_selectedSquadId != null)
                    GestureDetector(
                      onTap: _clearLink,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          l10n.playersUnlink,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (hasSquad) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(Icons.people_alt_rounded, color: c.accent, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      l10n.playersLinkToSquad,
                      style: TextStyle(
                        color: c.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 76,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: widget.squadPlayers.length,
                  itemBuilder: (_, i) {
                    final sp = widget.squadPlayers[i];
                    final spId = sp['id'] as int;
                    final spName = sp['name'] as String? ?? '';
                    final spNum = sp['shirt_number'] as int?;
                    final spPos = sp['position'] as String? ?? '';
                    final selected = _selectedSquadId == spId;

                    return GestureDetector(
                      onTap: () => _selectSquadPlayer(sp),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 68,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? c.accent.withValues(alpha: 0.15)
                              : c.elevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected ? c.accent : c.border,
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              spNum != null ? '#$spNum' : '—',
                              style: TextStyle(
                                color: selected ? c.accent : c.textHi,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              spName.split(' ').first,
                              style: TextStyle(
                                color: selected ? c.accent : c.muted,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            if (spPos.isNotEmpty)
                              Text(
                                spPos,
                                style: TextStyle(color: c.dim, fontSize: 8),
                                overflow: TextOverflow.ellipsis,
                              ),
                            if (selected)
                              Icon(
                                Icons.check_circle_rounded,
                                color: c.accent,
                                size: 12,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(child: Divider(color: c.border)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        l10n.playersOrEditManually,
                        style: TextStyle(color: c.dim, fontSize: 11),
                      ),
                    ),
                    Expanded(child: Divider(color: c.border)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ] else ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: c.elevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: c.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: c.muted, size: 14),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.playersNoLinkedTeamHint,
                          style: TextStyle(
                            color: c.muted,
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _SheetField(
                      controller: _nameCtrl,
                      label: l10n.editPlayerNameLabel,
                      c: c,
                      enabled: _selectedSquadId == null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SheetField(
                      controller: _numberCtrl,
                      label: '#',
                      c: c,
                      inputType: TextInputType.number,
                      enabled: _selectedSquadId == null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: c.accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _selectedSquadId != null
                        ? l10n.playersLinkAndSave
                        : l10n.saveBtn,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final AppColorTokens c;
  final TextInputType? inputType;
  final bool enabled;

  const _SheetField({
    required this.controller,
    required this.label,
    required this.c,
    this.inputType,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        keyboardType: inputType,
        enabled: enabled,
        style: TextStyle(
          color: enabled ? c.textHi : c.muted,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: c.text, fontSize: 12),
          filled: true,
          fillColor: enabled ? c.elevated : c.surface,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: c.border2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: c.accent, width: 1.5),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: c.border.withValues(alpha: 0.4)),
          ),
        ),
      );
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: c.muted, fontSize: 13)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: c.textHi,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class PlayerDetailRow extends StatelessWidget {
  final String label;
  final String value;
  const PlayerDetailRow(this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: c.muted, fontSize: 13)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: c.textHi,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCol extends StatelessWidget {
  final String label;
  final String value;
  const _StatCol(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(color: c.dim, fontSize: 9, letterSpacing: 0.8),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: TextStyle(
                color: c.textHi,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}