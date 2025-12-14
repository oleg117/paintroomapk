import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../providers/theme_provider.dart';
import '../services/preferences_service.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  final _professionController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
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

  Future<void> _loadProfile() async {
    final profile = await PreferencesService.getUserProfile();
    final authService = AuthService();
    final firebaseUser = authService.currentUser;
    
    setState(() {
      _nameController.text = firebaseUser?.displayName ?? profile?.displayName ?? '';
      _emailController.text = firebaseUser?.email ?? profile?.email ?? '';
      _phoneController.text = profile?.phone ?? '';
      _companyController.text = profile?.company ?? '';
      _professionController.text = profile?.profession ?? '';
      _isLoading = false;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final profile = UserProfile(
      displayName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      company: _companyController.text.trim(),
      profession: _professionController.text.trim(),
    );

    await PreferencesService.saveUserProfile(profile);

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate('profile_updated') ?? 'Профиль обновлён'),
          backgroundColor: const Color(0xFF4CAF50),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF1E1E2C) : Colors.grey[100],
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF2A2A3C) : Colors.white,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E2C) : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF2A2A3C) : Colors.white,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context).translate('personal_info') ?? 'Личная информация',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _nameController,
                label: AppLocalizations.of(context).translate('full_name') ?? 'Полное имя',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(context).translate('field_required') ?? 'Обязательное поле';
                  }
                  return null;
                },
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                label: AppLocalizations.of(context).translate('email') ?? 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(context).translate('field_required') ?? 'Обязательное поле';
                  }
                  if (!value.contains('@')) {
                    return AppLocalizations.of(context).translate('invalid_email') ?? 'Неверный email';
                  }
                  return null;
                },
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: AppLocalizations.of(context).translate('phone') ?? 'Телефон',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _companyController,
                label: AppLocalizations.of(context).translate('company') ?? 'Компания',
                icon: Icons.business_outlined,
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _professionController,
                label: AppLocalizations.of(context).translate('profession') ?? 'Профессия',
                icon: Icons.work_outline,
                isDark: isDark,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        AppLocalizations.of(context).translate('save') ?? 'Сохранить',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    required bool isDark,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
        prefixIcon: Icon(
          icon,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF2A2A3C) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF4CAF50),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
      ),
    );
  }
}
