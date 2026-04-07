import 'package:flutter/material.dart'; // Widgets base do Flutter (Container, Column, etc.)
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart'; // Grid em mosaico (staggered)
import 'package:lojavirtual/models/section.dart'; // Modelo Section (nome, tipo, itens)
import 'package:lojavirtual/screens/home/components/item_tile.dart'; // Card/Tile de cada item da seção
import 'package:lojavirtual/screens/home/components/section_header.dart'; // Cabeçalho da seção

class SectionStaggered extends StatelessWidget { // Widget sem estado para seção em grade
  const SectionStaggered(this.section, {super.key}); // Recebe a seção a renderizar

  final Section section; // Dados da seção (título e itens)

  @override
  Widget build(BuildContext context) { // Constrói a UI da seção
    if (section.items.isEmpty) { // Se não há itens para mostrar
      return const SizedBox.shrink(); // Retorna vazio (não ocupa espaço)
    }

    return Container( // Bloco visual da seção
      margin: const EdgeInsets.symmetric(vertical: 8), // Espaço acima e abaixo da seção
      child: Column( // Organiza cabeçalho + grade na vertical
        crossAxisAlignment: CrossAxisAlignment.start, // Alinha conteúdo à esquerda
        children: <Widget>[ // Lista de widgets filhos
          SectionHeader(section),
          StaggeredGrid.count(
            crossAxisCount: 4,
            itemCount:context.Section.items.length,
            itembuilder: (_, index) {
              return Image(image: NetworkImage
              (section.items[index].image,
              fit: BoxFit.cover,
              );
            },
            staggeredTileBuilder: (index) => StaggeredTile.count(
              index.isEven ? 2 : 1, // Itens pares ocupam 2 colunas, ímpares 1
              
            ),  
              
              
              
             
            