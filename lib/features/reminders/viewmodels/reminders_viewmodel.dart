import 'package:flutter/material.dart';
import '../models/reminder_model.dart';
import '../services/reminder_repository.dart';

/// Hatırlatma ViewModel
class RemindersViewModel extends ChangeNotifier {
  final ReminderRepository _repo = ReminderRepository();

  List<ReminderModel> _reminders = [];
  bool _isLoading = false;
  String? _error;

  List<ReminderModel> get reminders => _reminders;
  List<ReminderModel> get activeReminders =>
      _reminders.where((r) => !r.isCompleted).toList();
  List<ReminderModel> get overdueReminders =>
      _reminders.where((r) => r.status == 'overdue').toList();
  List<ReminderModel> get soonReminders =>
      _reminders.where((r) => r.status == 'soon').toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadReminders(String vehicleId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _reminders = await _repo.getReminders(vehicleId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Hatırlatmalar yüklenirken hata oluştu';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addReminder(ReminderModel reminder) async {
    try {
      final newReminder = await _repo.addReminder(reminder);
      _reminders.insert(0, newReminder);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Hatırlatma eklenirken hata oluştu';
      notifyListeners();
      return false;
    }
  }

  Future<void> completeReminder(String id) async {
    try {
      await _repo.completeReminder(id);
      final index = _reminders.indexWhere((r) => r.id == id);
      if (index != -1) {
        _reminders[index] = ReminderModel(
          id: _reminders[index].id,
          vehicleId: _reminders[index].vehicleId,
          type: _reminders[index].type,
          title: _reminders[index].title,
          targetDate: _reminders[index].targetDate,
          targetKm: _reminders[index].targetKm,
          isCompleted: true,
          createdAt: _reminders[index].createdAt,
        );
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> deleteReminder(String id) async {
    try {
      await _repo.deleteReminder(id);
      _reminders.removeWhere((r) => r.id == id);
      notifyListeners();
    } catch (_) {}
  }
}
