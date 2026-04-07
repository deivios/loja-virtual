// ========== LOGIN_SCREEN.DART - Tela de login ==========
// Email + senha. Valida, chama signIn. SnackBar verde/vermelho. CRIAR CONTA -> /signup.

import 'package:flutter/material.dart'; // Scaffold, Form, TextFormField, etc.
import 'package:lojavirtual/helpers/validators.dart'; // emailValid
import 'package:lojavirtual/models/user.dart' as model; // model.User
import 'package:lojavirtual/models/user_manager.dart'; // UserManager, signIn
import 'package:provider/provider.dart'; // context.read

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController(); // Controla campo email
  final TextEditingController passController = TextEditingController(); // Controla campo senha
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passFocusNode = FocusNode();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>(); // Para validate()
  bool isLoading = false; // true durante login
  String? errorMessage; // Mensagem de erro do Firebase

  @override
  void initState() {
    super.initState();
    // Ao abrir a tela, já foca no campo de e-mail para aceitar teclado físico.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !isLoading) {
        emailFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    emailController.dispose(); // Libera memória
    passController.dispose();
    emailFocusNode.dispose();
    passFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async { // Chamado ao clicar em Entrar
    if (!formKey.currentState!.validate()) return; // Valida campos (retorna se inválido)

    setState(() {
      isLoading = true;
      errorMessage = null; // Limpa erro anterior
    });

    final error = await context.read<UserManager>().signIn(
      model.User(
        email: emailController.text.trim(),
        password: passController.text,
        name: '',
        confirmPassword: '',
        id: '',
      ),
    ); // signIn retorna null se sucesso

    if (!mounted) return;
    setState(() {
      isLoading = false;
      errorMessage = error;
    });

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red, duration: const Duration(seconds: 4)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login realizado com sucesso!'), backgroundColor: Colors.green, duration: Duration(seconds: 2)),
      );
      if (context.mounted) Navigator.of(context).pop(); // Fecha tela de login
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrar'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pushNamed('/signup'), // Vai para tela de cadastro
            child: const Text('CRIAR CONTA', style: TextStyle(fontSize: 14, color: Colors.white)),
          ),
        ],
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.blue,
      body: Center(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Card(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextFormField( // Campo email
                      focusNode: emailFocusNode,
                      autofocus: true,
                      enabled: !isLoading,
                      controller: emailController,
                      decoration: const InputDecoration(hintText: 'E-mail'),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      autocorrect: false,
                      onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(passFocusNode),
                      validator: (email) => emailValid(email ?? '') ? null : 'E-mail inválido',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextFormField( // Campo senha
                      focusNode: passFocusNode,
                      enabled: !isLoading,
                      controller: passController,
                      decoration: const InputDecoration(hintText: 'Senha'),
                      obscureText: true, // Esconde caracteres (bolinhas)
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) {
                        if (!isLoading) _handleLogin();
                      },
                      autocorrect: false,
                      validator: (pass) => (pass!.isEmpty || pass.length < 6) ? 'Senha Inválida' : null, // Mín 6 chars
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: TextButton(
                        onPressed: () {}, // TODO: recuperação de senha
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: const Text('Esqueci minha senha'),
                      ),
                    ),
                  ),
                  if (errorMessage != null) ...[ // Caixa de erro (se houver)
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                            const SizedBox(width: 8),
                            Expanded(child: Text(errorMessage!)),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      height: 44,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleLogin, // Desabilita durante loading
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                              )
                            : const Text('Entrar', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
