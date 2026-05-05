import 'package:flutter/material.dart';

import '../../../../../core/theme/app_color_tokens.dart';
import '../../../../../l10n/generated/app_localizations.dart'; // IMPORTANTE
import '../../../../../shared/widgets/section_label.dart';

class PlayersTab extends StatefulWidget {
  final List players;
  const PlayersTab({super.key, required this.players});

  @override
  State<PlayersTab> createState() => _PlayersTabState();
}

class _PlayersTabState extends State<PlayersTab> {
  late List<Map<String, dynamic>> _players;

  @override
  void initState() {
    super.initState();
    _players = widget.players
        .map((p) => Map<String, dynamic>.from(p as Map))
        .toList();
  }

  void _updatePlayer(int index, Map<String, dynamic> updated) {
    setState(() => _players[index] = updated);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _players.length + 1,
      itemBuilder: (ctx, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SectionLabel(l10n.playersSection),
          );
        }
        final idx = i - 1;
        return PlayerCard(
          player: _players[idx],
          onEdit: (updated) => _updatePlayer(idx, updated),
        );
      },
    );
  }
}

class PlayerCard extends StatelessWidget {
  final Map<String, dynamic> player;
  final void Function(Map<String, dynamic>) onEdit;
  const PlayerCard({super.key, required this.player, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final c        = context.colors;
    final l10n     = AppLocalizations.of(context)!;
    final rank     = player['rank'] as int;
    final number   = (player['custom_number'] as int?) ?? rank;
    final name     = (player['custom_name'] as String?)?.isNotEmpty == true
        ? player['custom_name'] as String
        : l10n.playerLabel(rank);
    final zone     = player['zone'] as String? ?? '—';
    final km       = (player['distance_km']    as num?)?.toDouble() ?? 0;
    final spd      = (player['speed_ms']       as num?)?.toDouble() ?? 0;
    final poss     = (player['possession_pct'] as num).toDouble();
    final presence = (player['presence_pct']   as num).toDouble();

    return GestureDetector(
      onTap: () => _showPlayerDetail(context, player, name, zone),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.border),
        ),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: c.accentLo,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text('$number',
                    style: TextStyle(color: c.accent, fontWeight: FontWeight.w900, fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name,
                    style: TextStyle(color: c.text, fontWeight: FontWeight.w700, fontSize: 14)),
                Text(zone,
                    style: TextStyle(color: c.dim, fontSize: 12)),
              ])),
              GestureDetector(
                onTap: () => _showEditDialog(context),
                child: Container(
                  width: 32, height: 32,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: c.elevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: c.border2),
                  ),
                  child: Icon(Icons.edit_outlined, color: c.dim, size: 15),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: c.elevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: c.border2),
                ),
                child: Text(l10n.detailsBtn,
                    style: TextStyle(color: c.accent, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: presence / 100,
                backgroundColor: c.border,
                valueColor: AlwaysStoppedAnimation<Color>(c.accentLo),
                minHeight: 3,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(border: Border(top: BorderSide(color: c.border))),
            child: Row(children: [
              _StatColumn(l10n.statDistance, '${km.toStringAsFixed(2)} km'),
              Container(width: 1, height: 36, color: c.border),
              _StatColumn(l10n.statSpeed,    '${spd.toStringAsFixed(1)} m/s'),
              Container(width: 1, height: 36, color: c.border),
              _StatColumn(l10n.statPoss,     '$poss%'),
            ]),
          ),
        ]),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _EditPlayerDialog(player: player, onSave: onEdit),
    );
  }

  void _showPlayerDetail(BuildContext context, Map<String, dynamic> p, String name, String zone) {
    final c        = context.colors;
    final l10n     = AppLocalizations.of(context)!;
    final rank     = p['rank'] as int;
    final number   = (p['custom_number'] as int?) ?? rank;
    final km       = (p['distance_km']    as num?)?.toDouble() ?? 0;
    final spd      = (p['speed_ms']       as num?)?.toDouble() ?? 0;
    final poss     = (p['possession_pct'] as num).toDouble();
    final presence = (p['presence_pct']   as num).toDouble();

    showModalBottomSheet(
      context: context,
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: c.accentLo,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text('$number',
                  style: TextStyle(color: c.accent, fontWeight: FontWeight.w900, fontSize: 22)),
            ),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name,
                  style: TextStyle(color: c.text, fontSize: 18, fontWeight: FontWeight.w700)),
              Text(zone,
                  style: TextStyle(color: c.dim, fontSize: 13)),
            ]),
          ]),
          const SizedBox(height: 24),
          PlayerDetailRow(l10n.detailDistanceCovered, '${km.toStringAsFixed(2)} km'),
          PlayerDetailRow(l10n.detailAverageSpeed,    '${spd.toStringAsFixed(1)} m/s'),
          PlayerDetailRow(l10n.detailBallPossession,  '$poss%'),
          PlayerDetailRow(l10n.detailFieldPresence,   '$presence%'),
          PlayerDetailRow(l10n.detailMainZone,        zone),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.accentLo,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.accentLo),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.auto_awesome_outlined, color: c.accent, size: 16),
              const SizedBox(width: 10),
              Expanded(child: Text(
                km > 0.5
                    ? l10n.insightHighActivity(
                        km.toStringAsFixed(2),
                        spd.toStringAsFixed(1),
                      )
                    : l10n.insightModerateActivity(zone),
                style: TextStyle(color: c.text, fontSize: 13, height: 1.5),
              )),
            ]),
          ),
          const SizedBox(height: 10),
        ]),
      ),
    );
  }
}

class _EditPlayerDialog extends StatefulWidget {
  final Map<String, dynamic> player;
  final void Function(Map<String, dynamic>) onSave;
  const _EditPlayerDialog({required this.player, required this.onSave});

  @override
  State<_EditPlayerDialog> createState() => _EditPlayerDialogState();
}

class _EditPlayerDialogState extends State<_EditPlayerDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _numberCtrl;
  late final TextEditingController _posCtrl;

  @override
  void initState() {
    super.initState();
    final rank = widget.player['rank'] as int;
    _nameCtrl   = TextEditingController(
        text: widget.player['custom_name'] as String? ?? 'Jugador $rank');
    _numberCtrl = TextEditingController(
        text: '${widget.player['custom_number'] ?? rank}');
    _posCtrl    = TextEditingController(
        text: widget.player['zone'] as String? ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _numberCtrl.dispose();
    _posCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AlertDialog(
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Editar jugador',
          style: TextStyle(color: c.text, fontSize: 17, fontWeight: FontWeight.w700)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        _Field(controller: _nameCtrl,   label: 'Nombre'),
        const SizedBox(height: 12),
        _Field(controller: _numberCtrl, label: 'Número', inputType: TextInputType.number),
        const SizedBox(height: 12),
        _Field(controller: _posCtrl,    label: 'Posición'),
      ]),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar', style: TextStyle(color: c.dim)),
        ),
        TextButton(
          onPressed: _save,
          child: Text('Guardar',
              style: TextStyle(color: c.accent, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  void _save() {
    final rank    = widget.player['rank'] as int;
    final updated = Map<String, dynamic>.from(widget.player);
    final name    = _nameCtrl.text.trim();
    updated['custom_name']   = name.isEmpty ? null : name;
    updated['custom_number'] = int.tryParse(_numberCtrl.text.trim()) ?? rank;
    updated['zone']          = _posCtrl.text.trim();
    widget.onSave(updated);
    Navigator.pop(context);
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? inputType;
  const _Field({required this.controller, required this.label, this.inputType});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return TextField(
      controller: controller,
      keyboardType: inputType,
      style: TextStyle(color: c.text, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: c.dim, fontSize: 13),
        enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: c.border)),
        focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: c.accent, width: 1.5)),
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
      child: Row(children: [
        Text(label, style: TextStyle(color: c.muted, fontSize: 13)),
        const Spacer(),
        Text(value, style: TextStyle(color: c.text, fontSize: 13, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  const _StatColumn(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(children: [
          Text(label, style: TextStyle(color: c.dim, fontSize: 9, letterSpacing: 0.8)),
          const SizedBox(height: 3),
          Text(value, style: TextStyle(color: c.text, fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}
