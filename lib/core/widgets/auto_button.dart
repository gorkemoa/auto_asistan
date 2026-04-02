import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_typography.dart';

/// Premium buton bileşeni — birden fazla varyant
enum AutoButtonVariant { primary, secondary, outline, ghost, danger }

class AutoButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AutoButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double? height;
  final Color? color;

  const AutoButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AutoButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final h = height ?? AppDimensions.buttonHeight;

    switch (variant) {
      case AutoButtonVariant.primary:
        return _buildPrimary(h);
      case AutoButtonVariant.secondary:
        return _buildSecondary(h);
      case AutoButtonVariant.outline:
        return _buildOutline(h);
      case AutoButtonVariant.ghost:
        return _buildGhost(h);
      case AutoButtonVariant.danger:
        return _buildDanger(h);
    }
  }

  Widget _buildPrimary(double h) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: h,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColors.accentBlue,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ),
        child: _buildChild(AppColors.textOnPrimary),
      ),
    );
  }

  Widget _buildSecondary(double h) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: h,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: (color ?? AppColors.accentBlue).withValues(
            alpha: 0.1,
          ),
          foregroundColor: color ?? AppColors.accentBlue,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ),
        child: _buildChild(color ?? AppColors.accentBlue),
      ),
    );
  }

  Widget _buildOutline(double h) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: h,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color ?? AppColors.accentBlue,
          side: BorderSide(color: color ?? AppColors.accentBlue, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ),
        child: _buildChild(color ?? AppColors.accentBlue),
      ),
    );
  }

  Widget _buildGhost(double h) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: h,
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        child: _buildChild(color ?? AppColors.accentBlue),
      ),
    );
  }

  Widget _buildDanger(double h) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: h,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColors.danger,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ),
        child: _buildChild(AppColors.textOnPrimary),
      ),
    );
  }

  Widget _buildChild(Color color) {
    if (isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2.5, color: color),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(label, style: AppTypography.buttonMedium.copyWith(color: color)),
        ],
      );
    }

    return Text(
      label,
      style: AppTypography.buttonMedium.copyWith(color: color),
    );
  }
}
