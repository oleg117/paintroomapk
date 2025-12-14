import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService extends ChangeNotifier {
  static const String _localeKey = 'app_locale';
  Locale _locale = const Locale('ru');

  Locale get locale => _locale;

  // Поддерживаемые языки
  static const List<Locale> supportedLocales = [
    Locale('ru'), // Русский
    Locale('en'), // Английский
    Locale('fr'), // Французский
    Locale('de'), // Немецкий
  ];

  static const Map<String, String> languageNames = {
    'ru': 'Русский',
    'en': 'English',
    'fr': 'Français',
    'de': 'Deutsch',
  };

  static const Map<String, String> languageFlags = {
    'ru': '🇷🇺',
    'en': '🇬🇧',
    'fr': '🇫🇷',
    'de': '🇩🇪',
  };

  LocaleService() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_localeKey);
    if (localeCode != null) {
      _locale = Locale(localeCode);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;
    
    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  String getLanguageName(String code) {
    return languageNames[code] ?? code;
  }

  String getLanguageFlag(String code) {
    return languageFlags[code] ?? '';
  }
}
