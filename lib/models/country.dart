class Country {
  final String id;
  final String name;
  final String nameRu;
  final String code;
  final String flagEmoji;
  final double averagePricePerSqm;
  final String currency;

  Country({
    required this.id,
    required this.name,
    required this.nameRu,
    required this.code,
    required this.flagEmoji,
    required this.averagePricePerSqm,
    this.currency = 'EUR',
  });

  // Добавлен геттер для совместимости
  String get flag => flagEmoji;

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'] as String,
      name: json['name'] as String,
      nameRu: json['name_ru'] as String,
      code: json['code'] as String,
      flagEmoji: json['flag_emoji'] as String,
      averagePricePerSqm: (json['average_price_per_sqm'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'EUR',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ru': nameRu,
      'code': code,
      'flag_emoji': flagEmoji,
      'average_price_per_sqm': averagePricePerSqm,
      'currency': currency,
    };
  }
}
