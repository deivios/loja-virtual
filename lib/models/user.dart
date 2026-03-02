// ========== USER.DART - Modelo de usuário ==========
// Representa usuário. Dados do Auth + Firestore. Senha NUNCA salva no Firestore.

import 'package:cloud_firestore/cloud_firestore.dart'; // DocumentSnapshot, CollectionReference

class User {
  String id; // UID do Firebase Auth (identificador único)
  String confirmPassword; // Usado só no cadastro para validar, não é salvo
  String name; // Nome completo (exibido no Drawer)
  String email; // E-mail para login
  String password; // Senha (só no login/cadastro, NUNCA no Firestore)

  User({
    required this.id,
    required this.email,
    required this.password,
    required this.name,
    required this.confirmPassword,
  }); // Construtor - required = parâmetro obrigatório

  factory User.fromDocument(DocumentSnapshot document) { // Cria User a partir do Firestore
    final data = document.data() as Map<String, dynamic>?; // Campos do documento
    return User(
      id: document.id, // ID do documento = UID do Auth
      name: data?['name'] as String? ?? '', // Pega name ou string vazia
      email: data?['email'] as String? ?? '',
      password: '', // Senha não fica no Firestore
      confirmPassword: '',
    );
  }

  CollectionReference get cartReference =>
      FirebaseFirestore.instance.collection('users').doc(id).collection('cart'); // Referência à subcoleção users/{id}/cart

  Future<void> saveData() async { // Salva ou atualiza nome e email no Firestore
    await FirebaseFirestore.instance.collection('users').doc(id).set({
      'name': name,
      'email': email,
    }); // set: cria ou substitui documento. Só name e email (nunca senha)
  }
}
