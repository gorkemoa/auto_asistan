import 'package:flutter/material.dart';
import 'package:iconoir_flutter/iconoir_flutter.dart' as iconoir;
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/auto_card.dart';
import '../models/vehicle_model.dart';
import '../viewmodels/garage_viewmodel.dart';
import 'add_vehicle_view.dart';

/// Araç detay ekranı
class VehicleDetailView extends StatefulWidget {
  final VehicleModel vehicle;
  final GarageViewModel viewModel;

  const VehicleDetailView({
    super.key,
    required this.vehicle,
    required this.viewModel,
  });

  @override
  State<VehicleDetailView> createState() => _VehicleDetailViewState();
}

class _VehicleDetailViewState extends State<VehicleDetailView> {
  late VehicleModel _vehicle;

  @override
  void initState() {
    super.initState();
    _vehicle = widget.vehicle;
    widget.viewModel.loadChecklist(_vehicle.id);
  }

  void _editVehicle() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddVehicleView(
          vehicle: _vehicle,
          onSaved: (updated) async {
            final success = await widget.viewModel.updateVehicle(updated);
            if (success && mounted) {
              setState(() => _vehicle = updated);
              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }

  void _deleteVehicle() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Aracı Sil'),
        content: Text(
          '${_vehicle.displayName} aracını silmek istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await widget.viewModel.deleteVehicle(_vehicle.id);
              if (mounted) Navigator.pop(context);
            },
            child: Text(
              AppStrings.delete,
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_vehicle.displayName, style: AppTypography.h4),
        actions: [
          IconButton(
            onPressed: _editVehicle,
            icon: const Icon(Icons.edit_outlined, size: 20),
          ),
          IconButton(
            onPressed: _deleteVehicle,
            icon: Icon(
              Icons.delete_outline_rounded,
              size: 20,
              color: AppColors.danger,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Araç Başlık Kartı
            _buildHeaderCard(),
            const SizedBox(height: AppDimensions.spacing20),

            // Bilgi Grid
            _buildInfoGrid(),
            const SizedBox(height: AppDimensions.spacing24),

            // Checklist
            Text(AppStrings.checklist, style: AppTypography.h4),
            const SizedBox(height: AppDimensions.spacing12),
            _buildChecklist(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return AutoCard(
      gradient: AppColors.primaryGradient,
      hasBorder: false,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _vehicle.displayName,
                  style: AppTypography.h3.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  _vehicle.subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusFull,
                    ),
                  ),
                  child: Text(
                    CurrencyFormatter.formatKm(_vehicle.currentKm),
                    style: AppTypography.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid() {
    final items = [
      _InfoItem(
        iconoir.Calendar(width: 20, height: 20, color: AppColors.accentBlue),
        'Yıl',
        '${_vehicle.year}',
      ),
      _InfoItem(
        iconoir.GasTank(width: 20, height: 20, color: AppColors.accentBlue),
        'Motor',
        _vehicle.engineType ?? '-',
      ),
      _InfoItem(
        iconoir.InfoCircle(width: 20, height: 20, color: AppColors.accentBlue),
        'Plaka',
        _vehicle.plate ?? '-',
      ),
      _InfoItem(
        iconoir.Palette(width: 20, height: 20, color: AppColors.accentBlue),
        'Renk',
        _vehicle.color ?? '-',
      ),
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: items.map((item) {
        return AutoCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              item.icon,
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(item.label, style: AppTypography.caption),
                    Text(
                      item.value,
                      style: AppTypography.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChecklist() {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final items = widget.viewModel.checklistItems;
        if (items.isEmpty) {
          return AutoCard(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacing16),
                child: Text(
                  'Checklist yükleniyor...',
                  style: AppTypography.bodySmall,
                ),
              ),
            ),
          );
        }

        return AutoCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: items.asMap().entries.map((entry) {
              final item = entry.value;
              final isLast = entry.key == items.length - 1;
              return Column(
                children: [
                  CheckboxListTile(
                    value: item.isChecked,
                    onChanged: (val) {
                      widget.viewModel.toggleChecklist(item.id, val ?? false);
                    },
                    title: Text(
                      item.itemName,
                      style: AppTypography.bodyMedium.copyWith(
                        decoration: item.isChecked
                            ? TextDecoration.lineThrough
                            : null,
                        color: item.isChecked
                            ? AppColors.textTertiary
                            : AppColors.textPrimary,
                      ),
                    ),
                    activeColor: AppColors.success,
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  if (!isLast) const Divider(height: 0, indent: 52),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _InfoItem {
  final Widget icon;
  final String label;
  final String value;
  const _InfoItem(this.icon, this.label, this.value);
}
