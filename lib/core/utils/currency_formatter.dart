import 'package:intl/intl.dart';

/// Para birimi formatlama
class CurrencyFormatter {
  CurrencyFormatter._();

  static final _formatter = NumberFormat.currency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 2,
  );

  static final _compact = NumberFormat.compactCurrency(
    locale: 'tr_TR',
    symbol: '₺',
    decimalDigits: 0,
  );

  static final _noSymbol = NumberFormat('#,##0.00', 'tr_TR');

  /// Tam format: ₺1.234,56
  static String format(double amount) => _formatter.format(amount);

  /// Kısa format: ₺1,2B
  static String compact(double amount) => _compact.format(amount);

  /// Sembolsüz: 1.234,56
  static String noSymbol(double amount) => _noSymbol.format(amount);

  /// KM formatları
  static String formatKm(int km) =>
      '${NumberFormat('#,###', 'tr_TR').format(km)} km';
}
