// ========== VALIDATORS.DART - Funções de validação ==========
// Usadas nos TextFormField. validator retorna null se válido, string se inválido.

bool emailValid(String email) {
  // email: string a validar
  if (email.isEmpty) return false; // String vazia = inválido
  const pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$'; // Regex: parte antes do @ + @ + domínio.ext (ex: user@domain.com)
  return RegExp(pattern).hasMatch(
    email.trim(),
  ); // trim remove espaços; hasMatch retorna true se válido
}
