import 'package:flutter/material.dart';                    // Importa o pacote principal do Flutter (widgets como Card, Row, Image, Text, etc.)
import 'package:lojavirtual/models/product.dart';         // Importa o modelo Product (classe com dados como name, description, images, etc.)

class ProductListTile extends StatelessWidget {           // Widget sem estado para exibir um produto em formato de tile (cartão na lista)
  const ProductListTile(this.product, {super.key});       // Construtor constante – recebe o objeto Product como parâmetro obrigatório

  final Product product;                                    // Referência ao produto que será exibido neste tile

  @override
  Widget build(BuildContext context) {                      // Método obrigatório que constrói a interface visual do widget
    final String? imageUrl = product.images.isNotEmpty      // Pega a primeira URL da lista de imagens (se existir), senão null
        ? product.images.first                              // Usa a primeira imagem disponível
        : null;                                             // Sem imagens → retorna null para mostrar placeholder

    return GestureDetector(
      onTap: (){
        Navigator.of(context).pushNamed('/product', arguments: product);
      },
      child: Card(                                            // Card cria o efeito visual de cartão com sombra e bordas
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Margens externas: 12 horizontal e 6 vertical (espaçamento entre tiles)
        shape: RoundedRectangleBorder(                        // Define o formato das bordas do Card
          borderRadius: BorderRadius.circular(4),             // Bordas arredondadas com raio 4 pixels
        ),
        child: Container(                                     // Container interno para controlar altura e padding
          height: 100,                                        // Altura fixa do tile (100 pixels) – mantém uniformidade na lista
          padding: const EdgeInsets.all(8),                   // Padding interno de 8 pixels em todos os lados
          child: Row(                                         // Row organiza os elementos lado a lado (imagem + textos)
            children: <Widget>[                               // Lista de widgets filhos da Row
      
              AspectRatio(                                    // Mantém proporção 1:1 (quadrado) para a área da imagem
                aspectRatio: 1,                               // Largura = altura
                child: ClipRRect(                             // Arredonda os cantos da imagem ou placeholder
                  borderRadius: BorderRadius.circular(4),     // Mesmo raio do Card para visual consistente
                  child: imageUrl == null                     // Verifica se há URL de imagem válida
                      ? Container(                            // Placeholder quando não tem imagem
                          color: Colors.grey[300],            // Fundo cinza claro
                          child: const Icon(Icons.image, color: Colors.grey), // Ícone cinza de "sem imagem"
                        )
                      : Image.network(                        // Carrega a imagem da internet
                          imageUrl,                            // URL da imagem
                          fit: BoxFit.cover,                  // Preenche o espaço cortando bordas se necessário
                        ),
                ),
              ),
      
              const SizedBox(width: 12),                      // Espaço horizontal fixo entre a imagem e os textos
      
              Expanded(                                       // Expanded ocupa todo o espaço restante da Row
                child: Column(                                // Column organiza os textos na vertical
                  crossAxisAlignment: CrossAxisAlignment.start, // Alinha todos os textos à esquerda
                  mainAxisAlignment: MainAxisAlignment.center,  // Centraliza verticalmente no espaço disponível
                  children: <Widget>[                           // Filhos da Column
      
                    Text(                                       // Nome do produto
                      product.name,                             // Texto do nome vindo do modelo Product
                      maxLines: 1,                              // Limita a 1 linha
                      overflow: TextOverflow.ellipsis,          // Coloca reticências (...) se o texto for longo
                      style: const TextStyle(                   // Estilo do texto do nome
                        fontSize: 16,
                        fontWeight: FontWeight.w800,            // Negrito mais forte (extra-bold)
                      ),
                    ),
      
                    const SizedBox(height: 4),                  // Espaço vertical de 4 pixels
      
                    Text(                                       // Texto fixo "A partir de"
                      'A partir de',
                      style: TextStyle(
                        fontSize: 12,                           // Tamanho pequeno
                        color: Colors.grey[600],                // Cor cinza médio
                      ),
                    ),
      
                    const SizedBox(height: 2),                  // Pequeno espaço vertical
      
                    Text(                                       // Preço fixo (por enquanto hardcoded)
                      'R\$19,99',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,            // Negrito
                        color: Color.fromARGB(255, 4, 80, 142), // Azul escuro personalizado
                      ),
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

  String _formatBRL(num value) {                            // Método auxiliar para formatar valores em Real (R$)
    // Retorna no formato "R$ 19.99" com ponto e 2 casas decimais
    return 'R\$ ${value.toStringAsFixed(2)}';
  }
}