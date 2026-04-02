import '../../../core/services/supabase_service.dart';
import '../../../core/utils/logger.dart';
import '../models/expense_model.dart';

/// Gider repository
class ExpenseRepository {
  final _client = SupabaseService.client;

  /// Araç giderlerini getir
  Future<List<ExpenseModel>> getExpenses(String vehicleId) async {
    AppLogger.supabaseOp('SELECT', 'expenses', {'vehicle_id': vehicleId});
    try {
      final data = await _client
          .from('expenses')
          .select()
          .eq('vehicle_id', vehicleId)
          .order('date', ascending: false);

      AppLogger.info('Giderler getirildi: ${(data as List).length}');
      return data.map((e) => ExpenseModel.fromJson(e)).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Gider Getirme Hatası', e, stackTrace);
      return [];
    }
  }

  /// Gider ekle
  Future<ExpenseModel> addExpense(ExpenseModel expense) async {
    AppLogger.supabaseOp('INSERT', 'expenses', expense.toJson());
    try {
      final data = await _client
          .from('expenses')
          .insert(expense.toJson())
          .select()
          .single();
      AppLogger.info('Gider eklendi: ${data['id']}');
      return ExpenseModel.fromJson(data);
    } catch (e, stackTrace) {
      AppLogger.error('Gider Ekleme Hatası', e, stackTrace);
      rethrow;
    }
  }

  /// Gider sil
  Future<void> deleteExpense(String id) async {
    AppLogger.supabaseOp('DELETE', 'expenses', {'id': id});
    try {
      await _client.from('expenses').delete().eq('id', id);
      AppLogger.info('Gider silindi');
    } catch (e, stackTrace) {
      AppLogger.error('Gider Silme Hatası', e, stackTrace);
      rethrow;
    }
  }

  /// Aylık gider toplamı
  Future<double> getMonthlyTotal(String vehicleId, int year, int month) async {
    AppLogger.supabaseOp('SELECT_SUM', 'expenses', {'vehicle_id': vehicleId, 'month': month, 'year': year});
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);

    try {
      final data = await _client
          .from('expenses')
          .select('amount')
          .eq('vehicle_id', vehicleId)
          .gte('date', startDate.toIso8601String().split('T').first)
          .lte('date', endDate.toIso8601String().split('T').first);

      double total = 0;
      for (final row in data) {
        total += (row['amount'] as num).toDouble();
      }
      return total;
    } catch (e, stackTrace) {
      AppLogger.error('Aylık Toplam Hatası', e, stackTrace);
      return 0;
    }
  }

  /// Kategori bazlı toplam
  Future<Map<String, double>> getCategoryTotals(
    String vehicleId, {
    int? year,
  }) async {
    AppLogger.supabaseOp('SELECT_GROUP_BY', 'expenses', {'vehicle_id': vehicleId, 'year': year});
    try {
      var query = _client
          .from('expenses')
          .select('category, amount')
          .eq('vehicle_id', vehicleId);

      if (year != null) {
        query = query.gte('date', '$year-01-01').lte('date', '$year-12-31');
      }

      final data = await query;
      final Map<String, double> totals = {};
      for (final row in data) {
        final cat = row['category'] as String;
        final amount = (row['amount'] as num).toDouble();
        totals[cat] = (totals[cat] ?? 0) + amount;
      }
      return totals;
    } catch (e, stackTrace) {
      AppLogger.error('Kategori Toplam Hatası', e, stackTrace);
      return {};
    }
  }
}
