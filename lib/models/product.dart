import 'package:cloud_firestore/cloud_firestore.dart';  // Pacote para acessar o Firestore (banco de dados)
import 'package:flutter/foundation.dart';               // Pacote com ChangeNotifier para notificar mudanças na UI
import 'package:lojavirtual/models/item_size.dart';     // Importa o modelo ItemSize (tamanho com nome, preço, estoque)

class Product extends ChangeNotifier {                 // Classe Product que herda ChangeNotifier (permite notifyListeners)
  final String id;                                     // ID único do documento no Firestore
  final String name;                                   // Nome do produto
  final String description;                            // Descrição do produto
  final List<String> images;                         // Lista de URLs das imagens
  final num basePrice;                                 // Preço base (pode vir de basePrice, price, preco ou valor)
  final List<ItemSize> sizes;                          // Lista de tamanhos disponíveis (P, M, G, etc.)

  // Construtor que cria um Product a partir de um documento do Firestore
  Product.fromDocument(DocumentSnapshot document)
    : id = document.id,                                // ID do documento = id do produto
      name =
          (((document.data() as Map<String, dynamic>?) ??  // Converte documento para Map
                      const <String, dynamic>{})['name'] ??  // Busca campo 'name', se null usa ''
                  '')
              .toString(),                             // Garante que sempre retorna String
      description =
          (((document.data() as Map<String, dynamic>?) ??
                      const <String, dynamic>{})['description'] ??
                  '')
              .toString(),                             // Mesma lógica para description
      sizes = _parseSizes(document),                   // Converte array 'sizes' ou 'tamanhos' em List<ItemSize>
      images =
          ((((document.data() as Map<String, dynamic>?) ??
                      const <String, dynamic>{})['images']
                  as List?)                            // Busca array 'images' e faz cast para List
              ?.map((e) => e.toString())               // Converte cada item da lista para String (URL)
              .toList()) ??
          <String>[],                                  // Se null, retorna lista vazia
      basePrice =
          _toNum(                                      // Converte valor para num usando _toNum
            ((document.data() as Map<String, dynamic>?) ??
                    const <String, dynamic>{})['basePrice'] ??  // Tenta basePrice
                ((document.data() as Map<String, dynamic>?) ??
                    const <String, dynamic>{})['price'] ??       // Tenta price
                ((document.data() as Map<String, dynamic>?) ??
                    const <String, dynamic>{})['preco'] ??       // Tenta preco
                ((document.data() as Map<String, dynamic>?) ??
                    const <String, dynamic>{})['valor'],         // Tenta valor
          ) ??
          0 {                                          // Se nenhum existir, usa 0
    _selectedSize = null;                              // Inicia sem tamanho selecionado (botão fica desabilitado)
  }

  // Converte o array de tamanhos do Firestore em List<ItemSize>
  static List<ItemSize> _parseSizes(DocumentSnapshot document) {
    final data =
        (document.data() as Map<String, dynamic>?) ?? const <String, dynamic>{};  // Dados do documento ou Map vazio
    final raw = (data['sizes'] ?? data['tamanhos']) as List?;  // Busca 'sizes' ou 'tamanhos' (pt-BR)
    if (raw == null || raw.isEmpty) return [];         // Se não houver tamanhos, retorna lista vazia

    return raw.map((e) {                               // Para cada item do array
      if (e is Map) {                                  // Se for um Map (objeto com name, price, stock)
        return ItemSize.fromMap(_normalizeSizeMap(Map<String, dynamic>.from(e)));  // Converte e normaliza
      }
      return ItemSize.fromMap({'name': e.toString(), 'price': 0, 'stock': 0});  // Fallback para formato inválido
    }).toList();
  }

  // Normaliza os nomes dos campos (aceita name/nome, price/preco, stock/estoque)
  static Map<String, dynamic> _normalizeSizeMap(Map<String, dynamic> m) {
    return {
      'name': (m['name'] ?? m['nome'] ?? '-').toString(),  // Nome do tamanho ou '-'
      'price': _toNum(m['price'] ?? m['preco']) ?? 0,     // Preço convertido para num ou 0
      'stock': _toInt(m['stock'] ?? m['estoque']) ?? 0,    // Estoque convertido para int ou 0
    };
  }

  // Converte valor dinâmico para int (aceita int, num ou String)
  static int? _toInt(dynamic v) {
    if (v is int) return v;                            // Já é int, retorna direto
    if (v is num) return v.toInt();                    // É num (double), converte para int
    if (v is String) return int.tryParse(v);           // Se não for número, retorna null
    return null;
  }

  // Converte valor dinâmico para num (aceita int, double ou String com vírgula/ponto)
  static num? _toNum(dynamic v) {
    if (v is num) return v;                            // Já é número, retorna direto
    if (v is String) {
      final normalized = v.replaceAll('.', '').replaceAll(',', '.');  // "1.234,56" -> "1234.56"
      return num.tryParse(normalized);                 // Converte String para número
    }
    return null;
  }

  // Retorna o preço a exibir: basePrice se > 0, senão o menor preço entre os tamanhos
  num get effectivePrice {
    if (basePrice > 0) return basePrice;               // Se tem preço base, usa ele
    if (sizes.isEmpty) return 0;                       // Se não tem tamanhos, retorna 0
    return sizes.map((s) => s.price).reduce((a, b) => a < b ? a : b);  // Retorna o menor preço dos tamanhos
  }

  ItemSize? findSize(String sizeName) {               // Busca o ItemSize pelo nome (P, M, GG)
    try {                                            // Tenta encontrar na lista de tamanhos
      return sizes.firstWhere((s) => s.name == sizeName); // Retorna o tamanho com nome correspondente
    } on StateError {                                 // StateError quando firstWhere não encontra
      return null;                                    // Retorna null se o tamanho não existir
    }
  }

  ItemSize? _selectedSize;                              // Tamanho atualmente selecionado (null = nenhum)
  ItemSize? get selectedSize => _selectedSize;         // Getter para ler o tamanho selecionado
  set selectedSize(ItemSize? value) {
    _selectedSize = value;                             // Atualiza o tamanho selecionado
    notifyListeners();                                 // Notifica a UI para reconstruir (Provider)
  }

}
