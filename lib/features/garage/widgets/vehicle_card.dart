import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../models/vehicle_model.dart';

/// Araç kartı widget'ı — premium, animasyonlu
class VehicleCard extends StatelessWidget {
  final VehicleModel vehicle;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onSelect;

  const VehicleCard({
    super.key,
    required this.vehicle,
    this.isSelected = false,
    this.onTap,
    this.onSelect,
  });

  IconData _getEngineIcon() {
    switch (vehicle.engineType?.toLowerCase()) {
      case 'benzin':
        return Icons.local_gas_station_rounded;
      case 'dizel':
        return Icons.local_gas_station_rounded;
      case 'elektrik':
        return Icons.bolt_rounded;
      case 'hibrit':
        return Icons.eco_rounded;
      case 'lpg':
        return Icons.propane_rounded;
      default:
        return Icons.directions_car_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: isSelected ? AppColors.accentBlue : AppColors.surfaceDivider,
            width: isSelected ? 2 : 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.accentBlue.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: isSelected ? 20 : 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.cardPaddingLg),
          child: Row(
            children: [
              // Araç ikonu
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? AppColors.accentGradient
                      : AppColors.cardGradient,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: Icon(
                  Icons.directions_car_filled_rounded,
                  color: isSelected ? Colors.white : AppColors.accentBlue,
                  size: 28,
                ),
              ),

              const SizedBox(width: AppDimensions.spacing16),

              // Araç bilgileri
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.displayName,
                      style: AppTypography.h4,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimensions.spacing4),
                    Row(
                      children: [
                        Icon(_getEngineIcon(),
                            size: 14, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          '${vehicle.year}',
                          style: AppTypography.caption,
                        ),
                        if (vehicle.engineType != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: const BoxDecoration(
                              color: AppColors.textTertiary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(vehicle.engineType!, style: AppTypography.caption),
                        ],
                      ],
                    ),
                    if (vehicle.plate != null && vehicle.plate!.isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.spacing4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryNavy.withValues(alpha: 0.06),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusSm),
                        ),
                        child: Text(
                          vehicle.plate!,
                          style: AppTypography.labelSmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // KM bilgisi
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.formatKm(vehicle.currentKm),
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.accentBlue,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text('Güncel', style: AppTypography.caption),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.03);
  }
}
