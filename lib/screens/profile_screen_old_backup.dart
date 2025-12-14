import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../providers/data_provider.dart';
import '../providers/theme_provider.dart';
import '../services/preferences_service.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/locale_service.dart';
import '../widgets/glass_container.dart';
import '../l10n/app_localizations.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              _buildProfileInfo(context),
              _buildPreferences(context),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final authService = AuthService();
    final firebaseUser = authService.currentUser;
    
    return GlassContainer(
      gradientColors: isDark 
        ? [const Color(0xFF6A1B9A), const Color(0xFF8E24AA)]
        : [const Color(0xFF9C27B0), const Color(0xFF7B1FA2)],
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                shape: BoxShape.circle,
                image: firebaseUser?.photoURL != null
                    ? DecorationImage(
                        image: NetworkImage(firebaseUser!.photoURL!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: firebaseUser?.photoURL == null
                  ? Icon(
                      firebaseUser != null
                          ? Icons.person
                          : Icons.person_outline,
                      size: 50,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            // Name
            Text(
              firebaseUser?.displayName ?? _userProfile?.displayName ?? 'Гость',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (firebaseUser?.email != null || _userProfile?.email != null) ...[
              const SizedBox(height: 8),
              Text(
                firebaseUser?.email ?? _userProfile?.email ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
            const SizedBox(height: 16),
            // Buttons
            if (firebaseUser == null)
              ElevatedButton.icon(
                onPressed: () => _showLoginScreen(context),
                icon: const Icon(Icons.login),
                label: const Text('Войти через Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF9C27B0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: () => _handleSignOut(context),
                icon: const Icon(Icons.logout),
                label: const Text('Выйти'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF9C27B0),
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
  
  void _showLoginScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    ).then((_) {
      // Обновить профиль после возвращения с экрана входа
      setState(() {});
    });
  }
  
  Future<void> _handleSignOut(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выход'),
        content: const Text('Вы уверены, что хотите выйти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
    
    if (confirm == true && mounted) {
      await AuthService().signOut();
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Вы успешно вышли из аккаунта'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    }
  }

  Widget _buildProfileInfo(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    if (_userProfile == null || !_userProfile!.isComplete) {
      return GlassContainer(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        opacity: 0.2,
        borderColor: isDark ? Colors.orange[700]! : Colors.orange[200]!,
        borderRadius: 16,
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: isDark ? Colors.orange[400] : Colors.orange[700],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Заполните профиль, чтобы получить персонализированный опыт',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.orange[200] : Colors.orange[900],
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return GlassContainer(
      margin: const EdgeInsets.all(16),
      opacity: isDark ? 0.15 : 0.25,
      borderRadius: 16,
      child: Column(
        children: [
          if (_userProfile!.phone != null)
            _buildInfoTile(
              Icons.phone,
              'Телефон',
              _userProfile!.phone!,
              Colors.blue,
            ),
          if (_userProfile!.company != null)
            _buildInfoTile(
              Icons.business,
              'Компания',
              _userProfile!.company!,
              Colors.orange,
            ),
          if (_userProfile!.profession != null)
            _buildInfoTile(
              Icons.work,
              'Профессия',
              _userProfile!.profession!,
              Colors.purple,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPreferences(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final selectedCountry = dataProvider.selectedCountry;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return GlassContainer(
      margin: const EdgeInsets.all(16),
      opacity: isDark ? 0.15 : 0.25,
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Предпочтения',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.public,
                color: Color(0xFFFF6B35),
                size: 24,
              ),
            ),
            title: const Text('Страна по умолчанию'),
            subtitle: Text(selectedCountry?.nameRu ?? 'Не выбрана'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Show country selector
            },
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.euro_symbol,
                color: Colors.green,
                size: 24,
              ),
            ),
            title: const Text('Валюта'),
            subtitle: Text(_userProfile?.preferredCurrency ?? 'EUR'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Show currency selector
            },
          ),
          SwitchListTile(
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.receipt,
                color: Colors.blue,
                size: 24,
              ),
            ),
            title: const Text('Цены с НДС'),
            subtitle: const Text('Показывать цены с учетом НДС'),
            value: _userProfile?.showPricesWithVAT ?? true,
            onChanged: (value) {
              if (_userProfile != null) {
                _saveProfile(_userProfile!.copyWith(showPricesWithVAT: value));
              }
            },
          ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return SwitchListTile(
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: Colors.deepPurple,
                    size: 24,
                  ),
                ),
                title: const Text('Темная тема'),
                subtitle: Text(themeProvider.isDarkMode ? 'Включена' : 'Выключена'),
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                },
              );
            },
          ),
          Consumer<LocaleService>(
            builder: (context, localeService, child) {
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.language,
                    color: Colors.teal,
                    size: 24,
                  ),
                ),
                title: const Text('Язык'),
                subtitle: Text(
                  '${localeService.getLanguageFlag(localeService.locale.languageCode)} ${localeService.getLanguageName(localeService.locale.languageCode)}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  _showLanguageSelector(context, localeService);
                },
              );
            },
          ),
          SwitchListTile(
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.notifications_active,
                color: Colors.orange,
                size: 24,
              ),
            ),
            title: const Text('Ежедневные напоминания'),
            subtitle: const Text('Уведомление о расчёте в 10:00'),
            value: _notificationsEnabled,
            onChanged: (value) async {
              await NotificationService().setNotificationsEnabled(value);
              setState(() {
                _notificationsEnabled = value;
              });
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value
                          ? '✅ Напоминания включены (10:00 ежедневно)'
                          : '❌ Напоминания отключены',
                    ),
                    backgroundColor: value ? Colors.green : Colors.orange,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return GlassContainer(
      margin: const EdgeInsets.all(16),
      opacity: isDark ? 0.15 : 0.25,
      borderRadius: 16,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.help_outline, color: Color(0xFF2196F3)),
            title: const Text('Помощь и поддержка'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Show help
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Color(0xFF4CAF50)),
            title: const Text('О приложении'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showAboutDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.restart_alt, color: Color(0xFFFF9800)),
            title: const Text('Показать онбоардинг'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _resetOnboarding(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Color(0xFFF44336)),
            title: const Text('Очистить данные'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _clearData(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile(UserProfile profile) async {
    await PreferencesService.saveUserProfile(profile);
    setState(() {
      _userProfile = profile;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Профиль сохранен'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('О приложении'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paintroom - Construction Costs EU',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('Версия: 1.0.0'),
            SizedBox(height: 16),
            Text(
              'Справочник цен на строительные работы в Европе с удобным калькулятором стоимости.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetOnboarding(BuildContext context) async {
    await PreferencesService.resetOnboarding();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Перезапустите приложение, чтобы увидеть онбоардинг'),
          backgroundColor: Color(0xFF2196F3),
        ),
      );
    }
  }

  Future<void> _clearData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Очистить данные?'),
        content: const Text(
          'Все ваши данные будут удалены. Это действие нельзя отменить.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await PreferencesService.clearUserProfile();
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      dataProvider.clearCalculator();
      
      setState(() {
        _userProfile = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Данные очищены'),
            backgroundColor: Color(0xFFF44336),
          ),
        );
      }
    }
  }

  void _showLanguageSelector(BuildContext context, LocaleService localeService) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1F2E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  l10n.translate('select_language'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              ...LocaleService.supportedLocales.map((locale) {
                final isSelected = localeService.locale.languageCode == locale.languageCode;
                return ListTile(
                  leading: Text(
                    LocaleService.languageFlags[locale.languageCode] ?? '',
                    style: const TextStyle(fontSize: 32),
                  ),
                  title: Text(
                    LocaleService.languageNames[locale.languageCode] ?? locale.languageCode,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? const Color(0xFF2196F3)
                          : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Color(0xFF2196F3))
                      : null,
                  onTap: () async {
                    final selectedLanguageName = LocaleService.languageNames[locale.languageCode] ?? locale.languageCode;
                    await localeService.setLocale(locale);
                    if (context.mounted) {
                      Navigator.pop(context);
                      // Получаем новую локализацию после смены языка
                      final newL10n = AppLocalizations.of(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${LocaleService.languageFlags[locale.languageCode]} ${newL10n.translate('language_changed')} $selectedLanguageName',
                          ),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  final UserProfile? profile;

  const EditProfileScreen({super.key, this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _companyController;
  late TextEditingController _professionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile?.name);
    _emailController = TextEditingController(text: widget.profile?.email);
    _phoneController = TextEditingController(text: widget.profile?.phone);
    _companyController = TextEditingController(text: widget.profile?.company);
    _professionController = TextEditingController(text: widget.profile?.profession);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _professionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать профиль'),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: const Text(
              'Сохранить',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Имя *',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Телефон',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _companyController,
                decoration: const InputDecoration(
                  labelText: 'Компания',
                  prefixIcon: Icon(Icons.business),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _professionController,
                decoration: const InputDecoration(
                  labelText: 'Профессия',
                  prefixIcon: Icon(Icons.work),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '* Обязательные поля',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveProfile() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Заполните обязательные поля'),
          backgroundColor: Color(0xFFF44336),
        ),
      );
      return;
    }

    final profile = UserProfile(
      name: name,
      email: email,
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      company: _companyController.text.trim().isEmpty
          ? null
          : _companyController.text.trim(),
      profession: _professionController.text.trim().isEmpty
          ? null
          : _professionController.text.trim(),
      preferredCountry: widget.profile?.preferredCountry ?? 'DE',
      preferredCurrency: widget.profile?.preferredCurrency ?? 'EUR',
      showPricesWithVAT: widget.profile?.showPricesWithVAT ?? true,
    );

    Navigator.pop(context, profile);
  }
}
