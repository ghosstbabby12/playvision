import 'package:flutter/material.dart';

import '../../../../../core/theme/app_color_tokens.dart';

class MiniStatCard extends StatelessWidget {
  final String value;
  final String label;
  const MiniStatCard(this.value, this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Expanded(
      child: Column(children: [
        Text(value,
            style: TextStyle(
              color: c.text,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            )),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(color: c.dim, fontSize: 10)),
      ]),
    );
  }
}
