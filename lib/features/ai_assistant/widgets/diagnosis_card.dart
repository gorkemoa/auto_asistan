import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../models/chat_message_model.dart';

/// Arıza teşhis kartı — ciddiyet göstergesi ve tavsiyeler
class DiagnosisCard extends StatelessWidget {
  final DiagnosisModel diagnosis;

  const DiagnosisCard({super.key, required this.diagnosis});

  Color get _severityColor {
    switch (diagnosis.severity) {
      case 'low': return AppColors.success;
      case 'medium': return AppColors.warning;
      case 'high': return AppColors.danger;
      case 'critical': return const Color(0xFF991B1B);
      default: return AppColors.info;
    }
  }

  IconData get _severityIcon {
    switch (diagnosis.severity) {
      case 'low': return Icons.check_circle_outline_rounded;
      case 'medium': return Icons.warning_amber_rounded;
      case 'high': return Icons.error_outline_rounded;
      case 'critical': return Icons.dangerous_rounded;
      default: return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: _severityColor.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: _severityColor.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _severityColor.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppDimensions.radiusLg),
                  topRight: Radius.circular(AppDimensions.radiusLg),
                ),
              ),
              child: Row(
                children: [
                  Icon(_severityIcon, color: _severityColor, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          diagnosis.possibleIssue,
                          style: AppTypography.labelLarge,
                        ),
                        Text(
                          'Durum: ${diagnosis.severityText}',
                          style: AppTypography.caption.copyWith(
                            color: _severityColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sürüş uyarısı
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: diagnosis.canDrive
                          ? AppColors.successLight
                          : AppColors.dangerLight,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusSm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          diagnosis.canDrive
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          size: 16,
                          color: diagnosis.canDrive
                              ? AppColors.success
                              : AppColors.danger,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          diagnosis.canDrive
                              ? 'Sürüş güvenli (dikkatli olun)'
                              : 'Aracı kullanmayın!',
                          style: AppTypography.labelSmall.copyWith(
                            color: diagnosis.canDrive
                                ? AppColors.success
                                : AppColors.danger,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tavsiyeler
                  if (diagnosis.recommendations.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text('Tavsiyeler:', style: AppTypography.labelMedium),
                    const SizedBox(height: 6),
                    ...diagnosis.recommendations.map((rec) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('•  ',
                                  style: TextStyle(
                                      color: AppColors.accentBlue,
                                      fontWeight: FontWeight.bold)),
                              Expanded(
                                child: Text(rec, style: AppTypography.bodySmall),
                              ),
                            ],
                          ),
                        )),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05);
  }
}
