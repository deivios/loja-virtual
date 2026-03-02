// ========== SEARCH_DIALOG.DART - Diálogo de busca ==========
// Campo de texto. Enter -> pop(texto). Voltar -> pop(null). initialText preenche campo.

import 'package:flutter/material.dart'; // Material, SafeArea, Stack, Card, TextFormField

class SearchDialog extends StatefulWidget {
  const SearchDialog({super.key, this.initialText}); // initialText: texto inicial (para editar)
  final String? initialText;

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  final TextEditingController _controller = TextEditingController(); // Controla o texto do campo

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialText?.trim() ?? ''; // Preenche com texto inicial
    if (_controller.text.isNotEmpty) {
      _controller.selection = TextSelection(baseOffset: 0, extentOffset: _controller.text.length); // Seleciona todo o texto
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Libera memória
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency, // Fundo transparente (overlay escurece por baixo)
      child: SafeArea( // Respeita notch/status bar
        child: Stack(
          children: [
            Positioned( // Posiciona o card no topo
              top: 8,
              left: 8,
              right: 8,
              child: Card(
                elevation: 8, // Sombra do card
                child: TextFormField(
                  controller: _controller,
                  autofocus: true, // Foco automático (teclado aparece)
                  decoration: InputDecoration(
                    border: InputBorder.none, // Sem borda
                    hintText: 'Buscar produto...',
                    contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
                    prefixIcon: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).pop(), // Fecha sem retornar (pop null)
                    ),
                  ),
                  onFieldSubmitted: (_) => Navigator.of(context).pop(_controller.text.trim()), // Enter retorna texto
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
