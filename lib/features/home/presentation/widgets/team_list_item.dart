import 'package:flutter/material.dart';

import '../../../../../core/theme/app_color_tokens.dart';

class TeamListItem extends StatelessWidget {
  final Map<String, dynamic> team;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const TeamListItem({
    super.key,
    required this.team,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Dismissible(
      key: ValueKey(team['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: c.dangerBg,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        child: Icon(Icons.delete_outline, color: c.danger, size: 20),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.border),
        ),
        child: Row(children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: c.accentLo,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.groups_outlined, color: c.accent, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(team['name'] ?? '—',
                style: TextStyle(color: c.text, fontSize: 14, fontWeight: FontWeight.w600)),
            Text('${team['club'] ?? '—'} · ${team['category'] ?? '—'}',
                style: TextStyle(color: c.dim, fontSize: 11)),
          ])),
          GestureDetector(
            onTap: onEdit,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(Icons.edit_outlined, color: c.dim, size: 16),
            ),
          ),
        ]),
      ),
    );
  }
}
