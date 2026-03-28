import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/chore_model.dart';

class ChoreProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  List<ChoreModel> _chores = [];
  bool _isLoading = false;
  String? _householdId;

  List<ChoreModel> get chores => _chores;
  bool get isLoading => _isLoading;

  List<ChoreModel> get pending =>
      _chores.where((c) => !c.isCompleted).toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  List<ChoreModel> get completed => _chores.where((c) => c.isCompleted).toList();
  List<ChoreModel> get overdue => _chores.where((c) => c.isOverdue).toList();
  List<ChoreModel> get dueToday =>
      _chores.where((c) => c.isDueToday && !c.isCompleted).toList();

  List<ChoreModel> choresForUser(String userId) =>
      _chores.where((c) => c.assignedToId == userId).toList();

  int completionRate() {
    if (_chores.isEmpty) return 0;
    return ((completed.length / _chores.length) * 100).round();
  }

  Map<String, int> completionByUser() {
    final Map<String, int> result = {};
    for (final chore in completed) {
      result[chore.assignedToId] = (result[chore.assignedToId] ?? 0) + 1;
    }
    return result;
  }

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
    _chores = [];
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
          .collection('chores')
          .get();
      _chores = snap.docs.map((d) => ChoreModel.fromJson(d.data())).toList();
    } catch (e) {
      debugPrint('ChoreProvider._load error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  // Legacy method
  void loadChores() {
    if (_householdId != null) _load(_householdId!);
  }

  Future<void> addChore(ChoreModel chore) async {
    if (_householdId == null) return;
    _isLoading = true;
    notifyListeners();

    final newChore = chore.copyWith(id: _uuid.v4(), createdAt: DateTime.now());
    _chores = [..._chores, newChore];
    _isLoading = false;
    notifyListeners();

    await _db
        .collection('households')
        .doc(_householdId)
        .collection('chores')
        .doc(newChore.id)
        .set(newChore.toJson());
  }

  Future<void> toggleChore(String choreId) async {
    final idx = _chores.indexWhere((c) => c.id == choreId);
    if (idx == -1 || _householdId == null) return;
    final updated = _chores[idx].copyWith(isCompleted: !_chores[idx].isCompleted);
    _chores[idx] = updated;
    notifyListeners();
    await _db
        .collection('households')
        .doc(_householdId)
        .collection('chores')
        .doc(choreId)
        .update({'isCompleted': updated.isCompleted});
  }

  Future<void> deleteChore(String choreId) async {
    _chores.removeWhere((c) => c.id == choreId);
    notifyListeners();
    if (_householdId == null) return;
    await _db
        .collection('households')
        .doc(_householdId)
        .collection('chores')
        .doc(choreId)
        .delete();
  }

  Future<void> reassignChore(String choreId, String newUserId) async {
    final idx = _chores.indexWhere((c) => c.id == choreId);
    if (idx == -1 || _householdId == null) return;
    _chores[idx] = _chores[idx].copyWith(assignedToId: newUserId);
    notifyListeners();
    await _db
        .collection('households')
        .doc(_householdId)
        .collection('chores')
        .doc(choreId)
        .update({'assignedToId': newUserId});
  }
}
