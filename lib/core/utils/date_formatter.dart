import 'package:intl/intl.dart';

/// Tarih formatlama yardımcıları
class DateFormatter {
  DateFormatter._();

  static final _dayMonthYear = DateFormat('dd MMM yyyy', 'tr_TR');
  static final _dayMonth = DateFormat('dd MMM', 'tr_TR');
  static final _monthYear = DateFormat('MMM yyyy', 'tr_TR');
  static final _fullDate = DateFormat('dd MMMM yyyy', 'tr_TR');
  static final _shortDate = DateFormat('dd.MM.yyyy');

  static String dayMonthYear(DateTime date) => _dayMonthYear.format(date);
  static String dayMonth(DateTime date) => _dayMonth.format(date);
  static String monthYear(DateTime date) => _monthYear.format(date);
  static String fullDate(DateTime date) => _fullDate.format(date);
  static String shortDate(DateTime date) => _shortDate.format(date);

  /// Kalan gün hesaplama
  static int daysUntil(DateTime targetDate) {
    final now = DateTime.now();
    return targetDate.difference(now).inDays;
  }

  /// Kalan gün metni
  static String daysUntilText(DateTime targetDate) {
    final days = daysUntil(targetDate);
    if (days < 0) return '${-days} gün gecikmiş';
    if (days == 0) return 'Bugün';
    if (days == 1) return 'Yarın';
    return '$days gün kaldı';
  }

  /// Göreceli zaman (örn: "3 saat önce")
  static String relative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Az önce';
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
    if (diff.inHours < 24) return '${diff.inHours} saat önce';
    if (diff.inDays < 7) return '${diff.inDays} gün önce';
    return shortDate(date);
  }
}
