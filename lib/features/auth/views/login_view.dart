import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/auto_button.dart';
import '../../../core/widgets/auto_text_field.dart';
import '../../../core/utils/validators.dart';
import '../viewmodels/auth_viewmodel.dart';

/// Giriş ekranı — premium, minimalist tasarım
class LoginView extends StatefulWidget {
  final VoidCallback onRegisterTap;
  final VoidCallback onLoginSuccess;

  const LoginView({
    super.key,
    required this.onRegisterTap,
    required this.onLoginSuccess,
  });

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _viewModel = AuthViewModel();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await _viewModel.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      widget.onLoginSuccess();
    } else if (_viewModel.error != null && mounted) {
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
                const SizedBox(height: AppDimensions.spacing48),

                // Logo / Marka
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: AppColors.accentGradient,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                    ),
                    child: const Icon(
                      Icons.directions_car_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.8, 0.8)),

                const SizedBox(height: AppDimensions.spacing32),

                // Başlık
                Center(
                  child: Text(AppStrings.loginTitle, style: AppTypography.h1),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: AppDimensions.spacing8),

                Center(
                  child: Text(
                    AppStrings.loginSubtitle,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: AppDimensions.spacing40),

                // E-posta
                AutoTextField(
                  label: AppStrings.email,
                  hint: 'ornek@mail.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: Validators.email,
                ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.05),

                const SizedBox(height: AppDimensions.spacing20),

                // Şifre
                AutoTextField(
                  label: AppStrings.password,
                  hint: '••••••••',
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
                ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.05),

                const SizedBox(height: AppDimensions.spacing12),

                // Şifremi unuttum
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Şifre sıfırlama
                    },
                    child: Text(
                      AppStrings.forgotPassword,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.accentBlue,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.spacing24),

                // Giriş Butonu
                ListenableBuilder(
                  listenable: _viewModel,
                  builder: (context, _) {
                    return AutoButton(
                      label: AppStrings.login,
                      onPressed: _handleLogin,
                      isLoading: _viewModel.isLoading,
                      icon: Icons.arrow_forward_rounded,
                    );
                  },
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: AppDimensions.spacing32),

                // Kayıt ol link
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings.noAccount,
                        style: AppTypography.bodySmall,
                      ),
                      TextButton(
                        onPressed: widget.onRegisterTap,
                        child: Text(
                          AppStrings.register,
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.accentBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 700.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
