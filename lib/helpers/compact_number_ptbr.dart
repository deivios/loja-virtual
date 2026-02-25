// Formata números de forma compacta em PT-BR (ex: 1.5K, 2.3M, 1.2B)

String formatCompactPtBr(num value, {int decimals = 2}) {  // Formata valor com sufixo K, M ou B
  final abs = value.abs();                                // Valor absoluto para comparação

  if (abs >= 1e9) {
    return '${_formatDecimalPtBr(value / 1e9, decimals)}B';  // Bilhões
  }
  if (abs >= 1e6) {
    return '${_formatDecimalPtBr(value / 1e6, decimals)}M';  // Milhões
  }
  if (abs >= 1e3) {
    return '${_formatDecimalPtBr(value / 1e3, decimals)}K';  // Milhares
  }

  return _formatIntPtBr(value.round());                  // Sem sufixo: formata como inteiro pt-BR (milhar com ponto)
}

String _formatDecimalPtBr(num value, int decimals) {      // Formata decimal com vírgula (pt-BR)
  final fixed = value.toStringAsFixed(decimals);
  return fixed.replaceAll('.', ',');
}

String _formatIntPtBr(int value) {                        // Formata inteiro com ponto como separador de milhar (pt-BR)
  final negative = value < 0;
  var s = value.abs().toString();

  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    final indexFromEnd = s.length - i;
    buf.write(s[i]);
    if (indexFromEnd > 1 && indexFromEnd % 3 == 1) {
      buf.write('.');                                    // Insere ponto a cada 3 dígitos
    }
  }

  return negative ? '-${buf.toString()}' : buf.toString();
}

