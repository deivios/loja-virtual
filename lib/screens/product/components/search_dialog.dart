import 'package:flutter/material.dart';                    // Importa o pacote principal do Flutter (widgets como Material, SafeArea, Stack, Card, TextFormField, etc.)

class SearchDialog extends StatelessWidget {               // Widget sem estado que representa uma caixa de diálogo de busca (overlay de pesquisa)
  const SearchDialog({super.key});                         // Construtor constante (boa prática para performance e imutabilidade)

  @override
  Widget build(BuildContext context) {                     // Método obrigatório que constrói a interface do widget
    return Material(                                       // Material com transparência para criar um overlay sem fundo sólido
      type: MaterialType.transparency,                     // Remove o fundo padrão do Material (deixa transparente)
      child: SafeArea(                                     // SafeArea garante que o conteúdo não fique sob notch, status bar ou home indicator
        child: Stack(                                      // Stack permite posicionar widgets sobrepostos (aqui usado para posicionar o campo de busca no topo)
          children: <Widget>[                              // Lista de filhos da Stack

            Positioned(                                    // Posiciona o Card no topo da tela com margens
              top: 8,                                      // Distância do topo da tela: 8 pixels
              left: 8,                                     // Distância da esquerda: 8 pixels
              right: 8,                                    // Distância da direita: 8 pixels (ocupa quase toda a largura)
              child: Card(                                 // Card cria o fundo elevado com sombra para o campo de busca
                elevation: 8,                              // Elevação/sombra forte (parece flutuante)
                child: TextFormField(                      // Campo de texto para digitar o termo de busca
                  autofocus: true,                         // Foca automaticamente no campo ao abrir o dialog
                  decoration: InputDecoration(             // Decoração do campo (sem borda, hint, ícone, padding)
                    border: InputBorder.none,              // Remove qualquer borda padrão
                    hintText: 'Buscar produto...',         // Texto de dica quando o campo está vazio
                    contentPadding: const EdgeInsets.symmetric( // Padding interno do campo
                      vertical: 15,                        // Espaço vertical (topo e base)
                      horizontal: 8,                       // Espaço horizontal (esquerda e direita)
                    ),
                    prefixIcon: IconButton(                // Ícone à esquerda do campo (botão de voltar)
                      icon: const Icon(Icons.arrow_back),  // Ícone de seta para trás
                      onPressed: () => Navigator.of(context).pop(), // Fecha o dialog ao clicar (volta para tela anterior)
                    ),
                  ),
                  onFieldSubmitted: (_) => Navigator.of(context).pop(), // Fecha o dialog ao pressionar ENTER/OK no teclado
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}