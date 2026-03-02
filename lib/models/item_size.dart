// ========== ITEM_SIZE.DART - Tamanho do produto ==========
// P, M, GG com preço e estoque. Usado em Product e CartProduct.

class ItemSize {
  final String name; // Nome do tamanho (P, M, G, GG)
  final num price; // Preço deste tamanho (pode variar: GG mais caro que P)
  final int stock; // Quantidade em estoque (0 = sem estoque, desabilita botão)

  ItemSize.fromMap(Map<String, dynamic> map) // Construtor a partir do Firestore
      : name = (map['name'] ?? map['nome'] ?? '-').toString(), // Aceita name ou nome
        price = _parseNum(map['price'] ?? map['preco']), // Aceita price ou preco
        stock = _parseInt(map['stock'] ?? map['estoque']); // Aceita stock ou estoque

  static num _parseNum(dynamic v) { // Converte para número
    if (v is num) return v; // Já é num
    if (v is String) return num.tryParse(v.replaceAll(',', '.')) ?? 0; // Vírgula -> ponto decimal
    return 0; // Fallback
  }

  static int _parseInt(dynamic v) { // Converte para int
    if (v is int) return v; // Já é int
    if (v is num) return v.toInt(); // Converte num
    if (v is String) return int.tryParse(v) ?? 0; // Tenta parse da string
    return 0; // Fallback
  }

  bool get hasStock => stock > 0; // true = tem estoque (habilita botão Adicionar)
}
