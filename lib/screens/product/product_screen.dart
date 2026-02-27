import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:lojavirtual/models/cart_manager.dart';
import 'package:lojavirtual/models/product.dart';
import 'package:lojavirtual/models/user_manager.dart';
import 'package:lojavirtual/screens/product/components/size_widget.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen(this.product, {super.key});
  final Product product;

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int _current = 0;
  static const double _dotSize = 8;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.product.selectedSize = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final images = product.images;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(title: Text(product.name), centerTitle: true),
      body: ChangeNotifierProvider<Product>.value(
        value: product,
        child: GestureDetector(
          onTap: () => product.selectedSize = null,
          behavior: HitTestBehavior.deferToChild,
          child: ListView(
            children: [
              CarouselSlider(
                items: images.map((url) => Image.network(url, fit: BoxFit.cover, width: double.infinity)).toList(),
                options: CarouselOptions(
                  aspectRatio: 1,
                  viewportFraction: 1,
                  enableInfiniteScroll: images.length > 1,
                  onPageChanged: (index, reason) => setState(() => _current = index),
                ),
              ),
              if (images.length > 1) ...[
                const SizedBox(height: 8),
                Center(
                  child: AnimatedSmoothIndicator(
                    activeIndex: _current,
                    count: images.length,
                    effect: WormEffect(
                      dotWidth: _dotSize,
                      dotHeight: _dotSize,
                      spacing: 4,
                      dotColor: const Color.fromARGB(0, 0, 3, 6),
                      activeDotColor: primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text('A partir de', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    ),
                    Consumer<Product>(
                      builder: (_, p, __) => Text(
                        p.selectedSize != null
                            ? 'R\$ ${p.selectedSize!.price.toStringAsFixed(2).replaceAll('.', ',')}'
                            : 'R\$ ${p.effectivePrice.toStringAsFixed(2).replaceAll('.', ',')}',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 16, bottom: 8),
                      child: Text('Descrição', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    ),
                    Text(product.description, style: const TextStyle(fontSize: 14, height: 1.2)),
                    const Padding(
                      padding: EdgeInsets.only(top: 16, bottom: 8),
                      child: Text('Tamanhos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: product.sizes.map((size) => SizeWidget(size: size)).toList(),
                    ),
                    const SizedBox(height: 20),
                    Consumer2<UserManager, Product>(
                      builder: (context, userManager, product, _) {
                        final hasValidSize = product.selectedSize != null && product.selectedSize!.hasStock;
                        return SizedBox(
                          height: 44,
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: hasValidSize ? primaryColor : Colors.grey[400],
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey[400],
                              disabledForegroundColor: Colors.white70,
                            ),
                            onPressed: hasValidSize
                                ? () async {
                                    if (userManager.isLoggedIn) {
                                      await context.read<CartManager>().addToCart(product);
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Produto adicionado ao carrinho!')),
                                      );
                                      Navigator.of(context).pushReplacementNamed('/cart');
                                    } else {
                                      Navigator.of(context).pushNamed('/login');
                                    }
                                  }
                                : null,
                            child: Text(
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
