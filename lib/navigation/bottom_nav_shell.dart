import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_typography.dart';
import '../features/home/views/home_view.dart';
import '../features/garage/views/garage_view.dart';
import '../features/expenses/views/expenses_view.dart';
import '../features/reminders/views/reminders_view.dart';
import '../features/map/views/map_view.dart';
import '../features/garage/viewmodels/garage_viewmodel.dart';

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
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Aktivite & Finans', style: AppTypography.h2),
                    IconButton(
                      icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
                      onPressed: () {},
                    ),
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
                    labelStyle: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
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

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        border: Border(
          top: BorderSide(color: AppColors.surfaceDivider, width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: AppDimensions.bottomNavHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, Icons.home_outlined,
                  AppStrings.navHome),
              _buildNavItem(1, Icons.garage_rounded, Icons.garage_outlined,
                  AppStrings.navGarage),
              _buildNavItem(
                  2, Icons.map_rounded, Icons.map_outlined, AppStrings.navMap),
              _buildNavItem(
                  3,
                  Icons.account_balance_wallet_rounded,
                  Icons.account_balance_wallet_outlined,
                  AppStrings.navExpenses),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
  ) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => _navigateToTab(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.accentBlue.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              ),
              child: Icon(
                isActive ? activeIcon : inactiveIcon,
                color:
                    isActive ? AppColors.accentBlue : AppColors.textTertiary,
                size: 24,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color:
                    isActive ? AppColors.accentBlue : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
