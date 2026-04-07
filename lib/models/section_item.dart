class SectionItem {
  SectionItem.fromMap(Map<String, dynamic> map) {
    image = _firstValidImageUrl(map, const ['image', 'url']);
    link = _firstNonEmptyString(map, const [
      'link',
      'target',
      'externalUrl',
      'external_url',
      'href',
    ]);
    product = _firstNonEmptyString(map, const [
      'product',
      'produto',
      'productId',
      'product_id',
      'pid',
      'id',
    ]);
  }

  late String image;
  late String link;
  late String product;

  static final RegExp _invalidLiterals = RegExp(
    r'^(null|undefined|\[\]|\{\})$',
    caseSensitive: false,
  );

  static String _firstNonEmptyString(
    Map<String, dynamic> map,
    List<String> keys,
  ) {
    for (final key in keys) {
      final text = _normalizeValueAsText(map[key]);
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  static String _firstValidImageUrl(
    Map<String, dynamic> map,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = map[key];
      final candidates = <dynamic>[
        value,
        if (value is List) ...value,
      ];
      for (final candidate in candidates) {
        final text = _normalizeValueAsText(candidate);
        if (text.isEmpty) continue;
        final uri = Uri.tryParse(text);
        final isHttp = uri != null &&
            (uri.scheme == 'http' || uri.scheme == 'https') &&
            (uri.host.isNotEmpty);
        if (isHttp) return text;
      }
    }
    return '';
  }

  static String _normalizeValueAsText(dynamic value) {
    if (value == null) return '';
    if (value is String) {
      final text = value.trim();
      if (_invalidLiterals.hasMatch(text)) return '';
      return text;
    }
    if (value is num || value is bool) return value.toString();
    return '';
  }

  @override
  String toString() {
    return 'SectionItem{image: $image, link: $link, product: $product}';
  }
}
