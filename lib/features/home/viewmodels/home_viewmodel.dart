import 'package:flutter/material.dart';
import '../../garage/viewmodels/garage_viewmodel.dart';
import '../../expenses/viewmodels/expenses_viewmodel.dart';
import '../../reminders/viewmodels/reminders_viewmodel.dart';

/// Dashboard ViewModel — ana sayfa verileri
class HomeViewModel extends ChangeNotifier {
  final GarageViewModel garageVM = GarageViewModel();
  final ExpensesViewModel expensesVM = ExpensesViewModel();
  final RemindersViewModel remindersVM = RemindersViewModel();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Tüm dashboard verilerini yükle
  Future<void> loadDashboard() async {
    _isLoading = true;
    notifyListeners();

    try {
      await garageVM.loadVehicles();

      final vehicleId = garageVM.selectedVehicle?.id;
      if (vehicleId != null) {
        await Future.wait([
          expensesVM.loadExpenses(vehicleId),
          remindersVM.loadReminders(vehicleId),
        ]);
      }
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  /// Araç değiştiğinde verileri yeniden yükle
  Future<void> onVehicleChanged(String vehicleId) async {
    await Future.wait([
      expensesVM.loadExpenses(vehicleId),
      remindersVM.loadReminders(vehicleId),
    ]);
    notifyListeners();
  }
}
