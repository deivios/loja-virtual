// Traduz códigos de erro do Firebase Auth para mensagens em português (exibe na tela de login/cadastro)

String getErrorString(String code) {                      // Traduz códigos de erro do Firebase para mensagens em PT-BR
  switch (code) {
    case 'invalid-credential':
      return 'E-mail ou senha incorretos.';
    
    case 'user-not-found':
      return 'Não há usuário cadastrado com este e-mail.';
    
    case 'wrong-password':
      return 'Sua senha está incorreta.';
    
    case 'invalid-email':
      return 'O e-mail informado é inválido.';
    
    case 'weak-password':
      return 'Sua senha é muito fraca.';
    
    case 'email-already-in-use':
      return 'Este e-mail já está sendo usado por outra conta.';
    
    case 'user-disabled':
      return 'Esta conta foi desabilitada.';
    
    case 'too-many-requests':
      return 'Muitas tentativas. Tente novamente mais tarde.';
    
    case 'operation-not-allowed':
      return 'Login com e-mail e senha está desabilitado.';
    
    case 'network-request-failed':
      return 'Sem conexão com a internet. Verifique sua rede.';
    
    default:
      return 'Ocorreu um erro ao fazer login. Tente novamente.';  // Mensagem padrão para erros desconhecidos
  }
}