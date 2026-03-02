// ========== CART_TILE.DART - Widget de um item do carrinho ==========
// Card: imagem, nome, tamanho, preço total. Usado na CartScreen.

import 'package:flutter/material.dart'; // Card, Padding, Row, SizedBox, Image, Text
import 'package:lojavirtual/common/custom_icon_button.dart'; // CustomIconButton
import 'package:lojavirtual/models/cart_product.dart'; // CartProduct
import 'package:provider/provider.dart'; // Consumer, Provider

class CartTile extends StatelessWidget {
  // Widget sem estado
  const CartTile(this.cartProduct, {super.key}); // Recebe CartProduct
  final CartProduct cartProduct; // Item do carrinho

  @override // Sobrescreve build do StatelessWidget
  Widget build(BuildContext context) {
    // Constrói o widget
    return Card(
      // Card com sombra
      margin: const EdgeInsets.symmetric(
        // Margem externa
        horizontal: 16, // 16px nas laterais
        vertical: 4, // 4px em cima e embaixo
      ),
      child: Padding(
        // Espaço interno
        padding: const EdgeInsets.symmetric(
          horizontal: 16, // 16px nas laterais
          vertical: 8, // 8px em cima e embaixo
        ),
        child: Row(
          // Layout horizontal: imagem à esquerda, textos à direita
          children: [
            // Lista de widgets da linha
            SizedBox(
              // Área fixa para a imagem
              height: 80, // Altura fixa
              width: 80, // Largura fixa
              child:
                  cartProduct
                      .product
                      .images
                      .isNotEmpty // Se tem imagens
                  ? Image.network(
                      // Carrega imagem da URL
                      cartProduct.product.images.first, // Primeira imagem
                      fit: BoxFit.cover, // Preenche mantendo proporção
                    )
                  : Container(
                      // Placeholder quando não tem imagem
                      color: Colors.grey[300], // Cinza claro
                      child: const Icon(
                        // Ícone de imagem
                        Icons.image, // Ícone padrão
                        color: Colors.grey, // Cor cinza
                      ),
                    ),
            ),
            Expanded(
              // Ocupa espaço restante
              child: Padding(
                // Espaço entre imagem e textos
                padding: const EdgeInsets.only(left: 16), // 16px à esquerda
                child: Column(
                  // Coluna de textos
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Alinha à esquerda
                  mainAxisSize: MainAxisSize.min, // Só o tamanho necessário
                  children: [
                    Text(
                      // Nome do produto
                      cartProduct.product.name,
                      style: const TextStyle(
                        // Estilo do texto
                        fontSize: 17, // Tamanho da fonte
                        fontWeight: FontWeight.w500, // Peso médio
                      ),
                      maxLines: 1, // Uma linha só
                      overflow:
                          TextOverflow.ellipsis, // Corta com "..." se longo
                    ),
                    Padding(
                      // Padding vertical
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                      ), // 8px em cima e embaixo
                      child: Text(
                        // Texto do tamanho
                        'Tamanho: ${cartProduct.size}', // P, M, GG
                        style: const TextStyle(
                          // Peso leve
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                    Provider<CartProduct>.value(
                      value: cartProduct,
                      child: Consumer<CartProduct>(
                        builder: (_, cp, __) {
                          if (cp.hasStock) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'R\$ ${cp.totalPrice.toStringAsFixed(2).replaceAll('.', ',')}',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          } else {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'Sem estoque suficiente',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              // Coluna: botão +, quantidade, botão -
              children: <Widget>[
                // Botões e quantidade
                CustomIconButton(
                  // Botão para adicionar quantidade
                  iconData: Icons.add, // Ícone de mais
                  color: Theme.of(context).primaryColor, // Cor primária do tema
                  onTap: cartProduct.increment, // Chama increment ao tocar
                ),
                Text(
                  // Exibe a quantidade
                  '${cartProduct.quantity}',
                  style: const TextStyle(fontSize: 20), // Fonte maior
                ),
                CustomIconButton(
                  // Botão para remover quantidade
                  iconData: Icons.remove, // Ícone de menos
                  color: cartProduct.quantity > 1
                      ? Theme.of(context)
                            .primaryColor // Cor normal se tem mais de 1
                      : Colors
                            .red, // Vermelho quando última unidade (remove do carrinho)
                  onTap: cartProduct.decrement, // Chama decrement ao tocar
                ),
              ],
            ),
            CustomIconButton(
              // Botão para remover item do carrinho
              iconData: Icons.delete_outline, // Ícone de lixeira
              color: Colors.red, // Cor vermelha
              onTap: cartProduct.remove, // Remove item por completo
            ),
          ],
        ),
      ),
    );
  }
}
