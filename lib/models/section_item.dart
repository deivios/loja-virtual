class SectionItem {
  SectionItem.fromMap(Map<String, dynamic> map) {
    // construtor a partir de um mapa (ex: dados do Firestore)
    image = map['image'] as String; // extrai a URL ou caminho da imagem
  }

  late String image; // URL ou caminho da imagem do item

  @override
  String toString() {
    // sobrescreve toString para exibir o conteúdo ao debugar/inspecionar
    return 'SectionItem{image: $image}'; // retorna representação em texto do objeto
  }
}
