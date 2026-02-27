import 'package:flutter/material.dart';
import 'package:lojavirtual/helpers/validators.dart';
import 'package:lojavirtual/models/user.dart' as model;
import 'package:lojavirtual/models/user_manager.dart';
import 'package:provider/provider.dart';

class SigUpScreen extends StatefulWidget {
  const SigUpScreen({super.key});

  @override
  State<SigUpScreen> createState() => _SigUpScreenState();
}

class _SigUpScreenState extends State<SigUpScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final model.User user = model.User(email: '', password: '', name: '', confirmPassword: '', id: '');
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text('Criar Conta', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              shrinkWrap: true,
              children: [
                TextFormField(
                  enabled: !isLoading,
                  decoration: const InputDecoration(hintText: 'Nome Completo'),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (name) {
                    if (name!.isEmpty) return 'Campo obrigatório';
                    if (name.trim().split(' ').length < 2) return 'Preencha seu Nome completo';
                    return null;
                  },
                  onSaved: (name) => user.name = name!,
                ),
                const SizedBox(height: 16),
                TextFormField(
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
                  enabled: !isLoading,
                  decoration: const InputDecoration(hintText: 'Senha'),
                  obscureText: true,
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
                      disabledBackgroundColor: Theme.of(context).primaryColor.withAlpha(100),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (formKey.currentState!.validate()) {
                              formKey.currentState?.save();
                              if (user.password != user.confirmPassword) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Senhas não coincidem!'), backgroundColor: Colors.red),
                                );
                                return;
                              }
                              setState(() => isLoading = true);
                              final error = await context.read<UserManager>().signUp(user);
                              setState(() => isLoading = false);
                              if (error != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Falha ao cadastrar: $error'), backgroundColor: Colors.red, duration: const Duration(seconds: 4)),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Conta criada com sucesso!'), backgroundColor: Colors.green, duration: Duration(seconds: 2)),
                                );
                                if (context.mounted) Navigator.of(context).pop();
                              }
                            }
                          },
                    child: isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Criar Conta', style: TextStyle(fontSize: 18)),
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
