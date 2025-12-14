import 'dart:math';

enum RoomType {
  apartment('Квартира', 'Apartment'),
  house('Дом', 'House'),
  office('Офис', 'Office'),
  commercial('Коммерческое', 'Commercial');

  final String nameRu;
  final String nameEn;
  const RoomType(this.nameRu, this.nameEn);
}

enum ObjectCondition {
  newConstruction('Новостройка', 'New Construction'),
  secondary('Вторичка', 'Secondary'),
  requiresRenovation('Требует ремонта', 'Requires Renovation');

  final String nameRu;
  final String nameEn;
  const ObjectCondition(this.nameRu, this.nameEn);
}

enum DesignComplexity {
  standard('Стандартный', 'Standard'),
  medium('Средний', 'Medium'),
  premium('Премиум', 'Premium');

  final String nameRu;
  final String nameEn;
  const DesignComplexity(this.nameRu, this.nameEn);
}

class RoomParameters {
  final RoomType roomType;
  final ObjectCondition condition;
  final DesignComplexity complexity;
  final double floorArea; // м²
  final double ceilingHeight; // м
  final bool includeMaterials;
  final bool includeVAT;
  final double vatRate;

  RoomParameters({
    this.roomType = RoomType.apartment,
    this.condition = ObjectCondition.newConstruction,
    this.complexity = DesignComplexity.standard,
    this.floorArea = 20.0,
    this.ceilingHeight = 2.5,
    this.includeMaterials = false,
    this.includeVAT = true,
    this.vatRate = 20.0,
  });

  // Расчет площади стен
  double get wallArea {
    // Предполагаем квадратное помещение для упрощения
    final sideLength = sqrt(floorArea);
    final perimeter = sideLength * 4;
    return perimeter * ceilingHeight;
  }

  // Расчет площади потолка
  double get ceilingArea => floorArea;

  // Расчет периметра
  double get perimeter {
    final sideLength = sqrt(floorArea);
    return sideLength * 4;
  }

  // Коэффициент сложности для расчета
  double get complexityMultiplier {
    switch (complexity) {
      case DesignComplexity.standard:
        return 1.0;
      case DesignComplexity.medium:
        return 1.3;
      case DesignComplexity.premium:
        return 1.6;
    }
  }

  // Коэффициент состояния объекта
  double get conditionMultiplier {
    switch (condition) {
      case ObjectCondition.newConstruction:
        return 1.0;
      case ObjectCondition.secondary:
        return 1.15;
      case ObjectCondition.requiresRenovation:
        return 1.35;
    }
  }

  // Коэффициент материалов
  double get materialsMultiplier => includeMaterials ? 2.5 : 1.0;

  // Коэффициент НДС
  double get vatMultiplier => includeVAT ? (1 + vatRate / 100) : 1.0;

  RoomParameters copyWith({
    RoomType? roomType,
    ObjectCondition? condition,
    DesignComplexity? complexity,
    double? floorArea,
    double? ceilingHeight,
    bool? includeMaterials,
    bool? includeVAT,
    double? vatRate,
  }) {
    return RoomParameters(
      roomType: roomType ?? this.roomType,
      condition: condition ?? this.condition,
      complexity: complexity ?? this.complexity,
      floorArea: floorArea ?? this.floorArea,
      ceilingHeight: ceilingHeight ?? this.ceilingHeight,
      includeMaterials: includeMaterials ?? this.includeMaterials,
      includeVAT: includeVAT ?? this.includeVAT,
      vatRate: vatRate ?? this.vatRate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'room_type': roomType.name,
      'condition': condition.name,
      'complexity': complexity.name,
      'floor_area': floorArea,
      'ceiling_height': ceilingHeight,
      'include_materials': includeMaterials,
      'include_vat': includeVAT,
      'vat_rate': vatRate,
    };
  }

  factory RoomParameters.fromJson(Map<String, dynamic> json) {
    return RoomParameters(
      roomType: RoomType.values.firstWhere(
        (e) => e.name == json['room_type'],
        orElse: () => RoomType.apartment,
      ),
      condition: ObjectCondition.values.firstWhere(
        (e) => e.name == json['condition'],
        orElse: () => ObjectCondition.newConstruction,
      ),
      complexity: DesignComplexity.values.firstWhere(
        (e) => e.name == json['complexity'],
        orElse: () => DesignComplexity.standard,
      ),
      floorArea: (json['floor_area'] as num?)?.toDouble() ?? 20.0,
      ceilingHeight: (json['ceiling_height'] as num?)?.toDouble() ?? 2.5,
      includeMaterials: json['include_materials'] as bool? ?? false,
      includeVAT: json['include_vat'] as bool? ?? true,
      vatRate: (json['vat_rate'] as num?)?.toDouble() ?? 20.0,
    );
  }
}
