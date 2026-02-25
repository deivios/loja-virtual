import 'package:cloud_firestore/cloud_firestore.dart'; // Pacote Firestore para acessar coleção do carrinho
import 'package:flutter/foundation.dart'; // ChangeNotifier para notificar mudanças na UI
import 'package:lojavirtual/models/cart_product.dart'; // Modelo CartProduct (produto no carrinho)
import 'package:lojavirtual/models/product.dart'; // Modelo Product (produto com tamanhos, preços)
import 'package:lojavirtual/models/user.dart'; // Modelo User (dados do usuário)
import 'package:lojavirtual/models/user_manager.dart'; // Gerenciador de usuário (login, logout)

class CartManager extends ChangeNotifier {
  // Gerenciador do carrinho de compras

  final FirebaseFirestore _firestoreRef =
      FirebaseFirestore.instance; // Instância do Firestore

  CollectionReference get cartReference => _firestoreRef.collection(
    'cart',
  ); // Referência à coleção 'cart' (top-level)

  CollectionReference
  get _userCartReference => // Referência ao carrinho do usuário logado (users/{userId}/cart)
      _firestoreRef.collection('users').doc(user!.id).collection('cart');

  List<CartProduct> items =
      []; // Lista de itens no carrinho (produto + quantidade + tamanho)
  User? user; // Usuário atual logado (null se não estiver logado)
  UserManager?
  _userManager; // Referência ao UserManager (injetada pelo ProxyProvider)
  int _loadVersion =
      0; // Evita que _loadCartItems sobrescreva itens adicionados localmente

  void addToCart(Product product) {
    // Adiciona um produto ao carrinho
    items.add(
      CartProduct.fromProduct(product),
    ); // Cria CartProduct a partir do Product e adiciona na lista
    user =
        _userManager?.user; // Atualiza referência ao usuário atual (se logado)
    _loadVersion++; // Incrementa para evitar que _loadCartItems sobrescreva
    notifyListeners(); // Notifica a UI da mudança
  }

  void updateUser(UserManager userManager) {
    // Chamado pelo ProxyProvider quando UserManager muda
    final previousUserId =
        user?.id; // Guarda o ID do usuário anterior para detectar troca
    _userManager = userManager; // Armazena referência ao UserManager
    user = userManager
        .user; // Atualiza o usuário atual (pode ser null ao deslogar)

    if (user?.id != previousUserId) {
      // Só limpa e recarrega quando o usuário muda (login/logout/troca)
      items.clear(); // Limpa o carrinho ao trocar de usuário
      if (user != null) {
        _loadCartItems(); // Carrega itens do Firestore (assíncrono)
      } else {
        notifyListeners(); // Notifica quando desloga (items já está vazio)
      }
    }
  }

  Future<void> _loadCartItems() async {
    // Carrega itens do carrinho do Firestore
    if (user == null) return;
    final loadVersion =
        ++_loadVersion; // Marca esta carga para evitar sobrescrever itens adicionados depois
    try {
      final QuerySnapshot cartSnap = await _userCartReference
          .get(); // Busca documentos da coleção cart do usuário
      final List<CartProduct> loadedItems = [];
      for (final doc in cartSnap.docs) {
        // Para cada documento do carrinho
        final data = doc.data() as Map<String, dynamic>? ?? {};
        final productId =
            data['productId'] as String? ??
            doc.id; // ID do produto (campo productId ou id do doc)
        final productDoc = await _firestoreRef
            .collection('products')
            .doc(productId)
            .get(); // Busca o Product
        if (productDoc.exists) {
          final product = Product.fromDocument(
            productDoc,
          ); // Cria Product a partir do documento
          loadedItems.add(
            CartProduct.fromDocument(doc, product),
          ); // Cria CartProduct e adiciona na lista
        }
      }
      if (loadVersion == _loadVersion) {
        // Só sobrescreve se não houve addToCart durante o carregamento
        items = loadedItems; // Atualiza a lista de itens
        notifyListeners(); // Notifica a UI para reconstruir
      }
    } on FirebaseException catch (e) {
      // Trata erro de permissão ou conexão do Firestore
      if (e.code == 'permission-denied') {
        // Se não tem permissão, mantém items em memória (não sobrescreve)
        debugPrint(
          '[CartManager] permission-denied ao carregar carrinho: ${e.message}',
        );
      } else {
        debugPrint(
          '[CartManager] Erro ao carregar carrinho: ${e.code} - ${e.message}',
        );
      }
      if (loadVersion == _loadVersion) {
        notifyListeners(); // Notifica para atualizar UI (items pode estar vazio)
      }
    }
  }
}
