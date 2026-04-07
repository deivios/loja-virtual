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
  final FocusNode nameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool isLoading = false; // true durante cadastro

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !isLoading) {
        nameFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    nameFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => isLoading = true);

    final user = model.User(
      id: '',
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text,
      confirmPassword: confirmPasswordController.text,
    );

    final error = await context.read<UserManager>().signUp(user);
    if (!mounted) return;

    setState(() => isLoading = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao cadastrar: $error'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Conta criada com sucesso!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.of(context).pop();
  }

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
                    child: TextFormField(
                      // Nome completo
                      focusNode: nameFocusNode,
                      autofocus: true,
                      enabled: !isLoading,
                      controller: nameController,
                      decoration: const InputDecoration(hintText: 'Nome Completo'),
                      textInputAction: TextInputAction.next,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (name) {
                        if (name == null || name.trim().isEmpty) {
                          return 'Campo obrigatório';
                        }
                        if (name.trim().split(' ').length < 2) {
                          return 'Preencha seu Nome completo';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(emailFocusNode),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextFormField(
                      // E-mail
                      focusNode: emailFocusNode,
                      enabled: !isLoading,
                      controller: emailController,
                      decoration: const InputDecoration(hintText: 'E-mail'),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      autofillHints: const [AutofillHints.email],
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (email) {
                        if (email == null || email.trim().isEmpty) {
                          return 'Campo obrigatório';
                        }
                        if (!emailValid(email)) return 'E-mail inválido';
                        return null;
                      },
                      onFieldSubmitted: (_) => FocusScope.of(
                        context,
                      ).requestFocus(passwordFocusNode),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextFormField(
                      // Senha
                      focusNode: passwordFocusNode,
                      enabled: !isLoading,
                      controller: passwordController,
                      decoration: const InputDecoration(hintText: 'Senha'),
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (pass) {
                        if (pass == null || pass.isEmpty) return 'Campo obrigatório';
                        if (pass.length < 6) return 'Senha muito curta';
                        return null;
                      },
                      onFieldSubmitted: (_) => FocusScope.of(
                        context,
                      ).requestFocus(confirmPasswordFocusNode),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextFormField(
                      // Confirmação de senha
                      focusNode: confirmPasswordFocusNode,
                      enabled: !isLoading,
                      controller: confirmPasswordController,
                      decoration: const InputDecoration(hintText: 'Repita a Senha'),
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (pass) {
                        if (pass == null || pass.isEmpty) return 'Campo obrigatório';
                        if (pass.length < 6) return 'Senha muito curta';
                        if (pass != passwordController.text) {
                          return 'Senhas não coincidem';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) {
                        if (!isLoading) _handleSignUp();
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      height: 44,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          disabledBackgroundColor: Theme.of(context).primaryColor
                              .withAlpha(100),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: isLoading ? null : _handleSignUp,
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Criar Conta',
                                style: TextStyle(fontSize: 18),
                              ),
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
