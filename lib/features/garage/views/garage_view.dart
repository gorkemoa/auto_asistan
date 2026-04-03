import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';

import '../../../core/widgets/loading_indicator.dart';
import '../viewmodels/garage_viewmodel.dart';
import '../models/vehicle_model.dart';
import '../widgets/vehicle_card.dart';
import 'add_vehicle_view.dart';
import 'vehicle_detail_view.dart';

/// Garaj ana ekranı — araç listesi ve yönetim
class GarageView extends StatefulWidget {
  const GarageView({super.key});

  @override
  State<GarageView> createState() => _GarageViewState();
}

class _GarageViewState extends State<GarageView> {
  final _viewModel = GarageViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.loadVehicles();
  }

  void _openAddVehicle() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddVehicleView(
          onSaved: (vehicle) {
            _viewModel.addVehicle(vehicle);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _openVehicleDetail(VehicleModel vehicle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VehicleDetailView(
          vehicle: vehicle,
          viewModel: _viewModel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppDimensions.pagePaddingH, 16, AppDimensions.pagePaddingH, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppStrings.myGarage, style: AppTypography.h2),
                  IconButton(
                    onPressed: _openAddVehicle,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accentBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                      ),
                      child: const Icon(Icons.add_rounded, color: AppColors.accentBlue, size: 24),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) {
                  if (_viewModel.isLoading) {
                    return const LoadingIndicator(message: 'Araçlar yükleniyor...');
                  }

                  if (!_viewModel.hasVehicles) {
                    return _buildEmptyState();
                  }

                  return _buildVehicleList();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacing32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
              ),
              child: const Icon(
                Icons.garage_rounded,
                color: Colors.white,
                size: 48,
              ),
            ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8)),
            const SizedBox(height: AppDimensions.spacing24),
            Text(AppStrings.emptyGarage, style: AppTypography.h3)
                .animate()
                .fadeIn(delay: 200.ms),
            const SizedBox(height: AppDimensions.spacing8),
            Text(
              AppStrings.emptyGarageSubtitle,
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: AppDimensions.spacing32),
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                onPressed: _openAddVehicle,
                icon: const Icon(Icons.add_rounded),
                label: const Text(AppStrings.addVehicle),
              ),
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleList() {
    return RefreshIndicator(
      onRefresh: _viewModel.loadVehicles,
      color: AppColors.accentBlue,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        itemCount: _viewModel.vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = _viewModel.vehicles[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.spacing16),
            child: VehicleCard(
              vehicle: vehicle,
              isSelected: _viewModel.selectedVehicle?.id == vehicle.id,
              onTap: () => _openVehicleDetail(vehicle),
              onSelect: () => _viewModel.selectVehicle(vehicle),
            ),
          );
        },
      ),
    );
  }
}
