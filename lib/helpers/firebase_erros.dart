// ========== FIREBASE_ERROS.DART - Traduz erros do Firebase Auth ==========
// Código em inglês -> mensagem em português para SnackBar.

String getErrorString(String code) { // code: código do FirebaseAuthException (ex: wrong-password)
  switch (code) {
    case 'invalid-credential':
      return 'E-mail ou senha incorretos.'; // Firebase unifica wrong-password e user-not-found
    case 'user-not-found':
      return 'Não há usuário cadastrado com este e-mail.'; // E-mail não existe no Auth
    case 'wrong-password':
      return 'Sua senha está incorreta.'; // Senha errada
    case 'invalid-email':
      return 'O e-mail informado é inválido.'; // Formato de e-mail inválido
    case 'weak-password':
      return 'Sua senha é muito fraca.'; // Senha com menos de 6 caracteres
    case 'email-already-in-use':
      return 'Este e-mail já está sendo usado por outra conta.'; // Cadastro com e-mail existente
    case 'user-disabled':
      return 'Esta conta foi desabilitada.'; // Conta bloqueada no Firebase
    case 'too-many-requests':
      return 'Muitas tentativas. Tente novamente mais tarde.'; // Rate limit excedido
    case 'operation-not-allowed':
      return 'Login com e-mail e senha está desabilitado.'; // Método desativado no console Firebase
    case 'network-request-failed':
      return 'Sem conexão com a internet. Verifique sua rede.'; // Sem internet
    default:
      return 'Ocorreu um erro ao fazer login. Tente novamente.'; // Código não mapeado
  }
}
