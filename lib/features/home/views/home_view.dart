import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/auto_card.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../viewmodels/home_viewmodel.dart';
import '../../reminders/models/reminder_model.dart';
import '../../reminders/views/add_reminder_view.dart';
import '../../expenses/models/expense_model.dart';
import '../../expenses/views/add_expense_view.dart';
import '../../garage/views/add_vehicle_view.dart';
import '../../ai_assistant/views/ai_chat_view.dart';

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

              return RefreshIndicator(
                onRefresh: _viewModel.loadDashboard,
                color: AppColors.accentBlue,
                child: CustomScrollView(
                  slivers: [
                    _buildAppBar(),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.pagePaddingH,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: AppDimensions.spacing16),
                            if (_viewModel.garageVM.hasVehicles) ...[
                              _buildVehicleSelector(),
                              const SizedBox(height: AppDimensions.spacing24),
                              _buildSummaryGrid(),
                              const SizedBox(height: AppDimensions.spacing32),
                              _buildRecentExpenses(),
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
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 80,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.surfaceLight,
      title: Text(
        AppStrings.appName,
        style: AppTypography.h2.copyWith(fontSize: 22),
      ),
      actions: [
        _buildAppAction(
          icon: Icons.auto_fix_high_rounded,
          color: AppColors.accentTeal,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiChatView())),
        ),
        _buildAppAction(
          icon: Icons.add_card_rounded,
          color: AppColors.expenseFuel,
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
        _buildAppAction(
          icon: Icons.notification_add_rounded,
          color: AppColors.warning,
          onTap: () {
            final vehicleId = _viewModel.garageVM.selectedVehicle?.id;
            if (vehicleId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddReminderView(
                    vehicleId: vehicleId,
                    onSaved: (reminder) {
                      _viewModel.remindersVM.addReminder(reminder);
                      Navigator.pop(context);
                      _viewModel.loadDashboard();
                    },
                  ),
                ),
              );
            }
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildAppAction({required IconData icon, required Color color, required VoidCallback onTap}) {
    return IconButton(
      onPressed: onTap,
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
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
                            style: AppTypography.h3.copyWith(color: Colors.white, fontSize: 22),
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
                    const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 20),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Güncel Durum',
                      style: AppTypography.caption.copyWith(color: Colors.white.withValues(alpha: 0.7)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.formatKm(vehicle.currentKm),
                      style: AppTypography.h3.copyWith(color: Colors.white, fontSize: 24),
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
              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryGrid() {
    return ListenableBuilder(
      listenable: _viewModel.expensesVM,
      builder: (context, _) => ListenableBuilder(
        listenable: _viewModel.remindersVM,
        builder: (context, _) {
          final nextReminder = _viewModel.remindersVM.activeReminders.isNotEmpty
              ? _viewModel.remindersVM.activeReminders.first
              : null;

          return SizedBox(
            height: 250,
            child: Row(
              children: [
                // Sol Büyük Kart: Sıradaki İşlem (Reminder Hero)
                Expanded(
                  flex: 11,
                  child: _buildReminderHeroCard(nextReminder),
                ),
                const SizedBox(width: 12),
                // Sağ Kolon: Aylık Gider ve KM
                Expanded(
                  flex: 8,
                  child: Column(
                    children: [
                      // Aylık Gider Kartı
                      Expanded(
                        child: _buildAylikGiderSmallCard(),
                      ),
                      const SizedBox(height: 12),
                      // KM Kartı
                      _buildKmStatCardCompact(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReminderHeroCard(ReminderModel? next) {
    return AutoCard(
      gradient: next != null ? AppColors.primaryGradient : null,
      color: next == null ? AppColors.surfaceLight : Colors.white,
      padding: const EdgeInsets.all(22),
      child: Stack(
        children: [
          Positioned(
            right: -25,
            bottom: -25,
            child: Icon(
              Icons.notifications_none_rounded,
              size: 110,
              color: (next != null ? Colors.white : AppColors.primaryNavy).withValues(alpha: 0.08),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: (next != null ? Colors.white : AppColors.primaryNavy).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'SIRADAKİ İŞLEM',
                      style: AppTypography.caption.copyWith(
                        color: next != null ? Colors.white : AppColors.primaryNavy,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (next != null) ...[
                    Text(
                      next.title,
                      style: AppTypography.h3.copyWith(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ] else ...[
                    Text(
                      'Planlanmış işlem yok',
                      style: AppTypography.h4.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (next != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, color: Colors.white70, size: 14),
                        const SizedBox(width: 8),
                        Text(
                          next.targetDate != null ? '${next.targetDate!.day} ${_monthName(next.targetDate!.month)} ${next.targetDate!.year}' : 'KM Takibi',
                          style: AppTypography.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: widget.onNavigateToReminders,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: next != null ? Colors.white.withValues(alpha: 0.15) : Colors.white,
                        foregroundColor: next != null ? Colors.white : AppColors.primaryNavy,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        side: BorderSide(
                          color: next != null ? Colors.white.withValues(alpha: 0.3) : AppColors.surfaceDivider,
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Tümünü Gör', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAylikGiderSmallCard() {
    return AutoCard(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Aylık Gider',
                style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
              const Icon(Icons.show_chart_rounded, size: 16, color: AppColors.accentBlue),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            child: Text(
              CurrencyFormatter.format(_viewModel.expensesVM.monthlyTotal),
              style: AppTypography.h4.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Toplam: ${CurrencyFormatter.compact(_viewModel.expensesVM.totalExpenses)}',
            style: AppTypography.caption.copyWith(color: AppColors.textTertiary, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildKmStatCardCompact() {
    final km = _viewModel.garageVM.selectedVehicle?.currentKm ?? 0;
    return AutoCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Güncel KM',
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                km.toString(),
                style: AppTypography.h4.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 2),
              Text(
                'km',
                style: AppTypography.caption.copyWith(color: AppColors.textTertiary, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildRecentExpenses() {
    return ListenableBuilder(
      listenable: _viewModel.expensesVM,
      builder: (context, _) {
        final expenses = _viewModel.expensesVM.expenses.take(5).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Son İşlemler', style: AppTypography.h3.copyWith(fontSize: 20)),
                const Icon(Icons.sort_rounded, size: 16, color: AppColors.textSecondary),
              ],
            ),
            const SizedBox(height: 16),
            if (expenses.isEmpty)
              const AutoCard(child: Center(child: Padding(padding: EdgeInsets.all(12), child: Text('Henüz işlem yok', style: TextStyle(fontSize: 12)))))
            else
              AutoCard(
                padding: EdgeInsets.zero,
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: expenses.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.surfaceDivider, indent: 64),
                  itemBuilder: (context, index) => _buildExpenseRow(expenses[index]),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildExpenseRow(ExpenseModel expense) {
    IconData icon;
    Color color;
    switch (expense.category) {
      case 'yakit': icon = Icons.local_gas_station_rounded; color = AppColors.expenseFuel; break;
      case 'bakim': icon = Icons.build_rounded; color = AppColors.expenseMaintenance; break;
      case 'sigorta':
      case 'kasko': icon = Icons.shield_rounded; color = AppColors.expenseInsurance; break;
      default: icon = Icons.receipt_rounded; color = AppColors.expenseOther;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.categoryDisplayName, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w600)),
                Text('${expense.date.day} ${_monthName(expense.date.month)} ${expense.date.year}', style: AppTypography.caption.copyWith(color: AppColors.textTertiary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(CurrencyFormatter.format(expense.amount), style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w600)),
              Row(
                children: [
                  Text('Detay', style: AppTypography.caption.copyWith(color: AppColors.textTertiary)),
                  const Icon(Icons.chevron_right_rounded, size: 14, color: AppColors.textTertiary),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return AutoCard(
      gradient: AppColors.primaryGradient,
      hasBorder: false,
      child: Column(
        children: [
          const Icon(Icons.directions_car_filled_rounded, color: Colors.white, size: 56),
          const SizedBox(height: 16),
          Text('AutoAssist\'e Hoş Geldiniz! 🚗', style: AppTypography.h3.copyWith(color: Colors.white), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Dijital araç asistanınızı kullanmaya başlamak için ilk aracınızı ekleyin.', style: AppTypography.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.8)), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddVehicleView(onSaved: (v) { _viewModel.garageVM.addVehicle(v); Navigator.pop(context); _viewModel.loadDashboard(); }))),
            icon: const Icon(Icons.add_rounded),
            label: const Text(AppStrings.addVehicle),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primaryNavy),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
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
              final isSelected = v.id == _viewModel.garageVM.selectedVehicle?.id;
              return ListTile(
                leading: Container(width: 42, height: 42, decoration: BoxDecoration(gradient: isSelected ? AppColors.accentGradient : AppColors.cardGradient, borderRadius: BorderRadius.circular(10)), child: Icon(Icons.directions_car_filled_rounded, color: isSelected ? Colors.white : AppColors.accentBlue, size: 22)),
                title: Text(v.displayName, style: AppTypography.labelLarge),
                subtitle: Text('${v.year} • ${v.plate ?? ""}', style: AppTypography.caption),
                trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.accentBlue) : null,
                onTap: () { _viewModel.garageVM.selectVehicle(v); _viewModel.onVehicleChanged(v.id); Navigator.pop(context); },
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
