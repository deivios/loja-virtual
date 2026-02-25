import 'package:flutter/material.dart';                    // Pacote principal do Flutter (widgets, temas, gestos etc.)
import 'package:lojavirtual/models/item_size.dart';         // Importa o modelo ItemSize (que tem name, price, stock etc.)
import 'package:lojavirtual/models/product.dart';           // Importa o modelo Product (para acessar selectedSize)
import 'package:provider/provider.dart';                    // Pacote Provider para gerenciamento de estado

// Widget que representa visualmente cada tamanho disponível (ex: P, M, G com preço diferenciado)
// É Stateless porque a mudança de seleção é controlada pelo Product (via Provider)
class SizeWidget extends StatelessWidget {
  const SizeWidget({super.key, required this.size});        // Construtor: recebe o ItemSize obrigatório

  final ItemSize size;                                      // O objeto ItemSize específico deste widget (nome, preço, estoque)

  @override
  Widget build(BuildContext context) {                      // Método que constrói a interface do widget
    // Acessa o Product atual no Provider (watch = escuta mudanças e rebuilda quando necessário)
    final product = context.watch<Product>();
    
    // Verifica se este tamanho é o selecionado atualmente no Product
    final selected = size == product.selectedSize;

    // GestureDetector para detectar toque e permitir selecionar o tamanho
    return GestureDetector(
      onTap: () {                                           // Quando o usuário toca neste tamanho
        if (size.hasStock) {                                // Só permite selecionar se tiver estoque
          product.selectedSize = size;                      // Atualiza o tamanho selecionado no Product
          // O setState() não é necessário aqui porque Provider + watch já cuida do rebuild
        }
      },
      child: Container(                                     // Container externo que envolve todo o chip do tamanho
        decoration: BoxDecoration(
          border: Border.all(                                 // Borda ao redor do widget inteiro
            color: !size.hasStock                             // Lógica de cor da borda:
                ? Colors.red.withAlpha(50)                    // Sem estoque → vermelho claro
                : selected                                    // Tem estoque:
                    ? Theme.of(context).primaryColor          // Selecionado → cor primária do tema
                    : Colors.grey,                            // Não selecionado → cinza
            width: selected ? 2 : 1,                          // Borda mais grossa (2px) quando selecionado
          ),
        ),
        child: Row(                                           // Row para colocar nome do tamanho + preço lado a lado
          mainAxisSize: MainAxisSize.min,                     // O Row ocupa apenas o espaço necessário (não expande)
          children: <Widget>[                                 // Filhos da Row
            Container(                                        // Parte esquerda: nome do tamanho com fundo
              color: !size.hasStock                           // Fundo vermelho claro se sem estoque
                  ? Colors.red.withAlpha(50)
                  : Colors.grey,                              // Senão fundo cinza
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8), // Padding interno
              child: Text(
                size.name,                                    // Exibe o nome do tamanho (P, M, G, GG etc.)
                style: const TextStyle(color: Colors.white),  // Texto branco para contraste
              ),
            ),
            Container(                                        // Parte direita: preço do tamanho
              padding: const EdgeInsets.symmetric(horizontal: 16), // Padding horizontal maior
              child: Text(
                'R\$ ${size.price.toDouble().toStringAsFixed(2)}', // Formata preço com 2 casas (ex: R$ 89.90)
                style: TextStyle(
                  color: !size.hasStock                         // Cor do texto do preço:
                      ? Colors.red.withAlpha(50)                // Sem estoque → vermelho claro
                      : Colors.grey,                            // Tem estoque → cinza
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}