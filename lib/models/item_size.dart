class ItemSize {                                          // Modelo que representa um tamanho do produto (P, M, G, etc.)
  final String name;                                      // Nome do tamanho (ex: "P", "M", "GG")
  final num price;                                        // Preço deste tamanho
  final int stock;                                        // Quantidade em estoque

  ItemSize.fromMap(Map<String, dynamic> map)              // Construtor: cria ItemSize a partir de Map (Firestore)
      : name = (map['name'] ?? map['nome'] ?? '-').toString(),  // Aceita 'name' ou 'nome'
        price = _parseNum(map['price'] ?? map['preco']),  // Aceita 'price' ou 'preco'
        stock = _parseInt(map['stock'] ?? map['estoque']); // Aceita 'stock' ou 'estoque'

  static num _parseNum(dynamic v) {                       // Converte valor para num (int, double ou String)
    if (v is num) return v;                              // Já é número, retorna direto
    if (v is String) return num.tryParse(v.replaceAll(',', '.')) ?? 0;  // String com vírgula -> ponto
    return 0;
  }

  static int _parseInt(dynamic v) {                       // Converte valor para int
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  bool get hasStock => stock > 0;                         // True se há estoque disponível

  @override
  String toString() {                                     // Representação em texto para debug
    return 'ItemSize{name: $name, price: $price, stock: $stock}';
  }
}
