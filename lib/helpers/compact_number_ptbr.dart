String formatCompactPtBr(num value, {int decimals = 2}) {
  final abs = value.abs();
  if (abs >= 1e9) return '${_formatDecimalPtBr(value / 1e9, decimals)}B';
  if (abs >= 1e6) return '${_formatDecimalPtBr(value / 1e6, decimals)}M';
  if (abs >= 1e3) return '${_formatDecimalPtBr(value / 1e3, decimals)}K';
  return _formatIntPtBr(value.round());
}

String _formatDecimalPtBr(num value, int decimals) {
  return value.toStringAsFixed(decimals).replaceAll('.', ',');
}

String _formatIntPtBr(int value) {
  final negative = value < 0;
  var s = value.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    final indexFromEnd = s.length - i;
    buf.write(s[i]);
    if (indexFromEnd > 1 && indexFromEnd % 3 == 1) buf.write('.');
  }
  return negative ? '-$buf' : buf.toString();
}
