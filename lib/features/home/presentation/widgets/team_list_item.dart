import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

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
  Widget build(BuildContext context) => Dismissible(
    key: ValueKey(team['id']),
    direction: DismissDirection.endToStart,
    background: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: AppColors.dangerBg,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerRight,
      child: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
    ),
    confirmDismiss: (_) async {
      onDelete();
      return false;
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        Container(
          width: 38, height: 38,
          decoration: const BoxDecoration(
            color: AppColors.accentLo,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.groups_outlined, color: AppColors.accent, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(team['name'] ?? '—',
              style: const TextStyle(color: AppColors.text, fontSize: 14, fontWeight: FontWeight.w600)),
          Text('${team['club'] ?? '—'} · ${team['category'] ?? '—'}',
              style: const TextStyle(color: AppColors.dim, fontSize: 11)),
        ])),
        GestureDetector(
          onTap: onEdit,
          child: const Padding(
            padding: EdgeInsets.all(6),
            child: Icon(Icons.edit_outlined, color: AppColors.dim, size: 16),
          ),
        ),
      ]),
    ),
  );
}
