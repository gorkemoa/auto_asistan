import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/auto_button.dart';
import '../../../core/utils/validators.dart';
import '../models/expense_model.dart';

/// Gider Ekleme Formu — Premium Minimal Tasarım (Todoist Inspired)
class AddExpenseView extends StatefulWidget {
  final String vehicleId;
  final Function(ExpenseModel) onSaved;

  const AddExpenseView({
    super.key,
    required this.vehicleId,
    required this.onSaved,
  });

  @override
  State<AddExpenseView> createState() => _AddExpenseViewState();
}

class _AddExpenseViewState extends State<AddExpenseView> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'yakit';
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('tr', 'TR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryNavy,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    final expense = ExpenseModel(
      id: '',
      vehicleId: widget.vehicleId,
      category: _selectedCategory,
      amount: double.parse(_amountController.text.trim()),
      date: _selectedDate,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      createdAt: DateTime.now(),
    );

    widget.onSaved(expense);
  }

  Color _getCategoryColor(String key) {
    switch (key) {
      case 'yakit': return AppColors.expenseFuel;
      case 'bakim': return AppColors.expenseMaintenance;
      case 'sigorta':
      case 'kasko': return AppColors.expenseInsurance;
      case 'yikama': return AppColors.expenseWash;
      case 'otopark': return AppColors.expenseParking;
      default: return AppColors.expenseOther;
    }
  }

  IconData _getCategoryIcon(String key) {
    switch (key) {
      case 'yakit': return Icons.local_gas_station_rounded;
      case 'bakim': return Icons.build_rounded;
      case 'sigorta': return Icons.security_rounded;
      case 'kasko': return Icons.shield_rounded;
      case 'yikama': return Icons.local_car_wash_rounded;
      case 'otopark': return Icons.local_parking_rounded;
      default: return Icons.more_horiz_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text('Yeni Gider Ekle', style: AppTypography.h4),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Harcalama Kategorisi'),
              const SizedBox(height: 12),
              _buildCategorySelectBox(),
              
              const SizedBox(height: 32),
              _buildSectionTitle('Gider Detayları'),
              const SizedBox(height: 12),
              _buildFormContainer([
                _buildAmountField(),
                _buildDivider(),
                _buildDateField(),
                _buildDivider(),
                _buildDescriptionField(),
              ]),

              const SizedBox(height: 48),
              AutoButton(
                label: 'Harcamayı Kaydet',
                onPressed: _handleSave,
                icon: Icons.check_circle_rounded,
                color: AppColors.primaryNavy,
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w800));
  }

  Widget _buildFormContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceDivider, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 55, color: AppColors.surfaceDivider);
  }

  Widget _buildCategorySelectBox() {
    final color = _getCategoryColor(_selectedCategory);
    final icon = _getCategoryIcon(_selectedCategory);
    final label = ExpenseModel.categories.firstWhere((c) => c['key'] == _selectedCategory)['label']!;

    return InkWell(
      onTap: _showCategoryPicker,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceDivider, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Seçili Kategori', style: AppTypography.caption),
                  Text(label, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const Icon(Icons.unfold_more_rounded, color: AppColors.textTertiary),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceDivider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text('Kategori Seçin', style: AppTypography.h4),
              const SizedBox(height: 24),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: ExpenseModel.categories.length,
                  itemBuilder: (context, index) {
                    final cat = ExpenseModel.categories[index];
                    final key = cat['key']!;
                    final isSelected = _selectedCategory == key;
                    final color = _getCategoryColor(key);
                    final icon = _getCategoryIcon(key);

                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedCategory = key);
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? color : AppColors.surfaceDivider,
                            width: isSelected ? 2 : 0.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(icon, color: isSelected ? color : AppColors.textTertiary, size: 28),
                            const SizedBox(height: 8),
                            Text(
                              cat['label']!,
                              textAlign: TextAlign.center,
                              style: AppTypography.caption.copyWith(
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                color: isSelected ? color : AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAmountField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextFormField(
        controller: _amountController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: AppTypography.h3,
        validator: (v) => Validators.number(v, 'Tutar'),
        decoration: InputDecoration(
          icon: const Icon(Icons.payments_rounded, color: AppColors.accentBlue),
          hintText: '0.00 ₺',
          labelText: 'Tutar',
          labelStyle: AppTypography.caption,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: _selectDate,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, color: AppColors.textTertiary, size: 20),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tarih', style: AppTypography.caption),
                  Text(
                    '${_selectedDate.day} ${_monthName(_selectedDate.month)} ${_selectedDate.year}',
                    style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextFormField(
        controller: _descriptionController,
        maxLines: 2,
        decoration: InputDecoration(
          icon: const Icon(Icons.notes_rounded, color: AppColors.textTertiary),
          hintText: 'Açıklama veya not ekle...',
          hintStyle: AppTypography.caption,
          labelText: 'Notlar (İsteğe Bağlı)',
          labelStyle: AppTypography.caption,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
    return months[month - 1];
  }
}
