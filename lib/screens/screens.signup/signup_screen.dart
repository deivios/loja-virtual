import 'package:flutter/material.dart';                    // Importa o pacote principal do Flutter (widgets, Material Design)
import 'package:lojavirtual/helpers/validators.dart';     // Importa funções auxiliares de validação (ex: emailValid)
import 'package:lojavirtual/models/user.dart' as model;   // Importa o modelo User (renomeado como model para evitar conflito)
import 'package:lojavirtual/models/user_manager.dart';    // Importa o gerenciador de usuário (com lógica de autenticação)
import 'package:provider/provider.dart';                  // Importa o Provider para gerenciamento de estado

class SigUpScreen extends StatefulWidget {               // Classe da tela de cadastro (Stateful porque tem estado mutável)
  @override
  State<SigUpScreen> createState() => _SigUpScreenState(); // Cria o estado associado a esta tela
}

class _SigUpScreenState extends State<SigUpScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>(); // Chave global para controlar e validar o formulário
  final model.User user = model.User(                          // Instância do modelo User que vai armazenar os dados digitados
    email: '',
    password: '',
    name: '',
    confirmPassword: '', id: '',
  );
  bool isLoading = false;       // Controla se está carregando (mostra spinner no botão)

  @override
  Widget build(BuildContext context) {                         // Método principal que constrói a interface da tela
    return Scaffold(                                           // Estrutura básica da tela (AppBar + Body + Fundo)
      
      backgroundColor: Colors.blue,                            // Cor de fundo da tela inteira (azul)
      
      appBar: AppBar(                                          // Barra superior da tela
        title: const Text(
          'Criar Conta',
          style: TextStyle(color: Colors.white),               // Texto branco para contraste com fundo azul
        ),
        centerTitle: true,                                     // Centraliza o título na AppBar
        backgroundColor: Colors.blue,                          // Mesma cor da tela para ficar uniforme
      ),
      
      body: Center(                                            // Centraliza todo o conteúdo da tela (vertical e horizontal)
        child: Card(                                           // Cria um cartão com sombra e bordas arredondadas
          margin: const EdgeInsets.symmetric(horizontal: 16), // Margem lateral para não encostar nas bordas da tela
          child: Form(                                           // Formulário que permite validação automática
            key: formKey,                                        // Associa a chave global ao formulário
            child: ListView(                                     // Lista rolável (útil se a tela for pequena)
              padding: const EdgeInsets.all(16),                 // Espaçamento interno em todos os lados
              shrinkWrap: true,                                  // Faz o ListView ocupar apenas o espaço necessário
              children: <Widget>[                                // Lista de widgets filhos (campos + botão)
                
                TextFormField(                                 // Campo de texto para o nome completo
                  enabled: !isLoading,
                  decoration: const InputDecoration(hintText: 'Nome Completo'),
                  autovalidateMode: AutovalidateMode.onUserInteraction, // Valida automaticamente ao digitar
                  validator: (name) {                              // Função de validação do nome
                    if (name!.isEmpty) {
                      return 'Campo obrigatório';
                    } else if (name.trim().split(' ').length < 2) {
                      return 'Preencha seu Nome completo';
                    }
                    return null;                                 // Retorna null = válido
                  },
                  onSaved: (name) => user.name = name!,           // Salva o valor no modelo User quando o form for salvo
                ),
                const SizedBox(height: 16),                        // Espaçamento vertical entre campos
                
                TextFormField(                                     // Campo de e-mail
                  enabled: !isLoading,
                  decoration: const InputDecoration(hintText: 'E-mail'),
                  keyboardType: TextInputType.emailAddress,        // Teclado otimizado para e-mail (@ e .com)
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (email) {
                    if (email!.isEmpty) {
                      return 'Campo obrigatório';
                    } else if (!emailValid(email)) {               // Usa função importada de validators.dart
                      return 'E-mail inválido';
                    }
                    return null;
                  },
                  onSaved: (email) => user.email = email!,
                ),
                const SizedBox(height: 16),
                
                TextFormField(                                     // Campo de senha
                  enabled: !isLoading,
                  decoration: const InputDecoration(hintText: 'Senha'),
                  obscureText: true,                               // Esconde os caracteres (••••)
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (pass) {
                    if (pass!.isEmpty) {
                      return 'Campo obrigatório';
                    } else if (pass.length < 6) {
                      return 'Senha muito curta';
                    }
                    return null;
                  },
                  onSaved: (pass) => user.password = pass!,
                ),
                const SizedBox(height: 16),
                
                TextFormField(                                     // Campo de confirmação de senha
                  enabled: !isLoading,
                  decoration: const InputDecoration(hintText: 'Repita a Senha'),
                  obscureText: true,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (pass) {
                    if (pass!.isEmpty) {
                      return 'Campo obrigatório';
                    } else if (pass.length < 6) {
                      return 'Senha muito curta';
                    }
                    return null;
                  },
                  onSaved: (pass) => user.confirmPassword = pass!,
                ),
                const SizedBox(height: 16),
                
                SizedBox(                                          // Define altura fixa para o botão
                  height: 44,
                  child: ElevatedButton(                           // Botão de cadastro
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,           // Cor primária do tema (geralmente azul)
                      disabledBackgroundColor: Theme.of(context).primaryColor.withAlpha(100), // Cor quando desabilitado
                      foregroundColor: Colors.white,                                 // Cor do texto/ícone
                    ),
                    child: isLoading                                   // Mostra spinner ou texto dependendo do estado
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
                    onPressed: isLoading ? null : () async {  // Desabilita botão durante loading
                      // Valida todos os campos do formulário
                      if (formKey.currentState!.validate()) {
                        formKey.currentState?.save();   // Salva os valores nos campos onSaved

                        // Verifica se as senhas coincidem (validação extra)
                        if (user.password != user.confirmPassword) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Senhas não coincidem!'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        setState(() { isLoading = true; }); // Ativa o loading (mostra spinner)

                        // Chama a função de cadastro no UserManager via Provider
                        final error = await context.read<UserManager>().signUp(user);

                        setState(() { isLoading = false; });           // Desativa o loading

                        if (error != null) {
                          // Mostra erro retornado (ex: "E-mail já existe")
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Falha ao cadastrar: $error'),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        } else {
                          // Sucesso
                          debugPrint('sucesso');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Conta criada com sucesso!'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                            ),
                          );
                          Navigator.of(context).pop(); // Volta para a tela anterior (geralmente login)
                        }
                      }
                    },
                    
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