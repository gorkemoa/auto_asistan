import '../../../core/services/supabase_service.dart';
import '../../../core/utils/logger.dart';
import '../models/vehicle_model.dart';

/// Araç repository — Supabase CRUD işlemleri
class VehicleRepository {
  final _client = SupabaseService.client;

  /// Kullanıcının tüm araçlarını getir
  Future<List<VehicleModel>> getVehicles() async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return [];

    AppLogger.supabaseOp('SELECT', 'vehicles', {'user_id': userId});
    try {
      final data = await _client
          .from('vehicles')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      AppLogger.info('Araçlar başarıyla getirildi: ${(data as List).length}');
      return data.map((e) => VehicleModel.fromJson(e)).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Araç Getirme Hatası', e, stackTrace);
      return [];
    }
  }

  /// Tek bir aracı getir
  Future<VehicleModel?> getVehicle(String id) async {
    AppLogger.supabaseOp('SELECT', 'vehicles', {'id': id});
    try {
      final data =
          await _client.from('vehicles').select().eq('id', id).maybeSingle();
      if (data == null) {
        AppLogger.warning('Araç bulunamadı: $id');
        return null;
      }
      return VehicleModel.fromJson(data);
    } catch (e, stackTrace) {
      AppLogger.error('Araç Detay Hatası', e, stackTrace);
      return null;
    }
  }

  /// Araç ekle
  Future<VehicleModel> addVehicle(VehicleModel vehicle) async {
    AppLogger.supabaseOp('INSERT', 'vehicles', vehicle.toJson());
    try {
      final data = await _client
          .from('vehicles')
          .insert(vehicle.toJson())
          .select()
          .single();
      AppLogger.info('Araç eklendi: ${data['id']}');
      return VehicleModel.fromJson(data);
    } catch (e, stackTrace) {
      AppLogger.error('Araç Ekleme Hatası', e, stackTrace);
      rethrow;
    }
  }

  /// Araç güncelle
  Future<void> updateVehicle(VehicleModel vehicle) async {
    AppLogger.supabaseOp('UPDATE', 'vehicles', {'id': vehicle.id});
    try {
      await _client
          .from('vehicles')
          .update(vehicle.toJson())
          .eq('id', vehicle.id);
      AppLogger.info('Araç güncellendi');
    } catch (e, stackTrace) {
      AppLogger.error('Araç Güncelleme Hatası', e, stackTrace);
      rethrow;
    }
  }

  /// Araç sil
  Future<void> deleteVehicle(String id) async {
    AppLogger.supabaseOp('DELETE', 'vehicles', {'id': id});
    try {
      await _client.from('vehicles').delete().eq('id', id);
      AppLogger.info('Araç silindi');
    } catch (e, stackTrace) {
      AppLogger.error('Araç Silme Hatası', e, stackTrace);
      rethrow;
    }
  }

  /// KM güncelle
  Future<void> updateKm(String vehicleId, int km) async {
    AppLogger.supabaseOp('UPDATE', 'vehicles', {'id': vehicleId, 'current_km': km});
    try {
      await _client
          .from('vehicles')
          .update({'current_km': km})
          .eq('id', vehicleId);
    } catch (e, stackTrace) {
      AppLogger.error('KM Güncelleme Hatası', e, stackTrace);
    }
  }

  // ── Checklist işlemleri ──

  /// Checklist'i getir
  Future<List<ChecklistItemModel>> getChecklist(String vehicleId) async {
    AppLogger.supabaseOp('SELECT', 'vehicle_checklists', {'vehicle_id': vehicleId});
    try {
      final data = await _client
          .from('vehicle_checklists')
          .select()
          .eq('vehicle_id', vehicleId)
          .order('item_name');

      AppLogger.info('Checklist getirildi: ${(data as List).length}');
      return data.map((e) => ChecklistItemModel.fromJson(e)).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Checklist Getirme Hatası', e, stackTrace);
      return [];
    }
  }

  /// Checklist item ekle
  Future<void> addChecklistItem(ChecklistItemModel item) async {
    AppLogger.supabaseOp('INSERT', 'vehicle_checklists', item.toJson());
    try {
      await _client.from('vehicle_checklists').insert(item.toJson());
    } catch (e, stackTrace) {
      AppLogger.error('Checklist Item Ekleme Hatası', e, stackTrace);
    }
  }

  /// Checklist item güncelle (check/uncheck)
  Future<void> toggleChecklistItem(String id, bool isChecked) async {
    AppLogger.supabaseOp('UPDATE', 'vehicle_checklists', {'id': id, 'is_checked': isChecked});
    try {
      await _client
          .from('vehicle_checklists')
          .update({'is_checked': isChecked})
          .eq('id', id);
    } catch (e, stackTrace) {
      AppLogger.error('Checklist Toggle Hatası', e, stackTrace);
    }
  }

  /// Araç için varsayılan checklist oluştur
  Future<void> createDefaultChecklist(String vehicleId) async {
    AppLogger.supabaseOp('INSERT_DEFAULT', 'vehicle_checklists', {'vehicle_id': vehicleId});
    try {
      final items = ChecklistItemModel.defaultItems.map((name) => {
            'vehicle_id': vehicleId,
            'item_name': name,
            'is_checked': false,
          });

      await _client.from('vehicle_checklists').insert(items.toList());
      AppLogger.info('Varsayılan checklist oluşturuldu');
    } catch (e, stackTrace) {
      AppLogger.error('Default Checklist Hatası', e, stackTrace);
    }
  }
}
