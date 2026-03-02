// ========== SIGNUP_SCREEN.DART - Tela de cadastro ==========
// Nome, email, senha, confirmação. onSaved preenche user. Valida senhas iguais.

import 'package:flutter/material.dart'; // Scaffold, Form, TextFormField, etc.
import 'package:lojavirtual/helpers/validators.dart'; // emailValid
import 'package:lojavirtual/models/user.dart' as model; // model.User
import 'package:lojavirtual/models/user_manager.dart'; // UserManager, signUp
import 'package:provider/provider.dart'; // context.read

class SigUpScreen extends StatefulWidget {
  const SigUpScreen({super.key});

  @override
  State<SigUpScreen> createState() => _SigUpScreenState();
}

class _SigUpScreenState extends State<SigUpScreen> {
  final GlobalKey<FormState> formKey =
      GlobalKey<FormState>(); // Para validate() e save()
  final model.User user = model.User(
    email: '',
    password: '',
    name: '',
    confirmPassword: '',
    id: '',
  ); // Preenchido por onSaved
  bool isLoading = false; // true durante cadastro

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, // Fundo azul
      appBar: AppBar(
        title: const Text('Criar Conta', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16), // Margem lateral
          child: Form(
            key: formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              shrinkWrap: true, // Não expande infinitamente
              children: [
                TextFormField(
                  // Nome completo
                  enabled: !isLoading, // Desabilita durante loading
                  decoration: const InputDecoration(hintText: 'Nome Completo'),
                  autovalidateMode:
                      AutovalidateMode.onUserInteraction, // Valida ao digitar
                  validator: (name) {
                    if (name!.isEmpty) return 'Campo obrigatório';
                    if (name.trim().split(' ').length < 2)
                      return 'Preencha seu Nome completo'; // Mínimo 2 palavras
                    return null;
                  },
                  onSaved: (name) =>
                      user.name = name!, // Salva no user ao form.save()
                ),
                const SizedBox(height: 16),
                TextFormField(
                  // E-mail
                  enabled: !isLoading,
                  decoration: const InputDecoration(hintText: 'E-mail'),
                  keyboardType: TextInputType.emailAddress,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (email) {
                    if (email!.isEmpty) return 'Campo obrigatório';
                    if (!emailValid(email)) return 'E-mail inválido';
                    return null;
                  },
                  onSaved: (email) => user.email = email!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  // Senha
                  enabled: !isLoading,
                  decoration: const InputDecoration(hintText: 'Senha'),
                  obscureText: true, // Esconde caracteres
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (pass) {
                    if (pass!.isEmpty) return 'Campo obrigatório';
                    if (pass.length < 6) return 'Senha muito curta';
                    return null;
                  },
                  onSaved: (pass) => user.password = pass!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  // Confirmação de senha
                  enabled: !isLoading,
                  decoration: const InputDecoration(hintText: 'Repita a Senha'),
                  obscureText: true,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (pass) {
                    if (pass!.isEmpty) return 'Campo obrigatório';
                    if (pass.length < 6) return 'Senha muito curta';
                    return null;
                  },
                  onSaved: (pass) => user.confirmPassword = pass!,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      disabledBackgroundColor: Theme.of(context).primaryColor
                          .withAlpha(100), // Azul transparente quando disabled
                      foregroundColor: Colors.white,
                    ),
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (formKey.currentState!.validate()) {
                              // Valida todos os campos
                              formKey.currentState
                                  ?.save(); // Chama onSaved de cada campo
                              if (user.password != user.confirmPassword) {
                                // Senhas diferentes?
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Senhas não coincidem!'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              setState(() => isLoading = true);
                              final error = await context
                                  .read<UserManager>()
                                  .signUp(user);
                              setState(() => isLoading = false);
                              if (error != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Falha ao cadastrar: $error'),
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 4),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Conta criada com sucesso!'),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                if (context.mounted)
                                  Navigator.of(context).pop(); // Fecha tela
                              }
                            }
                          },
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ) // Spinner
                        : const Text(
                            'Criar Conta',
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
