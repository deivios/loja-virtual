import 'package:cloud_firestore/cloud_firestore.dart';   // Pacote do Firestore para acessar o banco de dados
import 'package:flutter/material.dart';                   // Necessário para ChangeNotifier e debugPrint
import 'package:lojavirtual/models/product.dart';        // Importa o modelo Product (com factory fromDocument)
import 'dart:async';                                      // Necessário para StreamSubscription

class ProductManager extends ChangeNotifier {            // Gerenciador de produtos com ChangeNotifier para atualizar a UI automaticamente

  final FirebaseFirestore firestore = FirebaseFirestore.instance; // Instância singleton do Firestore

  // Nome da coleção no Firestore (pode mudar se for 'produtos' ou outro)
  static const String productsCollection = 'products';

  bool _loading = false;                                 // Flag de carregamento (true enquanto espera dados)
  String? _error;                                        // Mensagem de erro (null = sem erro)

  bool get loading => _loading;                          // Getter público para o estado de loading
  String? get error => _error;                           // Getter público para o erro

  StreamSubscription<QuerySnapshot>? _productsSub;       // Subscription para o stream de snapshots (permite cancelar depois)

  ProductManager() {                                     // Construtor: inicia a escuta em tempo real
    _listenToProducts();                                 // Chama o método que configura o listener
  }

  List<Product> _allProducts = [];                       // Lista interna de produtos (privada)
  List<Product> get allProducts => List<Product>.unmodifiable(_allProducts); // Getter público: retorna cópia imutável para segurança

  void _setLoading(bool v) {                             // Atualiza o estado de loading e notifica a UI
    _loading = v;
    notifyListeners();                                   // Rebuild em todos os Consumers/Listeners
  }

  void _setError(String? msg) {                          // Atualiza a mensagem de erro e notifica a UI
    _error = msg;
    notifyListeners();
  }

  void _listenToProducts() {                             // Configura listener em tempo real na coleção
    _setLoading(true);                                   // Marca como carregando
    _setError(null);                                     // Limpa erro anterior

    _productsSub?.cancel();                              // Cancela subscription anterior (evita múltiplos listeners)
    _productsSub = firestore.collection(productsCollection).snapshots().listen( // Escuta mudanças na coleção inteira
      (snapshot) {                                       // Callback chamado quando há dados ou atualização
        // Converte cada documento em um objeto Product usando factory fromDocument
        _allProducts = snapshot.docs.map((d) => Product.fromDocument(d)).toList();

        // Log de debug (visível no console do VS Code / devtools)
        debugPrint('[ProductManager] coleção="$productsCollection" docs=${snapshot.docs.length}');
        for (final p in _allProducts) {
          debugPrint('[ProductManager] Produto: ${p.id} ${p.name}');
        }

        _setLoading(false);                              // Finaliza loading
      },
      onError: (Object e, StackTrace st) {               // Callback de erro
        debugPrint('[ProductManager] ERRO ao ler coleção="$productsCollection": $e');
        debugPrintStack(stackTrace: st);                 // Mostra stack trace completo

        if (e is FirebaseException) {                    // Trata erros específicos do Firebase
          if (e.code == 'permission-denied') {           // Erro comum: regras de segurança negaram leitura
            _allProducts = [];                           // Limpa lista
            _setError(                                   // Mensagem amigável para o usuário
              'permission-denied: sem permissão para ler "$productsCollection". '
              'Ajuste as Rules do Firestore e publique.',
            );
            _productsSub?.cancel();                      // Cancela o listener para não ficar disparando erros
            _productsSub = null;
          } else {
            _setError('${e.code}: ${e.message ?? 'erro no Firebase'}');
          }
        } else {
          _setError('Erro ao carregar produtos: $e');    // Erro genérico
        }
        _setLoading(false);                              // Finaliza loading mesmo com erro
      },
    );
  }

  void retry() {                                         // Método público para tentar recarregar (ex: botão "Tentar novamente")
    _listenToProducts();
  }

  @override
  void dispose() {                                       // Método chamado quando o manager é destruído
    _productsSub?.cancel();                              // Cancela o listener para evitar memory leak
    super.dispose();                                     // Chama dispose do ChangeNotifier
  }
}