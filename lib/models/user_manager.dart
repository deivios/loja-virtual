import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:lojavirtual/models/user.dart' as model;
import 'package:lojavirtual/helpers/firebase_erros.dart';

class UserManager {
  final auth.FirebaseAuth firebaseAuth = auth.FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  model.User? user;
  bool loading = false;
  bool get isLoading => loading;
  bool get isLoggedIn => user != null;

  Future<void> signOut() async {
    await firebaseAuth.signOut();
    user = null;
  }

  Future<String?> signIn(model.User user) async {
    loading = true;
    try {
      final result = await firebaseAuth.signInWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );
      await _loadCurrentUser(firebaseUser: result.user);
      if (this.user == null && result.user != null) {
        this.user = model.User(
          id: result.user!.uid,
          email: result.user!.email ?? user.email,
          name: '',
          password: '',
          confirmPassword: '',
        );
      }
      return null;
    } on auth.FirebaseAuthException catch (e) {
      return getErrorString(e.code);
    } catch (e) {
      return 'Um erro inesperado ocorreu. Tente novamente.';
    } finally {
      loading = false;
    }
  }

  Future<String?> signUp(model.User user) async {
    loading = true;
    try {
      final result = await firebaseAuth.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );
      if (result.user != null) {
        await result.user!.updateDisplayName(user.name);
        await result.user!.reload();
      }
      user.id = result.user!.uid;
      await user.saveData();
      this.user = user;
      return null;
    } on auth.FirebaseAuthException catch (e) {
      return getErrorString(e.code);
    } catch (e) {
      return 'Um erro inesperado ocorreu. Tente novamente.';
    } finally {
      loading = false;
    }
  }

  Future<void> _loadCurrentUser({auth.User? firebaseUser}) async {
    final currentUser = firebaseUser ?? firebaseAuth.currentUser;
    if (currentUser == null) return;

    final docUser = await firestore.collection('users').doc(currentUser.uid).get();

    if (docUser.exists) {
      user = model.User.fromDocument(docUser);
      if (user!.name.trim().isEmpty) {
        final authName = (currentUser.displayName ?? '').trim();
        final emailPrefix = (currentUser.email ?? '').split('@').first.trim();
        user!.name = authName.isNotEmpty ? authName : emailPrefix;
        if (user!.name.isNotEmpty) {
          await firestore.collection('users').doc(currentUser.uid).set(
            {'name': user!.name, 'email': currentUser.email ?? user!.email},
            SetOptions(merge: true),
          );
        }
      }
    } else {
      final authName = (currentUser.displayName ?? '').trim();
      final emailPrefix = (currentUser.email ?? '').split('@').first.trim();
      final fallbackName = authName.isNotEmpty ? authName : emailPrefix;
      user = model.User(
        id: currentUser.uid,
        email: currentUser.email ?? '',
        name: fallbackName,
        password: '',
        confirmPassword: '',
      );
      await firestore.collection('users').doc(currentUser.uid).set(
        {'name': user!.name, 'email': user!.email},
        SetOptions(merge: true),
      );
    }
  }
}
