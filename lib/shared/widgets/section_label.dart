import 'package:flutter/material.dart';

import '../../core/theme/app_color_tokens.dart';

class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      color: context.colors.dim,
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 2,
    ),
  );
}
