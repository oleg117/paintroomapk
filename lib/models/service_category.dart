import 'package:flutter/material.dart';

class ServiceCategory {
  final String id;
  final String name;
  final String nameRu;
  final String description;
  final String descriptionRu;
  final IconData icon;
  final Color color;
  final List<ServiceItem> services;

  ServiceCategory({
    required this.id,
    required this.name,
    required this.nameRu,
    required this.description,
    required this.descriptionRu,
    required this.icon,
    required this.color,
    required this.services,
  });

  // Получить локализованное имя категории
  String getLocalizedName(String Function(String) translate) {
    final key = 'cat_$id';
    final translated = translate(key);
    // Если перевод не найден, вернуть name
    return translated == key ? name : translated;
  }

  // Получить локализованное описание категории
  String getLocalizedDescription(String Function(String) translate) {
    final key = 'cat_${id}_desc';
    final translated = translate(key);
    // Если перевод не найден, вернуть description
    return translated == key ? description : translated;
  }
}

class ServiceItem {
  final String id;
  final String categoryId;
  final String name;
  final String nameRu;
  final String unit;
  final String unitRu;
  final Map<String, PriceRange> pricesByCountry;
  final double materialsCostRatio; // Коэффициент стоимости материалов (0.0 - 3.0)

  ServiceItem({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.nameRu,
    required this.unit,
    required this.unitRu,
    required this.pricesByCountry,
    this.materialsCostRatio = 1.5, // По умолчанию материалы добавляют 50% к стоимости работ
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    final pricesJson = json['prices_by_country'] as Map<String, dynamic>;
    final pricesByCountry = <String, PriceRange>{};
    
    pricesJson.forEach((key, value) {
      pricesByCountry[key] = PriceRange.fromJson(value as Map<String, dynamic>);
    });

    return ServiceItem(
      id: json['id'] as String,
      categoryId: json['category_id'] as String,
      name: json['name'] as String,
      nameRu: json['name_ru'] as String,
      unit: json['unit'] as String,
      unitRu: json['unit_ru'] as String,
      pricesByCountry: pricesByCountry,
      materialsCostRatio: (json['materials_cost_ratio'] as num?)?.toDouble() ?? 1.5,
    );
  }

  Map<String, dynamic> toJson() {
    final pricesJson = <String, dynamic>{};
    pricesByCountry.forEach((key, value) {
      pricesJson[key] = value.toJson();
    });

    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'name_ru': nameRu,
      'unit': unit,
      'unit_ru': unitRu,
      'prices_by_country': pricesJson,
      'materials_cost_ratio': materialsCostRatio,
    };
  }
}

class PriceRange {
  final double min;
  final double max;
  final double average;

  PriceRange({
    required this.min,
    required this.max,
    required this.average,
  });

  factory PriceRange.fromJson(Map<String, dynamic> json) {
    return PriceRange(
      min: (json['min'] as num).toDouble(),
      max: (json['max'] as num).toDouble(),
      average: (json['average'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'min': min,
      'max': max,
      'average': average,
    };
  }

  String formatRange() {
    return '€${min.toStringAsFixed(0)} - €${max.toStringAsFixed(0)}';
  }
}
