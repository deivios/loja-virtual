// ========== ITEM_SIZE.DART - Tamanho do produto ==========
// P, M, GG com preço e estoque. Usado em Product e CartProduct.

class ItemSize {
  final String name; // Nome do tamanho (P, M, G, GG)
  final num price; // Preço deste tamanho (pode variar: GG mais caro que P)
  final int stock; // Quantidade em estoque (0 = sem estoque, desabilita botão)

  ItemSize.fromMap(Map<String, dynamic> map) // Construtor a partir do Firestore
      : name = (map['name'] ?? map['nome'] ?? map['title'] ?? map['titulo'] ?? '-')
            .toString(), // Aceita name/nome/title/titulo
        price = _parseNum(
          map['price'] ?? map['preco'] ?? map['preço'] ?? map['valor'],
        ),
        stock = _parseInt(
          map['stock'] ??
              map['estoque'] ??
              map['quantidade'] ??
              map['qty'],
        );

  static num _parseNum(dynamic v) { // Converte para número
    if (v is num) return v; // Já é num
    if (v is String) {
      var normalized = v.trim();
      normalized = normalized.replaceAll(RegExp(r'[^0-9,.\-]'), '');
      if (normalized.isEmpty) return 0;

      final lastComma = normalized.lastIndexOf(',');
      final lastDot = normalized.lastIndexOf('.');
      if (lastComma > -1 && lastDot > -1) {
        final decimalSeparator = lastComma > lastDot ? ',' : '.';
        if (decimalSeparator == ',') {
          normalized = normalized.replaceAll('.', '').replaceAll(',', '.');
        } else {
          normalized = normalized.replaceAll(',', '');
        }
      } else if (lastComma > -1) {
        normalized = normalized.replaceAll(',', '.');
      }

      return num.tryParse(normalized) ?? 0;
    }
    return 0; // Fallback
  }

  static int _parseInt(dynamic v) { // Converte para int
    if (v is int) return v; // Já é int
    if (v is num) return v.toInt(); // Converte num
    if (v is String) {
      final digitsOnly = v.replaceAll(RegExp(r'[^0-9\-]'), '');
      return int.tryParse(digitsOnly) ?? 0;
    }
    return 0; // Fallback
  }

  bool get hasStock => stock > 0; // true = tem estoque (habilita botão Adicionar)
}
