import 'package:flutter/material.dart';
import 'package:lojavirtual/models/section.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.section, {super.key});

  final Section section;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Text(
        section.name,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
