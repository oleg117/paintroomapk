import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // Получить страну устройства
  Future<String?> getUserCountry() async {
    try {
      // Сначала проверяем сохранённую страну
      final prefs = await SharedPreferences.getInstance();
      final savedCountry = prefs.getString('user_country');
      if (savedCountry != null) {
        return savedCountry;
      }

      // Проверяем права доступа к геолокации
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Используем locale устройства как fallback
          return await _getCountryFromLocale();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Используем locale устройства как fallback
        return await _getCountryFromLocale();
      }

      // Получаем текущую позицию
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 5),
      );

      // Получаем информацию о месте по координатам
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final countryCode = placemarks.first.isoCountryCode;
        if (countryCode != null) {
          final country = _convertCountryCode(countryCode);
          // Сохраняем страну
          await prefs.setString('user_country', country);
          return country;
        }
      }

      // Fallback на locale
      return await _getCountryFromLocale();
    } catch (e) {
      print('❌ Location Error: $e');
      // Fallback на locale
      return await _getCountryFromLocale();
    }
  }

  // Получить страну из системной локали устройства
  Future<String> _getCountryFromLocale() async {
    try {
      // В Android можно получить из системных настроек
      // Для примера возвращаем Германию как дефолт для Европы
      final prefs = await SharedPreferences.getInstance();
      
      // Пытаемся определить по языку устройства
      // Это упрощённая логика, в реальности можно использовать
      // platform channels для точного определения
      
      // По умолчанию возвращаем Германию (центр Европы)
      const defaultCountry = 'Германия';
      await prefs.setString('user_country', defaultCountry);
      return defaultCountry;
    } catch (e) {
      return 'Германия'; // Fallback
    }
  }

  // Конвертация ISO кода страны в русское название
  String _convertCountryCode(String isoCode) {
    final Map<String, String> countryMap = {
      'DE': 'Германия',
      'FR': 'Франция',
      'IT': 'Италия',
      'ES': 'Испания',
      'PL': 'Польша',
      'NL': 'Нидерланды',
      'BE': 'Бельгия',
      'AT': 'Австрия',
      'CH': 'Швейцария',
      'PT': 'Португалия',
      'GB': 'Великобритания',
      'IE': 'Ирландия',
      'DK': 'Дания',
      'SE': 'Швеция',
      'NO': 'Норвегия',
      'FI': 'Финляндия',
      'CZ': 'Чехия',
      'HU': 'Венгрия',
      'RO': 'Румыния',
      'BG': 'Болгария',
    };

    return countryMap[isoCode.toUpperCase()] ?? 'Германия';
  }

  // Сохранить выбранную пользователем страну
  Future<void> saveUserCountry(String country) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_country', country);
  }

  // Получить сохранённую страну
  Future<String?> getSavedCountry() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_country');
  }
}
