import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String id;
  String confirmPassword;
  String name;
  String email;
  String password;

  User({
    required this.id,
    required this.email,
    required this.password,
    required this.name,
    required this.confirmPassword,
  });

  factory User.fromDocument(DocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>?;
    return User(
      id: document.id,
      name: data?['name'] as String? ?? '',
      email: data?['email'] as String? ?? '',
      password: '',
      confirmPassword: '',
    );
  }

  CollectionReference get cartReference =>
      FirebaseFirestore.instance.collection('users').doc(id).collection('cart');

  Future<void> saveData() async {
    await FirebaseFirestore.instance.collection('users').doc(id).set({
      'name': name,
      'email': email,
    });
  }
}
