import 'package:firebase_auth/firebase_auth.dart';
import 'package:lojavirtual/models/user.dart' as model;
import 'package:lojavirtual/helpers/firebase_erros.dart';

class UserManager {
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool loading = false;
  bool get isLoading => loading;

  Future<String?> signIn(model.User user) async {
    loading = true;
    try {
      final UserCredential result = await auth.signInWithEmailAndPassword(
        email: user.email,
        password: user.password,
        
      );

      print('Login bem-sucedido! UID: ${result.user?.uid}');
      return null; // Sucesso

    } on FirebaseAuthException catch (e) {
      final String errorMessagePtBr = getErrorString(e.code);

      // Aqui é o que vai aparecer no console (debug)
      print('Erro no login:');
      print('   Código Firebase: ${e.code}');
      print('   Mensagem para o usuário: $errorMessagePtBr');
      if (e.message != null) {
        print('   Mensagem original Firebase: ${e.message}');
      }

      return errorMessagePtBr; // Retorna a versão em português para a tela
    } catch (e) {
      print('Erro inesperado durante o login: $e');
      return 'Um erro inesperado ocorreu. Tente novamente.';
    } finally {
      // Sempre executa (sucesso ou erro)
      loading = false;
    }
  }

  Future<String?> signUp(model.User user) async {
    loading = true;
    try {
      final UserCredential result = await auth.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
        
      );

     

      print('Cadastro bem-sucedido! UID: ${result.user?.uid}');
      return null; // Sucesso

    } on FirebaseAuthException catch (e) {
      final String errorMessagePtBr = getErrorString(e.code);

      // Aqui é o que vai aparecer no console (debug)
      print('Erro no cadastro:');
      print('   Código Firebase: ${e.code}');
      print('   Mensagem para o usuário: $errorMessagePtBr');
      if (e.message != null) {
        print('   Mensagem original Firebase: ${e.message}');
      }

      return errorMessagePtBr; // Retorna a versão em português para a tela
    } catch (e) {
      print('Erro inesperado durante o cadastro: $e');
      return 'Um erro inesperado ocorreu. Tente novamente.';
    } finally {
      // Sempre executa (sucesso ou erro)
      loading = false;
    }
  }
}
