import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/data_provider.dart';
import '../providers/theme_provider.dart';
import '../models/room_parameters.dart';
import '../models/service_category.dart';
import '../widgets/glass_container.dart';
import '../l10n/app_localizations.dart';

class AdvancedCalculatorScreen extends StatefulWidget {
  const AdvancedCalculatorScreen({super.key});

  @override
  State<AdvancedCalculatorScreen> createState() =>
      _AdvancedCalculatorScreenState();
}

class _AdvancedCalculatorScreenState extends State<AdvancedCalculatorScreen> {
  RoomParameters _roomParams = RoomParameters();
  final Map<String, bool> _selectedWorks = {};
  final Map<String, int> _workQuantities = {};
  final Map<String, bool> _expandedCategories = {}; // Для отслеживания раскрытых категорий
  bool _showResults = false; // Флаг показа результатов расчёта
  final ScrollController _scrollController = ScrollController(); // Контроллер прокрутки

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  _buildHeader(context),
                  if (_showResults) _buildResultsSection(context),
                  _buildParametersSection(context),
                  _buildWorksSection(context),
                  _buildAdditionalOptions(context),
                  const SizedBox(height: 100), // Padding для кнопки
                ],
              ),
            ),
            _buildFloatingCalculateButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).translate('calculator_pro'),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: theme.textTheme.headlineLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context).translate('calculator_subtitle'),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: theme.primaryColor),
            onPressed: () {
              setState(() {
                _roomParams = RoomParameters();
                _selectedWorks.clear();
                _workQuantities.clear();
                _showResults = false;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildParametersSection(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final country = dataProvider.selectedCountry;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return GlassContainer(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      opacity: isDark ? 0.15 : 0.25,
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.settings, color: Color(0xFF2196F3)),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context).translate('object_parameters'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Страна
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Выбрать страну',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            country?.flagEmoji ?? '🌍',
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              country?.nameRu ?? 'Выберите страну',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Тип помещения',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDropdown<RoomType>(
                      value: _roomParams.roomType,
                      items: RoomType.values,
                      itemLabel: (type) => type.nameRu,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _roomParams = _roomParams.copyWith(roomType: value);
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Состояние и сложность
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Состояние объекта',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDropdown<ObjectCondition>(
                      value: _roomParams.condition,
                      items: ObjectCondition.values,
                      itemLabel: (cond) => cond.nameRu,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _roomParams = _roomParams.copyWith(condition: value);
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Сложность дизайна',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDropdown<DesignComplexity>(
                      value: _roomParams.complexity,
                      items: DesignComplexity.values,
                      itemLabel: (comp) => comp.nameRu,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _roomParams =
                                _roomParams.copyWith(complexity: value);
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Площадь пола
          _buildSlider(
            label: 'Площадь пола',
            value: _roomParams.floorArea,
            min: 5,
            max: 200,
            unit: 'м²',
            icon: Icons.square_foot,
            color: const Color(0xFFFF6B35),
            onChanged: (value) {
              setState(() {
                _roomParams = _roomParams.copyWith(floorArea: value);
              });
            },
          ),
          const SizedBox(height: 16),

          // Высота потолков
          _buildSlider(
            label: 'Высота потолков',
            value: _roomParams.ceilingHeight,
            min: 2.0,
            max: 5.0,
            unit: 'м',
            icon: Icons.height,
            color: const Color(0xFF2196F3),
            onChanged: (value) {
              setState(() {
                _roomParams = _roomParams.copyWith(ceilingHeight: value);
              });
            },
          ),
          const SizedBox(height: 24),

          // Визуализация помещения
          _buildRoomVisualization(context),
          
          const SizedBox(height: 20),

          // Расчетные площади с прогресс-барами
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2196F3).withValues(alpha: 0.1),
                  const Color(0xFF42A5F5).withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF2196F3).withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2196F3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.calculate,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Автоматический расчет площадей',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildAreaProgressBar(
                  'Площадь стен',
                  _roomParams.wallArea,
                  Icons.square,
                  const Color(0xFFFF6B35),
                  200,
                ),
                const SizedBox(height: 16),
                _buildAreaProgressBar(
                  'Площадь потолка',
                  _roomParams.ceilingArea,
                  Icons.crop_square,
                  const Color(0xFF4CAF50),
                  200,
                ),
                const SizedBox(height: 16),
                _buildAreaProgressBar(
                  'Периметр',
                  _roomParams.perimeter,
                  Icons.straighten,
                  const Color(0xFF9C27B0),
                  80,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorksSection(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final country = dataProvider.selectedCountry;

    if (country == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: dataProvider.categories.map((category) {
          return _buildCategorySection(category, country.code);
        }).toList(),
      ),
    );
  }

  // Автоматический расчёт количества на основе параметров помещения
  int _getAutoQuantity(String serviceId) {
    // Округляем до целых для удобства
    switch (serviceId) {
      // Малярные работы (полные ID после категории)
      case 'painting_interior_walls':
      case 'interior_walls':
      case 'painting_exterior_facade':
      case 'exterior_facade':
      case 'painting_wallpaper':
      case 'wallpaper':
      case 'painting_decorative':
      case 'decorative':
        return _roomParams.wallArea.round(); // Площадь стен
      
      case 'painting_ceiling':
      case 'ceiling':
        return _roomParams.ceilingArea.round(); // Площадь потолка
      
      // Напольные покрытия
      case 'flooring_laminate':
      case 'laminate':
      case 'flooring_parquet':
      case 'parquet':
      case 'flooring_vinyl':
      case 'vinyl':
        return _roomParams.floorArea.round(); // Площадь пола
      
      // Облицовка плиткой
      case 'tiling_floor':
      case 'floor':
      case 'tiling_wall':
        return _roomParams.floorArea.round(); // Площадь пола (по умолчанию)
      
      // Электромонтаж (штучные работы) - по умолчанию 1 шт
      case 'electrical_outlet':
      case 'outlet':
      case 'electrical_switch':
      case 'switch':
      case 'electrical_lighting':
      case 'lighting':
      case 'electrical_wiring':
      case 'wiring':
        return 1; // Пользователь может увеличить
      
      // Сантехника (штучные работы)
      case 'plumbing_toilet':
      case 'toilet':
      case 'plumbing_sink':
      case 'sink':
      case 'plumbing_kitchen_sink':
      case 'kitchen_sink':
      case 'plumbing_shower':
      case 'shower':
      case 'plumbing_bathtub':
      case 'bathtub':
      case 'plumbing_shower_cabin':
      case 'shower_cabin':
      case 'plumbing_mixer':
      case 'mixer':
        return 1;
      
      // Сантехника (погонные метры)
      case 'plumbing_pipe_replacement':
      case 'pipe_replacement':
        return _roomParams.perimeter.round(); // Погонные метры труб
      
      // Столярные работы (штучные)
      case 'carpentry_door':
      case 'door':
      case 'carpentry_window':
      case 'window':
        return 1;
      
      // Кровельные работы
      case 'roofing_tile_replacement':
      case 'tile_replacement':
      case 'roofing_waterproofing':
      case 'waterproofing':
        return _roomParams.floorArea.round(); // Площадь кровли ≈ площадь пола
      
      case 'roofing_gutter_installation':
      case 'gutter_installation':
        return _roomParams.perimeter.round(); // Погонные метры
      
      // Фасадные работы
      case 'facade_insulation':
      case 'insulation':
      case 'facade_plastering':
      case 'plastering':
        return _roomParams.wallArea.round(); // Площадь стен
      
      // HVAC (штучные)
      case 'hvac_radiator':
      case 'radiator':
      case 'hvac_ac_installation':
      case 'ac_installation':
      case 'hvac_ventilation':
      case 'ventilation':
        return 1;
      
      // Остекление (штучные)
      case 'glazing_window_pvc':
      case 'window_pvc':
      case 'glazing_door_installation':
      case 'door_installation':
        return 1;
      
      // Штукатурка и стены (общий случай для wall/ceiling если не попали в предыдущие)
      case 'plastering_wall':
      case 'wall':
        return _roomParams.wallArea.round(); // Площадь стен
      case 'plastering_drywall':
      case 'drywall':
      case 'plastering_ceiling':
        return _roomParams.ceilingArea.round(); // Гипсокартон на потолок
      
      // Ландшафт
      case 'landscaping_lawn':
      case 'lawn':
      case 'landscaping_paving':
      case 'paving':
        return _roomParams.floorArea.round();
      case 'landscaping_fence':
      case 'fence':
        return _roomParams.perimeter.round();
      
      default:
        return 1; // По умолчанию 1 единица
    }
  }

  Widget _buildCategorySection(ServiceCategory category, String countryCode) {
    // Инициализируем состояние раскрытия категории (по умолчанию - свернута)
    _expandedCategories[category.id] ??= false;
    final isExpanded = _expandedCategories[category.id]!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 16),
      opacity: isDark ? 0.15 : 0.25,
      borderRadius: 16,
      child: Column(
        children: [
          // Category header - теперь кликабельный
          InkWell(
            onTap: () {
              setState(() {
                _expandedCategories[category.id] = !isExpanded;
              });
            },
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isExpanded ? Radius.zero : const Radius.circular(16),
                  bottomRight: isExpanded ? Radius.zero : const Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: category.color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(category.icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      category.getLocalizedName(AppLocalizations.of(context).translate),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: category.color,
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
          // Services - показываем только если категория раскрыта
          if (isExpanded)
            ...category.services.map((service) {
              final workKey = '${category.id}_${service.id}';
              final isSelected = _selectedWorks[workKey] ?? false;
              final quantity = _workQuantities[workKey] ?? 0;
              final priceRange = service.pricesByCountry[countryCode];

              if (priceRange == null) return const SizedBox.shrink();

              return _buildWorkToggle(
                service.nameRu,
                service.unitRu,
                priceRange.average,
                isSelected,
                quantity,
                workKey,
                category.color,
              );
            }),
        ],
      ),
    );
  }

  Widget _buildWorkToggle(
    String name,
    String unit,
    double price,
    bool isSelected,
    int quantity,
    String workKey,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Switch(
            value: isSelected,
            onChanged: (value) {
              setState(() {
                _selectedWorks[workKey] = value;
                if (!value) {
                  _workQuantities[workKey] = 0;
                } else {
                  // Автоматически подставляем количество при включении
                  final parts = workKey.split('_');
                  final serviceId = parts.length >= 2 ? parts.sublist(1).join('_') : workKey;
                  _workQuantities[workKey] = _getAutoQuantity(serviceId);
                }
              });
            },
            activeThumbColor: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                Text(
                  '€${price.toStringAsFixed(0)} за $unit',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (isSelected) ...[
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  color: color,
                  onPressed: () {
                    if (quantity > 0) {
                      setState(() {
                        _workQuantities[workKey] = quantity - 1;
                      });
                    }
                  },
                ),
                Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: Text(
                    quantity.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: color,
                  onPressed: () {
                    setState(() {
                      _workQuantities[workKey] = quantity + 1;
                    });
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAdditionalOptions(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return GlassContainer(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      opacity: isDark ? 0.15 : 0.25,
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Дополнительные опции',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.shopping_cart, color: Colors.orange),
            ),
            title: const Text('Черновые материалы'),
            subtitle: Text(
              'Включить в расчет +${((_roomParams.materialsMultiplier - 1) * 100).toStringAsFixed(0)}% от стоимости работ на черновые материалы.',
              style: const TextStyle(fontSize: 12),
            ),
            value: _roomParams.includeMaterials,
            onChanged: (value) {
              setState(() {
                _roomParams = _roomParams.copyWith(includeMaterials: value);
              });
            },
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.percent, color: Colors.blue),
            ),
            title: Text('Ставка НДС ${_roomParams.vatRate.toStringAsFixed(0)}%'),
            subtitle: const Text(
              'Увеличить цену на дополнительную стоимость в итоговую смету.',
              style: TextStyle(fontSize: 12),
            ),
            value: _roomParams.includeVAT,
            onChanged: (value) {
              setState(() {
                _roomParams = _roomParams.copyWith(includeVAT: value);
              });
            },
          ),
        ],
      ),
    );
  }



  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required String Function(T) itemLabel,
    required void Function(T?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(itemLabel(item)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required String unit,
    required IconData icon,
    required Color color,
    required void Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${value.toStringAsFixed(value >= 10 ? 0 : 1)} $unit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: ((max - min) * (value >= 10 ? 1 : 10)).toInt(),
          activeColor: color,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildRoomVisualization(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Визуализация помещения',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_roomParams.floorArea.toStringAsFixed(0)} м²',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 3D представление комнаты
          Container(
            height: 180,
            child: CustomPaint(
              painter: RoomPainter(
                floorArea: _roomParams.floorArea,
                ceilingHeight: _roomParams.ceilingHeight,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.home_work,
                      size: 48,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_roomParams.ceilingHeight.toStringAsFixed(1)} м',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildRoomStat('Длина', '${math.sqrt(_roomParams.floorArea).toStringAsFixed(1)} м'),
              Container(
                width: 1,
                height: 30,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              _buildRoomStat('Высота', '${_roomParams.ceilingHeight.toStringAsFixed(1)} м'),
              Container(
                width: 1,
                height: 30,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              _buildRoomStat('Объем', '${(_roomParams.floorArea * _roomParams.ceilingHeight).toStringAsFixed(1)} м³'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoomStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildAreaProgressBar(
    String label,
    double value,
    IconData icon,
    Color color,
    double maxValue,
  ) {
    final percentage = (value / maxValue).clamp(0.0, 1.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${value.toStringAsFixed(1)} м${label.contains('Периметр') ? '' : '²'}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: percentage,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  double _calculateTotal() {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final country = dataProvider.selectedCountry;
    if (country == null) return 0;

    double totalLabor = 0;
    double totalMaterials = 0;

    _selectedWorks.forEach((workKey, isSelected) {
      if (isSelected) {
        final quantity = _workQuantities[workKey] ?? 0;
        if (quantity > 0) {
          final parts = workKey.split('_');
          if (parts.length >= 2) {
            final categoryId = parts[0];
            final serviceId = parts.sublist(1).join('_');

            final category = dataProvider.categories
                .where((c) => c.id == categoryId)
                .firstOrNull;
            if (category != null) {
              final service = category.services
                  .where((s) => s.id == serviceId)
                  .firstOrNull;
              if (service != null) {
                final priceRange = service.pricesByCountry[country.code];
                if (priceRange != null) {
                  final laborCost = priceRange.average * quantity;
                  totalLabor += laborCost;
                  
                  // Применяем индивидуальный коэффициент материалов для каждой работы
                  if (_roomParams.includeMaterials) {
                    totalMaterials += laborCost * (service.materialsCostRatio - 1.0);
                  }
                }
              }
            }
          }
        }
      }
    });

    // Сумма работ и материалов
    double subtotal = totalLabor + totalMaterials;
    
    // Применяем коэффициенты сложности и состояния
    subtotal *= _roomParams.complexityMultiplier;
    subtotal *= _roomParams.conditionMultiplier;
    
    // Применяем НДС к итоговой сумме
    subtotal *= _roomParams.vatMultiplier;

    return subtotal;
  }

  Widget _buildFloatingCalculateButton(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Positioned(
      right: 20,
      bottom: 20,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 300),
        scale: _showResults ? 0.9 : 1.0,
        child: FloatingActionButton.extended(
          onPressed: () {
            setState(() {
              _showResults = true;
            });
            // Прокручиваем наверх с анимацией
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
            );
          },
          backgroundColor: isDark ? const Color(0xFF2196F3) : const Color(0xFF1976D2),
          foregroundColor: Colors.white,
          elevation: 8,
          icon: const Icon(Icons.calculate, size: 28),
          label: const Text(
            'Расчёт',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsSection(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final total = _calculateTotal();
    
    return AnimatedOpacity(
      opacity: _showResults ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 600),
      child: GlassContainer(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        padding: const EdgeInsets.all(24),
        opacity: isDark ? 0.15 : 0.25,
        borderRadius: 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Результаты расчёта',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _showResults = false;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Анимированная диаграмма (круговая)
            Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeOutCubic,
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return CustomPaint(
                      painter: _PriceChartPainter(
                        progress: value,
                        total: total,
                        isDark: isDark,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '€${(total * value).toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              'Итого',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Детализация под диаграммой
            _buildCompactBreakdown(total),
            
            const SizedBox(height: 20),
            
            // Кнопка полной детализации
            Center(
              child: ElevatedButton.icon(
                onPressed: total > 0 ? () => _showBreakdown(context) : null,
                icon: const Icon(Icons.receipt_long),
                label: const Text('Подробная детализация'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF2196F3) : const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactBreakdown(double total) {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final country = dataProvider.selectedCountry;
    if (country == null) return const SizedBox.shrink();

    double laborSubtotal = 0;
    double materialsSubtotal = 0;
    int worksCount = 0;

    _selectedWorks.forEach((workKey, isSelected) {
      if (isSelected) {
        final quantity = _workQuantities[workKey] ?? 0;
        if (quantity > 0) {
          worksCount++;
          final parts = workKey.split('_');
          if (parts.length >= 2) {
            final categoryId = parts[0];
            final serviceId = parts.sublist(1).join('_');

            final category = dataProvider.categories
                .where((c) => c.id == categoryId)
                .firstOrNull;
            if (category != null) {
              final service = category.services
                  .where((s) => s.id == serviceId)
                  .firstOrNull;
              if (service != null) {
                final priceRange = service.pricesByCountry[country.code];
                if (priceRange != null) {
                  final laborCost = priceRange.average * quantity;
                  laborSubtotal += laborCost;
                  
                  final materialsCost = _roomParams.includeMaterials 
                      ? laborCost * (service.materialsCostRatio - 1.0)
                      : 0;
                  materialsSubtotal += materialsCost;
                }
              }
            }
          }
        }
      }
    });

    // Применяем коэффициенты
    final baseSubtotal = laborSubtotal + materialsSubtotal;
    final withComplexity = baseSubtotal * _roomParams.complexityMultiplier;
    final withCondition = withComplexity * _roomParams.conditionMultiplier;
    final finalTotal = withCondition * _roomParams.vatMultiplier;

    return Column(
      children: [
        _buildBreakdownRow('Выбрано работ', '$worksCount', Colors.blue),
        const SizedBox(height: 12),
        _buildBreakdownRow('Работы', '€${laborSubtotal.toStringAsFixed(2)}', Colors.orange),
        if (_roomParams.includeMaterials) ...[
          const SizedBox(height: 12),
          _buildBreakdownRow('Материалы', '€${materialsSubtotal.toStringAsFixed(2)}', Colors.green),
        ],
        if (_roomParams.complexityMultiplier != 1.0) ...[
          const SizedBox(height: 12),
          _buildBreakdownRow(
            'Коэфф. сложности',
            '×${_roomParams.complexityMultiplier.toStringAsFixed(2)}',
            Colors.purple,
          ),
        ],
        if (_roomParams.conditionMultiplier != 1.0) ...[
          const SizedBox(height: 12),
          _buildBreakdownRow(
            'Коэфф. состояния',
            '×${_roomParams.conditionMultiplier.toStringAsFixed(2)}',
            Colors.teal,
          ),
        ],
        if (_roomParams.vatMultiplier != 1.0) ...[
          const SizedBox(height: 12),
          _buildBreakdownRow(
            'НДС',
            '×${_roomParams.vatMultiplier.toStringAsFixed(2)}',
            Colors.red,
          ),
        ],
        const Divider(height: 32),
        _buildBreakdownRow(
          'ИТОГО',
          '€${finalTotal.toStringAsFixed(2)}',
          const Color(0xFFFF6B35),
          isBold: true,
        ),
      ],
    );
  }

  Widget _buildBreakdownRow(String label, String value, Color color, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: isBold ? 18 : 15,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18 : 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showBreakdown(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Детализация расчета',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildBreakdownContent(),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildBreakdownContent() {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final country = dataProvider.selectedCountry;
    if (country == null) return const SizedBox.shrink();

    final items = <Widget>[];
    double laborSubtotal = 0;
    double materialsSubtotal = 0;

    _selectedWorks.forEach((workKey, isSelected) {
      if (isSelected) {
        final quantity = _workQuantities[workKey] ?? 0;
        if (quantity > 0) {
          final parts = workKey.split('_');
          if (parts.length >= 2) {
            final categoryId = parts[0];
            final serviceId = parts.sublist(1).join('_');

            final category = dataProvider.categories
                .where((c) => c.id == categoryId)
                .firstOrNull;
            if (category != null) {
              final service = category.services
                  .where((s) => s.id == serviceId)
                  .firstOrNull;
              if (service != null) {
                final priceRange = service.pricesByCountry[country.code];
                if (priceRange != null) {
                  final laborCost = priceRange.average * quantity;
                  laborSubtotal += laborCost;
                  
                  // Рассчитываем материалы для этой работы
                  final materialsCost = _roomParams.includeMaterials 
                      ? laborCost * (service.materialsCostRatio - 1.0)
                      : 0;
                  materialsSubtotal += materialsCost;

                  items.add(
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service.nameRu,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '$quantity ${service.unitRu} × €${priceRange.average.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                if (_roomParams.includeMaterials && materialsCost > 0)
                                  Text(
                                    '  + материалы (×${service.materialsCostRatio.toStringAsFixed(1)}): €${materialsCost.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.green[700],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            '€${(laborCost + materialsCost).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              }
            }
          }
        }
      }
    });

    items.add(const Divider(height: 32));
    final subtotal = laborSubtotal + materialsSubtotal;
    items.add(Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Работы', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          Text('€${laborSubtotal.toStringAsFixed(2)}', 
               style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    ));
    if (_roomParams.includeMaterials && materialsSubtotal > 0) {
      items.add(Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Черновые материалы (итого)', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
            Text('€${materialsSubtotal.toStringAsFixed(2)}', 
                 style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ));
    }
    items.add(Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Промежуточный итог', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
          Text('€${subtotal.toStringAsFixed(2)}', 
               style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    ));

    final complexityAdjustment = subtotal * (_roomParams.complexityMultiplier - 1);
    if (complexityAdjustment > 0) {
      items.add(Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Сложность дизайна (${_roomParams.complexity.nameRu})', 
                 style: TextStyle(fontSize: 14, color: Colors.grey[700])),
            Text('€${complexityAdjustment.toStringAsFixed(2)}', 
                 style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ));
    }

    final conditionAdjustment = subtotal * (_roomParams.conditionMultiplier - 1);
    if (conditionAdjustment > 0) {
      items.add(Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Состояние объекта (${_roomParams.condition.nameRu})', 
                 style: TextStyle(fontSize: 14, color: Colors.grey[700])),
            Text('€${conditionAdjustment.toStringAsFixed(2)}', 
                 style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ));
    }

    double runningTotal = subtotal + complexityAdjustment + conditionAdjustment;

    if (_roomParams.includeVAT) {
      final vatAmount = runningTotal * (_roomParams.vatRate / 100);
      items.add(Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('НДС ${_roomParams.vatRate.toStringAsFixed(0)}%', 
                 style: TextStyle(fontSize: 14, color: Colors.grey[700])),
            Text('€${vatAmount.toStringAsFixed(2)}', 
                 style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ));
      runningTotal += vatAmount;
    }

    items.add(const Divider(height: 32));
    items.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'ИТОГО:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '€${runningTotal.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF6B35),
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items,
    );
  }


}

// Custom Painter для 3D визуализации комнаты
class RoomPainter extends CustomPainter {
  final double floorArea;
  final double ceilingHeight;

  RoomPainter({required this.floorArea, required this.ceilingHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final roomWidth = size.width * 0.5;
    final roomDepth = size.height * 0.3;
    final heightScale = ceilingHeight / 3.0;

    // Задняя стена (верхняя плоскость)
    final backTopLeft = Offset(center.dx - roomWidth / 2, center.dy - roomDepth - 20 * heightScale);
    final backTopRight = Offset(center.dx + roomWidth / 2, center.dy - roomDepth - 20 * heightScale);
    final backBottomLeft = Offset(center.dx - roomWidth / 2, center.dy - roomDepth + 20 * heightScale);
    final backBottomRight = Offset(center.dx + roomWidth / 2, center.dy - roomDepth + 20 * heightScale);

    // Передняя стена (нижняя плоскость)
    final frontTopLeft = Offset(center.dx - roomWidth / 2 - 20, center.dy + roomDepth - 20 * heightScale);
    final frontTopRight = Offset(center.dx + roomWidth / 2 + 20, center.dy + roomDepth - 20 * heightScale);
    final frontBottomLeft = Offset(center.dx - roomWidth / 2 - 20, center.dy + roomDepth + 20 * heightScale);
    final frontBottomRight = Offset(center.dx + roomWidth / 2 + 20, center.dy + roomDepth + 20 * heightScale);

    // Рисуем заднюю стену
    final backPath = Path()
      ..moveTo(backTopLeft.dx, backTopLeft.dy)
      ..lineTo(backTopRight.dx, backTopRight.dy)
      ..lineTo(backBottomRight.dx, backBottomRight.dy)
      ..lineTo(backBottomLeft.dx, backBottomLeft.dy)
      ..close();
    canvas.drawPath(backPath, fillPaint);
    canvas.drawPath(backPath, paint);

    // Рисуем левую стену
    final leftPath = Path()
      ..moveTo(backTopLeft.dx, backTopLeft.dy)
      ..lineTo(frontTopLeft.dx, frontTopLeft.dy)
      ..lineTo(frontBottomLeft.dx, frontBottomLeft.dy)
      ..lineTo(backBottomLeft.dx, backBottomLeft.dy)
      ..close();
    canvas.drawPath(leftPath, fillPaint);
    canvas.drawPath(leftPath, paint);

    // Рисуем правую стену
    final rightPath = Path()
      ..moveTo(backTopRight.dx, backTopRight.dy)
      ..lineTo(frontTopRight.dx, frontTopRight.dy)
      ..lineTo(frontBottomRight.dx, frontBottomRight.dy)
      ..lineTo(backBottomRight.dx, backBottomRight.dy)
      ..close();
    canvas.drawPath(rightPath, fillPaint);
    canvas.drawPath(rightPath, paint);

    // Рисуем пол
    final floorPath = Path()
      ..moveTo(backBottomLeft.dx, backBottomLeft.dy)
      ..lineTo(backBottomRight.dx, backBottomRight.dy)
      ..lineTo(frontBottomRight.dx, frontBottomRight.dy)
      ..lineTo(frontBottomLeft.dx, frontBottomLeft.dy)
      ..close();
    canvas.drawPath(floorPath, fillPaint);
    canvas.drawPath(floorPath, paint);

    // Рисуем потолок
    final ceilingPath = Path()
      ..moveTo(backTopLeft.dx, backTopLeft.dy)
      ..lineTo(backTopRight.dx, backTopRight.dy)
      ..lineTo(frontTopRight.dx, frontTopRight.dy)
      ..lineTo(frontTopLeft.dx, frontTopLeft.dy)
      ..close();
    canvas.drawPath(ceilingPath, fillPaint);
    canvas.drawPath(ceilingPath, paint);
  }

  @override
  bool shouldRepaint(RoomPainter oldDelegate) {
    return oldDelegate.floorArea != floorArea ||
        oldDelegate.ceilingHeight != ceilingHeight;
  }
}

// Painter для анимированной круговой диаграммы цены
class _PriceChartPainter extends CustomPainter {
  final double progress;
  final double total;
  final bool isDark;

  _PriceChartPainter({
    required this.progress,
    required this.total,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Фон круга
    final bgPaint = Paint()
      ..color = isDark 
          ? Colors.white.withValues(alpha: 0.1) 
          : Colors.grey.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Анимированная дуга прогресса
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF2196F3),
          const Color(0xFF1976D2),
          const Color(0xFFFF6B35),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );

    // Внешнее свечение
    if (progress > 0.9) {
      final glowPaint = Paint()
        ..color = const Color(0xFFFF6B35).withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 24
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(center, radius, glowPaint);
    }
  }

  @override
  bool shouldRepaint(_PriceChartPainter oldDelegate) {
    return oldDelegate.progress != progress || 
           oldDelegate.total != total ||
           oldDelegate.isDark != isDark;
  }
}
