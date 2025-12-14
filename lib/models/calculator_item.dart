class CalculatorItem {
  final String serviceId;
  final String serviceName;
  final String serviceNameRu;
  final String unit;
  final String unitRu;
  final double quantity;
  final double pricePerUnit;
  final String countryCode;

  CalculatorItem({
    required this.serviceId,
    required this.serviceName,
    required this.serviceNameRu,
    required this.unit,
    required this.unitRu,
    required this.quantity,
    required this.pricePerUnit,
    required this.countryCode,
  });

  double get total => quantity * pricePerUnit;

  CalculatorItem copyWith({
    String? serviceId,
    String? serviceName,
    String? serviceNameRu,
    String? unit,
    String? unitRu,
    double? quantity,
    double? pricePerUnit,
    String? countryCode,
  }) {
    return CalculatorItem(
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      serviceNameRu: serviceNameRu ?? this.serviceNameRu,
      unit: unit ?? this.unit,
      unitRu: unitRu ?? this.unitRu,
      quantity: quantity ?? this.quantity,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      countryCode: countryCode ?? this.countryCode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceId,
      'service_name': serviceName,
      'service_name_ru': serviceNameRu,
      'unit': unit,
      'unit_ru': unitRu,
      'quantity': quantity,
      'price_per_unit': pricePerUnit,
      'country_code': countryCode,
    };
  }

  factory CalculatorItem.fromJson(Map<String, dynamic> json) {
    return CalculatorItem(
      serviceId: json['service_id'] as String,
      serviceName: json['service_name'] as String,
      serviceNameRu: json['service_name_ru'] as String,
      unit: json['unit'] as String,
      unitRu: json['unit_ru'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      pricePerUnit: (json['price_per_unit'] as num).toDouble(),
      countryCode: json['country_code'] as String,
    );
  }
}
