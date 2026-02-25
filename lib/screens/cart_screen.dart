import 'package:flutter/material.dart'; // Pacote principal do Flutter (Scaffold, AppBar, Column, etc.)
import 'package:lojavirtual/models/cart_manager.dart'; // Gerenciador do carrinho de compras (lista de itens)
import 'package:lojavirtual/screens/components/cart_tile.dart'; // Widget que exibe cada item do carrinho
import 'package:provider/provider.dart'; // Pacote de gerenciamento de estado (Consumer)

class CartScreen extends StatelessWidget {                   // Tela do carrinho – widget sem estado
  const CartScreen({super.key});                             // Construtor constante – tela reutilizável

  @override                                                  // Sobrescreve o método obrigatório que constrói a UI
  Widget build(BuildContext context) {                       // Método chamado pelo Flutter para renderizar a tela
    return Scaffold(
      backgroundColor: Colors.blueAccent,                    // Cor de fundo da tela
      appBar: AppBar(                                        // Barra superior da tela (onde aparece "Carrinho")
        backgroundColor: Colors.blueAccent,                  // Cor azul de fundo da AppBar
        foregroundColor: Colors.white,                      // Ícone de voltar e título em branco
        title: const Text('Carrinho'),                       // Título exibido na barra
        centerTitle: true,                                   // Centraliza o título na AppBar
      ),
      body: Consumer<CartManager>(                          // Consumer escuta mudanças no CartManager e reconstrói
        builder: (_, cartManager, __) {                      // Função builder: recebe contexto, cartManager e child
          return Column(                                    // Coluna para empilhar os itens verticalmente
            children: cartManager.items
                .map((cartProduct) => CartTile(cartProduct)) // Mapeia cada item do carrinho em CartTile
                .toList(),                                   // Converte o Iterable em List<Widget>
          );
        },
      ),
    );
  }
}
