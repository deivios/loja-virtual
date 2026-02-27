import 'package:flutter/material.dart';
import 'package:lojavirtual/models/user_manager.dart';
import 'package:provider/provider.dart';

class CustomDrawerHeader extends StatelessWidget {
  const CustomDrawerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final userManager = context.read<UserManager>();
    return Container(
      padding: const EdgeInsets.fromLTRB(32, 24, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text('Loja do \nVinicius', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(
            'Olá, ${userManager.user?.name ?? ''}',
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              if (userManager.isLoggedIn) {
                await userManager.signOut();
                if (context.mounted) Navigator.of(context).pop();
              } else {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/login');
              }
            },
            child: Text(
              userManager.isLoggedIn ? 'Sair' : 'Entre ou cadastre-se >',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 4, 80, 142)),
            ),
          ),
        ],
      ),
    );
  }
}
