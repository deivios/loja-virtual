import 'package:flutter/material.dart';
import 'package:lojavirtual/common/custom_drawer/custom_drawer.dart';
import 'package:lojavirtual/models/home_manager.dart';
import 'package:lojavirtual/models/section.dart';
import 'package:lojavirtual/screens/home/components/section_list.dart';
import 'package:lojavirtual/screens/home/components/section_staggered.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeManager = context.watch<HomeManager>();

    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(title: const Text('Início'), centerTitle: true),
      body: Builder(
        builder: (_) {
          if (homeManager.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (homeManager.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(homeManager.error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: homeManager.retry,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (homeManager.sections.isEmpty) {
            return const Center(child: Text('Nenhuma seção cadastrada.'));
          }

          return ListView.builder(
            itemCount: homeManager.sections.length,
            itemBuilder: (_, index) {
              final section = homeManager.sections[index];
              return _SectionWidget(section);
            },
          );
        },
      ),
    );
  }
}

class _SectionWidget extends StatelessWidget {
  const _SectionWidget(this.section);

  final Section section;

  @override
  Widget build(BuildContext context) {
    switch (section.type.toLowerCase()) {
      case 'staggered':
        return SectionStaggered(section);
      case 'list':
      default:
        return SectionList(section);
    }
  }
}
