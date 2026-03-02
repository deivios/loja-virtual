// ========== CART_MANAGER.DART - Gerenciador do carrinho ==========
import 'package:cloud_firestore/cloud_firestore.dart'; // importa FirebaseFirestore e tipos como QuerySnapshot
import 'package:flutter/foundation.dart'; // importa ChangeNotifier e debugPrint
import 'package:lojavirtual/models/cart_product.dart'; // importa modelo CartProduct
import 'package:lojavirtual/models/product.dart'; // importa modelo Product
import 'package:lojavirtual/models/user.dart'; // importa modelo User (contém cartReference)
import 'package:lojavirtual/models/user_manager.dart'; // importa UserManager para observar login

class CartManager extends ChangeNotifier {
  // gerenciador do carrinho que notifica a UI
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // instância singleton do Firestore
  List<CartProduct> items =
      []; // lista atual de itens do carrinho (fonte da UI)
  User? user; // referência ao usuário logado (null = deslogado)
  UserManager? _userManager; // referência ao gerenciador de usuário
  num get productsPrice => items.fold(
    0.0,
    (sum, cp) => sum + cp.totalPrice,
  ); // preço total do carrinho
  int _loadVersion = 0; // contador para evitar race condition load × add

  Future<void> addToCart(Product product) async {
    // adiciona produto ao carrinho (principal método)
    final cartProduct = CartProduct.fromProduct(
      product,
    ); // cria objeto CartProduct a partir do Product
    user = _userManager?.user; // atualiza referência ao usuário atual

    if (user == null) {
      // usuário não está logado
      items.add(cartProduct); // adiciona apenas localmente
      _bindCallbacks(cartProduct); // vincula métodos increment/decrement/remove
      _loadVersion++; // incrementa versão de controle
      notifyListeners(); // avisa listeners (atualiza UI)
      return; // encerra execução (não salva no Firestore)
    }

    try {
      final query = await user!
          .cartReference // consulta subcoleção cart por produto
          .where('pid', isEqualTo: cartProduct.productId)
          .get();

      QueryDocumentSnapshot?
      existingDoc; // vai armazenar documento já existente (mesmo tamanho)

      for (final doc in query.docs) {
        // percorre documentos encontrados
        final data =
            doc.data() as Map<String, dynamic>? ??
            {}; // obtém dados do documento
        if ((data['size'] ?? '') == cartProduct.size) {
          // mesmo produto e mesmo tamanho?
          existingDoc = doc; // guarda referência ao doc existente
          break; // sai do loop (encontrou)
        }
      }

      if (existingDoc != null) {
        // item já existe no carrinho
        final data = existingDoc.data() as Map<String, dynamic>? ?? {};
        final currentQty =
            (data['quantity'] ?? 1) as int; // quantidade atual no Firestore
        await existingDoc.reference.update({
          'quantity': currentQty + 1,
        }); // incrementa no Firestore

        final idx = items.indexWhere(
          (i) => i.stackable(product),
        ); // procura item correspondente na lista local
        if (idx >= 0) {
          items[idx].quantity++; // incrementa localmente
          items[idx].firestoreDocId ??= existingDoc.id; // garante id do doc
          _bindCallbacks(items[idx]); // garante callbacks vinculados
        } else {
          cartProduct.quantity =
              currentQty + 1; // corrige quantidade (caso inconsistência)
          cartProduct.firestoreDocId = existingDoc.id;
          items.add(cartProduct); // adiciona na lista local
          _bindCallbacks(cartProduct);
        }
      } else {
        // item novo
        final docRef = await user!.cartReference.add(
          cartProduct.toCartItemMap(),
        ); // cria novo documento no Firestore
        cartProduct.firestoreDocId = docRef.id; // armazena id do doc
        items.add(cartProduct); // adiciona na lista local
        _bindCallbacks(cartProduct); // vincula callbacks
      }

      _loadVersion++; // marca que houve alteração
      notifyListeners(); // atualiza interface
    } on FirebaseException catch (e) {
      debugPrint(
        '[CartManager] Erro Firestore: ${e.code} - ${e.message}',
      ); // loga erro do Firestore
      items.add(cartProduct); // fallback: adiciona localmente
      _bindCallbacks(cartProduct);
      _loadVersion++;
      notifyListeners();
    } catch (e, st) {
      debugPrint('[CartManager] Erro: $e'); // loga erro genérico
      debugPrint('$st'); // imprime stack trace
      items.add(cartProduct); // fallback
      _bindCallbacks(cartProduct);
      _loadVersion++;
      notifyListeners();
    }
  }

  void increment(CartProduct cartProduct) {
    final idx = items.indexWhere(
      (i) => i.productId == cartProduct.productId && i.size == cartProduct.size,
    );
    if (idx < 0) return;
    items[idx].quantity++;
    _onItemUpdated();
    notifyListeners();
  }

  void decrement(CartProduct cartProduct) {
    final idx = items.indexWhere(
      (i) => i.productId == cartProduct.productId && i.size == cartProduct.size,
    );
    if (idx < 0) return;
    items[idx].quantity--;
    _onItemUpdated();
    notifyListeners();
  }

  void _onItemUpdated() {
    // Remove itens com qtd 0 e sincroniza o restante com o Firestore
    for (final cp in List.from(items)) {
      if (cp.quantity == 0) {
        removeOfCart(cp);
        continue;
      }
      _updateCartProduct(cp);
    }
    // productsPrice é getter calculado (items.fold)
  }

  void _updateCartProduct(CartProduct cartProduct) {
    if (user == null) return;
    try {
      if (cartProduct.firestoreDocId != null) {
        user!.cartReference
            .doc(cartProduct.firestoreDocId)
            .update(cartProduct.toCartItemMap());
      } else {
        _updateQuantityFirestore(cartProduct, cartProduct.quantity);
      }
    } on FirebaseException catch (e) {
      debugPrint('[CartManager] Erro ao atualizar: ${e.code} - ${e.message}');
    }
  }

  bool get isCartValid {
    for (final cartProduct in items) {
      if (!cartProduct.hasStock) return false;
    }
    return true;
  }

  void removeOfCart(CartProduct cartProduct) {
    // remove item da lista local e do Firestore
    items.removeWhere(
      (p) => p.productId == cartProduct.productId && p.size == cartProduct.size,
    );
    _removeFromFirestore(cartProduct);
    notifyListeners();
  }

  void removeItem(CartProduct cartProduct) {
    // alias para removeOfCart (usado nos callbacks)
    removeOfCart(cartProduct);
  }

  Future<void> _updateQuantityFirestore(
    CartProduct cartProduct,
    int newQuantity,
  ) async {
    if (user == null) return; // sem usuário logado → ignora
    try {
      final query = await user!.cartReference
          .where('pid', isEqualTo: cartProduct.productId)
          .get();
      for (final doc in query.docs) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        if ((data['size'] ?? '') == cartProduct.size) {
          // encontrou documento correto
          await doc.reference.update({
            'quantity': newQuantity,
          }); // atualiza apenas quantidade
          return;
        }
      }
    } on FirebaseException catch (e) {
      debugPrint(
        '[CartManager] Erro ao atualizar: ${e.code} - ${e.message}',
      ); // loga erro
    }
  }

  Future<void> _removeFromFirestore(CartProduct cartProduct) async {
    if (user == null) return;
    try {
      if (cartProduct.firestoreDocId != null) {
        await user!.cartReference.doc(cartProduct.firestoreDocId).delete();
        return;
      }
      final query = await user!.cartReference
          .where('pid', isEqualTo: cartProduct.productId)
          .get();
      for (final doc in query.docs) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        if ((data['size'] ?? '') == cartProduct.size) {
          await doc.reference.delete();
          return;
        }
      }
    } on FirebaseException catch (e) {
      debugPrint('[CartManager] Erro ao remover: ${e.code} - ${e.message}');
    }
  }

  void _bindCallbacks(CartProduct cp) {
    // vincula callbacks ao CartProduct
    cp.setCallbacks(
      onIncrement: () => increment(cp), // callback de incremento
      onDecrement: () => decrement(cp), // callback de decremento
      onRemove: () => removeItem(cp), // callback de remoção
    );
  }

  void updateUser(UserManager userManager) {
    // chamado quando login/logout ocorre
    _userManager = userManager; // guarda referência ao UserManager
    user = userManager.user; // atualiza usuário atual
    items.clear(); // limpa carrinho atual
    if (user != null) {
      _loadCartItems(); // carrega carrinho do Firestore
    } else {
      notifyListeners(); // carrinho vazio → atualiza UI
    }
  }

  Future<void> _loadCartItems() async {
    // carrega itens salvos no Firestore
    if (user == null) return;
    final loadVersion = ++_loadVersion; // marca versão desta carga
    try {
      final cartSnap = await user!.cartReference
          .get(); // busca todos itens da subcoleção cart
      final loadedItems =
          <CartProduct>[]; // lista temporária de itens carregados

      for (final doc in cartSnap.docs) {
        // para cada documento do carrinho
        final data = doc.data() as Map<String, dynamic>? ?? {};
        final productId =
            (data['productId'] ?? data['pid']) as String? ??
            doc.id; // obtém id do produto
        final productDoc = await _firestore
            .collection('products')
            .doc(productId)
            .get(); // busca dados do produto
        if (productDoc.exists) {
          // produto ainda existe?
          final product = Product.fromDocument(
            productDoc,
          ); // converte para objeto Product
          loadedItems.add(
            CartProduct.fromDocument(doc, product),
          ); // cria CartProduct completo
        }
      }

      if (loadVersion == _loadVersion) {
        // nenhuma alteração concorrente ocorreu
        items = loadedItems; // substitui lista atual
        for (final cp in items)
          _bindCallbacks(cp); // vincula callbacks em todos itens
        notifyListeners(); // atualiza interface
      }
    } on FirebaseException catch (e) {
      debugPrint('[CartManager] Erro ao carregar: ${e.code} - ${e.message}');
      if (loadVersion == _loadVersion)
        notifyListeners(); // notifica mesmo com erro
    }
  }
}
