import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:lojavirtual/models/cart_product.dart';
import 'package:lojavirtual/models/product.dart';
import 'package:lojavirtual/models/user.dart';
import 'package:lojavirtual/models/user_manager.dart';

class CartManager extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<CartProduct> items = [];
  User? user;
  UserManager? _userManager;
  int _loadVersion = 0;

  Future<void> addToCart(Product product) async {
    final cartProduct = CartProduct.fromProduct(product);
    user = _userManager?.user;

    if (user == null) {
      items.add(cartProduct);
      _loadVersion++;
      notifyListeners();
      return;
    }

    try {
      final query = await user!.cartReference.where('pid', isEqualTo: cartProduct.productId).get();
      QueryDocumentSnapshot? existingDoc;

      for (final doc in query.docs) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        if ((data['size'] ?? '') == cartProduct.size) {
          existingDoc = doc;
          break;
        }
      }

      if (existingDoc != null) {
        final data = existingDoc.data() as Map<String, dynamic>? ?? {};
        final currentQty = (data['quantity'] ?? 1) as int;
        await existingDoc.reference.update({'quantity': currentQty + 1});

        final idx = items.indexWhere((i) => i.stackable(product));
        if (idx >= 0) {
          items[idx].quantity++;
        } else {
          cartProduct.quantity = currentQty + 1;
          items.add(cartProduct);
        }
      } else {
        await user!.cartReference.add(cartProduct.toCartItemMap());
        items.add(cartProduct);
      }
      _loadVersion++;
      notifyListeners();
    } on FirebaseException catch (e) {
      debugPrint('[CartManager] Erro Firestore: ${e.code} - ${e.message}');
      items.add(cartProduct);
      _loadVersion++;
      notifyListeners();
    } catch (e, st) {
      debugPrint('[CartManager] Erro: $e');
      debugPrint('$st');
      items.add(cartProduct);
      _loadVersion++;
      notifyListeners();
    }
  }

  void updateUser(UserManager userManager) {
    _userManager = userManager;
    user = userManager.user;
    items.clear();
    if (user != null) {
      _loadCartItems();
    } else {
      notifyListeners();
    }
  }

  Future<void> _loadCartItems() async {
    if (user == null) return;
    final loadVersion = ++_loadVersion;

    try {
      final cartSnap = await user!.cartReference.get();
      final loadedItems = <CartProduct>[];

      for (final doc in cartSnap.docs) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        final productId = (data['productId'] ?? data['pid']) as String? ?? doc.id;

        final productDoc = await _firestore.collection('products').doc(productId).get();
        if (productDoc.exists) {
          final product = Product.fromDocument(productDoc);
          loadedItems.add(CartProduct.fromDocument(doc, product));
        }
      }

      if (loadVersion == _loadVersion) {
        items = loadedItems;
        notifyListeners();
      }
    } on FirebaseException catch (e) {
      debugPrint('[CartManager] Erro ao carregar: ${e.code} - ${e.message}');
      if (loadVersion == _loadVersion) notifyListeners();
    }
  }
}
