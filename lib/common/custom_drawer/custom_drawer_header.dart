import 'package:flutter/material.dart';                    // Importa o pacote principal do Flutter (widgets, temas, navegação, etc.)
import 'package:lojavirtual/models/user_manager.dart';     // Importa o modelo/gerenciador de usuário da sua aplicação
import 'package:provider/provider.dart';                   // Importa o Provider → gerenciador de estado usado no app

class CustomDrawerHeader extends StatelessWidget {         // Cria um widget sem estado chamado CustomDrawerHeader (cabeçalho do Drawer)
  const CustomDrawerHeader({super.key});                   // Construtor constante (permite melhor performance e é padrão moderno)

  @override                                                // Sobrescreve o método build obrigatório de StatelessWidget
  Widget build(BuildContext context) {                     // Método que constrói e retorna a interface do widget
    final userManager = context.read<UserManager>();       // Lê a instância do UserManager do Provider (apenas leitura, não escuta mudanças)

    return Container(                                      // Container usado como raiz para aplicar padding e possivelmente decoração
      padding: const EdgeInsets.fromLTRB(32, 24, 16, 8),   // Define margens internas: esq 32, topo 24, dir 16, baixo 8
      child: Column(                                       // Column organiza os filhos na vertical
        crossAxisAlignment: CrossAxisAlignment.start,      // Alinha todo o conteúdo à esquerda
        mainAxisAlignment: MainAxisAlignment.spaceAround,  // Distribui o espaço disponível entre os elementos
        children: <Widget>[                                // Lista de widgets filhos da Column
          Text(                                            // Primeiro texto: título da loja
            'Loja do \nVinicius',                          // \n faz quebra de linha
            style: TextStyle(                              // Estilo do texto
              fontSize: 34,                                // Tamanho grande para destaque
              fontWeight: FontWeight.bold,                 // Negrito
            ),
          ),
          const SizedBox(height: 16),                      // Espaço vertical fixo de 16 pixels
          Text(                                            // Texto de saudação com nome do usuário
            'Olá, ${userManager.user?.name ?? ''}',        // Mostra "Olá, Nome" ou "Olá, " se não tiver nome
            overflow: TextOverflow.ellipsis,               // Se o texto for muito longo, coloca reticências (...)
            maxLines: 2,                                   // Limita a no máximo 2 linhas
            style: const TextStyle(                        // Estilo do texto de saudação
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),                       // Pequeno espaço vertical
          GestureDetector(                                 // Detecta toques na área do texto "Sair / Entrar"
            onTap: () async {                              // Função executada quando o usuário tocar no texto
              if (userManager.isLoggedIn) {                // Verifica se o usuário está logado
                await userManager.signOut();               // Desloga o usuário (geralmente limpa dados e token)
                if (context.mounted)                       // Verifica se o widget ainda existe na árvore (evita erro após async)
                  Navigator.of(context).pop();             // Fecha o Drawer após logout
              } else {  
                Navigator.of(context).pop();             // Usuário não está logado
                Navigator.of(context).pushNamed('/login'); // Navega para a tela de login
              }
            },
            child: Text(                                   // Texto clicável
              userManager.isLoggedIn                     // Condicional ternário
                  ? 'Sair'                               // Mostra "Sair" se logado
                  : 'Entre ou cadastre-se >',            // Mostra isso se não estiver logado
              style: const TextStyle(                    // Estilo do texto clicável
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 4, 80, 142),  // Cor azul escura personalizada
              ),
            ),
          ),
        ],
      ),
    );
  }
}