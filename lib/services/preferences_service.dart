import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class PreferencesService {
  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyUserProfile = 'user_profile';
  static const String _keyFirstLaunch = 'first_launch';
  static const String _keyDarkMode = 'dark_mode';
  static const String _keySelectedCountry = 'selected_country';

  static Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingComplete) ?? false;
  }

  static Future<void> setOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingComplete, true);
  }

  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirst = prefs.getBool(_keyFirstLaunch) ?? true;
    if (isFirst) {
      await prefs.setBool(_keyFirstLaunch, false);
    }
    return isFirst;
  }

  static Future<UserProfile?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyUserProfile);
    if (jsonString == null) return null;
    
    try {
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserProfile.fromJson(jsonMap);
    } catch (e) {
      return null;
    }
  }

  static Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(profile.toJson());
    await prefs.setString(_keyUserProfile, jsonString);
  }

  static Future<void> clearUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserProfile);
  }

  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyOnboardingComplete);
    await prefs.setBool(_keyFirstLaunch, true);
  }

  // Методы для темной темы
  Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkMode) ?? false;
  }

  Future<void> setDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, isDark);
  }

  // Методы для выбора страны
  static Future<String?> getSelectedCountry() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySelectedCountry);
  }

  static Future<void> saveSelectedCountry(String countryCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedCountry, countryCode);
  }
}
