import 'dart:math'; // Usado para calcular menor valor com min().

import 'package:carousel_slider/carousel_slider.dart'; // Carrossel das imagens do produto.
import 'package:cloud_firestore/cloud_firestore.dart'; // Leitura e escrita no Firestore.
import 'package:flutter/material.dart'; // Widgets visuais do Flutter Material.
import 'package:lojavirtual/models/product.dart'; // Modelo Product do projeto.
import 'package:smooth_page_indicator/smooth_page_indicator.dart'; // Bolinhas do carrossel.

class ProductScreen extends StatefulWidget {
  // Tela com estado para editar produto.
  const ProductScreen(this.product, {super.key}); // Recebe o produto pela rota.
  final Product product; // Produto recebido ao abrir esta tela.

  @override
  State<ProductScreen> createState() => _ProductScreenState(); // Cria o estado da tela.
}

class _ProductScreenState extends State<ProductScreen> {
  // Classe que guarda estado da UI.
  int _current = 0; // Índice atual da imagem no carrossel.
  static const double _dotSize = 8; // Tamanho das bolinhas do indicador.
  static const List<String> _commonSizeOrder = <String>[
    // Ordem fixa de tamanhos permitidos.
    'P', // Tamanho pequeno.
    'M', // Tamanho médio.
    'GG', // Tamanho grande.
  ];

  final TextEditingController _descriptionController =
      TextEditingController(); // Controller da descrição.
  final List<_EditableSize> _editableSizes =
      []; // Lista de linhas de tamanho editáveis na tela.
  final Map<String, num> _knownPricesBySize =
      <String, num>{}; // Cache de preço conhecido por tamanho.
  bool _saving = false; // Controla loading do botão salvar.
  bool _deleting = false; // Controla loading do botão excluir.

  @override
  void initState() {
    // Executa ao abrir a tela.
    super.initState(); // Chama init padrão do Flutter.
    _applyProductData(widget.product); // Aplica dados iniciais vindos da rota.
    _loadLatestProductFromFirestore(); // Atualiza com dados mais recentes do Firestore.
  }

  @override
  void dispose() {
    // Executa ao fechar a tela.
    _descriptionController.dispose(); // Libera controller da descrição.
    for (final size in _editableSizes) {
      // Percorre todas as linhas de tamanho.
      size.dispose(); // Libera controllers de cada linha.
    }
    super.dispose(); // Finaliza dispose padrão do Flutter.
  }

  num _parsePrice(String value) {
    // Converte texto de preço em número.
    final cleaned = value
        .trim()
        .replaceAll('R\$', '')
        .replaceAll(',', '.'); // Remove símbolo e normaliza decimal.
    return num.tryParse(cleaned) ?? 0; // Retorna número ou 0 se inválido.
  }

  int _parseStock(String value) {
    // Converte texto de estoque em inteiro.
    return int.tryParse(value.trim()) ?? 0; // Retorna inteiro ou 0 se inválido.
  }

  String _priceText(num value) {
    // Formata número para texto com 2 casas.
    return value.toStringAsFixed(2); // Exemplo: 23.9 -> 23.90.
  }

  void _applyProductData(Product source) {
    // Carrega dados do produto para os campos da UI.
    _descriptionController.text = source.description; // Preenche descrição.

    for (final size in _editableSizes) {
      // Limpa linhas antigas.
      size.dispose(); // Libera recursos de cada linha antiga.
    }
    _editableSizes.clear(); // Limpa lista de linhas.
    _knownPricesBySize.clear(); // Limpa cache de preços conhecidos.

    final aggregated =
        <String, _AggregatedSize>{}; // Mapa para consolidar tamanhos por nome.
    for (final item in source.sizes) {
      // Percorre tamanhos vindos do produto.
      final normalizedName = _normalizeSizeName(
        item.name,
      ); // Normaliza nome (P/M/GG).
      if (normalizedName == null) continue; // Ignora tamanhos fora da regra.

      final entry =
          aggregated[normalizedName] ??
          _AggregatedSize(); // Obtém acumulador atual do tamanho.
      if (item.stock > entry.stock) {
        // Se estoque atual é maior...
        entry.stock = item.stock; // ...guarda maior estoque.
      }
      if (item.price > 0 && item.price > entry.price) {
        // Se preço atual é válido e maior...
        entry.price = item.price; // ...guarda melhor preço conhecido.
      }
      aggregated[normalizedName] = entry; // Salva acumulador no mapa.
    }

    for (final sizeName in _commonSizeOrder) {
      // Monta sempre P, M e GG na ordem fixa.
      final data = aggregated[sizeName]; // Pega dados consolidados do tamanho.
      final stock = data?.stock ?? 0; // Estoque do tamanho (ou 0).
      final directPrice =
          data?.price ?? 0; // Preço vindo direto do tamanho (ou 0).
      final fallbackPrice = source.effectivePrice > 0
          ? source.effectivePrice
          : 0; // Preço de fallback do produto.
      num resolvedPrice = directPrice > 0
          ? directPrice
          : fallbackPrice; // Preço final resolvido.
      if (sizeName == 'M') {
        // Regra especial solicitada para tamanho M.
        resolvedPrice = 23.99; // Força preço do M.
      }

      if (directPrice > 0) {
        // Se houve preço direto válido...
        _knownPricesBySize[sizeName] =
            directPrice; // ...guarda como preço conhecido.
      } else if (resolvedPrice > 0) {
        // Senão, se há preço resolvido...
        _knownPricesBySize[sizeName] =
            resolvedPrice; // ...guarda fallback conhecido.
      }

      _editableSizes.add(
        // Adiciona linha na UI.
        _EditableSize(
          // Cria linha de tamanho editável.
          title: sizeName, // Define título P/M/GG.
          stock: stock.toString(), // Define estoque como texto.
          price: _priceText(resolvedPrice), // Define preço formatado.
        ),
      );
    }
  }

  Future<void> _loadLatestProductFromFirestore() async {
    // Busca versão mais nova do produto no banco.
    try {
      // Tenta buscar no Firestore.
      final doc = await FirebaseFirestore
          .instance // Instância do Firestore.
          .collection('products') // Coleção de produtos.
          .doc(widget.product.id) // Documento do produto atual.
          .get(); // Faz leitura.
      if (!mounted || !doc.exists)
        return; // Sai se tela fechou ou doc não existe.
      setState(() {
        // Atualiza UI.
        _applyProductData(
          Product.fromDocument(doc),
        ); // Reaplica dados frescos do Firestore.
      });
    } catch (_) {
      // Captura erro de rede/permissão etc.
      // Keep screen usable with local route data if fetch fails.
    }
  }

  num get _previewPrice {
    // Calcula "A partir de" exibido no topo.
    final prices =
        _editableSizes // Pega preços das linhas.
            .map(
              (size) => _parsePrice(size.priceController.text),
            ) // Converte para número.
            .where((price) => price > 0) // Mantém só preços válidos.
            .toList(); // Converte para lista.

    if (prices.isEmpty) {
      // Se não houver preço válido...
      return widget.product.effectivePrice; // ...usa preço efetivo do produto.
    }

    return prices.reduce(min); // Retorna menor preço da lista.
  }

  int get _totalStock {
    // Soma de todo estoque exibido.
    return _editableSizes.fold<int>(
      // Faz fold acumulando inteiro.
      0, // Começa em zero.
      (total, size) =>
          total +
          _parseStock(size.stockController.text), // Soma estoque de cada linha.
    );
  }

  num get _totalInventoryValue {
    // Soma total em dinheiro (estoque x preço).
    return _editableSizes.fold<num>(0, (total, size) {
      // Faz fold acumulando num.
      final stock = _parseStock(
        size.stockController.text,
      ); // Lê estoque atual da linha.
      final price = _parsePrice(
        size.priceController.text,
      ); // Lê preço atual da linha.
      if (stock <= 0 || price <= 0) return total; // Ignora linha inválida.
      return total + (stock * price); // Soma valor da linha.
    });
  }

  String _nextSuggestedSizeTitle() {
    // Sugere próximo tamanho faltante.
    final usedTitles =
        _editableSizes // Pega títulos já usados.
            .map(
              (size) => size.titleController.text.trim().toUpperCase(),
            ) // Normaliza títulos.
            .where((title) => title.isNotEmpty) // Ignora vazios.
            .toSet(); // Converte para set.

    for (final sizeName in _commonSizeOrder) {
      // Percorre ordem oficial.
      if (!usedTitles.contains(sizeName))
        return sizeName; // Retorna primeiro faltante.
    }
    return ''; // Se nenhum faltar, retorna vazio.
  }

  String? _normalizeSizeName(String raw) {
    // Normaliza e valida tamanho.
    final upper = raw
        .trim()
        .toUpperCase(); // Remove espaços e sobe para maiúsculo.
    if (_commonSizeOrder.contains(upper)) return upper; // Aceita apenas P/M/GG.
    return null; // Rejeita qualquer outro valor.
  }

  void _sortAndDeduplicateSizes() {
    // Ordena e remove duplicados de tamanhos.
    final mergedByName =
        <String, _EditableSize>{}; // Mapa para unificar por nome.

    for (final size in _editableSizes) {
      // Percorre linhas atuais.
      final normalized = _normalizeSizeName(
        size.titleController.text,
      ); // Normaliza título da linha.
      if (normalized == null) {
        // Se título inválido...
        size.dispose(); // ...descarta controllers.
        continue; // ...e segue próxima linha.
      }

      size.titleController.text = normalized; // Corrige visualmente o título.
      final knownPrice = _parsePrice(
        size.priceController.text,
      ); // Lê preço da linha.
      if (knownPrice > 0) {
        // Se preço é válido...
        final existingKnown =
            _knownPricesBySize[normalized] ?? 0; // Pega preço conhecido atual.
        if (knownPrice > existingKnown) {
          // Se preço atual é melhor...
          _knownPricesBySize[normalized] = knownPrice; // ...atualiza cache.
        }
      }

      final existing =
          mergedByName[normalized]; // Verifica se já existe linha desse tamanho.
      if (existing == null) {
        // Se não existe...
        mergedByName[normalized] = size; // ...salva esta linha.
        continue; // ...e vai para próxima.
      }

      final existingStock = _parseStock(
        existing.stockController.text,
      ); // Estoque da linha já existente.
      final existingPrice = _parsePrice(
        existing.priceController.text,
      ); // Preço da linha já existente.
      final candidateStock = _parseStock(
        size.stockController.text,
      ); // Estoque da linha candidata.
      final candidatePrice = _parsePrice(
        size.priceController.text,
      ); // Preço da linha candidata.

      if (candidateStock > existingStock) {
        // Se candidato tem mais estoque...
        existing.stockController.text = candidateStock
            .toString(); // ...mantém maior estoque.
      }
      if (existingPrice <= 0 && candidatePrice > 0) {
        // Se existente não tinha preço válido...
        existing.priceController.text = _priceText(
          candidatePrice,
        ); // ...usa preço do candidato.
      } else if (candidateStock >= existingStock && candidatePrice > 0) {
        // Regra extra para atualizar preço.
        existing.priceController.text = _priceText(
          candidatePrice,
        ); // Atualiza preço da linha final.
      }

      if (candidatePrice > 0) {
        // Se candidato tem preço válido...
        final bestKnown =
            _knownPricesBySize[normalized] ?? 0; // Pega melhor conhecido.
        if (candidatePrice > bestKnown) {
          // Se candidato é melhor...
          _knownPricesBySize[normalized] = candidatePrice; // ...atualiza cache.
        }
      }

      if (existingPrice > 0) {
        // Se linha existente tem preço válido...
        final bestKnown =
            _knownPricesBySize[normalized] ?? 0; // Lê melhor conhecido.
        if (existingPrice > bestKnown) {
          // Se existente é melhor...
          _knownPricesBySize[normalized] = existingPrice; // ...atualiza cache.
        }
      }

      size.dispose(); // Descarta linha duplicada após mescla.
    }

    final unique = mergedByName.values
        .toList(); // Converte mapa final para lista.

    unique.sort((a, b) {
      // Ordena lista na ordem P/M/GG.
      final ia = _commonSizeOrder.indexOf(
        a.titleController.text.toUpperCase(),
      ); // Índice do primeiro.
      final ib = _commonSizeOrder.indexOf(
        b.titleController.text.toUpperCase(),
      ); // Índice do segundo.
      return ia.compareTo(ib); // Compara índices para ordenar.
    });

    _editableSizes // Atualiza lista principal.
      ..clear() // Limpa conteúdo atual.
      ..addAll(unique); // Adiciona lista ordenada sem duplicados.
  }

  void _addSize() {
    // Adiciona novo tamanho faltante.
    final nextTitle = _nextSuggestedSizeTitle(); // Descobre qual tamanho falta.
    if (nextTitle.isEmpty) {
      // Se nenhum tamanho falta...
      ScaffoldMessenger.of(context).showSnackBar(
        // Exibe aviso.
        const SnackBar(
          content: Text('Apenas P, M e GG sao permitidos.'),
        ), // Mensagem.
      );
      return; // Encerra sem adicionar.
    }

    setState(() {
      // Atualiza UI.
      final defaultPrice = // Define preço inicial da nova linha.
          _knownPricesBySize[nextTitle] ?? // Tenta preço conhecido do tamanho.
          (widget.product.effectivePrice > 0
              ? widget.product.effectivePrice
              : 0); // Fallback do produto.
      _editableSizes.add(
        // Adiciona linha nova.
        _EditableSize(
          // Cria linha editável.
          title: nextTitle, // Define título sugerido.
          stock: '0', // Inicia com estoque zero.
          price: _priceText(defaultPrice), // Inicia com preço padrão formatado.
        ),
      );
      _sortAndDeduplicateSizes(); // Garante ordem e consistência.
    });
  }

  void _removeSize(int index) {
    // Remove linha de tamanho pelo índice.
    if (index < 0 || index >= _editableSizes.length) return; // Valida índice.
    setState(() {
      // Atualiza UI.
      final size = _editableSizes.removeAt(index); // Remove da lista.
      size.dispose(); // Libera controllers da linha removida.
    });
  }

  void _incrementStock(int index) {
    // Incrementa estoque via seta para cima.
    if (index < 0 || index >= _editableSizes.length) return; // Valida índice.
    setState(() {
      // Atualiza UI.
      final current = _parseStock(
        _editableSizes[index].stockController.text,
      ); // Lê estoque atual.
      _editableSizes[index].stockController.text = (current + 1)
          .toString(); // Soma 1.
      _applySuggestedPriceIfNeeded(
        index,
      ); // Se preço estiver zerado, tenta preencher.
    });
  }

  void _decrementStock(int index) {
    // Decrementa estoque via seta para baixo.
    if (index < 0 || index >= _editableSizes.length) return; // Valida índice.
    setState(() {
      // Atualiza UI.
      final current = _parseStock(
        _editableSizes[index].stockController.text,
      ); // Lê estoque atual.
      final next = current > 0 ? current - 1 : 0; // Evita estoque negativo.
      _editableSizes[index].stockController.text = next
          .toString(); // Escreve novo valor.
    });
  }

  void _onStockChanged(int index, String value) {
    // Chamado ao digitar estoque manualmente.
    if (index < 0 || index >= _editableSizes.length) return; // Valida índice.
    setState(() {
      // Atualiza UI.
      _applySuggestedPriceIfNeeded(
        index,
      ); // Tenta preencher preço quando necessário.
    });
  }

  void _applySuggestedPriceIfNeeded(int index) {
    // Preenche preço automaticamente quando aplicável.
    if (index < 0 || index >= _editableSizes.length) return; // Valida índice.

    final size = _editableSizes[index]; // Lê linha alvo.
    final stock = _parseStock(
      size.stockController.text,
    ); // Lê estoque da linha.
    final currentPrice = _parsePrice(
      size.priceController.text,
    ); // Lê preço da linha.
    if (stock <= 0 || currentPrice > 0)
      return; // Só age se estoque > 0 e preço zerado.

    final normalizedTitle =
        _normalizeSizeName(size.titleController.text) ??
        ''; // Normaliza título da linha.
    final fallbackPrice = // Define preço de fallback.
        _knownPricesBySize[normalizedTitle] ?? // Tenta cache por tamanho.
        (widget.product.effectivePrice > 0
            ? widget.product.effectivePrice
            : 0); // Tenta preço do produto.
    if (fallbackPrice > 0) {
      // Se conseguiu preço válido...
      size.priceController.text = _priceText(
        fallbackPrice,
      ); // ...preenche o campo de preço.
    }
  }

  Future<void> _saveProduct() async {
    // Salva alterações no Firestore.
    FocusScope.of(context).unfocus(); // Fecha teclado.
    final description = _descriptionController.text
        .trim(); // Lê descrição digitada.

    final sizes =
        _editableSizes // Converte linhas em mapas para salvar.
            .map(
              // Mapeia cada linha.
              (size) => {
                // Cria map da linha.
                'name':
                    _normalizeSizeName(size.titleController.text.trim()) ??
                    '', // Nome normalizado.
                'stock': _parseStock(
                  size.stockController.text,
                ), // Estoque numérico.
                'price': _parsePrice(
                  size.priceController.text,
                ).toDouble(), // Preço numérico.
              },
            )
            .where(
              // Filtra apenas linhas vendáveis.
              (size) => // Regra de validação da linha.
                  (size['name'] as String).isNotEmpty && // Nome obrigatório.
                  (size['stock'] as int) >
                      0 && // Estoque deve ser maior que zero.
                  (size['price'] as double) >
                      0, // Preço deve ser maior que zero.
            )
            .toList(); // Materializa lista final.

    if (description.isEmpty) {
      // Valida descrição.
      ScaffoldMessenger.of(context).showSnackBar(
        // Mostra aviso.
        const SnackBar(
          content: Text('Preencha a descrição do produto.'),
        ), // Mensagem.
      );
      return; // Interrompe salvar.
    }

    if (sizes.isEmpty) {
      // Valida existência de tamanhos vendáveis.
      ScaffoldMessenger.of(context).showSnackBar(
        // Mostra aviso.
        const SnackBar(
          // SnackBar de validação.
          content: Text(
            'Adicione pelo menos um tamanho com estoque e preco.',
          ), // Mensagem.
        ),
      );
      return; // Interrompe salvar.
    }

    final minPrice = sizes
        .map((size) => size['price'] as double)
        .reduce(min); // Calcula basePrice pelo menor preço.

    setState(() => _saving = true); // Ativa loading de salvar.
    try {
      // Tenta atualizar documento.
      await FirebaseFirestore
          .instance // Instância Firestore.
          .collection('products') // Coleção de produtos.
          .doc(widget.product.id) // Documento atual.
          .update({
            // Dados a atualizar.
            'description': description, // Atualiza descrição.
            'sizes': sizes, // Atualiza tamanhos.
            'basePrice': minPrice, // Atualiza preço base.
          });

      if (!mounted) return; // Evita usar context após fechar tela.
      ScaffoldMessenger.of(context).showSnackBar(
        // Mostra sucesso.
        const SnackBar(
          content: Text('Produto salvo com sucesso!'),
        ), // Mensagem de sucesso.
      );
    } on FirebaseException catch (e) {
      // Captura erro do Firebase.
      if (!mounted) return; // Evita usar context inválido.
      ScaffoldMessenger.of(context).showSnackBar(
        // Mostra erro.
        SnackBar(
          // SnackBar de erro.
          content: Text(
            'Erro ao salvar produto: ${e.message ?? e.code}',
          ), // Mensagem detalhada.
        ),
      );
    } finally {
      // Sempre executa no final.
      if (mounted) {
        // Se a tela ainda está aberta...
        setState(() => _saving = false); // ...desativa loading.
      }
    }
  }

  Future<void> _deleteProduct() async {
    // Exclui produto após confirmação.
    final shouldDelete = await showDialog<bool>(
      // Exibe diálogo de confirmação.
      context: context, // Contexto atual.
      builder: (context) => AlertDialog(
        // Janela modal.
        title: const Text('Excluir produto'), // Título do alerta.
        content: const Text(
          'Tem certeza que deseja excluir este produto?',
        ), // Texto de confirmação.
        actions: [
          // Botões de ação.
          TextButton(
            // Botão cancelar.
            onPressed: () =>
                Navigator.of(context).pop(false), // Fecha com false.
            child: const Text('Cancelar'), // Texto do botão.
          ),
          TextButton(
            // Botão confirmar exclusão.
            onPressed: () => Navigator.of(context).pop(true), // Fecha com true.
            child: const Text('Excluir'), // Texto do botão.
          ),
        ],
      ),
    );

    if (shouldDelete != true) return; // Sai se usuário cancelou.

    setState(() => _deleting = true); // Ativa loading de excluir.
    try {
      // Tenta excluir do Firestore.
      await FirebaseFirestore
          .instance // Instância Firestore.
          .collection('products') // Coleção de produtos.
          .doc(widget.product.id) // Documento atual.
          .delete(); // Exclui documento.

      if (!mounted) return; // Evita uso de context inválido.
      ScaffoldMessenger.of(context).showSnackBar(
        // Mostra sucesso.
        const SnackBar(
          content: Text('Produto excluído com sucesso!'),
        ), // Mensagem de sucesso.
      );
      Navigator.of(context).pop(); // Volta para tela anterior.
    } on FirebaseException catch (e) {
      // Captura erro de exclusão.
      if (!mounted) return; // Evita context inválido.
      ScaffoldMessenger.of(context).showSnackBar(
        // Mostra erro.
        SnackBar(
          // SnackBar de erro.
          content: Text(
            'Erro ao excluir produto: ${e.message ?? e.code}',
          ), // Mensagem detalhada.
        ),
      );
      setState(() => _deleting = false); // Desativa loading em caso de falha.
    }
  }

  @override
  Widget build(BuildContext context) {
    // Constrói a interface da tela.
    final product = widget.product; // Produto atual para exibição.
    final images = product.images; // Lista de URLs das imagens.
    final primaryColor = Theme.of(
      context,
    ).primaryColor; // Cor primária do tema.
    final mediaQuery = MediaQuery.of(context); // Dados de mídia da tela.

    return MediaQuery(
      // Sobrescreve escala de texto localmente.
      data: mediaQuery.copyWith(
        textScaler: const TextScaler.linear(1),
      ), // Mantém escala 1:1.
      child: Scaffold(
        // Estrutura principal da tela.
        appBar: AppBar(
          // Barra superior.
          title: const Text('Editar produto'), // Título da tela.
          centerTitle: true, // Centraliza título.
          actions: [
            // Ícones à direita da AppBar.
            IconButton(
              // Botão de excluir produto.
              onPressed: _deleting || _saving
                  ? null
                  : _deleteProduct, // Desabilita durante loading.
              icon:
                  _deleting // Mostra spinner se estiver excluindo.
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(
                      Icons.delete_outline,
                    ), // Ícone normal de lixeira.
            ),
          ],
        ),
        body: ListView(
          // Conteúdo rolável.
          children: [
            // Lista de seções da tela.
            CarouselSlider(
              // Carrossel de imagens.
              items:
                  images // Lista de URLs.
                      .map(
                        // Converte cada URL em widget.
                        (url) => Image.network(
                          // Imagem remota.
                          url, // URL da imagem.
                          fit: BoxFit.cover, // Preenche mantendo proporção.
                          width: double.infinity, // Largura máxima.
                        ),
                      )
                      .toList(), // Converte mapeamento para lista.
              options: CarouselOptions(
                // Opções do carrossel.
                aspectRatio: 1, // Carrossel quadrado.
                viewportFraction: 1, // Uma imagem por vez.
                enableInfiniteScroll:
                    images.length > 1, // Loop somente com mais de uma imagem.
                onPageChanged:
                    (index, reason) => // Callback de troca de página.
                    setState(
                      () => _current = index,
                    ), // Atualiza índice atual.
              ),
            ),
            if (images.length > 1) ...[
              // Mostra indicador só se houver mais de uma imagem.
              const SizedBox(height: 8), // Espaço vertical.
              Center(
                // Centraliza indicador.
                child: AnimatedSmoothIndicator(
                  // Indicador animado.
                  activeIndex: _current, // Página ativa.
                  count: images.length, // Total de páginas.
                  effect: WormEffect(
                    // Efeito visual "worm".
                    dotWidth: _dotSize, // Largura da bolinha.
                    dotHeight: _dotSize, // Altura da bolinha.
                    spacing: 4, // Espaço entre bolinhas.
                    dotColor: Colors.grey.shade300, // Cor das inativas.
                    activeDotColor: primaryColor, // Cor da ativa.
                  ),
                ),
              ),
              const SizedBox(height: 8), // Espaço vertical.
            ],
            Padding(
              // Padding do conteúdo textual/formulário.
              padding: const EdgeInsets.all(16), // Espaçamento geral.
              child: Column(
                // Coluna principal de campos.
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Alinha à esquerda.
                children: [
                  // Widgets da coluna.
                  Text(
                    // Nome do produto.
                    product.name, // Texto do nome.
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6), // Espaço.
                  const Text(
                    // Rótulo "A partir de".
                    'A partir de',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  Text(
                    // Preço inicial em destaque.
                    'R\$ ${_priceText(_previewPrice)}', // Valor formatado.
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 18), // Espaço.
                  const Text(
                    // Rótulo da descrição.
                    'Descrição',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8), // Espaço.
                  TextField(
                    // Campo de edição da descrição.
                    controller:
                        _descriptionController, // Controller da descrição.
                    minLines: 1, // Mínimo de linhas.
                    maxLines: 3, // Máximo de linhas.
                    style: const TextStyle(fontSize: 14), // Estilo do texto.
                    decoration: const InputDecoration(
                      // Decoração do campo.
                      isDense: true,
                      hintText: 'Descrição do produto',
                      border: UnderlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 18), // Espaço.
                  Row(
                    // Linha de título de tamanhos + botão adicionar.
                    children: [
                      const Text(
                        'Tamanhos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(), // Empurra botão para direita.
                      IconButton(
                        onPressed: _addSize, // Adiciona próximo tamanho.
                        icon: const Icon(Icons.add), // Ícone de mais.
                      ),
                    ],
                  ),
                  const SizedBox(height: 6), // Espaço.
                  for (
                    int index = 0;
                    index < _editableSizes.length;
                    index++
                  ) // Renderiza cada linha de tamanho.
                    _SizeRowEditor(
                      key: ValueKey(
                        _editableSizes[index],
                      ), // Chave estável da linha.
                      size: _editableSizes[index], // Dados da linha.
                      canDecrementStock: // Habilita seta para baixo só com estoque > 0.
                          _parseStock(
                            _editableSizes[index].stockController.text,
                          ) >
                          0,
                      onRemove: () => _removeSize(index), // Remove linha.
                      onIncrementStock: () =>
                          _incrementStock(index), // Aumenta estoque.
                      onDecrementStock: () =>
                          _decrementStock(index), // Diminui estoque.
                      onStockChanged: (value) => _onStockChanged(
                        index,
                        value,
                      ), // Mudança manual de estoque.
                      onChanged: () =>
                          setState(() {}), // Rebuild ao alterar campo.
                    ),
                  const SizedBox(height: 6), // Espaço.
                  Text(
                    // Mostra total de estoque.
                    'Total em estoque: $_totalStock',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2), // Espaço.
                  Text(
                    // Mostra valor total em estoque.
                    'Valor total em estoque: R\$ ${_priceText(_totalInventoryValue)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 22), // Espaço.
                  SizedBox(
                    // Área do botão salvar.
                    width: double.infinity, // Largura total.
                    height: 48, // Altura fixa.
                    child: ElevatedButton(
                      // Botão de salvar.
                      onPressed: _saving || _deleting
                          ? null
                          : _saveProduct, // Desabilita durante loading.
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child:
                          _saving // Mostra spinner enquanto salva.
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Salvar',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SizeRowEditor extends StatelessWidget {
  // Widget de uma linha de tamanho (título/estoque/preço).
  const _SizeRowEditor({
    // Construtor da linha.
    super.key, // Chave opcional.
    required this.size, // Dados da linha.
    required this.canDecrementStock, // Controle de habilitação da seta para baixo.
    required this.onRemove, // Callback para remover linha.
    required this.onIncrementStock, // Callback para aumentar estoque.
    required this.onDecrementStock, // Callback para diminuir estoque.
    required this.onStockChanged, // Callback ao digitar estoque.
    required this.onChanged, // Callback genérico para rebuild.
  });

  final _EditableSize size; // Referência da linha editável.
  final bool canDecrementStock; // Indica se pode decrementar estoque.
  final VoidCallback onRemove; // Ação de remover.
  final VoidCallback onIncrementStock; // Ação de aumentar.
  final VoidCallback onDecrementStock; // Ação de diminuir.
  final ValueChanged<String>
  onStockChanged; // Ação ao mudar estoque no teclado.
  final VoidCallback onChanged; // Ação ao mudar qualquer campo.

  @override
  Widget build(BuildContext context) {
    // Constrói a linha.
    const headerStyle = TextStyle(
      fontSize: 12,
      color: Colors.grey,
    ); // Estilo dos rótulos.
    const fieldStyle = TextStyle(fontSize: 14); // Estilo dos campos.
    return Padding(
      // Espaço inferior entre linhas.
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        // Linha horizontal.
        crossAxisAlignment: CrossAxisAlignment.end, // Alinha campos pela base.
        children: [
          Expanded(
            // Coluna Título.
            flex: 2,
            child: _FieldBlock(
              label: 'Título',
              labelStyle: headerStyle,
              child: TextField(
                controller: size.titleController, // Controller do título.
                style: fieldStyle,
                maxLength: 4, // Limite de caracteres.
                onChanged: (value) {
                  // Ao digitar título.
                  final upper = value.toUpperCase(); // Converte para maiúsculo.
                  if (upper != value) {
                    // Se mudou...
                    size
                        .titleController
                        .value = size.titleController.value.copyWith(
                      text: upper,
                      selection: TextSelection.collapsed(offset: upper.length),
                    ); // Reaplica texto em maiúsculo mantendo cursor no fim.
                  }
                  onChanged(); // Dispara rebuild.
                },
                decoration: const InputDecoration(
                  isDense: true,
                  counterText: '',
                  border: UnderlineInputBorder(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8), // Espaço entre colunas.
          Expanded(
            // Coluna Estoque.
            flex: 2,
            child: _FieldBlock(
              label: 'Estoque',
              labelStyle: headerStyle,
              child: TextField(
                controller: size.stockController, // Controller do estoque.
                style: fieldStyle,
                onChanged: (value) {
                  // Ao digitar estoque.
                  onStockChanged(value); // Aplica regra de preço sugerido.
                  onChanged(); // Rebuild.
                },
                keyboardType: TextInputType.number, // Teclado numérico.
                decoration: const InputDecoration(
                  isDense: true,
                  border: UnderlineInputBorder(),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8), // Espaço entre colunas.
          Expanded(
            // Coluna Preço.
            flex: 3,
            child: _FieldBlock(
              label: 'Preço',
              labelStyle: headerStyle,
              child: TextField(
                controller: size.priceController, // Controller do preço.
                style: fieldStyle,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ), // Teclado com decimal.
                onChanged: (_) => onChanged(), // Rebuild ao mudar preço.
                decoration: const InputDecoration(
                  isDense: true,
                  prefixText: 'R\$ ',
                  border: UnderlineInputBorder(),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onRemove, // Remove linha.
            icon: const Icon(
              Icons.remove,
              color: Colors.red,
            ), // Ícone vermelho.
          ),
          IconButton(
            onPressed: onIncrementStock, // Aumenta estoque.
            icon: const Icon(
              Icons.arrow_drop_up,
              color: Colors.green,
            ), // Seta verde para cima.
          ),
          IconButton(
            onPressed: canDecrementStock
                ? onDecrementStock
                : null, // Diminui estoque quando possível.
            icon: const Icon(Icons.arrow_drop_down), // Seta para baixo.
          ),
        ],
      ),
    );
  }
}

class _FieldBlock extends StatelessWidget {
  // Bloco padrão com label + campo.
  const _FieldBlock({
    required this.label, // Texto do rótulo.
    required this.child, // Campo interno.
    required this.labelStyle, // Estilo do rótulo.
  });

  final String label; // Rótulo.
  final Widget child; // Campo.
  final TextStyle labelStyle; // Estilo do rótulo.

  @override
  Widget build(BuildContext context) {
    // Monta label acima do campo.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle), // Exibe rótulo.
        child, // Exibe campo.
      ],
    );
  }
}

class _EditableSize {
  // Estrutura com controllers de uma linha de tamanho.
  _EditableSize({
    required String title, // Valor inicial do título.
    required String stock, // Valor inicial de estoque.
    required String price, // Valor inicial de preço.
  }) : titleController = TextEditingController(
         text: title,
       ), // Cria controller do título.
       stockController = TextEditingController(
         text: stock,
       ), // Cria controller do estoque.
       priceController = TextEditingController(
         text: price,
       ); // Cria controller do preço.

  final TextEditingController titleController; // Controller do título.
  final TextEditingController stockController; // Controller do estoque.
  final TextEditingController priceController; // Controller do preço.

  void dispose() {
    // Libera controllers para evitar leak.
    titleController.dispose(); // Libera título.
    stockController.dispose(); // Libera estoque.
    priceController.dispose(); // Libera preço.
  }
}

class _AggregatedSize {
  // Modelo auxiliar para consolidar tamanhos duplicados.
  int stock = 0; // Maior estoque encontrado.
  num price = 0; // Melhor preço encontrado.
}
