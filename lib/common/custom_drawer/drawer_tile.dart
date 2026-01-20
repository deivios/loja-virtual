import 'package:flutter/material.dart';                    // Importa o pacote Flutter básico (widgets como InkWell, Icon, Text, etc.)
import 'package:lojavirtual/models/page_manager.dart';     // Importa a classe PageManager (gerenciador de página atual do app)
import 'package:provider/provider.dart';                   // Importa o Provider (para acessar e observar o PageManager)

class DrawerTile extends StatelessWidget {                 // Widget sem estado que representa cada item do menu lateral (drawer)
  
  const DrawerTile({                                      // Construtor constante (boa prática para performance)
    required this.iconData,                               // Ícone obrigatório (ex: Icons.home)
    required this.title,                                  // Texto do item obrigatório (ex: 'Início')
    required this.page,                                   // Número da página associada a esse item (0, 1, 2...)
  });

  final IconData iconData;                                // Armazena o ícone passado no construtor
  final String title;                                     // Armazena o texto/título do item
  final int page;                                         // Armazena o índice da página que esse item representa

  @override
  Widget build(BuildContext context) {                    // Método que constrói o widget visual
    final int curPage = context.watch<PageManager>().page; // Observa (watch) o valor atual da página no PageManager
                                                           // Sempre que a página mudar, este widget será reconstruído

    return InkWell(                                        // Widget que detecta toques com efeito ripple (onda ao clicar)
      onTap: () {                                          // Quando o usuário tocar/clicar no item
        context.read<PageManager>().setPage(page);         // Atualiza a página atual no gerenciador (muda a tela principal)
                                                           // read = só executa a ação, não escuta mudanças
      },
      child: SizedBox(                                     // Define uma altura fixa para o item ficar uniforme
        height: 60,                                        // Altura total de cada item do drawer (60 pixels)
        child: Row(                                        // Alinha ícone + texto na horizontal
          children: <Widget>[                              // Lista de filhos da Row

            Padding(                                       // Espaçamento à esquerda do ícone
              padding: const EdgeInsets.symmetric(horizontal: 32), // 32 pixels de margem esquerda e direita
              child: Icon(                                 // Mostra o ícone
                iconData,                                  // O ícone passado (ex: Icons.home)
                size: 32,                                  // Tamanho do ícone: 32 pixels
                color: curPage == page                     // Cor condicional:
                    ? const Color.fromARGB(255, 3, 87, 156) // Azul quando a página está selecionada
                    : Colors.grey[700],                    // Cinza escuro quando não está selecionada
              ),
            ),

            Text(                                          // Mostra o texto do item
              title,                                         // O título passado (ex: 'Início')
              style: TextStyle(                              // Estilo do texto
                fontSize: 16,                                // Tamanho da fonte: 16 pixels
                color: curPage == page                       // Cor condicional:
                    ? const Color.fromARGB(255, 4, 80, 142)  // Azul quando selecionado
                    : const Color.fromARGB(255, 97, 97, 97), // Cinza médio quando não selecionado
              ),
            ),

            // Observação: você poderia adicionar um Expanded() aqui se quisesse que o texto ocupasse o espaço restante
            // Ex: Expanded(child: Text(...)) para evitar overflow em títulos longos

          ],
        ),
      ),
    );
  }
}