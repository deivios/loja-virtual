// ========== USER_MANAGER.DART - Gerenciador de autenticação ==========
// Login, cadastro, logout. Firebase Auth + Firestore (nome). Provider (não ChangeNotifier).

import 'package:cloud_firestore/cloud_firestore.dart'; // FirebaseFirestore, SetOptions
import 'package:firebase_auth/firebase_auth.dart' as auth; // auth. evita conflito com model.User
import 'package:flutter/foundation.dart';
import 'package:lojavirtual/models/user.dart' as model; // model.User
import 'package:lojavirtual/helpers/firebase_erros.dart'; // getErrorString - traduz erros para PT-BR

class UserManager extends ChangeNotifier {
  final auth.FirebaseAuth firebaseAuth = auth.FirebaseAuth.instance; // Singleton do Firebase Auth
  final FirebaseFirestore firestore = FirebaseFirestore.instance; // Singleton do Firestore

  model.User? user; // Usuário logado (null = deslogado)
  bool loading = false; // true durante login ou cadastro (mostra spinner)
  bool get isLoading => loading;
  bool get isLoggedIn => user != null; // true se há usuário logado

  UserManager() {
    _loadCurrentUser();
  }

  Future<void> signOut() async { // Faz logout
    await firebaseAuth.signOut(); // Desloga no Firebase Auth
    user = null; // Limpa referência em memória
    notifyListeners();
  }

  Future<String?> signIn(model.User user) async { // Login - retorna null se sucesso, mensagem de erro se falha
    loading = true;
    notifyListeners();
    try {
      final result = await firebaseAuth.signInWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );
      await _loadCurrentUser(firebaseUser: result.user); // Carrega dados do Firestore (nome, etc.)
      if (this.user == null && result.user != null) { // Documento não existe no Firestore (usuário antigo)
        this.user = model.User(
          id: result.user!.uid,
          email: result.user!.email ?? user.email,
          name: '',
          password: '',
          confirmPassword: '',
        ); // Cria User com dados do Auth
      }
      return null; // Sucesso
    } on auth.FirebaseAuthException catch (e) {
      return getErrorString(e.code); // Traduz código do erro para português
    } catch (e) {
      return 'Um erro inesperado ocorreu. Tente novamente.'; // Erro genérico (rede, etc.)
    } finally {
      loading = false; // Sempre desativa loading
      notifyListeners();
    }
  }

  Future<String?> signUp(model.User user) async { // Cadastro - retorna null se sucesso
    loading = true;
    notifyListeners();
    try {
      final result = await firebaseAuth.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      ); // Cria conta no Firebase Auth
      if (result.user != null) {
        await result.user!.updateDisplayName(user.name); // Salva nome no perfil do Auth
        await result.user!.reload(); // Recarrega dados atualizados
      }
      user.id = result.user!.uid; // Atualiza ID com UID gerado pelo Firebase
      await user.saveData(); // Salva nome e email no Firestore (coleção users)
      this.user = user;
      return null;
    } on auth.FirebaseAuthException catch (e) {
      return getErrorString(e.code);
    } catch (e) {
      return 'Um erro inesperado ocorreu. Tente novamente.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> _loadCurrentUser({auth.User? firebaseUser}) async { // Carrega User do Firestore
    final currentUser = firebaseUser ?? firebaseAuth.currentUser; // Parâmetro ou usuário atual
    if (currentUser == null) return; // Sem usuário = sai

    final docUser = await firestore.collection('users').doc(currentUser.uid).get(); // Busca doc users/{uid}

    if (docUser.exists) { // Documento existe (usuário já cadastrou antes)
      user = model.User.fromDocument(docUser);
      if (user!.name.trim().isEmpty) { // Nome veio vazio (dados antigos)
        final authName = (currentUser.displayName ?? '').trim();
        final emailPrefix = (currentUser.email ?? '').split('@').first.trim(); // joao@gmail.com -> joao
        user!.name = authName.isNotEmpty ? authName : emailPrefix; // Usa Auth ou parte do email
        if (user!.name.isNotEmpty) {
          await firestore.collection('users').doc(currentUser.uid).set(
            {'name': user!.name, 'email': currentUser.email ?? user!.email},
            SetOptions(merge: true), // merge: atualiza só esses campos, não apaga outros
          );
        }
      }
    } else { // Documento não existe (usuário novo ou migração)
      final authName = (currentUser.displayName ?? '').trim();
      final emailPrefix = (currentUser.email ?? '').split('@').first.trim();
      final fallbackName = authName.isNotEmpty ? authName : emailPrefix; // Nome do Auth ou prefixo do email
      user = model.User(
        id: currentUser.uid,
        email: currentUser.email ?? '',
        name: fallbackName,
        password: '',
        confirmPassword: '',
      );
      await firestore.collection('users').doc(currentUser.uid).set(
        {'name': user!.name, 'email': user!.email},
        SetOptions(merge: true), // Cria documento no Firestore
      );
    }
    notifyListeners();
  }
}
