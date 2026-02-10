import 'package:flutter/material.dart';                    // Importa o pacote principal do Flutter com widgets Material, SafeArea, Stack, Card, TextFormField, etc.

class SearchDialog extends StatefulWidget {               // Define um widget com estado (StatefulWidget) que será exibido como diálogo de busca

  const SearchDialog({                                    // Construtor constante da classe (permite otimização pelo compilador)
    super.key,                                            // Parâmetro key opcional (identificador do widget na árvore)
    this.initialText,                                     // Parâmetro opcional: texto inicial que pode ser passado para preencher o campo
  });

  final String? initialText;                              // Declara a propriedade que armazena o texto inicial (pode ser null)

  @override
  State<SearchDialog> createState() => _SearchDialogState(); // Método que cria e retorna a instância do estado associado a este widget
}

class _SearchDialogState extends State<SearchDialog> {    // Classe privada que gerencia o estado do widget SearchDialog

  final TextEditingController _controller = TextEditingController(); // Cria um controlador para gerenciar o conteúdo e o cursor do TextFormField

  @override
  void initState() {                                      // Método chamado uma única vez quando o estado é criado
    super.initState();                                    // Chama a implementação da classe pai (obrigatório)
    _controller.text = widget.initialText?.trim() ?? '';  // Define o texto inicial (remove espaços em branco das extremidades ou usa string vazia)
    if (_controller.text.isNotEmpty) {                    // Verifica se há algum texto preenchido
      _controller.selection = TextSelection(              // Se houver texto, seleciona todo o conteúdo automaticamente
        baseOffset: 0,                                    // Início da seleção (posição 0)
        extentOffset: _controller.text.length,            // Fim da seleção (última posição do texto)
      );
    }
  }

  @override
  void dispose() {                                        // Método chamado quando o widget está sendo removido permanentemente da árvore
    _controller.dispose();                                // Libera os recursos do TextEditingController (evita memory leak)
    super.dispose();                                      // Chama o dispose da classe pai
  }

  @override
  Widget build(BuildContext context) {                    // Método principal que constrói a interface visual do widget
    return Material(                                      // Usa Material com transparência para criar um overlay sem fundo opaco
      type: MaterialType.transparency,                    // Define que o Material não terá cor de fundo (totalmente transparente)
      child: SafeArea(                                    // Garante que o conteúdo não fique sob a barra de status, notch ou indicador de navegação
        child: Stack(                                     // Stack permite sobrepor widgets (usado aqui para posicionar o campo no topo)
          children: <Widget>[                             // Lista de widgets filhos que serão empilhados

            Positioned(                                   // Widget que posiciona seu filho em coordenadas específicas na Stack
              top: 8,                                     // Distância de 8 pixels a partir do topo da tela
              left: 8,                                    // Distância de 8 pixels da borda esquerda
              right: 8,                                   // Distância de 8 pixels da borda direita (faz ocupar quase toda a largura)
              child: Card(                                // Card fornece fundo elevado com bordas arredondadas e sombra
                elevation: 8,                             // Define a intensidade da sombra (valor alto = parece flutuar mais)
                child: TextFormField(                     // Campo de texto com suporte a formulários (mas aqui usado como campo simples)
                  controller: _controller,                // Associa o controlador criado anteriormente ao campo
                  autofocus: true,                        // Faz o campo receber foco automaticamente ao abrir o diálogo
                  decoration: InputDecoration(            // Configura a aparência visual do campo de texto
                    border: InputBorder.none,             // Remove completamente qualquer borda do campo
                    hintText: 'Buscar produto...',        // Texto de dica exibido quando o campo está vazio
                    contentPadding: const EdgeInsets.symmetric( // Define o preenchimento interno do campo
                      vertical: 15,                       // Espaçamento vertical (cima e baixo)
                      horizontal: 8,                      // Espaçamento horizontal (esquerda e direita)
                    ),
                    prefixIcon: IconButton(               // Ícone à esquerda do campo (funciona como botão)
                      icon: const Icon(Icons.arrow_back), // Ícone de seta para esquerda (significa "voltar")
                      onPressed: () => Navigator.of(context).pop(), // Ao clicar, fecha o diálogo sem retornar valor
                    ),
                  ),
                  onFieldSubmitted: (_) => Navigator.of(context).pop(_controller.text.trim()), // Quando o usuário aperta Enter/OK, retorna o texto digitado (removendo espaços extras)
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}