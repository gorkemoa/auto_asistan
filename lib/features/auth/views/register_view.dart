import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/auto_button.dart';
import '../../../core/widgets/auto_text_field.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/validators.dart';
import '../viewmodels/auth_viewmodel.dart';

/// Kayıt ekranı
class RegisterView extends StatefulWidget {
  final VoidCallback onLoginTap;
  final VoidCallback onRegisterSuccess;

  const RegisterView({
    super.key,
    required this.onLoginTap,
    required this.onRegisterSuccess,
  });

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _viewModel = AuthViewModel();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await _viewModel.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
    );

    if (success && mounted) {
      widget.onRegisterSuccess();
    } else if (_viewModel.error != null && mounted) {
      AppLogger.error('Kayıt başarısız (UI): ${_viewModel.error}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_viewModel.error!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.pagePaddingH,
            vertical: AppDimensions.spacing32,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppDimensions.spacing24),

                // Geri butonu
                IconButton(
                  onPressed: widget.onLoginTap,
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                ),

                const SizedBox(height: AppDimensions.spacing20),

                // Başlıklar
                Text(AppStrings.registerTitle, style: AppTypography.h1)
                    .animate()
                    .fadeIn(duration: 400.ms),
                const SizedBox(height: AppDimensions.spacing8),
                Text(
                  AppStrings.registerSubtitle,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ).animate().fadeIn(delay: 100.ms),

                const SizedBox(height: AppDimensions.spacing32),

                // Ad Soyad
                AutoTextField(
                  label: AppStrings.fullName,
                  hint: 'Adınız Soyadınız',
                  controller: _nameController,
                  prefixIcon: Icons.person_outline_rounded,
                  validator: (v) => Validators.required(v, 'Ad soyad'),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: AppDimensions.spacing16),

                // E-posta
                AutoTextField(
                  label: AppStrings.email,
                  hint: 'ornek@mail.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: Validators.email,
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: AppDimensions.spacing16),

                // Telefon (opsiyonel)
                AutoTextField(
                  label: '${AppStrings.phone} (isteğe bağlı)',
                  hint: '05XX XXX XX XX',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  validator: Validators.phone,
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: AppDimensions.spacing16),

                // Şifre
                AutoTextField(
                  label: AppStrings.password,
                  hint: 'En az 6 karakter',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outlined,
                  validator: Validators.password,
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textTertiary,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ).animate().fadeIn(delay: 500.ms),

                const SizedBox(height: AppDimensions.spacing16),

                // Şifre Tekrar
                AutoTextField(
                  label: AppStrings.confirmPassword,
                  hint: 'Şifrenizi tekrar girin',
                  controller: _confirmPasswordController,
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outlined,
                  validator: (v) =>
                      Validators.confirmPassword(v, _passwordController.text),
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: AppDimensions.spacing32),

                // Kayıt Butonu
                ListenableBuilder(
                  listenable: _viewModel,
                  builder: (context, _) {
                    return AutoButton(
                      label: AppStrings.register,
                      onPressed: _handleRegister,
                      isLoading: _viewModel.isLoading,
                      icon: Icons.person_add_rounded,
                    );
                  },
                ).animate().fadeIn(delay: 700.ms),

                const SizedBox(height: AppDimensions.spacing24),

                // Giriş yap link
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings.hasAccount,
                        style: AppTypography.bodySmall,
                      ),
                      TextButton(
                        onPressed: widget.onLoginTap,
                        child: Text(
                          AppStrings.login,
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.accentBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
