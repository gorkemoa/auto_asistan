import '../../../core/services/supabase_service.dart';
import '../../../core/utils/logger.dart';
import '../models/reminder_model.dart';

/// Hatırlatma repository
class ReminderRepository {
  final _client = SupabaseService.client;

  /// Araç hatırlatmalarını getir
  Future<List<ReminderModel>> getReminders(String vehicleId) async {
    AppLogger.supabaseOp('SELECT', 'reminders', {'vehicle_id': vehicleId});
    try {
      final data = await _client
          .from('reminders')
          .select()
          .eq('vehicle_id', vehicleId)
          .order('target_date', ascending: true);

      return (data as List).map((e) => ReminderModel.fromJson(e)).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Hatırlatma Getirme Hatası', e, stackTrace);
      return [];
    }
  }

  /// Aktif hatırlatmalar (tamamlanmamış)
  Future<List<ReminderModel>> getActiveReminders(String vehicleId) async {
    AppLogger.supabaseOp('SELECT_ACTIVE', 'reminders', {'vehicle_id': vehicleId});
    try {
      final data = await _client
          .from('reminders')
          .select()
          .eq('vehicle_id', vehicleId)
          .eq('is_completed', false)
          .order('target_date', ascending: true);

      return (data as List).map((e) => ReminderModel.fromJson(e)).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Aktif Hatırlatma Getirme Hatası', e, stackTrace);
      return [];
    }
  }

  /// Hatırlatma ekle
  Future<ReminderModel> addReminder(ReminderModel reminder) async {
    AppLogger.supabaseOp('INSERT', 'reminders', reminder.toJson());
    try {
      final data = await _client
          .from('reminders')
          .insert(reminder.toJson())
          .select()
          .single();
      AppLogger.info('Hatırlatma eklendi: ${data['id']}');
      return ReminderModel.fromJson(data);
    } catch (e, stackTrace) {
      AppLogger.error('Hatırlatma Ekleme Hatası', e, stackTrace);
      rethrow;
    }
  }

  /// Hatırlatma tamamla
  Future<void> completeReminder(String id) async {
    AppLogger.supabaseOp('UPDATE_STATUS', 'reminders', {'id': id, 'is_completed': true});
    try {
      await _client
          .from('reminders')
          .update({'is_completed': true})
          .eq('id', id);
    } catch (e, stackTrace) {
      AppLogger.error('Hatırlatma Tamamlama Hatası', e, stackTrace);
      rethrow;
    }
  }

  /// Hatırlatma sil
  Future<void> deleteReminder(String id) async {
    AppLogger.supabaseOp('DELETE', 'reminders', {'id': id});
    try {
      await _client.from('reminders').delete().eq('id', id);
    } catch (e, stackTrace) {
      AppLogger.error('Hatırlatma Silme Hatası', e, stackTrace);
      rethrow;
    }
  }
}
