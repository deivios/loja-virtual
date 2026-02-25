import 'package:flutter/material.dart';                    // Pacote principal do Flutter
import 'package:lojavirtual/helpers/compact_number_ptbr.dart';  // Formata números compactos (K, M, B) em pt-BR

class MoneySimulatorScreen extends StatefulWidget {        // Tela de demonstração do formatCompactPtBr
  const MoneySimulatorScreen({super.key});

  @override
  State<MoneySimulatorScreen> createState() => _MoneySimulatorScreenState();
}

class _MoneySimulatorScreenState extends State<MoneySimulatorScreen> {
  static const int _initialCoins = 652050;                 // Valor inicial de moedas para teste
  static const int _targetCoins = 99999999;                // Meta de moedas (exemplo)

  int _coins = _initialCoins;                             // Estado: quantidade atual de moedas

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;  // Cor primária do tema

    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulador de moedas (local)'),  // Título da tela
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Isso é só estudo: muda um valor local e mostra como ele ficaria abreviado.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.monetization_on_rounded, color: primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    formatCompactPtBr(_coins),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Valor inteiro: $_coins'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton(
                  onPressed: () => setState(() => _coins = _targetCoins),
                  child: const Text('Setar para 99.999.999'),
                ),
                OutlinedButton(
                  onPressed: () => setState(() => _coins = _initialCoins),
                  child: const Text('Reset 652.050'),
                ),
                OutlinedButton(
                  onPressed: () => setState(() => _coins += 1000),
                  child: const Text('+ 1.000'),
                ),
                OutlinedButton(
                  onPressed: () => setState(() => _coins += 100000),
                  child: const Text('+ 100.000'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

