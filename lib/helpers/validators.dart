bool emailValid(String email) {                            // Valida se o email tem formato válido
  if (email.isEmpty) return false;                        // String vazia retorna false
  const pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  final regExp = RegExp(pattern);                         // Regex para validar formato de email
  return regExp.hasMatch(email.trim());                   // Retorna true se o email corresponder ao padrão
}