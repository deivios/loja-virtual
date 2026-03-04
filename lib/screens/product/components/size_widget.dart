// ========== SIZE_WIDGET.DART - Botão de tamanho (P, M, GG) ==========
// Nome + preço. Toque seleciona (se hasStock). Destacado se selecionado. Sem estoque = vermelho.

import 'package:flutter/material.dart'; // GestureDetector, Container, Row, Text, BoxDecoration
import 'package:lojavirtual/models/item_size.dart'; // ItemSize
import 'package:lojavirtual/models/product.dart'; // Product
import 'package:provider/provider.dart'; // context.watch

class SizeWidget extends StatelessWidget {
  // Widget sem estado
  const SizeWidget({super.key, required this.size}); // Recebe ItemSize
  final ItemSize size; // Tamanho (P, M, GG) com preço e estoque

  @override
  Widget build(BuildContext context) {
    final product = context
        .watch<Product>(); // Escuta mudanças no Product (selectedSize)
    final selected =
        size == product.selectedSize; // Este tamanho está selecionado?

    return GestureDetector(
      // Área clicável
      onTap: () {
        if (size.hasStock) {
          product.selectedSize = size; // Só seleciona se tiver estoque
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: !size.hasStock
                ? Colors.red.withAlpha(50)
                : selected
                ? Theme.of(context).primaryColor
                : Colors
                      .grey, // Sem estoque: vermelho suave. Selecionado: azul. Não: cinza
            width: selected ? 2 : 1, // Borda mais grossa (2px) se selecionado
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Só o tamanho necessário
          children: [
            Container(
              // Parte do nome (P, M, GG)
              color: !size.hasStock
                  ? Colors.red.withAlpha(50)
                  : Colors.grey, // Vermelho suave ou cinza
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Text(
                size.name,
                style: const TextStyle(color: Colors.white),
              ), // Nome em branco
            ),
            Container(
              // Parte do preço
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'R\$ ${size.price.toDouble().toStringAsFixed(2)}', // Preço formatado
                style: TextStyle(
                  color: !size.hasStock
                      ? Colors.red.withAlpha(50)
                      : Colors.grey,
                ), // Vermelho ou cinza
              ),
            ),
            Container(
              // Parte do estoque
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '${size.stock} disp.', // Quantidade disponível (ex: "10 disp.")
                style: TextStyle(
                  fontSize: 12,
                  color: !size.hasStock ? Colors.red : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
