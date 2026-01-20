import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;  // Importa o Firebase Auth (com prefixo para evitar conflito)
import 'package:lojavirtual/models/user.dart' as model;     // Importa o modelo User (renomeado para evitar conflito)
import 'package:lojavirtual/helpers/firebase_erros.dart';   // Importa função que traduz erros do Firebase para PT-BR

class UserManager {
  final auth.FirebaseAuth firebaseAuth = auth.FirebaseAuth.instance;  // Instância única do Firebase Auth (usada em todo o app)
  final FirebaseFirestore firestore = FirebaseFirestore.instance; // Instância do Firestore para acessar banco de dados

  model.User? user;                                         // Usuário atual logado (carregado do Firestore)
  bool loading = false;                                     // Controla estado de carregamento (spinner, botão desabilitado)
  bool get isLoading => loading;                            // Getter para acessar o loading de forma limpa (ex: na tela)

  bool get isLoggedIn => user != null;

  Future<void> signOut() async {
    await firebaseAuth.signOut();
    user = null;
  }

  // Método de login com email/senha
  Future<String?> signIn(model.User user) async {           // Retorna null se sucesso ou mensagem de erro em PT-BR
    loading = true;                                         // Ativa o loading
    try {
      final auth.UserCredential result = await firebaseAuth.signInWithEmailAndPassword(  // Tenta fazer login no Firebase Auth
        email: user.email,
        password: user.password,
      );

      // No login, NÃO salva dados no Firestore (senão você pode sobrescrever nome/email com vazio).
      // Em vez disso, carregamos o perfil existente em users/{uid}.
      await _loadCurrentUser(firebaseUser: result.user);
      if (this.user == null && result.user != null) {
        // Se ainda não existe documento no Firestore, cria um objeto mínimo em memória.
        this.user = model.User(
          id: result.user!.uid,
          email: result.user!.email ?? user.email,
          name: '',
          password: '',
          confirmPassword: '',
        );
      }

      print('Login bem-sucedido! UID: ${result.user?.uid}'); // Log de sucesso no console (debug)
      return null;                                          // Retorna null = login OK

    } on auth.FirebaseAuthException catch (e) {                  // Captura erros específicos do Firebase Auth
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
      loading = false;                                      // Desativa o loading
    }
  }

  // Método de cadastro (signUp)
  Future<String?> signUp(model.User user) async {           // Retorna null se sucesso ou mensagem de erro em PT-BR
    loading = true;                                         // Ativa o loading
    try {
      final auth.UserCredential result = await firebaseAuth.createUserWithEmailAndPassword(  // Cria usuário no Firebase Auth
        email: user.email,
        password: user.password,
      );

      // Salva o nome também no Firebase Auth (serve como fallback se faltar no Firestore)
      if (result.user != null) {
        await result.user!.updateDisplayName(user.name);
        await result.user!.reload();
      }

      user.id = result.user!.uid;                           // Salva o UID gerado no modelo User
      await user.saveData();                                // Salva dados extras no Firestore (nome, email, etc.)
      this.user = user;

      print('Cadastro bem-sucedido! UID: ${result.user?.uid}'); // Log de sucesso
      return null;                                          // Sucesso

    } on auth.FirebaseAuthException catch (e) {                  // Erros específicos do Firebase (ex: email já existe)
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

  // Método que carrega os dados do usuário atual do Firestore
  Future<void> _loadCurrentUser({auth.User? firebaseUser}) async {
    // Pega o usuário do parâmetro ou o usuário logado atual (versão atual: propriedade, não método)
    final auth.User? currentUser = firebaseUser ?? firebaseAuth.currentUser;
    
    if (currentUser != null) {                              // Se há um usuário logado
      final DocumentSnapshot docUser = await firestore     // Busca o documento do usuário no Firestore
          .collection('users')                               // Coleção 'users'
          .doc(currentUser.uid)                              // Documento com ID = UID do usuário logado (versão atual: .doc() ao invés de .document())
          .get();                                            // Busca o documento
          

      if (docUser.exists) {                                  // Se o documento existe
        user = model.User.fromDocument(docUser);            // Cria objeto User usando factory constructor (versão atual)
        // Se o nome vier vazio do Firestore, usa fallback do Auth/email
        if (user!.name.trim().isEmpty) {
          final authName = (currentUser.displayName ?? '').trim();
          final emailPrefix = (currentUser.email ?? '').split('@').first.trim();
          user!.name = authName.isNotEmpty ? authName : emailPrefix;

          // (Opcional) Atualiza o Firestore para não ficar vazio
          if (user!.name.isNotEmpty) {
            await firestore.collection('users').doc(currentUser.uid).set(
              {
                'name': user!.name,
                'email': currentUser.email ?? user!.email,
              },
              SetOptions(merge: true),
            );
          }
        }
        print('Dados do usuário carregados:');
        print('   Nome: ${user?.name}');
        print('   Email: ${user?.email}');
      } else {
        // Se não existe documento, cria um usuário em memória (e opcionalmente cria no Firestore)
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

        // Cria o documento no Firestore (sem senha)
        await firestore.collection('users').doc(currentUser.uid).set(
          {
            'name': user!.name,
            'email': user!.email,
          },
          SetOptions(merge: true),
        );
      }
    }
  }
}