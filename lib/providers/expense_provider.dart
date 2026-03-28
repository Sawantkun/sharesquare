import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/expense_model.dart';

class ExpenseProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  List<ExpenseModel> _expenses = [];
  bool _isLoading = false;
  ExpenseCategory? _filterCategory;
  String? _householdId;

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

  void syncFromAuth(String? householdId) {
    if (householdId == _householdId) return;
    _householdId = householdId;
    if (householdId != null && householdId.isNotEmpty) {
      _load(householdId);
    } else {
      clear();
    }
  }

  void clear() {
    _expenses = [];
    _isLoading = false;
    _householdId = null;
    notifyListeners();
  }

  Future<void> _load(String householdId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final snap = await _db
          .collection('households')
          .doc(householdId)
          .collection('expenses')
          .orderBy('date', descending: true)
          .get();
      _expenses = snap.docs.map((d) => ExpenseModel.fromJson(d.data())).toList();
    } catch (e) {
      debugPrint('ExpenseProvider._load error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  // Legacy method
  void loadExpenses() {
    if (_householdId != null) _load(_householdId!);
  }

  double balanceForUser(String userId) {
    double balance = 0;
    for (final expense in _expenses.where((e) => !e.isSettled)) {
      if (expense.paidById == userId) {
        balance += expense.amount - expense.perPersonAmount;
      } else if (expense.splitAmongIds.contains(userId)) {
        balance -= expense.perPersonAmount;
      }
    }
    return balance;
  }

  Map<String, double> balanceSummary(List<String> memberIds) {
    return {for (final id in memberIds) id: balanceForUser(id)};
  }

  Map<ExpenseCategory, double> spendingByCategory() {
    final Map<ExpenseCategory, double> result = {};
    for (final e in _expenses) {
      result[e.category] = (result[e.category] ?? 0) + e.amount;
    }
    return result;
  }

  Map<String, double> spendingByUser() {
    final Map<String, double> result = {};
    for (final e in _expenses) {
      result[e.paidById] = (result[e.paidById] ?? 0) + e.amount;
    }
    return result;
  }

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
    if (_householdId == null) return;
    _isLoading = true;
    notifyListeners();

    final newExpense = expense.copyWith(id: _uuid.v4());
    _expenses = [newExpense, ..._expenses];
    _isLoading = false;
    notifyListeners();

    await _db
        .collection('households')
        .doc(_householdId)
        .collection('expenses')
        .doc(newExpense.id)
        .set(newExpense.toJson());
  }

  Future<void> settleExpense(String expenseId) async {
    final idx = _expenses.indexWhere((e) => e.id == expenseId);
    if (idx == -1 || _householdId == null) return;
    _expenses[idx] = _expenses[idx].copyWith(isSettled: true);
    notifyListeners();
    await _db
        .collection('households')
        .doc(_householdId)
        .collection('expenses')
        .doc(expenseId)
        .update({'isSettled': true});
  }

  Future<void> deleteExpense(String expenseId) async {
    _expenses.removeWhere((e) => e.id == expenseId);
    notifyListeners();
    if (_householdId == null) return;
    await _db
        .collection('households')
        .doc(_householdId)
        .collection('expenses')
        .doc(expenseId)
        .delete();
  }

  void setFilter(ExpenseCategory? category) {
    _filterCategory = category;
    notifyListeners();
  }
}
