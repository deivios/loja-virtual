import 'package:carousel_slider/carousel_slider.dart';          // Pacote para criar carrossel de imagens
import 'package:flutter/material.dart';                         // Pacote principal do Flutter (widgets, temas, etc.)
import 'package:lojavirtual/models/product.dart';               // Importa o modelo Product que criamos antes
import 'package:lojavirtual/screens/product/components/size_widget.dart'; // Widget customizado para exibir cada tamanho
import 'package:smooth_page_indicator/smooth_page_indicator.dart'; // Pacote para indicadores animados (pontinhos bonitos)

// Tela de detalhes do produto – usa StatefulWidget porque precisa mudar estado (índice do carrossel)
class ProductScreen extends StatefulWidget {
  const ProductScreen(this.product, {super.key});               // Construtor: recebe o produto como parâmetro obrigatório

  final Product product;                                        // Armazena a referência ao produto passado

  @override
  State<ProductScreen> createState() => _ProductScreenState();  // Cria o estado privado da tela
}

// Estado privado da tela (aqui fica a lógica mutável)
class _ProductScreenState extends State<ProductScreen> {
  int _current = 0;                                             // Guarda o índice da imagem atual no carrossel (começa em 0)

  static const double _dotSize = 8;                             // Tamanho fixo dos pontinhos indicadores (8 pixels)

  @override
  Widget build(BuildContext context) {                          // Método principal que constrói toda a interface
    final product = widget.product;                             // Atalho para acessar o produto (evita widget. toda hora)
    final images = widget.product.images;                       // Atalho para a lista de URLs de imagens
    final primaryColor = Theme.of(context).primaryColor;        // Pega a cor primária definida no tema do app
    final priceText = product.basePrice.toDouble().toStringAsFixed(2); // Formata preço com 2 casas decimais (ex: 99.90)

    return Scaffold(                                            // Estrutura principal da tela (tem AppBar + body)
      appBar: AppBar(                                           // Barra superior da tela
        title: Text(product.name),                              // Mostra o nome do produto como título
        centerTitle: true,                                      // Centraliza o título na AppBar
      ),
      body: ListView(                                           // Corpo da tela com rolagem vertical (bom para conteúdos longos)
        children: <Widget>[                                     // Lista de widgets que vão aparecer um abaixo do outro
          CarouselSlider(                                       // Carrossel de imagens do produto
            items: images                                         // Pega a lista de URLs
                .map(                                             // Transforma cada URL em um widget de imagem
                  (url) => Image.network(                         // Carrega imagem da internet
                    url,                                          // URL da imagem vinda do Firestore
                    fit: BoxFit.cover,                            // Faz a imagem preencher o espaço mantendo proporção
                    width: double.infinity,                       // Ocupa toda a largura disponível
                  ),
                )
                .toList(),                                        // Converte o Iterable em List<Widget>
            options: CarouselOptions(                             // Configurações do comportamento do carrossel
              aspectRatio: 1,                                     // Proporção quadrada (1:1) – ideal para produtos
              viewportFraction: 1,                                // Cada slide ocupa 100% da tela (sem ver o próximo)
              enableInfiniteScroll: images.length > 1,            // Scroll infinito só se tiver mais de 1 imagem
              onPageChanged: (index, reason) {                    // Quando o usuário desliza ou muda de página
                setState(() => _current = index);                 // Atualiza o estado para mudar o pontinho ativo
              },
            ),
          ),
          if (images.length > 1) ...[                           // Só mostra indicadores se tiver mais de uma foto
            const SizedBox(height: 8),                          // Espacinho vertical antes dos pontinhos
            Center(                                             // Centraliza os indicadores na tela
              child: AnimatedSmoothIndicator(                   // Widget animado de pontinhos (smooth_page_indicator)
                activeIndex: _current,                          // Qual pontinho está ativo agora
                count: images.length,                           // Quantos pontinhos vão aparecer
                effect: WormEffect(                             // Efeito "minhoca" (o pontinho ativo cresce e se move)
                  dotWidth: _dotSize,                           // Largura de cada pontinho
                  dotHeight: _dotSize,                          // Altura de cada pontinho
                  spacing: 4,                                   // Espaço entre os pontinhos
                  dotColor: const Color.fromARGB(0, 0, 3, 6),   // Cor dos pontinhos inativos (quase transparente)
                  activeDotColor: Theme.of(context).primaryColor, // Cor do pontinho ativo = cor primária do app
                ),
              ),
            ),
            const SizedBox(height: 8),                          // Espacinho depois dos pontinhos
          ],
          Padding(                                              // Seção principal de informações (nome, preço, descrição, tamanhos)
            padding: const EdgeInsets.all(16),                  // Margem interna de 16px em todos os lados
            child: Column(                                      // Coluna para empilhar os textos verticalmente
              crossAxisAlignment: CrossAxisAlignment.start,     // Alinha tudo à esquerda
              children: <Widget>[                               // Conteúdo da seção de detalhes
                Text(                                           // Nome grande do produto
                  product.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Padding(                                  // Texto "A partir de" pequeno e cinza
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'A partir de',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Text(                                           // Preço em destaque
                  'R\$ $priceText',
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,                        // Usa a cor primária do tema
                  ),
                ),
                const Padding(                                  // Título "Descrição"
                  padding: EdgeInsets.only(top: 16, bottom: 8),
                  child: Text(
                    'Descrição',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(                                           // Texto completo da descrição
                  product.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    height: 1.2,                                // Aumenta um pouco o espaçamento entre linhas
                  ),
                ),
                const Padding(                                  // Título "Tamanhos"
                  padding: EdgeInsets.only(top: 16, bottom: 8),
                  child: Text(
                    'Tamanhos',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Wrap(                                           // Widget que quebra automaticamente para a próxima linha
                  spacing: 8,                                   // Espaço horizontal entre os widgets filhos
                  runSpacing: 8,                                // Espaço vertical entre as linhas
                  children: product.sizes                       // Para cada tamanho na lista
                      .map((size) => SizeWidget(size: size))    // Cria um SizeWidget passando o tamanho
                      .toList(),                                // Converte para lista de widgets
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}