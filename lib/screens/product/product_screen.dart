import 'package:carousel_slider/carousel_slider.dart'; // Importa o pacote do carousel_slider para o carrossel de imagens
import 'package:flutter/material.dart'; // Importa os widgets e materiais básicos do Flutter
import 'package:lojavirtual/models/product.dart'; // Importa o modelo Product (dados do produto)
import 'package:smooth_page_indicator/smooth_page_indicator.dart'; // Importa o pacote para os indicadores animados (pontinhos)

class ProductScreen extends StatefulWidget { // Declara a tela como StatefulWidget (precisa de estado mutável)
  const ProductScreen(this.product, {super.key}); // Construtor que recebe o produto obrigatório

  final Product product; // Armazena o produto passado para a tela

  @override
  State<ProductScreen> createState() => _ProductScreenState(); // Cria o estado da tela
}

class _ProductScreenState extends State<ProductScreen> { // Classe privada do estado
  int _current = 0; // Índice da imagem atualmente exibida no carousel

  static const double _dotSize = 6; // Tamanho fixo dos pontinhos indicadores

  @override
  Widget build(BuildContext context) { // Método que constrói a UI
    final product = widget.product; // Referência rápida ao produto
    final images = widget.product.images; // Lista de URLs das imagens
    final primaryColor = Theme.of(context).primaryColor; // Cor primária do tema do app
    final priceText = product.basePrice.toDouble().toStringAsFixed(2); // Preço formatado (não usado no código atual)

    return Scaffold( // Estrutura básica da tela
      appBar: AppBar( // Barra superior
        title: Text(product.name), // Título = nome do produto
        centerTitle: true, // Centraliza o título
      ),
      body: ListView( // Corpo com rolagem vertical
        children: <Widget>[ // Lista de widgets filhos
          CarouselSlider( // Componente do carrossel
            items: images // Lista de imagens
                .map( // Mapeia cada URL para um widget Image.network
                  (url) => Image.network(
                    url, // URL da imagem
                    fit: BoxFit.cover, // Preenche todo o espaço mantendo proporção
                    width: double.infinity, // Largura total da tela
                  ),
                )
                .toList(), // Converte para lista de widgets
            options: CarouselOptions( // Opções de configuração do carousel
              aspectRatio: 1, // Proporção 1:1 (quadrado)
              viewportFraction: 1, // Cada item ocupa 100% da vista
              enableInfiniteScroll: images.length > 1, // Scroll infinito só com múltiplas imagens
              onPageChanged: (index, reason) { // Callback quando muda de página
                setState(() => _current = index); // Atualiza o índice atual
              },
            ),
          ),
          if (images.length > 1) ...[ // Condicional: mostra indicadores só se >1 imagem
            const SizedBox(height: 8), // Espaço vertical
            Center( // Centraliza os pontinhos
              child: AnimatedSmoothIndicator( // Widget dos indicadores animados
                activeIndex: _current, // Índice ativo atual
                count: images.length, // Total de imagens/pontinhos
                effect: WormEffect( // Efeito visual "Worm" (bolinha que cresce)
                  dotWidth: _dotSize, // Largura do pontinho
                  dotHeight: _dotSize, // Altura do pontinho
                  spacing: 4, // Espaçamento entre pontinhos
                  dotColor: const Color.fromARGB(0, 0, 3, 6), // Cor inativa (transparente aqui)
                  activeDotColor: Theme.of(context).primaryColor, // Cor do pontinho ativo
                ),
              ),
            ),
            const SizedBox(height: 8), // Espaço vertical após indicadores
          ],
          Padding( // Seção de informações do produto com padding
            padding: const EdgeInsets.all(16), // Padding de 16 em todos os lados
            child: Column( // Coluna com alinhamento à esquerda
              crossAxisAlignment: CrossAxisAlignment.start, // Alinha conteúdo à esquerda
              children: <Widget>[ // Lista de widgets da coluna
                Text( // Nome do produto
                  product.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Padding( // Texto "A partir de"
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'A partir de',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Text( // Preço (hard-coded como R\$ 19.99)
                  'R\$ 19.99',
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const Padding( // Título "Descrição"
                  padding: EdgeInsets.only(top: 16, bottom: 8),
                  child: Text(
                    'Descrição',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text( // Texto da descrição do produto
                  product.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.2, // Espaçamento entre linhas
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}