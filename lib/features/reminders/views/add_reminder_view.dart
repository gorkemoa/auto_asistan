import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/auto_button.dart';
import '../../../core/utils/validators.dart';
import '../models/reminder_model.dart';

/// Hatırlatma Ekleme Formu — Premium Minimal Tasarım (Todoist Inspired)
class AddReminderView extends StatefulWidget {
  final String vehicleId;
  final Function(ReminderModel) onSaved;

  const AddReminderView({
    super.key,
    required this.vehicleId,
    required this.onSaved,
  });

  @override
  State<AddReminderView> createState() => _AddReminderViewState();
}

class _AddReminderViewState extends State<AddReminderView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _targetKmController = TextEditingController();
  String _selectedType = 'bakim';
  DateTime? _targetDate;

  @override
  void dispose() {
    _titleController.dispose();
    _targetKmController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      locale: const Locale('tr', 'TR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.warning,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _targetDate = picked);
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    final reminder = ReminderModel(
      id: '',
      vehicleId: widget.vehicleId,
      type: _selectedType,
      title: _titleController.text.trim(),
      targetDate: _targetDate,
      targetKm: _targetKmController.text.trim().isNotEmpty
          ? int.tryParse(_targetKmController.text.trim())
          : null,
      createdAt: DateTime.now(),
    );

    widget.onSaved(reminder);
  }

  Color _getTypeColor(String key) {
    switch (key) {
      case 'bakim': return AppColors.expenseMaintenance;
      case 'sigorta':
      case 'kasko': return AppColors.expenseInsurance;
      case 'muayene': return AppColors.accentBlue;
      default: return AppColors.warning;
    }
  }

  IconData _getTypeIcon(String key) {
    switch (key) {
      case 'muayene': return Icons.fact_check_rounded;
      case 'sigorta': return Icons.security_rounded;
      case 'kasko': return Icons.shield_rounded;
      case 'bakim': return Icons.build_circle_rounded;
      default: return Icons.notifications_active_rounded;
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
        title: Text('Yeni Hatırlatıcı', style: AppTypography.h4),
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
              _buildSectionTitle('Hatırlatma Tipi'),
              const SizedBox(height: 12),
              _buildTypeSelectBox(),
              
              const SizedBox(height: 32),
              _buildSectionTitle('Plan Detayları'),
              const SizedBox(height: 12),
              _buildFormContainer([
                _buildTitleField(),
                _buildDivider(),
                _buildDateField(),
                _buildDivider(),
                _buildKmField(),
              ]),

              const SizedBox(height: 48),
              AutoButton(
                label: 'Planı Oluştur',
                onPressed: _handleSave,
                icon: Icons.notifications_active_rounded,
                color: AppColors.warning,
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

  Widget _buildTypeSelectBox() {
    final color = _getTypeColor(_selectedType);
    final icon = _getTypeIcon(_selectedType);
    final label = ReminderModel.types.firstWhere((t) => t['key'] == _selectedType)['label']!;

    return InkWell(
      onTap: _showTypePicker,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.surfaceDivider, width: 0.5),
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
                  Text('Bildirim Türü', style: AppTypography.caption),
                  Text(label, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            const Icon(Icons.arrow_drop_down_rounded, color: AppColors.textTertiary, size: 30),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  void _showTypePicker() {
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
              Text('Hatırlatma Türü', style: AppTypography.h4),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: ReminderModel.types.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final type = ReminderModel.types[index];
                    final key = type['key']!;
                    final isSelected = _selectedType == key;
                    final color = _getTypeColor(key);
                    final icon = _getTypeIcon(key);

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: color, size: 20),
                      ),
                      title: Text(
                        type['label']!,
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                        ),
                      ),
                      trailing: isSelected 
                        ? Icon(Icons.check_circle_rounded, color: color) 
                        : null,
                      onTap: () {
                        setState(() => _selectedType = key);
                        Navigator.pop(context);
                      },
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

  Widget _buildTitleField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextFormField(
        controller: _titleController,
        style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w600),
        validator: (v) => Validators.required(v, 'Açıklama'),
        decoration: InputDecoration(
          icon: const Icon(Icons.edit_note_rounded, color: AppColors.warning),
          hintText: 'Örn: 10.000 KM Bakımı',
          labelText: 'Plan Başlığı',
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
            const Icon(Icons.event_available_rounded, color: AppColors.textTertiary, size: 20),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hedef Tarih (İsteğe Bağlı)', style: AppTypography.caption),
                  Text(
                    _targetDate != null 
                        ? '${_targetDate!.day} ${_monthName(_targetDate!.month)} ${_targetDate!.year}'
                        : 'Seçilmedi',
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _targetDate != null ? AppColors.textPrimary : AppColors.textTertiary,
                    ),
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

  Widget _buildKmField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextFormField(
        controller: _targetKmController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          icon: const Icon(Icons.speed_rounded, color: AppColors.textTertiary),
          hintText: 'Örn: 45000',
          labelText: 'Hedef Kilometre (İsteğe Bağlı)',
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
