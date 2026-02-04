import 'package:cloud_firestore/cloud_firestore.dart';   // Importa o pacote do Cloud Firestore para acessar o banco de dados
import 'package:flutter/material.dart';                   // Importa o Material Design e o ChangeNotifier para gerenciamento de estado
import 'package:lojavirtual/models/product.dart';        // Importa o modelo Product (espera-se que tenha factory fromDocument)
import 'dart:async';                                      // Importa a biblioteca dart:async para usar StreamSubscription

class ProductManager extends ChangeNotifier {            // Define a classe ProductManager que herda de ChangeNotifier (para notificar a UI de mudanças)
  
  final FirebaseFirestore firestore = FirebaseFirestore.instance; // Cria uma referência à instância singleton do Firestore

  // Nome da coleção no Firestore onde os produtos estão armazenados
  static const String productsCollection = 'products';   // Define o nome da coleção como constante (pode ser 'produtos' em outros projetos)

  bool _loading = false;                                 // Variável privada que controla o estado de carregamento (inicia como false)
  String? _error;                                        // Variável privada para armazenar mensagem de erro (pode ser null)

  bool get loading => _loading;                          // Getter público que retorna o estado de loading
  String? get error => _error;                           // Getter público que retorna a mensagem de erro (ou null)

  StreamSubscription<QuerySnapshot>? _productsSub;       // Variável que guarda a inscrição (subscription) do stream do Firestore

  ProductManager() {                                     // Construtor da classe
    _listenToProducts();                                 // Chama o método que inicia a escuta em tempo real dos produtos
  }

  List<Product> _allProducts = [];                       // Lista privada que armazena todos os produtos carregados do Firestore
  List<Product> get allProducts => List<Product>.unmodifiable(_allProducts); // Getter público que retorna uma cópia imutável da lista

  String _search = '';                                   // String privada que guarda o texto de pesquisa atual
  String get search => _search;                          // Getter público para obter o texto de busca atual

  set search(String value) {                             // Setter público para alterar o texto de busca
    _search = value;                                     // Atualiza o valor interno
    notifyListeners();                                   // Notifica os listeners (widgets) que o estado mudou
  }

  List<Product> get filteredProducts {                   // Getter que retorna a lista filtrada com base na pesquisa
    final String s = _search.trim().toLowerCase();       // Pega o texto de busca, remove espaços e converte para minúsculo
    if (s.isEmpty) return allProducts;                   // Se não houver texto de busca, retorna todos os produtos

    return List<Product>.unmodifiable(                   // Retorna uma lista imutável com os produtos filtrados
      _allProducts.where((p) => p.name.toLowerCase().contains(s)), // Filtra produtos cujo nome contém o texto buscado (case insensitive)
    );
  }

  void _setLoading(bool v) {                             // Método privado para atualizar o estado de loading
    _loading = v;                                        // Altera o valor da variável _loading
    notifyListeners();                                   // Notifica a UI que o estado mudou
  }

  void _setError(String? msg) {                          // Método privado para definir/atualizar a mensagem de erro
    _error = msg;                                        // Define a mensagem de erro (pode ser null)
    notifyListeners();                                   // Notifica os listeners da mudança
  }

  void _listenToProducts() {                             // Método privado que configura o listener em tempo real
    _setLoading(true);                                   // Marca o estado como "carregando"
    _setError(null);                                     // Limpa qualquer erro anterior

    _productsSub?.cancel();                              // Cancela qualquer subscription anterior (evita múltiplos listeners)
    _productsSub = firestore.collection(productsCollection).snapshots().listen( // Inicia a escuta da coleção inteira em tempo real
      (snapshot) {                                       // Callback chamado sempre que há atualização nos dados
        // Converte cada documento do snapshot em um objeto Product
        _allProducts = snapshot.docs.map((d) => Product.fromDocument(d)).toList();

        // Log de debug para verificar quantos documentos foram carregados
        debugPrint('[ProductManager] coleção="$productsCollection" docs=${snapshot.docs.length}');
        for (final p in _allProducts) {                  // Percorre a lista de produtos para log
          debugPrint('[ProductManager] Produto: ${p.id} ${p.name}'); // Mostra id e nome de cada produto no console
        }

        _setLoading(false);                              // Finaliza o estado de carregamento
      },
      onError: (Object e, StackTrace st) {               // Callback chamado quando ocorre erro na escuta
        debugPrint('[ProductManager] ERRO ao ler coleção="$productsCollection": $e'); // Mostra o erro no console
        debugPrintStack(stackTrace: st);                 // Mostra o stack trace completo do erro

        if (e is FirebaseException) {                    // Verifica se o erro é do tipo FirebaseException
          if (e.code == 'permission-denied') {           // Caso específico: falta de permissão no Firestore
            _allProducts = [];                           // Limpa a lista de produtos
            _setError(                                   // Define mensagem de erro amigável
              'permission-denied: sem permissão para ler "$productsCollection". '
              'Ajuste as Rules do Firestore e publique.',
            );
            _productsSub?.cancel();                      // Cancela a subscription para não ficar disparando erros
            _productsSub = null;                         // Limpa a referência da subscription
          } else {
            _setError('${e.code}: ${e.message ?? 'erro no Firebase'}'); // Outros erros do Firebase
          }
        } else {
          _setError('Erro ao carregar produtos: $e');   // Erro genérico não identificado
        }
        _setLoading(false);                              // Finaliza o loading mesmo em caso de erro
      },
    );
  }

  void retry() {                                         // Método público para tentar recarregar os dados manualmente
    _listenToProducts();                                 // Chama novamente o método de escuta
  }

  @override
  void dispose() {                                       // Sobrescreve o método dispose (chamado quando o objeto é descartado)
    _productsSub?.cancel();                              // Cancela a subscription do Firestore para evitar memory leak
    super.dispose();                                     // Chama o dispose da classe pai (ChangeNotifier)
  }
}