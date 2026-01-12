import 'package:firebase_auth/firebase_auth.dart';           // Importa o Firebase Auth para login e cadastro
import 'package:lojavirtual/models/user.dart' as model;     // Importa o modelo User (renomeado para evitar conflito)
import 'package:lojavirtual/helpers/firebase_erros.dart';   // Importa função que traduz erros do Firebase para PT-BR

class UserManager {
  final FirebaseAuth auth = FirebaseAuth.instance;          // Instância única do Firebase Auth (usada em todo o app)
  bool loading = false;                                     // Controla estado de carregamento (spinner, botão desabilitado)
  bool get isLoading => loading;                            // Getter para acessar o loading de forma limpa (ex: na tela)

  // Método de login com email/senha
  Future<String?> signIn(model.User user) async {           // Retorna null se sucesso ou mensagem de erro em PT-BR
    loading = true;                                         // Ativa o loading (mostra spinner na tela)
    try {
      final UserCredential result = await auth.signInWithEmailAndPassword(  // Tenta fazer login no Firebase Auth
        email: user.email,
        password: user.password,
      );

      user.id = result.user!.uid;                           // Salva o UID do usuário logado no modelo User
      await user.saveData();                                // Salva dados extras no Firestore (chama método do model)

      print('Login bem-sucedido! UID: ${result.user?.uid}'); // Log de sucesso no console (debug)
      return null;                                          // Retorna null = login OK

    } on FirebaseAuthException catch (e) {                  // Captura erros específicos do Firebase Auth
      final String errorMessagePtBr = getErrorString(e.code); // Traduz código de erro para mensagem em português

      print('Erro no login:');                              // Log detalhado para debug
      print('   Código Firebase: ${e.code}');
      print('   Mensagem para o usuário: $errorMessagePtBr');
      if (e.message != null) {
        print('   Mensagem original Firebase: ${e.message}');
      }

      return errorMessagePtBr;                              // Retorna mensagem amigável para mostrar na tela
    } catch (e) {                                           // Captura qualquer outro erro inesperado
      print('Erro inesperado durante o login: $e');
      return 'Um erro inesperado ocorreu. Tente novamente.';
    } finally {                                             // Sempre executa, independente de sucesso ou erro
      loading = false;                                      // Desativa o loading (esconde spinner)
    }
  }

  // Método de cadastro (signUp)
  Future<String?> signUp(model.User user) async {           // Retorna null se sucesso ou mensagem de erro em PT-BR
    loading = true;                                         // Ativa o loading
    try {
      final UserCredential result = await auth.createUserWithEmailAndPassword(  // Cria usuário no Firebase Auth
        email: user.email,
        password: user.password,
      );

      user.id = result.user!.uid;                           // Salva o UID gerado no modelo User
      await user.saveData();                                // Salva dados extras no Firestore (nome, email, etc.)

      print('Cadastro bem-sucedido! UID: ${result.user?.uid}'); // Log de sucesso
      return null;                                          // Sucesso

    } on FirebaseAuthException catch (e) {                  // Erros específicos do Firebase (ex: email já existe)
      final String errorMessagePtBr = getErrorString(e.code);

      print('Erro no cadastro:');
      print('   Código Firebase: ${e.code}');
      print('   Mensagem para o usuário: $errorMessagePtBr');
      if (e.message != null) {
        print('   Mensagem original Firebase: ${e.message}');
      }

      return errorMessagePtBr;                              // Mensagem em PT-BR para a tela
    } catch (e) {                                           // Erro genérico
      print('Erro inesperado durante o cadastro: $e');
      return 'Um erro inesperado ocorreu. Tente novamente.';
    } finally {
      loading = false;                                      // Sempre desativa o loading
    }
  }
}