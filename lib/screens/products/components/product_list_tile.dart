// ========== PRODUCT_LIST_TILE.DART - Widget de um produto na lista ==========
// Card clicável: imagem, nome, "A partir de", preço. Toque -> /product com arguments.

import 'package:flutter/material.dart'; // GestureDetector, Card, Row, Column, Text, Image
import 'package:lojavirtual/models/product.dart'; // Product

class ProductListTile extends StatelessWidget { // Widget sem estado
  const ProductListTile(this.product, {super.key}); // Recebe Product
  final Product product; // Produto a exibir

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.images.isNotEmpty ? product.images.first : null; // Primeira imagem ou null
    return GestureDetector( // Área clicável
      onTap: () => Navigator.of(context).pushNamed('/product', arguments: product), // Navega para detalhes
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Margem do card
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), // Bordas arredondadas
        child: Container(
          height: 100, // Altura fixa
          padding: const EdgeInsets.all(8), // Espaço interno
          child: Row( // Layout horizontal: imagem + textos
            children: [
              AspectRatio( // Mantém proporção quadrada
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4), // Corta cantos da imagem
                  child: imageUrl == null
                      ? Container(color: Colors.grey[300], child: const Icon(Icons.image, color: Colors.grey)) // Placeholder sem imagem
                      : Image.network(imageUrl, fit: BoxFit.cover), // Carrega da URL
                ),
              ),
              const SizedBox(width: 12), // Espaço entre imagem e textos
              Expanded( // Ocupa espaço restante
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Alinha à esquerda
                  mainAxisAlignment: MainAxisAlignment.center, // Centraliza verticalmente
                  children: [
                    Text(
                      product.name, // Nome do produto
                      maxLines: 1, // Uma linha
                      overflow: TextOverflow.ellipsis, // Corta com "..." se longo
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text('A partir de', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    const SizedBox(height: 2),
                    Text(
                      _formatBRL(product.effectivePrice), // Preço formatado
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color.fromARGB(255, 4, 80, 142)), // Azul escuro
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatBRL(num value) => 'R\$ ${value.toDouble().toStringAsFixed(2).replaceAll('.', ',')}'; // Formato BR (vírgula decimal)
}
