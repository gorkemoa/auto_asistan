import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/auto_button.dart';
import '../../../core/widgets/auto_text_field.dart';
import '../../../core/utils/validators.dart';
import '../../../core/services/supabase_service.dart';
import '../models/vehicle_model.dart';

/// Araç ekleme / düzenleme formu
class AddVehicleView extends StatefulWidget {
  final VehicleModel? vehicle; // null ise yeni ekleme
  final Function(VehicleModel) onSaved;

  const AddVehicleView({
    super.key,
    this.vehicle,
    required this.onSaved,
  });

  @override
  State<AddVehicleView> createState() => _AddVehicleViewState();
}

class _AddVehicleViewState extends State<AddVehicleView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _brandController;
  late final TextEditingController _modelController;
  late final TextEditingController _yearController;
  late final TextEditingController _plateController;
  late final TextEditingController _kmController;
  String? _selectedEngineType;
  String? _selectedColor;

  bool get isEditing => widget.vehicle != null;

  final _engineTypes = ['Benzin', 'Dizel', 'Elektrik', 'Hibrit', 'LPG'];
  final _colors = [
    'Beyaz', 'Siyah', 'Gri', 'Kırmızı', 'Mavi',
    'Yeşil', 'Gümüş', 'Lacivert', 'Bordo', 'Turuncu',
  ];

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    _brandController = TextEditingController(text: v?.brand ?? '');
    _modelController = TextEditingController(text: v?.model ?? '');
    _yearController = TextEditingController(text: v?.year.toString() ?? '');
    _plateController = TextEditingController(text: v?.plate ?? '');
    _kmController = TextEditingController(text: v?.currentKm.toString() ?? '0');
    _selectedEngineType = v?.engineType;
    _selectedColor = v?.color;
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _plateController.dispose();
    _kmController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    final vehicle = VehicleModel(
      id: widget.vehicle?.id ?? '',
      userId: SupabaseService.currentUser?.id ?? '',
      brand: _brandController.text.trim(),
      model: _modelController.text.trim(),
      year: int.parse(_yearController.text.trim()),
      engineType: _selectedEngineType,
      plate: _plateController.text.trim(),
      currentKm: int.tryParse(_kmController.text.trim()) ?? 0,
      color: _selectedColor,
      createdAt: widget.vehicle?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onSaved(vehicle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? AppStrings.editVehicle : AppStrings.addVehicle,
          style: AppTypography.h4,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Marka
              AutoTextField(
                label: AppStrings.brand,
                hint: 'Örn: Toyota, BMW, Volkswagen',
                controller: _brandController,
                prefixIcon: Icons.directions_car_outlined,
                validator: (v) => Validators.required(v, 'Marka'),
              ),
              const SizedBox(height: AppDimensions.spacing16),

              // Model
              AutoTextField(
                label: AppStrings.model,
                hint: 'Örn: Corolla, 320i, Golf',
                controller: _modelController,
                prefixIcon: Icons.label_outline_rounded,
                validator: (v) => Validators.required(v, 'Model'),
              ),
              const SizedBox(height: AppDimensions.spacing16),

              // Yıl ve Motor Tipi (yan yana)
              Row(
                children: [
                  Expanded(
                    child: AutoTextField(
                      label: AppStrings.year,
                      hint: '2024',
                      controller: _yearController,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.calendar_today_outlined,
                      validator: Validators.year,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacing16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.engineType, style: AppTypography.labelMedium),
                        const SizedBox(height: AppDimensions.spacing8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedEngineType,
                          items: _engineTypes
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e, style: AppTypography.bodyMedium),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedEngineType = v),
                          decoration: const InputDecoration(
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          ),
                          hint: Text('Seçin', style: AppTypography.bodySmall),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacing16),

              // Plaka
              AutoTextField(
                label: AppStrings.plate,
                hint: '34 ABC 123',
                controller: _plateController,
                prefixIcon: Icons.confirmation_number_outlined,
                validator: Validators.plate,
              ),
              const SizedBox(height: AppDimensions.spacing16),

              // Güncel KM
              AutoTextField(
                label: AppStrings.currentKm,
                hint: '0',
                controller: _kmController,
                keyboardType: TextInputType.number,
                prefixIcon: Icons.speed_outlined,
                validator: (v) => Validators.number(v, 'KM'),
              ),
              const SizedBox(height: AppDimensions.spacing16),

              // Renk
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.color, style: AppTypography.labelMedium),
                  const SizedBox(height: AppDimensions.spacing8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _colors.map((color) {
                      final isSelected = _selectedColor == color;
                      return ChoiceChip(
                        label: Text(color),
                        selected: isSelected,
                        onSelected: (_) =>
                            setState(() => _selectedColor = color),
                        selectedColor: AppColors.accentBlue.withValues(alpha: 0.15),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? AppColors.accentBlue
                              : AppColors.textSecondary,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.spacing32),

              // Kaydet butonu
              AutoButton(
                label: AppStrings.save,
                onPressed: _handleSave,
                icon: Icons.check_rounded,
              ),

              const SizedBox(height: AppDimensions.spacing16),
            ],
          ),
        ),
      ),
    );
  }
}
