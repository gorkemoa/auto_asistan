import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/loading_indicator.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import '../viewmodels/expenses_viewmodel.dart';
import 'add_expense_view.dart';
import '../models/expense_model.dart';

/// Finans ve Gider Takibi Ekranı — TODOIST Style Minimal Tasarım
class ExpensesView extends StatefulWidget {
  final String? vehicleId;

  const ExpensesView({super.key, this.vehicleId});

  @override
  State<ExpensesView> createState() => _ExpensesViewState();
}

class _ExpensesViewState extends State<ExpensesView> {
  final _viewModel = ExpensesViewModel();

  @override
  void initState() {
    super.initState();
    if (widget.vehicleId != null) {
      _viewModel.loadExpenses(widget.vehicleId!);
    }
  }

  @override
  void didUpdateWidget(covariant ExpensesView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.vehicleId != oldWidget.vehicleId && widget.vehicleId != null) {
      _viewModel.loadExpenses(widget.vehicleId!);
    }
  }

  void _addExpense() {
    if (widget.vehicleId == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddExpenseView(
          vehicleId: widget.vehicleId!,
          onSaved: (expense) {
            _viewModel.addExpense(expense);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'yakit':
        return AppColors.expenseFuel;
      case 'bakim':
        return AppColors.expenseMaintenance;
      case 'sigorta':
      case 'kasko':
        return AppColors.expenseInsurance;
      case 'yikama':
        return AppColors.expenseWash;
      case 'otopark':
        return AppColors.expenseParking;
      default:
        return AppColors.expenseOther;
    }
  }

  Widget _getCategoryIcon(
    String category, {
    double size = 20,
    Color color = AppColors.textPrimary,
  }) {
    switch (category) {
      case 'yakit':
        return iconoir.GasTank(width: size, height: size, color: color);
      case 'bakim':
        return iconoir.Wrench(width: size, height: size, color: color);
      case 'sigorta':
        return iconoir.Shield(width: size, height: size, color: color);
      case 'kasko':
        return iconoir.ShieldCheck(width: size, height: size, color: color);
      case 'yikama':
        return iconoir.Droplet(width: size, height: size, color: color);
      case 'otopark':
        return iconoir.Parking(width: size, height: size, color: color);
      default:
        return iconoir.MoreHoriz(width: size, height: size, color: color);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton:
          FloatingActionButton(
            onPressed: _addExpense,
            backgroundColor: AppColors.primaryNavy,
            shape: const CircleBorder(),
            child: const iconoir.Plus(
              width: 28,
              height: 28,
              color: Colors.white,
            ),
          ).animate().scale(
            delay: 400.ms,
            duration: 400.ms,
            curve: Curves.easeOutBack,
          ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.isLoading) {
            return const LoadingIndicator(message: 'Yükleniyor...');
          }

          if (widget.vehicleId == null) {
            return const Center(child: Text('Araç bulunamadı'));
          }

          if (_viewModel.expenses.isEmpty) {
            return _buildEmptyState();
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Özet Satırı
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  child: Row(
                    children: [
                      _buildSummaryChip(
                        'Bu Ay',
                        CurrencyFormatter.format(_viewModel.monthlyTotal),
                      ),
                      const SizedBox(width: 12),
                      _buildSummaryChip(
                        'Toplam',
                        CurrencyFormatter.format(_viewModel.totalExpenses),
                      ),
                    ],
                  ),
                ),
              ),

              // Gider Listesi
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _buildExpenseItem(_viewModel.expenses[index], index),
                    childCount: _viewModel.expenses.length,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryChip(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceDivider, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.caption.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              child: Text(
                value,
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseItem(ExpenseModel expense, int index) {
    final color = _getCategoryColor(expense.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: _getCategoryIcon(
                    expense.category,
                    size: 18,
                    color: color,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.categoryDisplayName,
                        style: AppTypography.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${expense.date.day} ${_monthName(expense.date.month)}',
                        style: AppTypography.caption.copyWith(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.format(expense.amount),
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (expense.description != null &&
                        expense.description!.isNotEmpty)
                      Text(
                        expense.description!,
                        style: AppTypography.caption.copyWith(fontSize: 10),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.surfaceDivider),
        ],
      ),
    ).animate().fadeIn(delay: (index * 40).ms).slideX(begin: 0.05, end: 0);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconoir.EmptyPage(
            width: 48,
            height: 48,
            color: AppColors.textTertiary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text('Henüz gider yok', style: AppTypography.caption),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    return months[month - 1];
  }
}
