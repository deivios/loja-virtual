import 'package:carousel_slider/carousel_slider.dart';           // pacote para carrossel de imagens deslizável
import 'package:flutter/material.dart';                         // widgets básicos Flutter: Scaffold, AppBar, Text, etc
import 'package:lojavirtual/models/cart_manager.dart';          // gerenciador do carrinho (método addToCart)
import 'package:lojavirtual/models/product.dart';               // modelo Product (com imagens, tamanhos, preço, etc)
import 'package:lojavirtual/models/user_manager.dart';          // gerenciador de usuário (isLoggedIn)
import 'package:lojavirtual/screens/product/components/size_widget.dart'; // widget que exibe cada tamanho disponível
import 'package:provider/provider.dart';                        // ChangeNotifierProvider, Consumer, Consumer2, context.read
import 'package:smooth_page_indicator/smooth_page_indicator.dart'; // indicador animado de pontos para carrossel

class ProductScreen extends StatefulWidget {                   // tela de detalhes do produto (tem estado)
  const ProductScreen(this.product, {super.key});              // recebe o Product via construtor (geralmente via Navigator)
  final Product product;                                       // produto exibido nesta tela

  @override
  State<ProductScreen> createState() => _ProductScreenState(); // cria o estado associado
}

class _ProductScreenState extends State<ProductScreen> {
  int _current = 0;                                            // índice da imagem atualmente visível no carrossel
  static const double _dotSize = 8;                            // tamanho fixo dos pontinhos indicadores

  @override
  void initState() {                                           // chamado uma vez quando o widget é inserido
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {         // executa após o primeiro frame ser desenhado
      widget.product.selectedSize = null;                      // limpa qualquer tamanho previamente selecionado
    });
  }

  @override
  Widget build(BuildContext context) {                         // constrói a interface da tela
    final product = widget.product;                            // atalho para o produto recebido
    final images = product.images;                             // lista de URLs das imagens
    final primaryColor = Theme.of(context).primaryColor;       // cor primária do tema (normalmente azul)

    return Scaffold(                                           // estrutura principal da tela
      appBar: AppBar(                                          // barra superior
        title: Text(product.name),                             // título = nome do produto
        centerTitle: true,                                     // centraliza o título
      ),
      body: ChangeNotifierProvider<Product>.value(             // fornece o Product para os SizeWidget via Provider
        value: product,                                        // usa o objeto já existente (não cria novo)
        child: GestureDetector(                                // detecta toques fora dos widgets filhos
          onTap: () => product.selectedSize = null,            // ao tocar em qualquer lugar fora → desmarca tamanho
          behavior: HitTestBehavior.deferToChild,              // só captura toque se não for tratado por filho
          child: ListView(                                     // permite scroll vertical de todo o conteúdo
            children: [
              CarouselSlider(                                  // carrossel de imagens do produto
                items: images.map((url) =>                     // para cada URL cria um widget de imagem
                  Image.network(url, fit: BoxFit.cover, width: double.infinity)
                ).toList(),
                options: CarouselOptions(
                  aspectRatio: 1,                              // mantém proporção quadrada (1:1)
                  viewportFraction: 1,                         // cada imagem ocupa 100% da largura
                  enableInfiniteScroll: images.length > 1,     // loop infinito só se tiver mais de uma foto
                  onPageChanged: (index, reason) =>            // callback quando página muda
                      setState(() => _current = index),        // atualiza índice da imagem atual
                ),
              ),
              if (images.length > 1) ...[                      // só exibe indicador se tiver mais de 1 imagem
                const SizedBox(height: 8),                     // espaço acima dos pontinhos
                Center(                                        // centraliza o indicador
                  child: AnimatedSmoothIndicator(              // pontinhos animados indicando posição
                    activeIndex: _current,                     // índice da imagem atual
                    count: images.length,                      // total de imagens
                    effect: WormEffect(                        // estilo "minhoca" (worm)
                      dotWidth: _dotSize,                      // largura de cada ponto
                      dotHeight: _dotSize,                     // altura de cada ponto
                      spacing: 4,                              // espaço entre pontos
                      dotColor: const Color.fromARGB(0, 0, 3, 6), // pontos inativos quase invisíveis
                      activeDotColor: primaryColor,            // ponto ativo = cor primária do app
                    ),
                  ),
                ),
                const SizedBox(height: 8),                     // espaço abaixo dos pontinhos
              ],
              Padding(                                         // padding geral ao redor do conteúdo textual
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // alinha tudo à esquerda
                  children: [
                    Text(product.name,                         // nome grande do produto
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                    const Padding(                             // texto "A partir de"
                      padding: EdgeInsets.only(top: 4),
                      child: Text('A partir de',
                          style: TextStyle(fontSize: 13, color: Colors.grey)),
                    ),
                    Consumer<Product>(                         // escuta mudanças no Product (principalmente selectedSize)
                      builder: (_, p, __) => Text(             // exibe preço
                        p.selectedSize != null
                            ? 'R\$ ${p.selectedSize!.price.toStringAsFixed(2).replaceAll('.', ',')}' // preço do tamanho escolhido
                            : 'R\$ ${p.effectivePrice.toStringAsFixed(2).replaceAll('.', ',')}',   // preço base se nada selecionado
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor),
                      ),
                    ),
                    const Padding(                             // título "Descrição"
                      padding: EdgeInsets.only(top: 16, bottom: 8),
                      child: Text('Descrição',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    ),
                    Text(product.description,                  // texto da descrição do produto
                        style: const TextStyle(fontSize: 14, height: 1.2)),
                    const Padding(                             // título "Tamanhos"
                      padding: EdgeInsets.only(top: 16, bottom: 8),
                      child: Text('Tamanhos',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    ),
                    Wrap(                                      // grid fluido de tamanhos (quebra linha automaticamente)
                      spacing: 8,                              // espaço horizontal entre chips
                      runSpacing: 8,                           // espaço vertical entre linhas
                      children: product.sizes                  // para cada tamanho do produto
                          .map((size) => SizeWidget(size: size)) // cria widget SizeWidget
                          .toList(),
                    ),
                    const SizedBox(height: 20),                // espaço antes do botão
                    Consumer2<UserManager, Product>(           // escuta tanto UserManager quanto Product
                      builder: (context, userManager, product, _) {
                        final hasValidSize = product.selectedSize != null && // tamanho selecionado E
                            product.selectedSize!.hasStock;                    // tem estoque disponível
                        return SizedBox(                       // container fixo para botão
                          height: 44,
                          width: double.infinity,
                          child: ElevatedButton(               // botão grande de ação
                            style: ElevatedButton.styleFrom(
                              backgroundColor: hasValidSize ? primaryColor : Colors.grey[400], // cor ativa/inativa
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey[400],
                              disabledForegroundColor: Colors.white70,
                            ),
                            onPressed: hasValidSize            // só habilita se tamanho válido
                                ? () async {
                                    if (userManager.isLoggedIn) { // usuário já logado?
                                      await context.read<CartManager>().addToCart(product); // adiciona ao carrinho
                                      if (!context.mounted) return; // protege contra navegação após dispose
                                      ScaffoldMessenger.of(context).showSnackBar( // feedback visual
                                        const SnackBar(content: Text('Produto adicionado ao carrinho!')),
                                      );
                                      Navigator.of(context).pushReplacementNamed('/cart'); // vai para carrinho substituindo
                                    } else {
                                      Navigator.of(context).pushNamed('/login'); // redireciona para login
                                    }
                                  }
                                : null,                        // botão desabilitado → onPressed = null
                            child: Text(                       // texto dinâmico do botão
                              userManager.isLoggedIn ? 'Adicionar ao Carrinho' : 'Entre para Comprar',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        );
                      },
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
}