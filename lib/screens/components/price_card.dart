import 'package:flutter/material.dart'; // Importa widgets Flutter: Card, Padding, Text, Row, etc
import 'package:lojavirtual/models/cart_manager.dart'; // Importa CartManager (para acessar itens e preços)
import 'package:provider/provider.dart'; // Importa Consumer para escutar mudanças no CartManager

class PriceCard extends StatelessWidget {
  // Widget sem estado que mostra resumo de preços
  const PriceCard({super.key, this.buttonText, this.onPressed});

  final String? buttonText; // Texto do botão (opcional)
  final VoidCallback? onPressed; // Ação ao pressionar (opcional)

  @override
  Widget build(BuildContext context) {
    // Método que constrói o widget
    return Consumer<CartManager>(
      // Escuta mudanças no CartManager via Provider
      builder: (_, cartManager, __) {
        // builder recebe contexto, CartManager e child (não usado)
        if (cartManager.items.isEmpty) {
          // Se o carrinho estiver vazio
          return const SizedBox.shrink(); // Retorna widget invisível (não ocupa espaço)
        }

        return Card(
          // Card com bordas e sombra (resumo visual)
          margin: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ), // Margens laterais e verticais
          child: Padding(
            // Espaçamento interno do card
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              16,
            ), // Padding uniforme em todos os lados
            child: Column(
              // Organiza conteúdo verticalmente
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Alinha todo conteúdo à esquerda
              children: [
                const Text(
                  // Título do resumo
                  'Resumo do Pedido',
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12), // Espaço vertical após o título
                Row(
                  // Linha: Subtotal
                  mainAxisAlignment: MainAxisAlignment
                      .spaceBetween, // Espaça os textos nas extremidades
                  children: <Widget>[
                    const Text('Subtotal'), // Texto fixo à esquerda
                    Text(
                      // Valor do subtotal formatado
                      'R\$ ${cartManager.productsPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                    ),
                  ],
                ),
                const Divider(), // Linha divisória horizontal
                const SizedBox(height: 12), // Espaço após a linha
                Row(
                  // Linha: Total (destacado)
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      // Texto "Total" em negrito
                      'Total',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      // Valor total em destaque (cor primária)
                      'R\$ ${cartManager.productsPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8), // Pequeno espaço antes do botão
                SizedBox(
                  // Container com largura total para botão
                  width: double.infinity,
                  child: ElevatedButton(
                    // Botão de ação principal
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(
                        context,
                      ).primaryColor, // Cor de fundo = cor primária do app
                      foregroundColor:
                          Colors.white, // Cor do texto e ícone = branco
                    ),
                    onPressed: onPressed,
                    child: Text(buttonText ?? 'Continuar para Entre'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
