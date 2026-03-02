// ========== MONEY_SIMULATOR_SCREEN.DART - Demo formatCompactPtBr ==========
// Testa formatação K, M, B. Ex: 652050 -> "652,1K", 99999999 -> "100M".

import 'package:flutter/material.dart';
import 'package:lojavirtual/helpers/compact_number_ptbr.dart';

class MoneySimulatorScreen extends StatefulWidget {
  const MoneySimulatorScreen({super.key});

  @override
  State<MoneySimulatorScreen> createState() => _MoneySimulatorScreenState();
}

class _MoneySimulatorScreenState extends State<MoneySimulatorScreen> {
  static const int _initialCoins = 652050;
  static const int _targetCoins = 99999999;
  int _coins = _initialCoins;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary; // Cor primária (azul)
    return Scaffold(
      appBar: AppBar(title: const Text('Simulador de moedas'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Valor local formatado em K, M, B.', style: TextStyle(color: Colors.grey)), // Texto cinza
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(16)), // Fundo cinza claro (black12)
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.monetization_on_rounded, color: primaryColor), // Ícone azul
                  const SizedBox(width: 8),
                  Text(formatCompactPtBr(_coins), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
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
                ElevatedButton(onPressed: () => setState(() => _coins = _targetCoins), child: const Text('99.999.999')),
                OutlinedButton(onPressed: () => setState(() => _coins = _initialCoins), child: const Text('Reset')),
                OutlinedButton(onPressed: () => setState(() => _coins += 1000), child: const Text('+ 1.000')),
                OutlinedButton(onPressed: () => setState(() => _coins += 100000), child: const Text('+ 100.000')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
