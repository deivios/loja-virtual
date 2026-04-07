import 'package:flutter/material.dart';
import 'package:lojavirtual/models/section.dart';
import 'package:lojavirtual/screens/home/components/item_tile.dart';
import 'package:lojavirtual/screens/home/components/section_header.dart';

class SectionList extends StatelessWidget {
  const SectionList(this.section, {super.key});

  final Section section;

  @override
  Widget build(BuildContext context) {
    if (section.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(section),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (_, index) => ItemTile(section.items[index]),
              separatorBuilder: (_, __) => const SizedBox(width: 4),
              itemCount: section.items.length,
            ),
          ),
        ],
      ),
    );
  }
}
