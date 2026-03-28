import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/expense_model.dart';
import '../data/mock_data.dart';

class ExpenseProvider extends ChangeNotifier {
  List<ExpenseModel> _expenses = [];
  bool _isLoading = false;
  ExpenseCategory? _filterCategory;
  final _uuid = const Uuid();

  List<ExpenseModel> get expenses => _filteredExpenses;
  List<ExpenseModel> get allExpenses => _expenses;
  bool get isLoading => _isLoading;
  ExpenseCategory? get filterCategory => _filterCategory;

  List<ExpenseModel> get _filteredExpenses {
    if (_filterCategory == null) return _expenses;
    return _expenses.where((e) => e.category == _filterCategory).toList();
  }

  List<ExpenseModel> get unsettled => _expenses.where((e) => !e.isSettled).toList();
  List<ExpenseModel> get settled => _expenses.where((e) => e.isSettled).toList();

  double get totalAmount => _expenses.fold(0, (sum, e) => sum + e.amount);

  void loadExpenses() {
    _expenses = List.from(MockData.expenses);
    _expenses.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  /// Returns balance for a user: positive = owed, negative = owes
  double balanceForUser(String userId) {
    double balance = 0;
    for (final expense in _expenses.where((e) => !e.isSettled)) {
      if (expense.paidById == userId) {
        // Paid for others → owed money
        balance += expense.amount - expense.perPersonAmount;
      } else if (expense.splitAmongIds.contains(userId)) {
        // In split but didn't pay → owes
        balance -= expense.perPersonAmount;
      }
    }
    return balance;
  }

  Map<String, double> balanceSummary(List<String> memberIds) {
    return {for (final id in memberIds) id: balanceForUser(id)};
  }

  /// Spending per category for current month
  Map<ExpenseCategory, double> spendingByCategory() {
    final Map<ExpenseCategory, double> result = {};
    for (final e in _expenses) {
      result[e.category] = (result[e.category] ?? 0) + e.amount;
    }
    return result;
  }

  /// Spending per user
  Map<String, double> spendingByUser() {
    final Map<String, double> result = {};
    for (final e in _expenses) {
      result[e.paidById] = (result[e.paidById] ?? 0) + e.amount;
    }
    return result;
  }

  /// Monthly totals (last 6 months)
  List<double> monthlyTotals() {
    final now = DateTime.now();
    return List.generate(6, (i) {
      final month = DateTime(now.year, now.month - i);
      return _expenses
          .where((e) => e.date.year == month.year && e.date.month == month.month)
          .fold(0.0, (sum, e) => sum + e.amount);
    }).reversed.toList();
  }

  Future<void> addExpense(ExpenseModel expense) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    final newExpense = expense.copyWith(id: _uuid.v4());
    _expenses = [newExpense, ..._expenses];
    _isLoading = false;
    notifyListeners();
  }

  void settleExpense(String expenseId) {
    final idx = _expenses.indexWhere((e) => e.id == expenseId);
    if (idx != -1) {
      _expenses[idx] = _expenses[idx].copyWith(isSettled: true);
      notifyListeners();
    }
  }

  void deleteExpense(String expenseId) {
    _expenses.removeWhere((e) => e.id == expenseId);
    notifyListeners();
  }

  void setFilter(ExpenseCategory? category) {
    _filterCategory = category;
    notifyListeners();
  }
}
