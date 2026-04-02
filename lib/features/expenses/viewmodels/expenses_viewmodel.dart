import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../services/expense_repository.dart';

/// Gider ViewModel
class ExpensesViewModel extends ChangeNotifier {
  final ExpenseRepository _repo = ExpenseRepository();

  List<ExpenseModel> _expenses = [];
  Map<String, double> _categoryTotals = {};
  double _monthlyTotal = 0;
  bool _isLoading = false;
  String? _error;

  List<ExpenseModel> get expenses => _expenses;
  Map<String, double> get categoryTotals => _categoryTotals;
  double get monthlyTotal => _monthlyTotal;
  double get totalExpenses =>
      _expenses.fold(0, (sum, e) => sum + e.amount);
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Giderleri yükle
  Future<void> loadExpenses(String vehicleId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _expenses = await _repo.getExpenses(vehicleId);
      _categoryTotals = await _repo.getCategoryTotals(vehicleId);

      final now = DateTime.now();
      _monthlyTotal =
          await _repo.getMonthlyTotal(vehicleId, now.year, now.month);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Giderler yüklenirken hata oluştu';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Gider ekle
  Future<bool> addExpense(ExpenseModel expense) async {
    try {
      final newExpense = await _repo.addExpense(expense);
      _expenses.insert(0, newExpense);
      _monthlyTotal += expense.amount;
      _categoryTotals[expense.category] =
          (_categoryTotals[expense.category] ?? 0) + expense.amount;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gider eklenirken hata oluştu';
      notifyListeners();
      return false;
    }
  }

  /// Gider sil
  Future<bool> deleteExpense(ExpenseModel expense) async {
    try {
      await _repo.deleteExpense(expense.id);
      _expenses.removeWhere((e) => e.id == expense.id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gider silinirken hata oluştu';
      notifyListeners();
      return false;
    }
  }
}
