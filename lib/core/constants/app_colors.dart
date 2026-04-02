import 'package:flutter/material.dart';

/// AutoAssist renk paleti
/// Apple ekosistemine benzer; premium, kurumsal ve minimalist
class AppColors {
  AppColors._();

  // ── Ana Renkler ──
  static const Color primaryNavy = Color(0xFF0A1628);
  static const Color primaryBlue = Color(0xFF1E3A5F);
  static const Color accentBlue = Color(0xFF4A90D9);
  static const Color accentTeal = Color(0xFF00B4D8);

  // ── Yüzeyler ──
  static const Color surfaceLight = Color(0xFFF8F9FA);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceDivider = Color(0xFFE5E7EB);

  // ── Metin ──
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ── Durum Renkleri ──
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // ── Dekoratif ──
  static const Color silverMatte = Color(0xFFC0C0C8);
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // ── Gradient'ler ──
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryNavy, primaryBlue],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentBlue, accentTeal],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF0F4FF), Color(0xFFF8F9FA)],
  );

  // ── Gider Kategori Renkleri ──
  static const Color expenseFuel = Color(0xFF3B82F6);
  static const Color expenseMaintenance = Color(0xFF8B5CF6);
  static const Color expenseInsurance = Color(0xFFEC4899);
  static const Color expenseWash = Color(0xFF06B6D4);
  static const Color expenseParking = Color(0xFFF97316);
  static const Color expenseOther = Color(0xFF6B7280);
}
