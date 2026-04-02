import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../viewmodels/reminders_viewmodel.dart';
import '../models/reminder_model.dart';
import 'add_reminder_view.dart';

/// Hatırlatmalar Ekranı — TODOIST Style Minimal Tasarım
class RemindersView extends StatefulWidget {
  final String? vehicleId;

  const RemindersView({super.key, this.vehicleId});

  @override
  State<RemindersView> createState() => _RemindersViewState();
}

class _RemindersViewState extends State<RemindersView> {
  final _viewModel = RemindersViewModel();

  @override
  void initState() {
    super.initState();
    if (widget.vehicleId != null) {
      _viewModel.loadReminders(widget.vehicleId!);
    }
  }

  @override
  void didUpdateWidget(covariant RemindersView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.vehicleId != oldWidget.vehicleId && widget.vehicleId != null) {
      _viewModel.loadReminders(widget.vehicleId!);
    }
  }

  void _addReminder() {
    if (widget.vehicleId == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddReminderView(
          vehicleId: widget.vehicleId!,
          onSaved: (reminder) {
            _viewModel.addReminder(reminder);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'overdue': return AppColors.danger;
      case 'soon': return AppColors.warning;
      case 'completed': return AppColors.success;
      default: return AppColors.accentBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: _addReminder,
        backgroundColor: AppColors.warning,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ).animate().scale(delay: 400.ms, duration: 400.ms, curve: Curves.easeOutBack),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          if (_viewModel.isLoading) {
            return const LoadingIndicator(message: 'Yükleniyor...');
          }

          if (widget.vehicleId == null) {
            return const Center(child: Text('Araç bulunamadı'));
          }

          final overdue = _viewModel.overdueReminders;
          final soon = _viewModel.soonReminders;
          final active = _viewModel.activeReminders
              .where((r) => r.status != 'overdue' && r.status != 'soon')
              .toList();

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              if (overdue.isNotEmpty) ...[
                _buildSliverHeader('Gecikmiş', AppColors.danger),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildTodoItem(overdue[index], index),
                      childCount: overdue.length,
                    ),
                  ),
                ),
              ],

              if (soon.isNotEmpty) ...[
                _buildSliverHeader('Yaklaşan', AppColors.warning),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildTodoItem(soon[index], index),
                      childCount: soon.length,
                    ),
                  ),
                ),
              ],

              _buildSliverHeader('Aktif Planlar', AppColors.accentBlue),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: active.isEmpty && overdue.isEmpty && soon.isEmpty
                  ? SliverToBoxAdapter(child: _buildEmptyState())
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildTodoItem(active[index], index),
                        childCount: active.length,
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

  Widget _buildSliverHeader(String title, Color color) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
        child: Text(
          title, 
          style: AppTypography.labelLarge.copyWith(color: color, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _buildTodoItem(ReminderModel reminder, int index) {
    final statusColor = _getStatusColor(reminder.status);

    return Dismissible(
      key: Key(reminder.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: AppColors.danger,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (_) => _viewModel.deleteReminder(reminder.id),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => _viewModel.completeReminder(reminder.id),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        border: Border.all(color: statusColor, width: 2),
                        shape: BoxShape.circle,
                        color: reminder.isCompleted ? statusColor : Colors.transparent,
                      ),
                      child: reminder.isCompleted 
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reminder.title, 
                          style: AppTypography.labelMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            decoration: reminder.isCompleted ? TextDecoration.lineThrough : null,
                            color: reminder.isCompleted ? AppColors.textTertiary : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              reminder.typeDisplayName, 
                              style: AppTypography.caption.copyWith(fontSize: 11),
                            ),
                            if (reminder.targetDate != null) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.calendar_today_rounded, size: 10, color: AppColors.textTertiary),
                              const SizedBox(width: 4),
                              Text(
                                DateFormatter.daysUntilText(reminder.targetDate!),
                                style: AppTypography.caption.copyWith(
                                  fontSize: 11, 
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.surfaceDivider),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 40).ms).slideX(begin: 0.05, end: 0);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Text('-- Her şey tamam --', style: AppTypography.caption),
      ),
    );
  }
}
