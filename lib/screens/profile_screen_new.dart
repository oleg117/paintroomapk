import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../providers/theme_provider.dart';
import '../services/preferences_service.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/locale_service.dart';
import '../l10n/app_localizations.dart';

class ProfileScreenNew extends StatefulWidget {
  const ProfileScreenNew({super.key});

  @override
  State<ProfileScreenNew> createState() => _ProfileScreenNewState();
}

class _ProfileScreenNewState extends State<ProfileScreenNew> {
  UserProfile? _userProfile;
  bool _isLoading = true;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadNotificationSettings();
  }

  Future<void> _loadProfile() async {
    final profile = await PreferencesService.getUserProfile();
    setState(() {
      _userProfile = profile;
      _isLoading = false;
    });
  }

  Future<void> _loadNotificationSettings() async {
    final enabled = await NotificationService().areNotificationsEnabled();
    if (mounted) {
      setState(() {
        _notificationsEnabled = enabled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF1E1E2C) : Colors.grey[100],
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E2C) : Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                AppLocalizations.of(context).translate('profile'),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              
              // User Profile Card
              _buildUserCard(context, isDark),
              const SizedBox(height: 16),
              
              // Invite Friends Card (optional)
              _buildInviteCard(context, isDark),
              const SizedBox(height: 20),
              
              // Settings List
              _buildSettingsList(context, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, bool isDark) {
    final authService = AuthService();
    final firebaseUser = authService.currentUser;
    final displayName = firebaseUser?.displayName ?? _userProfile?.displayName ?? 'Пользователь';
    final email = firebaseUser?.email ?? _userProfile?.email;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A3C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              shape: BoxShape.circle,
              image: firebaseUser?.photoURL != null
                  ? DecorationImage(
                      image: NetworkImage(firebaseUser!.photoURL!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: firebaseUser?.photoURL == null
                ? Center(
                    child: Text(
                      displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                if (email != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteCard(BuildContext context, bool isDark) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A3C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        image: const DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=800&q=80',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black.withValues(alpha: 0.6),
              Colors.black.withValues(alpha: 0.3),
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.people_outline,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context).translate('invite_friends') ?? 'Пригласить друзей',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Text(
              'Путь легче\nвместе',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Share functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context).translate('coming_soon') ?? 'Скоро'),
                    backgroundColor: const Color(0xFF4CAF50),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Поделиться',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context, bool isDark) {
    final localeService = Provider.of<LocaleService>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A3C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingTile(
            context,
            icon: Icons.person_outline,
            title: AppLocalizations.of(context).translate('personal_info') ?? 'Личная информация',
            onTap: () {
              // Navigate to personal info
            },
            isDark: isDark,
          ),
          _buildDivider(isDark),
          _buildSettingTile(
            context,
            icon: Icons.calculate_outlined,
            title: AppLocalizations.of(context).translate('calculator_settings') ?? 'Настройки калькулятора',
            onTap: () {
              // Navigate to calculator settings
            },
            isDark: isDark,
          ),
          _buildDivider(isDark),
          _buildSettingTile(
            context,
            icon: Icons.flag_outlined,
            title: AppLocalizations.of(context).translate('country') ?? 'Страна',
            subtitle: 'Россия', // Dynamic from location service
            onTap: () {
              // Country selector
            },
            isDark: isDark,
          ),
          _buildDivider(isDark),
          _buildSettingTile(
            context,
            icon: Icons.notifications_outlined,
            title: AppLocalizations.of(context).translate('notifications') ?? 'Уведомления',
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (value) async {
                await NotificationService().setNotificationsEnabled(value);
                setState(() {
                  _notificationsEnabled = value;
                });
              },
              activeColor: const Color(0xFF4CAF50),
            ),
            isDark: isDark,
          ),
          _buildDivider(isDark),
          _buildSettingTile(
            context,
            icon: Icons.language_outlined,
            title: AppLocalizations.of(context).translate('language') ?? 'Язык',
            subtitle: LocaleService.languageNames[localeService.locale.languageCode] ?? 'Русский',
            onTap: () => _showLanguageSelector(context, localeService),
            isDark: isDark,
          ),
          _buildDivider(isDark),
          _buildSettingTile(
            context,
            icon: Icons.dark_mode_outlined,
            title: AppLocalizations.of(context).translate('dark_mode') ?? 'Тёмная тема',
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme();
              },
              activeColor: const Color(0xFF4CAF50),
            ),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Widget? trailing,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null)
                trailing
              else if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(
        height: 1,
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.2),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context, LocaleService localeService) {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A3C) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context).translate('select_language') ?? 'Выберите язык',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ...LocaleService.supportedLocales.map((locale) {
              final isSelected = localeService.locale == locale;
              return ListTile(
                leading: Text(
                  LocaleService.languageFlags[locale.languageCode] ?? '🌐',
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(
                  LocaleService.languageNames[locale.languageCode] ?? locale.languageCode,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: Color(0xFF4CAF50))
                    : null,
                onTap: () {
                  localeService.setLocale(locale);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${AppLocalizations.of(context).translate('language_changed')} ${LocaleService.languageNames[locale.languageCode]}',
                      ),
                      backgroundColor: const Color(0xFF4CAF50),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
