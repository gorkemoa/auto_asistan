import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_typography.dart';

/// Özel kart bileşeni — premium glassmorphism efektli
class AutoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final LinearGradient? gradient;
  final bool hasBorder;
  final bool hasShadow;
  final double? borderRadius;

  const AutoCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.gradient,
    this.hasBorder = true,
    this.hasShadow = true,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? AppColors.surfaceCard) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius ?? AppDimensions.radiusLg),
        border: hasBorder
            ? Border.all(color: AppColors.surfaceDivider, width: 0.5)
            : null,
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius ?? AppDimensions.radiusLg),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius ?? AppDimensions.radiusLg),
            child: Padding(
              padding: padding ?? const EdgeInsets.all(AppDimensions.cardPadding),
              child: child,
            ),
          ),
        ),
      ),
    );

    return card.animate().fadeIn(duration: 300.ms).slideY(begin: 0.02, end: 0);
  }
}

/// Gradient ikon kart — dashboard için
class AutoIconCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Color color;
  final VoidCallback? onTap;

  const AutoIconCard({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AutoCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: AppDimensions.spacing12),
          if (value != null) ...[
            Text(value!, style: AppTypography.numericMedium),
            const SizedBox(height: AppDimensions.spacing4),
          ],
          Text(
            label,
            style: AppTypography.labelMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
