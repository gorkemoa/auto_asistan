import 'package:flutter/material.dart';
import '../models/vehicle_model.dart';
import '../services/vehicle_repository.dart';
import '../../../core/services/storage_service.dart';

/// Garaj ViewModel
class GarageViewModel extends ChangeNotifier {
  final VehicleRepository _repo = VehicleRepository();

  List<VehicleModel> _vehicles = [];
  VehicleModel? _selectedVehicle;
  List<ChecklistItemModel> _checklistItems = [];
  bool _isLoading = false;
  String? _error;

  List<VehicleModel> get vehicles => _vehicles;
  VehicleModel? get selectedVehicle => _selectedVehicle;
  List<ChecklistItemModel> get checklistItems => _checklistItems;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasVehicles => _vehicles.isNotEmpty;

  /// Araçları yükle
  Future<void> loadVehicles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _vehicles = await _repo.getVehicles();

      // Aktif aracı seç
      final activeId = StorageService.activeVehicleId;
      if (activeId != null) {
        _selectedVehicle = _vehicles.where((v) => v.id == activeId).firstOrNull;
      }
      _selectedVehicle ??= _vehicles.firstOrNull;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Araçlar yüklenirken hata oluştu';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Araç seç
  void selectVehicle(VehicleModel vehicle) {
    _selectedVehicle = vehicle;
    StorageService.setActiveVehicleId(vehicle.id);
    notifyListeners();
  }

  /// Araç ekle
  Future<bool> addVehicle(VehicleModel vehicle) async {
    try {
      final newVehicle = await _repo.addVehicle(vehicle);
      await _repo.createDefaultChecklist(newVehicle.id);
      _vehicles.insert(0, newVehicle);
      _selectedVehicle = newVehicle;
      StorageService.setActiveVehicleId(newVehicle.id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Araç eklenirken hata oluştu';
      notifyListeners();
      return false;
    }
  }

  /// Araç güncelle
  Future<bool> updateVehicle(VehicleModel vehicle) async {
    try {
      await _repo.updateVehicle(vehicle);
      final index = _vehicles.indexWhere((v) => v.id == vehicle.id);
      if (index != -1) _vehicles[index] = vehicle;
      if (_selectedVehicle?.id == vehicle.id) _selectedVehicle = vehicle;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Araç güncellenirken hata oluştu';
      notifyListeners();
      return false;
    }
  }

  /// Araç sil
  Future<bool> deleteVehicle(String id) async {
    try {
      await _repo.deleteVehicle(id);
      _vehicles.removeWhere((v) => v.id == id);
      if (_selectedVehicle?.id == id) {
        _selectedVehicle = _vehicles.firstOrNull;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Araç silinirken hata oluştu';
      notifyListeners();
      return false;
    }
  }

  /// Checklist yükle
  Future<void> loadChecklist(String vehicleId) async {
    try {
      _checklistItems = await _repo.getChecklist(vehicleId);
      notifyListeners();
    } catch (_) {}
  }

  /// Checklist toggle
  Future<void> toggleChecklist(String itemId, bool isChecked) async {
    try {
      await _repo.toggleChecklistItem(itemId, isChecked);
      final index = _checklistItems.indexWhere((i) => i.id == itemId);
      if (index != -1) {
        _checklistItems[index] = ChecklistItemModel(
          id: _checklistItems[index].id,
          vehicleId: _checklistItems[index].vehicleId,
          itemName: _checklistItems[index].itemName,
          isChecked: isChecked,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (_) {}
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
