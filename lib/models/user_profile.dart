class UserProfile {
  final String? name;
  final String? displayName;  // Добавлено для совместимости
  final String? email;
  final String? phone;
  final String? company;
  final String? profession;
  final String preferredCountry;
  final String preferredCurrency;
  final bool showPricesWithVAT;

  UserProfile({
    this.name,
    String? displayName,
    this.email,
    this.phone,
    this.company,
    this.profession,
    this.preferredCountry = 'DE',
    this.preferredCurrency = 'EUR',
    this.showPricesWithVAT = true,
  }) : displayName = displayName ?? name;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String?,
      displayName: json['display_name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      company: json['company'] as String?,
      profession: json['profession'] as String?,
      preferredCountry: json['preferred_country'] as String? ?? 'DE',
      preferredCurrency: json['preferred_currency'] as String? ?? 'EUR',
      showPricesWithVAT: json['show_prices_with_vat'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'display_name': displayName,
      'email': email,
      'phone': phone,
      'company': company,
      'profession': profession,
      'preferred_country': preferredCountry,
      'preferred_currency': preferredCurrency,
      'show_prices_with_vat': showPricesWithVAT,
    };
  }

  UserProfile copyWith({
    String? name,
    String? displayName,
    String? email,
    String? phone,
    String? company,
    String? profession,
    String? preferredCountry,
    String? preferredCurrency,
    bool? showPricesWithVAT,
  }) {
    return UserProfile(
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      profession: profession ?? this.profession,
      preferredCountry: preferredCountry ?? this.preferredCountry,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      showPricesWithVAT: showPricesWithVAT ?? this.showPricesWithVAT,
    );
  }
  
  bool get isComplete => 
      name != null && 
      name!.isNotEmpty && 
      email != null && 
      email!.isNotEmpty;
}
