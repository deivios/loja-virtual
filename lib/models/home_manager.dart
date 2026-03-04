import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lojavirtual/models/section.dart';

class HomeManager {
  HomeManager() {
    _loadSections(); // chama o método ao criar o HomeManager
  }

  List<Section> sections = []; // lista de seções carregadas da coleção 'home'

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance; // instância do Firestore

  Future<void> _loadSections() async {
    firestore.collection('home').snapshots().listen((snapshot) {
      // escuta a coleção 'home' em tempo real
      sections
          .clear(); // limpa a lista antes de preencher (evita duplicatas em atualizações)
      for (final DocumentSnapshot document in snapshot.docs) {
        // percorre cada documento retornado
        sections.add(
          Section.fromDocument(document),
        ); // converte o documento em Section e adiciona à lista
      }
    });
  }
}
