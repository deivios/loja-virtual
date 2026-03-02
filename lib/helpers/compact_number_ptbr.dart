// ========== COMPACT_NUMBER_PTBR.DART - Formata números K, M, B ==========
// 1500 -> "1,5K", 1500000 -> "1,5M". Vírgula decimal, ponto milhares.

String formatCompactPtBr(num value, {int decimals = 2}) { // value: número, decimals: casas após vírgula (padrão 2)
  final abs = value.abs(); // Valor absoluto (ignora sinal negativo)
  if (abs >= 1e9) return '${_formatDecimalPtBr(value / 1e9, decimals)}B'; // >= 1 bilhão: divide por 1e9 e adiciona "B"
  if (abs >= 1e6) return '${_formatDecimalPtBr(value / 1e6, decimals)}M'; // >= 1 milhão: divide por 1e6 e adiciona "M"
  if (abs >= 1e3) return '${_formatDecimalPtBr(value / 1e3, decimals)}K'; // >= 1 mil: divide por 1e3 e adiciona "K"
  return _formatIntPtBr(value.round()); // Abaixo de 1000: formata inteiro com ponto como milhares
}

String _formatDecimalPtBr(num value, int decimals) { // Formata decimal no padrão BR
  return value.toStringAsFixed(decimals).replaceAll('.', ','); // Ex: 1.5 -> "1,50" (vírgula decimal)
}

String _formatIntPtBr(int value) { // Formata inteiro com separador de milhares
  final negative = value < 0; // Guarda se é negativo
  var s = value.abs().toString(); // Converte para string sem sinal
  final buf = StringBuffer(); // Buffer para montar string
  for (var i = 0; i < s.length; i++) { // Percorre cada dígito
    final indexFromEnd = s.length - i; // Posição da direita para esquerda
    buf.write(s[i]); // Adiciona o dígito
    if (indexFromEnd > 1 && indexFromEnd % 3 == 1) buf.write('.'); // Ponto a cada 3 dígitos (1.234.567)
  }
  return negative ? '-$buf' : buf.toString(); // Adiciona "-" se era negativo
}
