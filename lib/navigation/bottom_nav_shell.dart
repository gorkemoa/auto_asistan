import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';
import '../core/constants/app_typography.dart';
import '../features/home/views/home_view.dart';
import '../features/garage/views/garage_view.dart';
import '../features/expenses/views/expenses_view.dart';
import '../features/reminders/views/reminders_view.dart';
import '../features/map/views/map_view.dart';
import '../features/garage/viewmodels/garage_viewmodel.dart';
import '../features/settings/views/settings_view.dart';
import 'dart:ui';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

/// Bottom Navigation Shell — ana sayfa container'ı
class BottomNavShell extends StatefulWidget {
  const BottomNavShell({super.key});

  @override
  State<BottomNavShell> createState() => _BottomNavShellState();
}

class _BottomNavShellState extends State<BottomNavShell> {
  int _currentIndex = 0;
  final _garageVM = GarageViewModel();

  @override
  void initState() {
    super.initState();
    _garageVM.loadVehicles();
  }

  void _navigateToTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeView(
            onNavigateToGarage: () => _navigateToTab(1),
            onNavigateToExpenses: () => _navigateToTab(3),
            onNavigateToReminders: () => _navigateToTab(3),
          ),
          const GarageView(),
          const MapView(),
          ListenableBuilder(
            listenable: _garageVM,
            builder: (context, _) {
              return _buildExpensesOrReminders();
            },
          ),
          const SettingsView(),
        ],
      ),
      bottomNavigationBar: _buildCustomGlassBar(),
    );
  }

  Widget _buildExpensesOrReminders() {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.surfaceLight,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Aktivite & Finans', style: AppTypography.h2),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Todoist tarzı Custom Segmented Control
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDivider.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TabBar(
                    dividerColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(11),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    labelColor: AppColors.primaryNavy,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    unselectedLabelStyle: AppTypography.labelLarge,
                    tabs: const [
                      Tab(text: 'Giderler'),
                      Tab(text: 'Hatırlatmalar'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TabBarView(
                  children: [
                    ExpensesView(vehicleId: _garageVM.selectedVehicle?.id),
                    RemindersView(vehicleId: _garageVM.selectedVehicle?.id),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomGlassBar() {
    return Container(
      height:
          AppDimensions.bottomNavHeight + MediaQuery.of(context).padding.bottom,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: LiquidGlassLayer(
          child: LiquidGlass(
            shape: const LiquidRoundedRectangle(borderRadius: 28),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavItem(
                    0,
                    iconoir.Home(
                      width: 24,
                      height: 24,
                      color: _currentIndex == 0
                          ? AppColors.accentBlue
                          : AppColors.textTertiary,
                    ),
                    'Ana Sayfa',
                  ),
                  _buildNavItem(
                    1,
                    iconoir.Car(
                      width: 24,
                      height: 24,
                      color: _currentIndex == 1
                          ? AppColors.accentBlue
                          : AppColors.textTertiary,
                    ),
                    'Garaj',
                  ),
                  _buildNavItem(
                    2,
                    iconoir.MapsArrow(
                      width: 24,
                      height: 24,
                      color: _currentIndex == 2
                          ? AppColors.accentBlue
                          : AppColors.textTertiary,
                    ),
                    'Harita',
                  ),
                  _buildNavItem(
                    3,
                    iconoir.Wallet(
                      width: 24,
                      height: 24,
                      color: _currentIndex == 3
                          ? AppColors.accentBlue
                          : AppColors.textTertiary,
                    ),
                    'Giderler',
                  ),
                  _buildNavItem(
                    4,
                    iconoir.Settings(
                      width: 24,
                      height: 24,
                      color: _currentIndex == 4
                          ? AppColors.accentBlue
                          : AppColors.textTertiary,
                    ),
                    'Ayarlar',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, Widget icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _navigateToTab(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: icon,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                fontSize: 10,
                color: isSelected
                    ? AppColors.accentBlue
                    : AppColors.textTertiary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
