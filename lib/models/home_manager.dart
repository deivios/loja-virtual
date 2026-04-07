import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:lojavirtual/models/section.dart';

class HomeManager extends ChangeNotifier {
  HomeManager() {
    _listenToSections();
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final List<Section> _sections = [];
  StreamSubscription<QuerySnapshot>? _subscription;
  bool _loading = false;
  String? _error;

  List<Section> get sections => List.unmodifiable(_sections);
  bool get loading => _loading;
  String? get error => _error;

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  void _listenToSections() {
    _setLoading(true);
    _setError(null);
    _subscription?.cancel();

    _subscription = firestore.collection('home').snapshots().listen(
      (snapshot) {
        _sections
          ..clear()
          ..addAll(snapshot.docs.map((doc) => Section.fromDocument(doc)));
        _setLoading(false);
      },
      onError: (e) {
        _sections.clear();
        _setError('Erro ao carregar home: $e');
        _setLoading(false);
      },
    );
  }

  void retry() => _listenToSections();

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
