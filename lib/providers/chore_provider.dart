import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/chore_model.dart';
import '../data/mock_data.dart';

class ChoreProvider extends ChangeNotifier {
  List<ChoreModel> _chores = [];
  bool _isLoading = false;
  final _uuid = const Uuid();

  List<ChoreModel> get chores => _chores;
  bool get isLoading => _isLoading;

  List<ChoreModel> get pending =>
      _chores.where((c) => !c.isCompleted).toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  List<ChoreModel> get completed =>
      _chores.where((c) => c.isCompleted).toList();

  List<ChoreModel> get overdue =>
      _chores.where((c) => c.isOverdue).toList();

  List<ChoreModel> get dueToday =>
      _chores.where((c) => c.isDueToday && !c.isCompleted).toList();

  List<ChoreModel> choresForUser(String userId) =>
      _chores.where((c) => c.assignedToId == userId).toList();

  int completionRate() {
    if (_chores.isEmpty) return 0;
    return ((completed.length / _chores.length) * 100).round();
  }

  /// Chores completed per member
  Map<String, int> completionByUser() {
    final Map<String, int> result = {};
    for (final chore in completed) {
      result[chore.assignedToId] = (result[chore.assignedToId] ?? 0) + 1;
    }
    return result;
  }

  void loadChores() {
    _chores = List.from(MockData.chores);
    notifyListeners();
  }

  Future<void> addChore(ChoreModel chore) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    final newChore = chore.copyWith(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
    );
    _chores = [..._chores, newChore];
    _isLoading = false;
    notifyListeners();
  }

  void toggleChore(String choreId) {
    final idx = _chores.indexWhere((c) => c.id == choreId);
    if (idx != -1) {
      _chores[idx] = _chores[idx].copyWith(
        isCompleted: !_chores[idx].isCompleted,
      );
      notifyListeners();
    }
  }

  void deleteChore(String choreId) {
    _chores.removeWhere((c) => c.id == choreId);
    notifyListeners();
  }

  void reassignChore(String choreId, String newUserId) {
    final idx = _chores.indexWhere((c) => c.id == choreId);
    if (idx != -1) {
      _chores[idx] = _chores[idx].copyWith(assignedToId: newUserId);
      notifyListeners();
    }
  }
}
