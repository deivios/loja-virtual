// ========== CART_SCREEN.DART - Tela do carrinho ==========
// Mostra a lista de itens do carrinho usando Consumer<CartManager>

import 'package:flutter/material.dart'; // Importa widgets básicos: Scaffold, AppBar, Column, Text, etc
import 'package:lojavirtual/models/cart_manager.dart'; // Importa o gerenciador do carrinho (CartManager)
import 'package:lojavirtual/screens/components/cart_tile.dart'; // Importa o widget que representa cada item do carrinho
import 'package:lojavirtual/screens/components/price_card.dart'; // Importa card de preço total
import 'package:provider/provider.dart'; // Importa Consumer para escutar mudanças no CartManager

class CartScreen extends StatelessWidget {
  // Tela do carrinho (sem estado próprio – Stateless)
  const CartScreen({
    // Construtor da tela
    super.key, // Permite identificação na árvore de widgets (herdado)
  });

  @override
  Widget build(BuildContext context) {
    // Método obrigatório que constrói a interface
    return Scaffold(
      // Estrutura principal da tela (com AppBar + body)
      backgroundColor:
          Colors.blueAccent, // Define cor de fundo da tela inteira (azul claro)
      appBar: AppBar(
        // Barra superior da tela
        backgroundColor:
            Colors.blueAccent, // Mesma cor da tela para ficar uniforme
        foregroundColor: Colors.white, // Cor dos ícones (voltar) e do título
        title: const Text('Carrinho'), // Título exibido na AppBar
        centerTitle: true, // Centraliza o título na AppBar
      ),
      body: Consumer<CartManager>(
        builder: (_, cartManager, __) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!cartManager.isCartValid && cartManager.items.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.orange[100],
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange[800]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Alguns itens não têm estoque suficiente.',
                          style: TextStyle(color: Colors.orange[900]),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView(
                  children: <Widget>[
                    Column(
                      children: cartManager.items
                          .map((cartProduct) => CartTile(cartProduct))
                          .toList(),
                    ),
                    PriceCard(
                      buttonText: 'Continuar para Entrega',
                      onPressed: cartManager.isCartValid ? () {} : null,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
