import 'package:cloud_firestore/cloud_firestore.dart';     // Importa o pacote do Firestore para salvar dados no banco

class User {                                                // Classe que representa o usuário (modelo de dados)
  String id;                                                // ID único do usuário (normalmente o UID do Firebase Auth)
  String confirmPassword;                                   // Senha repetida (só usada na tela de cadastro, não salva no banco)
  String name;                                              // Nome completo do usuário
  String email;                                             // Email do usuário (usado no login e cadastro)
  String password;                                          // Senha do usuário (só usada no cadastro, nunca salva no Firestore)

  // Construtor da classe (exige todos os campos obrigatoriamente)
  User({
    required this.id,                                       // ID obrigatório (geralmente vem do Auth após criar usuário)
    required this.email,
    required this.password,
    required this.name,
    required this.confirmPassword,
  });

  // Factory constructor que cria um User a partir de um DocumentSnapshot do Firestore
  factory User.fromDocument(DocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>?;  // Pega os dados do documento (versão atual do Firestore)
    
    return User(
      id: document.id,                                        // ID do documento (versão atual: .id ao invés de .documentID)
      name: data?['name'] as String? ?? '',                  // Nome do usuário (com fallback para string vazia)
      email: data?['email'] as String? ?? '',                // Email do usuário (com fallback para string vazia)
      password: '',                                           // Senha não é salva no Firestore, então fica vazia
      confirmPassword: '',                                    // ConfirmPassword também não é salvo
    );
  }

  // Método assíncrono que salva os dados do usuário no Firestore
  Future<void> saveData() async {                           // Retorna Future<void> (não retorna valor, só executa)
    await FirebaseFirestore.instance                          // Acessa a instância do Firestore
        .collection('users')                                  // Coleção 'users' no banco (onde ficam os perfis)
        .doc(id)                                              // Documento com ID igual ao UID do usuário
        .set({                                                // Salva (ou sobrescreve) os dados no documento
          'name': name,                                       // Campo 'name' recebe o valor do nome
          'email': email,                                     // Campo 'email' recebe o valor do email
          // 'password': nunca salve senha no Firestore!
        });
  }
}