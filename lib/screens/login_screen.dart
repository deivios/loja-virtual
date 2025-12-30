import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrar'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      backgroundColor: Colors.blue,
      body: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),

          child: ListView(
            padding: const EdgeInsets.all(16),
            shrinkWrap: true,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(hintText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                validator: (email) {
                  return null;
                },
              ),
              const SizedBox(height: 16,),
              TextFormField(
                decoration: const InputDecoration(hintText: 'Senha'),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                obscureText: true,
                validator: (pass) {
                  if (pass!.isEmpty || pass.length < 6) return 'Senha Inválida';
                  return null;
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {

                  },                  
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  child: const Text(
                    'Esqueci minha senha'
                    ),
                ),
              ),
              const SizedBox(height: 16,),
              SizedBox(
                height: 44,
                child: ElevatedButton(
                  
                  onPressed: () {                 
                
                
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white
                
                ),                          
                child: const Text('Entrar',
                style: TextStyle(fontSize: 18
                ),
                ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
