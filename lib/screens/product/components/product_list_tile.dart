import 'package:flutter/material.dart';                    // Importa o pacote principal do Flutter (widgets como Card, Row, Image, etc.)
import 'package:lojavirtual/models/product.dart';         // Importa o modelo Product (classe que contém name, description, images, etc.)

class ProductListTile extends StatelessWidget {           // Widget sem estado para exibir um único produto em formato de tile/lista
  const ProductListTile(this.product, {super.key});       // Construtor constante – recebe o objeto Product como parâmetro obrigatório

  final Product product;                                    // Referência ao produto que será exibido neste tile

  @override
  Widget build(BuildContext context) {                      // Método obrigatório que constrói a interface visual
    final String? imageUrl = product.images.isNotEmpty      // Pega a primeira URL de imagem (se existir), senão null
        ? product.images.first                              // Usa a primeira imagem da lista
        : null;                                             // Sem imagens → null

    return Card(                                            // Card dá aparência de "cartão" com sombra e bordas suaves
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(                        // Define o formato das bordas do Card
        borderRadius: BorderRadius.circular(4),             // Bordas arredondadas com raio 4 (leve arredondamento)
      ),
      child: Container(                                     // Container interno para controlar padding e altura fixa
        height: 100,                                        // Altura fixa do tile (100 pixels) – bom para listas uniformes
        padding: const EdgeInsets.all(8),                   // Espaçamento interno de 8 pixels em todos os lados
        child: Row(                                         // Row organiza os elementos na horizontal (imagem + textos)
          children: <Widget>[                               // Lista de filhos da Row

            AspectRatio(                                    // Mantém proporção quadrada para a imagem (1:1)
              aspectRatio: 1,                               // Quadrado (largura = altura)
              child: ClipRRect(                             // Arredonda os cantos da imagem
                borderRadius: BorderRadius.circular(4),     // Mesmo raio do Card para consistência visual
                child: imageUrl == null                     // Verifica se tem imagem
                    ? Container(                            // Placeholder quando não tem imagem
                        color: Colors.grey[300],            // Fundo cinza claro
                        child: const Icon(Icons.image, color: Colors.grey), // Ícone de imagem cinza
                      )
                    : Image.network(                        // Carrega imagem da internet
                        imageUrl,                           // URL da imagem
                        fit: BoxFit.cover,                  // Preenche o espaço cortando se necessário (sem distorcer)
                      ),
              ),
            ),

            const SizedBox(width: 12),                      // Espaço horizontal fixo de 12 pixels entre imagem e texto

            Expanded(                                       // Expanded ocupa todo o espaço restante da Row
              child: Column(                                // Column organiza os textos na vertical
                crossAxisAlignment: CrossAxisAlignment.start, // Alinha textos à esquerda
                mainAxisAlignment: MainAxisAlignment.center,  // Centraliza verticalmente no espaço disponível
                children: <Widget>[                           // Filhos da Column

                  Text(                                       // Nome do produto
                    product.name,                             // Texto vindo do modelo Product
                    maxLines: 1,                              // Limita a 1 linha
                    overflow: TextOverflow.ellipsis,          // Coloca "..." se o texto for longo demais
                    style: const TextStyle(                   // Estilo do nome
                      fontSize: 16,
                      fontWeight: FontWeight.w800,            // Semi-negrito
                    ),
                  ),

                  const SizedBox(height: 4),
                  Text(
                    'A partir de',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 2),
                  Text(
                    'R\$19,99',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color.fromARGB(255, 4, 80, 142),
                    ),
                  ),

                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  String _formatBRL(num value) {
    // Igual ao print: "R$ 19.99" (ponto e 2 casas)
    return 'R\$ ${value.toStringAsFixed(2)}';
  }
}