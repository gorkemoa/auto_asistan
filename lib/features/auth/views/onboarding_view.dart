import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/auto_button.dart';
import '../../../core/services/storage_service.dart';

/// Onboarding ekranı — ilk kullanım
class OnboardingView extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingView({super.key, required this.onComplete});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final _pageController = PageController();
  int _currentPage = 0;

  final _pages = [
    _OnboardingPage(
      icon: Icons.directions_car_filled_rounded,
      title: 'Dijital Garaj',
      description:
          'Tüm araçlarınızı tek bir yerden yönetin. '
          'Marka, model, KM ve tüm bilgilerinizi kaydedin.',
      color: AppColors.accentBlue,
    ),
    _OnboardingPage(
      icon: Icons.auto_fix_high_rounded,
      title: 'AI Mekanik Asistanı',
      description:
          'Aracınızdaki sorunları yapay zeka destekli asistana anlatın. '
          'Olası arızaları ve tavsiyeleri anında öğrenin.',
      color: AppColors.accentTeal,
    ),
    _OnboardingPage(
      icon: Icons.map_rounded,
      title: 'Akıllı Harita',
      description:
          'En yakın servisler, sanayi siteleri ve TÜVTÜRK istasyonlarını '
          'konumunuza göre bulun.',
      color: AppColors.success,
    ),
    _OnboardingPage(
      icon: Icons.notifications_active_rounded,
      title: 'Proaktif Hatırlatmalar',
      description:
          'Bakım, muayene, sigorta ve kasko tarihleriniz yaklaştığında '
          'otomatik olarak uyarı alın.',
      color: AppColors.warning,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      StorageService.setOnboardingComplete();
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip butonu
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: () {
                    StorageService.setOnboardingComplete();
                    widget.onComplete();
                  },
                  child: Text(
                    'Geç',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),

            // Sayfa içeriği
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: page.color.withValues(alpha: 0.12),
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusXl + 10),
                          ),
                          child: Icon(page.icon, size: 56, color: page.color),
                        )
                            .animate()
                            .fadeIn(duration: 500.ms)
                            .scale(begin: const Offset(0.8, 0.8)),
                        const SizedBox(height: 40),
                        Text(
                          page.title,
                          style: AppTypography.h2,
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 200.ms),
                        const SizedBox(height: 16),
                        Text(
                          page.description,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 300.ms),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Sayfa göstergesi ve buton
            Padding(
              padding: const EdgeInsets.only(
                left: 40,
                right: 40,
                bottom: 40,
              ),
              child: Column(
                children: [
                  // Noktalar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _currentPage ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _currentPage
                              ? AppColors.accentBlue
                              : AppColors.surfaceDivider,
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusFull),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),
                  // Devam butonu
                  AutoButton(
                    label: _currentPage == _pages.length - 1
                        ? 'Başlayalım!'
                        : 'Devam',
                    onPressed: _nextPage,
                    icon: _currentPage == _pages.length - 1
                        ? Icons.rocket_launch_rounded
                        : Icons.arrow_forward_rounded,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
