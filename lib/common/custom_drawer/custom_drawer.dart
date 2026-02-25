import 'package:flutter/material.dart';                          // Importa o pacote principal do Flutter (contém Drawer, ListView, Stack, Icons, etc.)

import 'package:lojavirtual/common/custom_drawer/custom_drawer_header.dart';  
// Importa o cabeçalho personalizado que aparece no topo do drawer (com nome da loja, saudação e botão entrar/sair)

import 'package:lojavirtual/common/custom_drawer/drawer_tile.dart';           
// Importa o widget reutilizável que representa cada item do menu (ícone + texto + navegação)

class CustomDrawer extends StatelessWidget {               // Widget do menu lateral (Drawer)
  const CustomDrawer({super.key});                         // Construtor constante – menu lateral reutilizável

  @override                                                    // Sobrescreve o método obrigatório que constrói a UI
  Widget build(BuildContext context) {                         // Método chamado pelo Flutter para renderizar o widget
    return Drawer(                                             // Retorna um Drawer – widget nativo do Material Design para menu lateral
      child: Stack(                                            // Stack permite sobrepor widgets (fundo + conteúdo)
        children: <Widget>[                                    // Lista de widgets que serão empilhados

          // Camada 1: fundo com gradiente suave (efeito visual bonito)
          Container(
            decoration: const BoxDecoration(                   // Decoração apenas visual (sem child aqui)
              gradient: LinearGradient(                        // Cria um gradiente linear
                begin: Alignment.topCenter,                    // Começa no topo central
                end: Alignment.bottomCenter,                   // Termina na parte inferior central
                colors: <Color>[                               // Lista de cores do gradiente
                  Color.fromARGB(255, 214, 236, 250),         // Azul bem clarinho no topo
                  Colors.white,                                // Transição suave para branco na base
                ],
              ),
            ),
          ),

          // Camada 2: conteúdo principal (header + lista de itens) → fica por cima do gradiente
          ListView(                                            // ListView permite rolagem caso o conteúdo seja maior que a tela
            children: <Widget>[                                // Itens que vão aparecer no drawer (de cima para baixo)

              CustomDrawerHeader(),                            // Cabeçalho personalizado (nome da loja, "Olá, usuário", entrar/sair)
              const Divider(), // linha que aoanha em cima do INICIO E ABAIXO DO ENTRE 

              // Itens do menu – cada DrawerTile é um botão navegável
              DrawerTile(
                iconData: Icons.home,                          // Ícone de casinha
                title: 'Início',                               // Texto exibido
                page: 0,                                       // Índice da página (geralmente usado em PageView ou com Navigator)
              ),

              DrawerTile(
                iconData: Icons.list,                          // Ícone de lista/grid
                title: 'Produtos',                             // Texto
                page: 1,
              ),

              DrawerTile(
                iconData: Icons.playlist_add_check,            // Ícone de pedidos/lista de tarefas
                title: 'Meus Pedidos',                         // Texto
                page: 2,
              ),

              DrawerTile(
                iconData: Icons.location_on,                   // Ícone de localização/mapa
                title: 'Lojas',                                // Texto
                page: 3,
              ),

              // Dica: você pode adicionar mais itens aqui facilmente
              // Exemplo:
              // DrawerTile(iconData: Icons.person, title: 'Perfil', page: 4),
              // DrawerTile(iconData: Icons.info, title: 'Sobre', page: 5),

            ],
          ),
        ],
      ),
    );
  }         // Fecha o método build
}           // Fecha a classe CustomDrawer