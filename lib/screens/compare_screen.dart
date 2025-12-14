import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../providers/theme_provider.dart';
import '../models/country.dart';
import '../widgets/glass_container.dart';
import '../services/location_service.dart';
import '../l10n/app_localizations.dart';

class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  String? _selectedCountry1;
  String? _selectedCountry2;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadUserCountry();
  }

  Future<void> _loadUserCountry() async {
    final userCountry = await LocationService().getUserCountry();
    if (mounted && userCountry != null) {
      setState(() {
        _selectedCountry1 = userCountry;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _buildCompareContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return GlassContainer(
      gradientColors: isDark 
        ? [const Color(0xFF2D7A3F), const Color(0xFF388E3C)]
        : [const Color(0xFF4CAF50), const Color(0xFF388E3C)],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Сравнение цен',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Сравните цены между странами',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompareContent(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCountrySelectors(context, dataProvider),
                const SizedBox(height: 20),
                _buildCategorySelector(context, dataProvider),
                const SizedBox(height: 20),
                if (_selectedCountry1 != null &&
                    _selectedCountry2 != null &&
                    _selectedCategoryId != null)
                  _buildComparisonResults(context, dataProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCountrySelectors(
      BuildContext context, DataProvider dataProvider) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      opacity: isDark ? 0.15 : 0.25,
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Выберите страны для сравнения',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildCountryDropdown(
            'Страна 1',
            _selectedCountry1,
            dataProvider.countries,
            (value) {
              setState(() {
                _selectedCountry1 = value;
              });
            },
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.compare_arrows, color: Color(0xFF4CAF50)),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 12),
          _buildCountryDropdown(
            'Страна 2',
            _selectedCountry2,
            dataProvider.countries,
            (value) {
              setState(() {
                _selectedCountry2 = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCountryDropdown(
    String label,
    String? selectedValue,
    List<Country> countries,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedValue,
              hint: const Text('Выберите страну'),
              items: countries.map((country) {
                return DropdownMenuItem<String>(
                  value: country.code,
                  child: Row(
                    children: [
                      Text(country.flagEmoji, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Text(country.nameRu),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector(
      BuildContext context, DataProvider dataProvider) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      opacity: isDark ? 0.15 : 0.25,
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Выберите категорию услуг',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: dataProvider.categories.map((category) {
              final isSelected = _selectedCategoryId == category.id;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategoryId = category.id;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? category.color
                        : category.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        category.icon,
                        size: 18,
                        color: isSelected ? Colors.white : category.color,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        category.getLocalizedName(AppLocalizations.of(context).translate),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : category.color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonResults(
      BuildContext context, DataProvider dataProvider) {
    final country1 = dataProvider.countries
        .firstWhere((c) => c.code == _selectedCountry1);
    final country2 = dataProvider.countries
        .firstWhere((c) => c.code == _selectedCountry2);
    final category = dataProvider.categories
        .firstWhere((c) => c.id == _selectedCategoryId);

    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      opacity: isDark ? 0.15 : 0.25,
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(category.icon, color: category.color),
              const SizedBox(width: 12),
              Text(
                category.getLocalizedName(AppLocalizations.of(context).translate),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...category.services.map((service) {
            final price1 = service.pricesByCountry[country1.code];
            final price2 = service.pricesByCountry[country2.code];

            if (price1 == null || price2 == null) {
              return const SizedBox.shrink();
            }

            return _buildServiceComparison(
              service.nameRu,
              service.unitRu,
              country1,
              price1.average,
              country2,
              price2.average,
              category.color,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildServiceComparison(
    String serviceName,
    String unit,
    Country country1,
    double price1,
    Country country2,
    double price2,
    Color color,
  ) {
    final difference = ((price1 - price2) / price2 * 100).abs();
    final isCountry1Cheaper = price1 < price2;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            serviceName,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPriceColumn(
                  country1.flagEmoji,
                  country1.nameRu,
                  price1,
                  unit,
                  isCountry1Cheaper,
                  color,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.trending_up, color: Colors.white, size: 16),
                    const SizedBox(height: 4),
                    Text(
                      '${difference.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPriceColumn(
                  country2.flagEmoji,
                  country2.nameRu,
                  price2,
                  unit,
                  !isCountry1Cheaper,
                  color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceColumn(
    String flag,
    String countryName,
    double price,
    String unit,
    bool isCheaper,
    Color color,
  ) {
    return Column(
      children: [
        Text(flag, style: const TextStyle(fontSize: 32)),
        const SizedBox(height: 4),
        Text(
          countryName,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: isCheaper
                ? const Color(0xFF4CAF50)
                : color.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                '€${price.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isCheaper ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                'за $unit',
                style: TextStyle(
                  fontSize: 10,
                  color: isCheaper ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
        if (isCheaper)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(
              Icons.check_circle,
              color: Color(0xFF4CAF50),
              size: 20,
            ),
          ),
      ],
    );
  }
}
