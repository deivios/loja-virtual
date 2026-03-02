import 'package:flutter/material.dart'; // Material, InkWell, Icon, ClipRRect

class CustomIconButton extends StatelessWidget {
  // Botão customizado com ícone
  const CustomIconButton({
    // Construtor
    super.key, // Chave do widget
    required this.iconData, // Ícone obrigatório
    this.color, // Cor opcional
    this.onTap, // Callback ao tocar (opcional)
  });

  final IconData iconData; // Ícone a exibir
  final Color? color; // Cor do ícone (null = padrão)
  final VoidCallback? onTap; // Função chamada ao tocar

  @override // Sobrescreve build do StatelessWidget
  Widget build(BuildContext context) {
    // Constrói o widget
    return ClipRRect(
      // Recorta bordas arredondadas
      borderRadius: BorderRadius.circular(
        50,
      ), // Bordas totalmente arredondadas (círculo)
      child: Material(
        // Material para efeito de toque
        color: Colors.transparent, // Fundo transparente
        child: InkWell(
          // Área clicável com efeito ripple
          onTap: onTap, // Callback ao tocar
          child: Padding(
            // Espaço interno
            padding: const EdgeInsets.all(5), // 5px em todos os lados
            child: Icon(iconData, color: color), // Exibe o ícone
          ),
        ),
      ),
    );
  }
}
