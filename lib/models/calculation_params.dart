class CalculationParams {
  String countryCode;
  String roomType;
  String condition;
  String designComplexity;
  double floorArea;
  double ceilingHeight;
  bool includeVAT;
  bool includeMaterials;

  CalculationParams({
    this.countryCode = 'DE',
    this.roomType = 'apartment',
    this.condition = 'new',
    this.designComplexity = 'standard',
    this.floorArea = 50.0,
    this.ceilingHeight = 2.7,
    this.includeVAT = true,
    this.includeMaterials = false,
  });

  // Расчетные площади
  double get wallArea {
    // Периметр * высота - окна и двери (примерно 15%)
    final perimeter = 4 * (floorArea / 3).clamp(10, 50);
    return (perimeter * ceilingHeight * 0.85);
  }

  double get ceilingArea => floorArea;

  double get perimeter {
    return 4 * (floorArea / 3).clamp(10, 50);
  }

  CalculationParams copyWith({
    String? countryCode,
    String? roomType,
    String? condition,
    String? designComplexity,
    double? floorArea,
    double? ceilingHeight,
    bool? includeVAT,
    bool? includeMaterials,
  }) {
    return CalculationParams(
      countryCode: countryCode ?? this.countryCode,
      roomType: roomType ?? this.roomType,
      condition: condition ?? this.condition,
      designComplexity: designComplexity ?? this.designComplexity,
      floorArea: floorArea ?? this.floorArea,
      ceilingHeight: ceilingHeight ?? this.ceilingHeight,
      includeVAT: includeVAT ?? this.includeVAT,
      includeMaterials: includeMaterials ?? this.includeMaterials,
    );
  }
}

class WorkCategory {
  final String id;
  final String nameRu;
  final String icon;
  bool enabled;
  Map<String, bool> options;

  WorkCategory({
    required this.id,
    required this.nameRu,
    required this.icon,
    this.enabled = false,
    Map<String, bool>? options,
  }) : options = options ?? {};
}
