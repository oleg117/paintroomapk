import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/service_category.dart';
import '../models/calculator_item.dart';
import '../providers/data_provider.dart';
import '../l10n/app_localizations.dart';

class ServicesScreen extends StatelessWidget {
  final ServiceCategory category;

  const ServicesScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _buildServicesList(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: category.color,
        boxShadow: [
          BoxShadow(
            color: category.color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    category.icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.getLocalizedName(AppLocalizations.of(context).translate),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        category.getLocalizedDescription(AppLocalizations.of(context).translate),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesList(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        final country = dataProvider.selectedCountry;
        if (country == null) {
          return const Center(child: Text('Выберите страну'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: category.services.length,
          itemBuilder: (context, index) {
            final service = category.services[index];
            final priceRange = service.pricesByCountry[country.code];

            if (priceRange == null) {
              return const SizedBox.shrink();
            }

            return _buildServiceCard(context, service, priceRange, country.code);
          },
        );
      },
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    ServiceItem service,
    PriceRange priceRange,
    String countryCode,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    service.nameRu,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    service.unitRu,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: category.color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Минимум',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '€${priceRange.min.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Средняя',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '€${priceRange.average.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6B35),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Максимум',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '€${priceRange.max.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF44336),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                _addToCalculator(context, service, priceRange, countryCode);
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Добавить в калькулятор'),
              style: ElevatedButton.styleFrom(
                backgroundColor: category.color,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCalculator(
    BuildContext context,
    ServiceItem service,
    PriceRange priceRange,
    String countryCode,
  ) {
    showDialog(
      context: context,
      builder: (context) => _AddToCalculatorDialog(
        service: service,
        priceRange: priceRange,
        countryCode: countryCode,
        categoryColor: category.color,
      ),
    );
  }
}

class _AddToCalculatorDialog extends StatefulWidget {
  final ServiceItem service;
  final PriceRange priceRange;
  final String countryCode;
  final Color categoryColor;

  const _AddToCalculatorDialog({
    required this.service,
    required this.priceRange,
    required this.countryCode,
    required this.categoryColor,
  });

  @override
  State<_AddToCalculatorDialog> createState() => _AddToCalculatorDialogState();
}

class _AddToCalculatorDialogState extends State<_AddToCalculatorDialog> {
  late TextEditingController _quantityController;
  late double _selectedPrice;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: '1');
    _selectedPrice = widget.priceRange.average;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final total = quantity * _selectedPrice;

    return AlertDialog(
      title: Text(widget.service.nameRu),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Количество:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              suffixText: widget.service.unitRu,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Цена за единицу:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildPriceChip('Мин', widget.priceRange.min),
              const SizedBox(width: 8),
              _buildPriceChip('Сред', widget.priceRange.average),
              const SizedBox(width: 8),
              _buildPriceChip('Макс', widget.priceRange.max),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.categoryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Итого:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '€${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: widget.categoryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: () {
            final dataProvider =
                Provider.of<DataProvider>(context, listen: false);
            dataProvider.addCalculatorItem(
              CalculatorItem(
                serviceId: widget.service.id,
                serviceName: widget.service.name,
                serviceNameRu: widget.service.nameRu,
                unit: widget.service.unit,
                unitRu: widget.service.unitRu,
                quantity: quantity,
                pricePerUnit: _selectedPrice,
                countryCode: widget.countryCode,
              ),
            );
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Добавлено в калькулятор'),
                backgroundColor: Color(0xFF4CAF50),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.categoryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('Добавить'),
        ),
      ],
    );
  }

  Widget _buildPriceChip(String label, double price) {
    final isSelected = _selectedPrice == price;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPrice = price;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? widget.categoryColor
                : widget.categoryColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? Colors.white : widget.categoryColor,
                ),
              ),
              Text(
                '€${price.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : widget.categoryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
