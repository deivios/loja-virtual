import 'package:lojavirtual/models/user_manager.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:lojavirtual/helpers/validators.dart';
import 'package:lojavirtual/models/user.dart' as model;

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores dos campos de texto
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  // Chave para validar o formulário
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  
  

  // Controla se está carregando (mostra spinner)
  bool isLoading = false;

  // Guarda mensagem de erro para mostrar na tela
  String? errorMessage;

  @override
  void dispose() {
    // Libera os controladores quando a tela é destruída
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  // Função chamada quando clica em "Entrar"
  Future<void> _handleLogin() async {
    // Só continua se os campos estiverem válidos
    if (!formKey.currentState!.validate()) return;

    // Mostra loading e limpa erro anterior
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    // Tenta fazer login usando o UserManager
    final error = await context.read<UserManager>().signIn(
      model.User(
        email: emailController.text.trim(),
        password: passController.text, name: '', confirmPassword: '',
      ),
    );

    // Terminou a tentativa → para o loading
    setState(() {
      isLoading = false;
      errorMessage = error; // Coloca a mensagem de erro (ou null se sucesso)
    });

    if (error != null) {
      // Mostra erro no SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } else {
      // Login deu certo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login realizado com sucesso!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Aqui você deve colocar a navegação para a próxima tela
      // Exemplo: Navigator.of(context).pushReplacementNamed('/home');
      // ou fechar essa tela de alguma forma
      // onSuccess: () { ... }  ← isso aqui está errado, remova ou corrija
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrar'),
        centerTitle: true,
        actions: <Widget>[
          TextButton(
            onPressed:() {
              Navigator.of(context).pushNamed('/signup');
            },            
            
            child: const Text(
  'CRIAR CONTA',
  style: TextStyle(
    fontSize: 14,
    color: Colors.white,
     ),   // ← Aqui dentro do TextStyle!
  ),
),
              
        ],
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.blue,
      body: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Form(
            key: formKey, // Liga o formulário à validação
            child: ListView(
              padding: const EdgeInsets.all(16),
              shrinkWrap: true,
              children: [
                // Campo de e-mail
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(hintText: 'E-mail'),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  validator: (email) {
                    if (!emailValid(email!)) return 'E-mail inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo de senha
                TextFormField(
                  controller: passController,
                  decoration: const InputDecoration(hintText: 'Senha'),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  obscureText: true, // Esconde os caracteres
                  validator: (pass) {
                    if (pass!.isEmpty || pass.length < 6) return 'Senha Inválida';
                    return null;
                  },
                ),

                // Link "Esqueci minha senha" (ainda sem função)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {}, // ← Implementar recuperação de senha aqui
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: const Text('Esqueci minha senha'),
                  ),
                ),

                // Mostra mensagem de erro abaixo dos campos (se houver)
                if (errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Container(
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
                ],

                const SizedBox(height: 16),

                // Botão de login
                SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleLogin, // Desabilita quando está carregando
                    
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,//cor nomal
                      foregroundColor: Colors.white,//cor do texto/icone
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Entrar', style: TextStyle(fontSize: 18)),
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
