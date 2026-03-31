import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';

class MiniStatCard extends StatelessWidget {
  final String value;
  final String label;
  const MiniStatCard(this.value, this.label, {super.key});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(children: [
      Text(value,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          )),
      const SizedBox(height: 3),
      Text(label,
          style: const TextStyle(color: AppColors.dim, fontSize: 10)),
    ]),
  );
}
