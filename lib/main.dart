import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'providers/data_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/advanced_calculator_screen.dart';
import 'screens/compare_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/preferences_service.dart';
import 'services/auth_service.dart';
import 'services/location_service.dart';
import 'services/notification_service.dart';
import 'services/locale_service.dart';
import 'l10n/app_localizations.dart';

void main() async {
  // Критически важная инициализация Flutter
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase - необязательный, без него приложение работает
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kDebugMode) debugPrint('✅ Firebase initialized');
  } catch (e) {
    if (kDebugMode) debugPrint('⚠️ Firebase not available: $e');
  }
  
  // Auth Service - необязательный
  try {
    await AuthService().initialize();
    if (kDebugMode) debugPrint('✅ Auth Service initialized');
  } catch (e) {
    if (kDebugMode) debugPrint('⚠️ Auth Service not available: $e');
  }
  
  // Notification Service - необязательный
  try {
    await NotificationService().initialize();
    await NotificationService().scheduleDailyReminder(hour: 10, minute: 0);
    if (kDebugMode) debugPrint('✅ Notifications initialized');
  } catch (e) {
    if (kDebugMode) debugPrint('⚠️ Notifications not available: $e');
  }
  
  // Location Service - необязательный
  try {
    await LocationService().getUserCountry();
    if (kDebugMode) debugPrint('✅ Location initialized');
  } catch (e) {
    if (kDebugMode) debugPrint('⚠️ Location not available: $e');
  }
  
  // Запуск приложения в любом случае
  runApp(const PaintroomApp());
}

class PaintroomApp extends StatefulWidget {
  const PaintroomApp({super.key});

  @override
  State<PaintroomApp> createState() => _PaintroomAppState();
}

class _PaintroomAppState extends State<PaintroomApp> {
  bool _isLoading = true;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    try {
      final onboardingComplete = await PreferencesService.isOnboardingComplete()
          .timeout(const Duration(seconds: 5));
      if (mounted) {
        setState(() {
          _showOnboarding = !onboardingComplete;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Если проверка не удалась - показываем главный экран
      if (kDebugMode) {
        print('Onboarding check failed: $e');
      }
      if (mounted) {
        setState(() {
          _showOnboarding = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color(0xFFF0F4F8),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                ),
                const SizedBox(height: 24),
                Text(
                  'Paint ROOM',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Загрузка...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DataProvider()..loadData()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleService()),
      ],
      child: Consumer2<ThemeProvider, LocaleService>(
        builder: (context, themeProvider, localeService, child) {
          return MaterialApp(
            title: 'Paint ROOM - Construction Costs EU',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            locale: localeService.locale,
            supportedLocales: LocaleService.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              // Проверяем, поддерживается ли текущая локаль
              if (locale != null) {
                for (var supportedLocale in supportedLocales) {
                  if (supportedLocale.languageCode == locale.languageCode) {
                    return supportedLocale;
                  }
                }
              }
              // Если не поддерживается, возвращаем первую поддерживаемую локаль
              return supportedLocales.first;
            },
            home: _showOnboarding
                ? const OnboardingScreen()
                : const PaintroomMainScreen(),
          );
        },
      ),
    );
  }
}

class PaintroomMainScreen extends StatefulWidget {
  const PaintroomMainScreen({super.key});

  @override
  State<PaintroomMainScreen> createState() => _PaintroomMainScreenState();
}

class _PaintroomMainScreenState extends State<PaintroomMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const AdvancedCalculatorScreen(),
    const CompareScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.bottomNavigationBarTheme.backgroundColor,
        selectedItemColor: const Color(0xFF4CAF50),
        unselectedItemColor: isDark ? Colors.grey[400] : Colors.grey[600],
        selectedFontSize: 12,
        unselectedFontSize: 11,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_rounded),
            label: AppLocalizations.of(context).translate('nav_home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calculate_rounded),
            label: AppLocalizations.of(context).translate('nav_calculator'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.compare_arrows_rounded),
            label: AppLocalizations.of(context).translate('nav_compare'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_rounded),
            label: AppLocalizations.of(context).translate('nav_profile'),
          ),
        ],
      ),
    );
  }


}
