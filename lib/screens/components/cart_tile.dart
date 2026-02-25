import 'package:flutter/material.dart'; // Pacote principal do Flutter (Card, Row, Image, Text, etc.)
import 'package:lojavirtual/models/cart_product.dart'; // Modelo CartProduct (produto no carrinho com quantidade e tamanho)

class CartTile extends StatelessWidget {
  // Widget que exibe um item do carrinho (produto + quantidade + tamanho)
  const CartTile(
    this.cartProduct, {
    super.key,
  }); // Construtor: recebe o CartProduct como parâmetro obrigatório

  final CartProduct
  cartProduct; // Referência ao item do carrinho que será exibido

  @override // Sobrescreve o método obrigatório que constrói a UI
  Widget build(BuildContext context) {
    // Método chamado pelo Flutter para renderizar o tile
    return Card(
      // Card cria o efeito visual de cartão com sombra
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ), // Margens: 16 horizontal, 4 vertical
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ), // Padding interno do card
        child: Row(
          // Row organiza imagem e textos lado a lado
          children: <Widget>[
            // Lista de widgets filhos da Row
            SizedBox(
              // SizedBox define área fixa para a imagem
              height: 80, // Altura fixa de 80 pixels
              width: 80, // Largura fixa de 80 pixels
              child:
                  cartProduct
                      .product
                      .images
                      .isNotEmpty // Verifica se há imagens disponíveis
                  ? Image.network(
                      cartProduct
                          .product
                          .images
                          .first, // Carrega imagem da internet
                      fit: BoxFit.cover, // Preenche o espaço mantendo proporção
                    )
                  : Container(
                      color:
                          Colors.grey[300], // Placeholder quando não tem imagem
                      child: const Icon(
                        Icons.image,
                        color: Colors.grey,
                      ), // Ícone de "sem imagem"
                    ),
            ),
            Expanded(
              // Expanded ocupa todo o espaço restante da Row
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                ), // Padding à esquerda para separar da imagem
                child: Column(
                  // Column organiza os textos na vertical
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Alinha textos à esquerda
                  mainAxisSize:
                      MainAxisSize.min, // Ocupa apenas o espaço necessário
                  children: <Widget>[
                    Text(
                      cartProduct.product.name, // Nome do produto
                      style: const TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.w500,
                      ), // Estilo do nome
                      maxLines: 1, // Máximo 1 linha
                      overflow:
                          TextOverflow.ellipsis, // Reticências se for longo
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                      ), // Espaço entre nome e tamanho
                      child: Text(
                        'Tamanho: ${cartProduct.size}', // Texto do tamanho (ex: "Tamanho: M")
                        style: const TextStyle(
                          fontWeight: FontWeight.w300,
                        ), // Estilo leve
                      ),
                    ),
                    Text(
                      _formatPrice(
                        cartProduct,
                      ), // Preço do item formatado em R$
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ), // Estilo do preço
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(CartProduct cp) {
    // Método auxiliar para formatar preço em Real
    if (cp.product.sizes.isEmpty) {
      // Se não tem tamanhos, usa preço base
      final total =
          cp.product.effectivePrice * cp.quantity; // Preço efetivo × quantidade
      return 'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}'; // Formato "R$ 19,99"
    }
    final itemSize = cp.itemSize; // Obtém o ItemSize via getter (pode ser null)
    if (itemSize == null) {
      // Se não encontrou o tamanho, usa preço efetivo
      final total = cp.product.effectivePrice * cp.quantity;
      return 'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}';
    }
    final total = itemSize.price * cp.quantity; // Preço unitário × quantidade
    return 'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}'; // Formato "R$ 19,99"
  }
}
