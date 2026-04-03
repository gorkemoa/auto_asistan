import 'package:flutter/material.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/auto_card.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../viewmodels/home_viewmodel.dart';
import '../../expenses/views/add_expense_view.dart';
import '../../expenses/models/expense_model.dart';
import '../../garage/views/add_vehicle_view.dart';
import '../../ai_assistant/views/ai_chat_view.dart';
import '../widgets/dashboard_action_button.dart';
import '../../map/views/map_view.dart';

/// Ana Sayfa — Dashboard
class HomeView extends StatefulWidget {
  final VoidCallback? onNavigateToGarage;
  final VoidCallback? onNavigateToExpenses;
  final VoidCallback? onNavigateToReminders;

  const HomeView({
    super.key,
    this.onNavigateToGarage,
    this.onNavigateToExpenses,
    this.onNavigateToReminders,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _viewModel = HomeViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.loadDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return ListenableBuilder(
            listenable: _viewModel.garageVM,
            builder: (context, _) {
              if (_viewModel.isLoading && !_viewModel.garageVM.hasVehicles) {
                return const LoadingIndicator(message: AppStrings.loading);
              }

              return SafeArea(
                bottom: false,
                child: RefreshIndicator(
                  onRefresh: _viewModel.loadDashboard,
                  color: AppColors.accentBlue,
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.pagePaddingH,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment
                                .start, // Card looks better with start alignment
                            children: [
                              const SizedBox(height: AppDimensions.spacing16),
                              if (_viewModel.garageVM.hasVehicles) ...[
                                _buildVehicleSelector(),
                                const SizedBox(height: AppDimensions.spacing32),
                                _buildQuickActions(),
                                const SizedBox(height: AppDimensions.spacing32),
                                _buildRecentExpensesSection(),
                                const SizedBox(height: AppDimensions.spacing32),
                                _buildRemindersSection(),
                              ] else ...[
                                _buildWelcomeCard(),
                              ],
                              const SizedBox(height: AppDimensions.spacing32),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildVehicleSelector() {
    final vehicle = _viewModel.garageVM.selectedVehicle;
    if (vehicle == null) return const SizedBox.shrink();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        AutoCard(
          gradient: AppColors.primaryGradient,
          hasBorder: false,
          onTap: _showVehicleSwitcher,
          padding: EdgeInsets.zero,
          child: Container(
            height: 180,
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehicle.displayName,
                            style: AppTypography.h3.copyWith(
                              color: Colors.white,
                              fontSize: 22,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            vehicle.plate ?? '${vehicle.year} Model',
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.swap_horiz_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Güncel Durum',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.formatKm(vehicle.currentKm),
                      style: AppTypography.numericLarge.copyWith(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: -15,
          bottom: -15,
          child: IgnorePointer(
            child: Image.asset(
              'assets/Adsız tasarım (20).png',
              width: 170,
              height: 170,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        DashboardActionButton(
          iconWidget: const iconoir.Spark(
            width: 28,
            height: 28,
            color: AppColors.accentBlue,
          ),
          label: AppStrings.navAI,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AiChatView()),
          ),
        ),
        const SizedBox(width: 12),
        DashboardActionButton(
          iconWidget: const iconoir.MapsArrow(
            width: 28,
            height: 28,
            color: AppColors.accentTeal,
          ),
          label: AppStrings.map,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MapView()),
          ),
        ),
        const SizedBox(width: 12),
        DashboardActionButton(
          iconWidget: const iconoir.Plus(
            width: 28,
            height: 28,
            color: AppColors.primaryNavy,
          ),
          label: AppStrings.addExpense,
          onTap: () {
            final vehicleId = _viewModel.garageVM.selectedVehicle?.id;
            if (vehicleId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddExpenseView(
                    vehicleId: vehicleId,
                    onSaved: (expense) {
                      _viewModel.expensesVM.addExpense(expense);
                      Navigator.pop(context);
                      _viewModel.loadDashboard();
                    },
                  ),
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildRecentExpensesSection() {
    return ListenableBuilder(
      listenable: _viewModel.expensesVM,
      builder: (context, _) {
        final expenses = _viewModel.expensesVM.expenses.take(3).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppStrings.recentExpenses, style: AppTypography.h3),
                TextButton(
                  onPressed: widget.onNavigateToExpenses,
                  child: const Text(
                    'Tümü',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (expenses.isEmpty)
              AutoCard(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.receipt_long_rounded,
                      color: AppColors.textTertiary.withValues(alpha: 0.5),
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.emptyExpenses,
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              )
            else
              AutoCard(
                padding: EdgeInsets.zero,
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: expenses.length,
                  separatorBuilder: (_, _) => const Divider(
                    height: 1,
                    color: AppColors.surfaceDivider,
                    indent: 64,
                  ),
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return _buildDynamicExpenseRow(expense);
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDynamicExpenseRow(ExpenseModel expense) {
    Widget icon;
    Color color;
    switch (expense.category) {
      case 'yakit':
        icon = iconoir.GasTank(width: 20, height: 20, color: AppColors.expenseFuel);
        color = AppColors.expenseFuel;
        break;
      case 'bakim':
        icon = iconoir.Wrench(width: 20, height: 20, color: AppColors.expenseMaintenance);
        color = AppColors.expenseMaintenance;
        break;
      case 'sigorta':
      case 'kasko':
        icon = iconoir.Shield(width: 20, height: 20, color: AppColors.expenseInsurance);
        color = AppColors.expenseInsurance;
        break;
      default:
        icon = iconoir.Reports(width: 20, height: 20, color: AppColors.expenseOther);
        color = AppColors.expenseOther;
    }

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: icon,
      ),
      title: Text(
        expense.categoryDisplayName,
        style: AppTypography.labelMedium,
      ),
      subtitle: Text(
        '${expense.date.day} ${_monthName(expense.date.month)}',
        style: AppTypography.caption,
      ),
      trailing: Text(
        CurrencyFormatter.format(expense.amount),
        style: AppTypography.labelMedium.copyWith(color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildRemindersSection() {
    return ListenableBuilder(
      listenable: _viewModel.remindersVM,
      builder: (context, _) {
        final reminders = _viewModel.remindersVM.activeReminders
            .take(3)
            .toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppStrings.reminders, style: AppTypography.h3),
                TextButton(
                  onPressed: widget.onNavigateToReminders,
                  child: const Text(
                    'Tümü',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (reminders.isEmpty)
              AutoCard(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      color: AppColors.textTertiary.withValues(alpha: 0.5),
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.emptyReminders,
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              )
            else
              Column(
                children: reminders
                    .map(
                      (r) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AutoCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.accentBlue.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.event_note_rounded,
                                  color: AppColors.accentBlue,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      r.title,
                                      style: AppTypography.labelMedium,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      r.targetDate != null
                                          ? '${r.targetDate!.day} ${_monthName(r.targetDate!.month)} ${r.targetDate!.year}'
                                          : '${r.targetKm} KM',
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.textTertiary.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        );
      },
    );
  }

  Widget _buildWelcomeCard() {
    return AutoCard(
      gradient: AppColors.primaryGradient,
      hasBorder: false,
      child: Column(
        children: [
          const Icon(
            Icons.directions_car_filled_rounded,
            color: Colors.white,
            size: 56,
          ),
          const SizedBox(height: 16),
          Text(
            'AutoAssist\'e Hoş Geldiniz! 🚗',
            style: AppTypography.h3.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Dijital araç asistanınızı kullanmaya başlamak için ilk aracınızı ekleyin.',
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddVehicleView(
                  onSaved: (v) {
                    _viewModel.garageVM.addVehicle(v);
                    Navigator.pop(context);
                    _viewModel.loadDashboard();
                  },
                ),
              ),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text(AppStrings.addVehicle),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryNavy,
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'Oca',
      'Şub',
      'Mar',
      'Nis',
      'May',
      'Haz',
      'Tem',
      'Ağu',
      'Eyl',
      'Eki',
      'Kas',
      'Ara',
    ];
    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }

  void _showVehicleSwitcher() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Araç Seçin', style: AppTypography.h3),
            const SizedBox(height: 16),
            ..._viewModel.garageVM.vehicles.map((v) {
              final isSelected =
                  v.id == _viewModel.garageVM.selectedVehicle?.id;
              return ListTile(
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? AppColors.accentGradient
                        : AppColors.cardGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.directions_car_filled_rounded,
                    color: isSelected ? Colors.white : AppColors.accentBlue,
                    size: 22,
                  ),
                ),
                title: Text(v.displayName, style: AppTypography.labelLarge),
                subtitle: Text(
                  '${v.year} • ${v.plate ?? ""}',
                  style: AppTypography.caption,
                ),
                trailing: isSelected
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.accentBlue,
                      )
                    : null,
                onTap: () {
                  _viewModel.garageVM.selectVehicle(v);
                  _viewModel.onVehicleChanged(v.id);
                  Navigator.pop(context);
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
