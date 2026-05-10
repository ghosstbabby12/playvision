import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_color_tokens.dart';
import 'squad_controller.dart';

class SquadPage extends StatefulWidget {
  const SquadPage({super.key});

  @override
  State<SquadPage> createState() => _SquadPageState();
}

class _SquadPageState extends State<SquadPage> {
  late final SquadController _ctrl;
  final _searchCtrl = TextEditingController();

  static const _positions = ['All', 'GK', 'DEF', 'MID', 'FWD'];

  @override
  void initState() {
    super.initState();
    _ctrl = SquadController()..fetchData();
    _searchCtrl.addListener(() => _ctrl.setSearch(_searchCtrl.text));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Add player dialog ─────────────────────────────────────────────────────

  Future<void> _openAddPlayerDialog() async {
    if (_ctrl.teams.isEmpty) return;
    final c = context.colors;

    final nameCtrl   = TextEditingController();
    final numberCtrl = TextEditingController();
    String    selectedPos = 'MID';
    DateTime? birthDate;
    XFile?    photoFile;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          final dc = ctx.colors;

          return AlertDialog(
            backgroundColor: dc.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: dc.border2),
            ),
            title: Text('Nuevo jugador',
                style: TextStyle(
                    color: dc.text, fontWeight: FontWeight.w700, fontSize: 17)),
            content: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // Photo picker
                GestureDetector(
                  onTap: () async {
                    final f = await ImagePicker()
                        .pickImage(source: ImageSource.gallery, imageQuality: 80);
                    if (f != null) setS(() => photoFile = f);
                  },
                  child: Container(
                    height: 90,
                    decoration: BoxDecoration(
                      color: dc.elevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: dc.border2),
                    ),
                    child: photoFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: Image.network(photoFile!.path,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (_, __, ___) =>
                                    _PhotoPlaceholder(dc: dc)),
                          )
                        : _PhotoPlaceholder(dc: dc),
                  ),
                ),
                const SizedBox(height: 14),

                _DialogField(controller: nameCtrl,
                    label: 'Nombre completo', hint: 'Ej. Carlos García', dc: dc),
                const SizedBox(height: 12),

                _DialogField(controller: numberCtrl,
                    label: 'Dorsal', hint: 'Ej. 10',
                    keyboardType: TextInputType.number, dc: dc),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  initialValue: selectedPos,
                  dropdownColor: dc.elevated,
                  decoration: _dialogDecoration('Posición', dc),
                  style: TextStyle(color: dc.text, fontSize: 14),
                  items: ['GK', 'DEF', 'MID', 'FWD'].map((p) =>
                      DropdownMenuItem(value: p,
                          child: Text(_posLabel(p),
                              style: TextStyle(color: dc.text)))).toList(),
                  onChanged: (v) { if (v != null) setS(() => selectedPos = v); },
                ),
                const SizedBox(height: 12),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    birthDate == null
                        ? 'Fecha de nacimiento (opcional)'
                        : '${birthDate!.day}/${birthDate!.month}/${birthDate!.year}',
                    style: TextStyle(
                        color: birthDate == null ? dc.dim : dc.text,
                        fontSize: 14),
                  ),
                  trailing: Icon(Icons.calendar_today_outlined,
                      color: dc.accent, size: 18),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1970),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setS(() => birthDate = picked);
                  },
                ),
              ]),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Cancelar', style: TextStyle(color: dc.dim)),
              ),
              GestureDetector(
                onTap: () async {
                  if (nameCtrl.text.trim().isEmpty) return;
                  Navigator.pop(ctx);

                  final id = await _ctrl.addPlayer(
                    name:        nameCtrl.text.trim(),
                    position:    selectedPos,
                    shirtNumber: int.tryParse(numberCtrl.text.trim()),
                    birthDate:   birthDate?.toIso8601String().substring(0, 10),
                  );
                  if (!mounted) return;

                  if (id != null && photoFile != null) {
                    final bytes = await photoFile!.readAsBytes();
                    final ext   = photoFile!.name.split('.').last.toLowerCase();
                    await _ctrl.uploadPhoto(
                        playerId: id, bytes: bytes, extension: ext);
                  }

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(id != null
                        ? 'Jugador guardado' : 'Error al guardar'),
                    backgroundColor: c.elevated,
                  ));
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: c.accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Guardar',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _posLabel(String pos) => switch (pos) {
    'GK'  => 'Portero (GK)',
    'DEF' => 'Defensa (DEF)',
    'MID' => 'Centrocampista (MID)',
    'FWD' => 'Delantero (FWD)',
    _     => pos,
  };

  InputDecoration _dialogDecoration(String label, AppColorTokens dc) =>
      InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: dc.dim, fontSize: 13),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: dc.border2),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: dc.accent),
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: dc.elevated,
      );

  // ── Edit player dialog ────────────────────────────────────────────────────

  Future<void> _openEditPlayerDialog(Map<String, dynamic> player) async {
    final c = context.colors;

    final nameCtrl   = TextEditingController(
        text: player['name'] as String? ?? '');
    final numberCtrl = TextEditingController(
        text: (player['shirt_number'] as int?)?.toString() ?? '');
    String    selectedPos    = (player['position'] as String? ?? 'MID').toUpperCase();
    String    selectedStatus = (player['status']   as String? ?? 'active').toLowerCase();
    DateTime? birthDate;
    final bd  = player['birth_date'] as String?;
    if (bd != null && bd.isNotEmpty) {
      try { birthDate = DateTime.parse(bd); } catch (_) {}
    }
    XFile? photoFile;
    final int playerId = player['id'] as int;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          final dc = ctx.colors;

          return AlertDialog(
            backgroundColor: dc.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: dc.border2),
            ),
            title: Row(children: [
              Expanded(
                child: Text('Editar jugador',
                    style: TextStyle(
                        color: dc.text,
                        fontWeight: FontWeight.w700,
                        fontSize: 17)),
              ),
              // Delete button
              GestureDetector(
                onTap: () async {
                  Navigator.pop(ctx);
                  final confirmed = await _confirmDelete(player['name'] as String? ?? '');
                  if (!confirmed || !mounted) return;
                  final ok = await _ctrl.removePlayer(playerId);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(ok ? 'Jugador eliminado' : 'Error al eliminar'),
                    backgroundColor: c.elevated,
                  ));
                },
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B1A1A).withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: const Color(0xFFE53E3E).withValues(alpha: 0.4)),
                  ),
                  child: const Icon(Icons.delete_outline_rounded,
                      color: Color(0xFFFC8181), size: 16),
                ),
              ),
            ]),
            content: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // Photo picker
                GestureDetector(
                  onTap: () async {
                    final f = await ImagePicker()
                        .pickImage(source: ImageSource.gallery, imageQuality: 80);
                    if (f != null) setS(() => photoFile = f);
                  },
                  child: Container(
                    height: 90,
                    decoration: BoxDecoration(
                      color: dc.elevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: dc.border2),
                    ),
                    child: photoFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: Image.network(photoFile!.path,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (_, __, ___) =>
                                    _PhotoPlaceholder(dc: dc)))
                        : (player['photo_url'] as String?)?.isNotEmpty == true
                            ? Stack(fit: StackFit.expand, children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(11),
                                  child: Image.network(
                                    player['photo_url'] as String,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _PhotoPlaceholder(dc: dc),
                                  ),
                                ),
                                Positioned(
                                  bottom: 6, right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: dc.surface.withValues(alpha: 0.85),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(mainAxisSize: MainAxisSize.min,
                                        children: [
                                      Icon(Icons.edit_outlined,
                                          color: dc.accent, size: 12),
                                      const SizedBox(width: 4),
                                      Text('Cambiar',
                                          style: TextStyle(
                                              color: dc.accent, fontSize: 11)),
                                    ]),
                                  ),
                                ),
                              ])
                            : _PhotoPlaceholder(dc: dc),
                  ),
                ),
                const SizedBox(height: 14),

                _DialogField(controller: nameCtrl,
                    label: 'Nombre completo', hint: 'Ej. Carlos García', dc: dc),
                const SizedBox(height: 12),

                _DialogField(controller: numberCtrl,
                    label: 'Dorsal', hint: 'Ej. 10',
                    keyboardType: TextInputType.number, dc: dc),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  initialValue: selectedPos,
                  dropdownColor: dc.elevated,
                  decoration: _dialogDecoration('Posición', dc),
                  style: TextStyle(color: dc.text, fontSize: 14),
                  items: ['GK', 'DEF', 'MID', 'FWD'].map((p) =>
                      DropdownMenuItem(value: p,
                          child: Text(_posLabel(p),
                              style: TextStyle(color: dc.text)))).toList(),
                  onChanged: (v) { if (v != null) setS(() => selectedPos = v); },
                ),
                const SizedBox(height: 12),

                // Status
                DropdownButtonFormField<String>(
                  initialValue: selectedStatus,
                  dropdownColor: dc.elevated,
                  decoration: _dialogDecoration('Estado', dc),
                  style: TextStyle(color: dc.text, fontSize: 14),
                  items: [
                    DropdownMenuItem(value: 'active',
                        child: Text('Activo',
                            style: TextStyle(color: dc.text))),
                    DropdownMenuItem(value: 'injured',
                        child: Text('Lesionado',
                            style: TextStyle(color: dc.text))),
                    DropdownMenuItem(value: 'suspended',
                        child: Text('Suspendido',
                            style: TextStyle(color: dc.text))),
                    DropdownMenuItem(value: 'inactive',
                        child: Text('Inactivo',
                            style: TextStyle(color: dc.text))),
                  ],
                  onChanged: (v) { if (v != null) setS(() => selectedStatus = v); },
                ),
                const SizedBox(height: 12),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    birthDate == null
                        ? 'Fecha de nacimiento'
                        : '${birthDate!.day}/${birthDate!.month}/${birthDate!.year}',
                    style: TextStyle(
                        color: birthDate == null ? dc.dim : dc.text,
                        fontSize: 14),
                  ),
                  trailing: Icon(Icons.calendar_today_outlined,
                      color: dc.accent, size: 18),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: birthDate ?? DateTime(2000),
                      firstDate: DateTime(1970),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setS(() => birthDate = picked);
                  },
                ),
              ]),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Cancelar', style: TextStyle(color: dc.dim)),
              ),
              GestureDetector(
                onTap: () async {
                  if (nameCtrl.text.trim().isEmpty) return;
                  Navigator.pop(ctx);

                  final ok = await _ctrl.editPlayer(
                    id:          playerId,
                    name:        nameCtrl.text.trim(),
                    position:    selectedPos,
                    shirtNumber: int.tryParse(numberCtrl.text.trim()),
                    birthDate:   birthDate?.toIso8601String().substring(0, 10),
                    status:      selectedStatus,
                  );

                  if (!mounted) return;

                  // Upload new photo if selected
                  if (ok && photoFile != null) {
                    final bytes = await photoFile!.readAsBytes();
                    final ext   = photoFile!.name.split('.').last.toLowerCase();
                    await _ctrl.uploadPhoto(
                        playerId: playerId, bytes: bytes, extension: ext);
                  }

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content:
                        Text(ok ? 'Jugador actualizado' : 'Error al actualizar'),
                    backgroundColor: c.elevated,
                  ));
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: c.accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Guardar',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<bool> _confirmDelete(String name) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) {
            final dc = ctx.colors;
            return AlertDialog(
              backgroundColor: dc.surface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: dc.border2)),
              title: Text('Eliminar jugador',
                  style: TextStyle(
                      color: dc.text, fontWeight: FontWeight.w700)),
              content: Text(
                '¿Eliminar a $name de la plantilla? Esta acción no se puede deshacer.',
                style: TextStyle(color: dc.dim, fontSize: 14, height: 1.5),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text('Cancelar', style: TextStyle(color: dc.dim)),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(ctx, true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B1A1A).withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFFE53E3E)
                              .withValues(alpha: 0.5)),
                    ),
                    child: const Text('Eliminar',
                        style: TextStyle(
                            color: Color(0xFFFC8181),
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return ListenableBuilder(
      listenable: _ctrl,
      builder: (context, _) {
        if (_ctrl.errorMessage != null) {
          final msg = _ctrl.errorMessage!;
          _ctrl.consumeError();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ScaffoldMessenger.of(this.context).showSnackBar(
              SnackBar(content: Text(msg), backgroundColor: c.elevated),
            );
          });
        }

        final players  = _ctrl.filtered;
        final total    = _ctrl.countByPosition('All');
        final teamName = _ctrl.teams.isEmpty
            ? 'Mi equipo'
            : (_ctrl.teams.firstWhere(
                    (t) => t['id'] == _ctrl.selectedTeamId,
                    orElse: () => _ctrl.teams.first)['name'] as String? ??
                'Mi equipo');

        return Scaffold(
          backgroundColor: c.bg,
          body: SafeArea(
            child: Column(children: [
              // ── Header ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                        color: c.accent,
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.play_arrow_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('Plantilla',
                          style: TextStyle(
                              color: c.text, fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3)),
                      Text('$total jugadores · Temporada 2025/26',
                          style: TextStyle(color: c.dim, fontSize: 12)),
                    ]),
                  ),
                  GestureDetector(
                    onTap: _openAddPlayerDialog,
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                          color: c.accent,
                          borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.person_add_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_ctrl.teams.length > 1)
                    _TeamDropdown(ctrl: _ctrl, c: c)
                  else
                    _HeaderIcon(icon: Icons.notifications_outlined, c: c),
                ]),
              ),

              const SizedBox(height: 16),

              // ── Search ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _SearchBar(controller: _searchCtrl, c: c),
              ),

              const SizedBox(height: 14),

              // ── Position chips ────────────────────────────────────────
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemCount: _positions.length,
                  itemBuilder: (_, i) {
                    final pos    = _positions[i];
                    final active = _ctrl.selectedPosition == pos;
                    final count  = _ctrl.countByPosition(pos);
                    return _PositionChip(
                      label: pos == 'All' ? 'All' : '$pos $count',
                      active: active,
                      onTap: () => _ctrl.selectPosition(pos),
                      c: c,
                    );
                  },
                ),
              ),

              const SizedBox(height: 14),

              // ── Count row ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(children: [
                  Text('${players.length} jugadores',
                      style: TextStyle(color: c.dim, fontSize: 12,
                          fontWeight: FontWeight.w500)),
                  const Spacer(),
                  Text(teamName,
                      style: TextStyle(color: c.accent, fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ]),
              ),

              const SizedBox(height: 12),

              // ── Player grid ────────────────────────────────────────────
              Expanded(
                child: _ctrl.isLoading
                    ? Center(child: CircularProgressIndicator(
                        color: c.accent, strokeWidth: 1.5))
                    : players.isEmpty
                        ? _EmptyState(c: c)
                        : GridView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.62,
                            ),
                            itemCount: players.length,
                            itemBuilder: (_, i) => _PlayerCard(
                              player: players[i],
                              stats:  _ctrl.statsFor(players[i]['id'] as int),
                              c: c,
                              onEdit: () => _openEditPlayerDialog(players[i]),
                            ),
                          ),
              ),
            ]),
          ),
        );
      },
    );
  }
}

// ── Small widgets ─────────────────────────────────────────────────────────────

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final AppColorTokens c;
  const _HeaderIcon({required this.icon, required this.c});
  @override
  Widget build(BuildContext context) => Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
            color: c.elevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: c.border2)),
        child: Icon(icon, color: c.dim, size: 18),
      );
}

class _TeamDropdown extends StatelessWidget {
  final SquadController ctrl;
  final AppColorTokens c;
  const _TeamDropdown({required this.ctrl, required this.c});
  @override
  Widget build(BuildContext context) => Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
            color: c.elevated,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: c.border2)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: ctrl.selectedTeamId,
            dropdownColor: c.surface,
            icon: Icon(Icons.keyboard_arrow_down_rounded,
                color: c.dim, size: 16),
            style: TextStyle(color: c.text, fontSize: 13),
            items: ctrl.teams
                .map((t) => DropdownMenuItem(
                    value: t['id'] as int,
                    child: Text(t['name'] as String? ?? '—')))
                .toList(),
            onChanged: ctrl.selectTeam,
          ),
        ),
      );
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final AppColorTokens c;
  const _SearchBar({required this.controller, required this.c});
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 46,
            decoration: BoxDecoration(
                color: c.surface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: c.border)),
            child: TextField(
              controller: controller,
              style: TextStyle(color: c.text, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Buscar jugadores...',
                hintStyle: TextStyle(color: c.muted, fontSize: 14),
                prefixIcon:
                    Icon(Icons.search_rounded, color: c.muted, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
      );
}

class _PositionChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final AppColorTokens c;
  const _PositionChip(
      {required this.label, required this.active,
       required this.onTap,  required this.c});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: active ? c.accent : c.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: active ? c.accent : c.border),
            boxShadow: active
                ? [BoxShadow(
                    color: c.accent.withValues(alpha: 0.3),
                    blurRadius: 8, offset: const Offset(0, 2))]
                : null,
          ),
          child: Text(label,
              style: TextStyle(
                color: active ? Colors.white : c.dim,
                fontSize: 12,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              )),
        ),
      );
}

// ── PES-style player card ─────────────────────────────────────────────────────

class _PlayerCard extends StatelessWidget {
  final Map<String, dynamic> player;
  final Map<String, dynamic> stats;
  final AppColorTokens c;
  final VoidCallback? onEdit;
  const _PlayerCard(
      {required this.player, required this.stats,
       required this.c, this.onEdit});

  static const _accents = {
    'GK':  Color(0xFFF59E0B),
    'DEF': Color(0xFF3B82F6),
    'MID': Color(0xFF22C55E),
    'FWD': Color(0xFFA855F7),
  };
  static const _darkGrad = {
    'GK':  [Color(0xFF3D1F00), Color(0xFF78350F)],
    'DEF': [Color(0xFF0A1929), Color(0xFF1E3A5F)],
    'MID': [Color(0xFF052E16), Color(0xFF14532D)],
    'FWD': [Color(0xFF1E0A3C), Color(0xFF4C1D95)],
  };

  Color _accent(String p) => _accents[p] ?? const Color(0xFF6B7280);
  List<Color> _grad(String p) =>
      _darkGrad[p] ?? [const Color(0xFF111827), const Color(0xFF1F2937)];

  int _age(String? b) {
    if (b == null || b.isEmpty) return 0;
    try {
      final d = DateTime.parse(b);
      final n = DateTime.now();
      int a = n.year - d.year;
      if (n.month < d.month || (n.month == d.month && n.day < d.day)) a--;
      return a;
    } catch (_) { return 0; }
  }

  double _ovr() {
    final r = stats['avg_rating'] as double?;
    if (r == null || r <= 0) return 0;
    return (r * 10).clamp(0, 100);
  }

  String _form(double ovr) {
    if (ovr >= 80) return 'Excelente';
    if (ovr >= 65) return 'Bueno';
    if (ovr > 0)   return 'Regular';
    return '';
  }

  Color _formColor(String f) => switch (f) {
    'Excelente' => const Color(0xFF22C55E),
    'Bueno'     => const Color(0xFFF59E0B),
    _           => const Color(0xFF9CA3AF),
  };

  List<(String, double, String)> _bars(String pos) {
    final m    = stats['matches']     as int?    ?? 0;
    if (m == 0) return [];
    final rec  = stats['avg_rec']     as double? ?? 0;
    final pas  = stats['avg_passes']  as double? ?? 0;
    final sho  = stats['avg_shots']   as double? ?? 0;
    final sot  = stats['avg_sot']     as double? ?? 0;
    final min  = stats['avg_minutes'] as double? ?? 0;
    final rat  = stats['avg_rating']  as double? ?? 0;
    return switch (pos) {
      'GK'  => [
          ('MIN', (min / 90).clamp(0, 1), '${min.round()}'),
          ('REC', (rec / 8 ).clamp(0, 1), '${rec.round()}'),
          ('RAT', rat / 10,               rat.toStringAsFixed(1)),
        ],
      'DEF' => [
          ('REC', (rec / 8 ).clamp(0, 1), '${rec.round()}'),
          ('PAS', (pas / 50).clamp(0, 1), '${pas.round()}'),
          ('RAT', rat / 10,               rat.toStringAsFixed(1)),
        ],
      'MID' => [
          ('PAS', (pas / 60).clamp(0, 1), '${pas.round()}'),
          ('TIR', (sho / 5 ).clamp(0, 1), '${sho.round()}'),
          ('RAT', rat / 10,               rat.toStringAsFixed(1)),
        ],
      _     => [
          ('TIR', (sho / 5 ).clamp(0, 1), '${sho.round()}'),
          ('SOT', (sot / 3 ).clamp(0, 1), '${sot.round()}'),
          ('RAT', rat / 10,               rat.toStringAsFixed(1)),
        ],
    };
  }

  @override
  Widget build(BuildContext context) {
    final pos      = (player['position'] as String? ?? 'MID').toUpperCase();
    final number   = player['shirt_number'] as int? ?? 0;
    final name     = player['name'] as String? ?? '—';
    final age      = _age(player['birth_date'] as String?);
    final teamName = (player['teams'] is Map
        ? player['teams']['name'] as String? : null) ?? 'PlayVision';
    final status   = (player['status'] as String? ?? 'active').toLowerCase();
    final photoUrl = player['photo_url'] as String?;
    final ovr      = _ovr();
    final form     = _form(ovr);
    final accent   = _accent(pos);
    final grad     = _grad(pos);
    final bars     = _bars(pos);

    // Initials for avatar fallback
    final parts    = name.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : name.substring(0, name.length.clamp(0, 2)).toUpperCase();

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: grad[0],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: grad[1].withValues(alpha: 0.5),
              blurRadius: 14, offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(children: [
          // ── Photo section ──────────────────────────────────────
          Expanded(
            flex: 5,
            child: Stack(fit: StackFit.expand, children: [
              // Gradient background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [grad[0], grad[1]],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              // Player photo or avatar
              if (photoUrl != null && photoUrl.isNotEmpty)
                Image.network(
                  photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _AvatarFallback(initials: initials, accent: accent),
                )
              else
                _AvatarFallback(initials: initials, accent: accent),
              // Bottom gradient fade for text readability
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.4, 1.0],
                      colors: [
                        Colors.transparent,
                        grad[0].withValues(alpha: 0.95),
                      ],
                    ),
                  ),
                ),
              ),
              // OVR badge — top left
              Positioned(
                top: 8, left: 10,
                child: Column(children: [
                  Text(
                    ovr > 0 ? '${ovr.round()}' : '—',
                    style: TextStyle(
                      color: accent,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  Text('OVR',
                      style: TextStyle(
                          color: accent.withValues(alpha: 0.7),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1)),
                ]),
              ),
              // Position badge — top right
              Positioned(
                top: 10, right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(6),
                    border:
                        Border.all(color: accent.withValues(alpha: 0.6)),
                  ),
                  child: Text(pos,
                      style: TextStyle(
                          color: accent,
                          fontSize: 10,
                          fontWeight: FontWeight.w800)),
                ),
              ),
              // Shirt number — bottom left
              Positioned(
                bottom: 8, left: 10,
                child: Text(
                  number > 0 ? '#$number' : '',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              // Edit button — bottom right
              if (onEdit != null)
                Positioned(
                  bottom: 6, right: 8,
                  child: GestureDetector(
                    onTap: onEdit,
                    child: Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25)),
                      ),
                      child: const Icon(Icons.edit_outlined,
                          color: Colors.white, size: 14),
                    ),
                  ),
                ),
            ]),
          ),

          // ── Info section ───────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            color: grad[0],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                // Team + age
                Text(
                  age > 0 ? '$teamName · $age a' : teamName,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Form or status badge
                if (form.isNotEmpty)
                  _MiniTag(label: form, color: _formColor(form))
                else
                  _MiniTag(
                    label: status == 'active' ? 'Activo' : 'Inactivo',
                    color: status == 'active'
                        ? const Color(0xFF22C55E)
                        : const Color(0xFF6B7280),
                  ),
                const SizedBox(height: 8),
                // Stat bars
                if (bars.isNotEmpty)
                  ...bars.map((b) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(children: [
                          SizedBox(
                            width: 26,
                            child: Text(b.$1,
                                style: TextStyle(
                                    color: Colors.white
                                        .withValues(alpha: 0.45),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5)),
                          ),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: b.$2,
                                minHeight: 5,
                                backgroundColor:
                                    accent.withValues(alpha: 0.12),
                                valueColor:
                                    AlwaysStoppedAnimation(accent),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 28,
                            child: Text(b.$3,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color: accent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800)),
                          ),
                        ]),
                      ))
                else
                  // No match data yet — show empty bars
                  ...['GEN', 'ESP', 'RAT'].map((lbl) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(children: [
                          SizedBox(
                            width: 26,
                            child: Text(lbl,
                                style: TextStyle(
                                    color: Colors.white
                                        .withValues(alpha: 0.2),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700)),
                          ),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(
                                value: 0,
                                minHeight: 5,
                                backgroundColor:
                                    accent.withValues(alpha: 0.10),
                                valueColor:
                                    AlwaysStoppedAnimation(accent),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 28,
                            child: Text('—',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    color: Colors.white
                                        .withValues(alpha: 0.2),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ]),
                      )),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Avatar fallback ────────────────────────────────────────────────────────────

class _AvatarFallback extends StatelessWidget {
  final String initials;
  final Color accent;
  const _AvatarFallback({required this.initials, required this.accent});
  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.15),
              border: Border.all(
                  color: accent.withValues(alpha: 0.4), width: 2),
            ),
            alignment: Alignment.center,
            child: Text(initials,
                style: TextStyle(
                    color: accent,
                    fontSize: 26,
                    fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 8),
          Icon(Icons.add_a_photo_outlined,
              color: accent.withValues(alpha: 0.35), size: 16),
        ]),
      );
}

// ── Mini tag ───────────────────────────────────────────────────────────────────

class _MiniTag extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniTag({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(label,
            style: TextStyle(
                color: color, fontSize: 9, fontWeight: FontWeight.w700)),
      );
}

// ── Photo placeholder ─────────────────────────────────────────────────────────

class _PhotoPlaceholder extends StatelessWidget {
  final AppColorTokens dc;
  const _PhotoPlaceholder({required this.dc});
  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo_outlined, color: dc.dim, size: 28),
          const SizedBox(height: 6),
          Text('Agregar foto',
              style: TextStyle(color: dc.dim, fontSize: 12)),
        ],
      );
}

// ── Dialog field ───────────────────────────────────────────────────────────────

class _DialogField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final AppColorTokens dc;
  const _DialogField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.dc,
    this.keyboardType = TextInputType.text,
  });
  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: dc.text, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(color: dc.dim, fontSize: 13),
          hintStyle: TextStyle(color: dc.muted, fontSize: 13),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: dc.border2),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: dc.accent),
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: dc.elevated,
        ),
      );
}

// ── Empty state ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final AppColorTokens c;
  const _EmptyState({required this.c});
  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.group_outlined, color: c.accentLo, size: 52),
          const SizedBox(height: 14),
          Text('Sin jugadores', style: TextStyle(color: c.dim, fontSize: 14)),
          const SizedBox(height: 6),
          Text('Toca + para agregar jugadores',
              style: TextStyle(color: c.muted, fontSize: 12)),
        ]),
      );
}
