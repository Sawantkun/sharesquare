import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/household_model.dart';
import '../models/user_model.dart';
import '../models/bill_model.dart';

class HouseholdProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  HouseholdModel? _household;
  List<UserModel> _members = [];
  List<BillModel> _bills = [];
  bool _isLoading = false;
  String? _currentHouseholdId;

  HouseholdModel? get household => _household;
  List<UserModel> get members => _members;
  List<BillModel> get bills => _bills;
  bool get isLoading => _isLoading;
  bool get hasHousehold => _household != null;

  List<BillModel> get upcomingBills =>
      _bills.where((b) => !b.isPaid).toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  List<BillModel> get overdueBills => _bills.where((b) => b.isOverdue).toList();

  double get totalMonthlyBills => _bills.fold(0, (sum, b) => sum + b.amount);

  List<String> get houseRules => [];

  // Called by ProxyProvider when auth changes
  void syncFromAuth(String? householdId) {
    if (householdId == _currentHouseholdId) return;
    _currentHouseholdId = householdId;
    if (householdId != null && householdId.isNotEmpty) {
      _load(householdId);
    } else {
      clear();
    }
  }

  void clear() {
    _household = null;
    _members = [];
    _bills = [];
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _load(String householdId) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Load household doc
      final doc = await _db.collection('households').doc(householdId).get();
      if (!doc.exists) {
        _household = null;
        _isLoading = false;
        notifyListeners();
        return;
      }
      _household = HouseholdModel.fromJson(doc.data()!);

      // Load members
      if (_household!.memberIds.isNotEmpty) {
        final memberDocs = await Future.wait(
          _household!.memberIds.map((id) => _db.collection('users').doc(id).get()),
        );
        _members = memberDocs
            .where((d) => d.exists)
            .map((d) => UserModel.fromJson(d.data()!))
            .toList();
      }

      // Load bills
      final billsSnap = await _db
          .collection('households')
          .doc(householdId)
          .collection('bills')
          .get();
      _bills = billsSnap.docs.map((d) => BillModel.fromJson(d.data())).toList();
    } catch (e) {
      debugPrint('HouseholdProvider._load error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  // Legacy method called from screens
  void loadHousehold() {
    if (_currentHouseholdId != null) _load(_currentHouseholdId!);
  }

  Future<HouseholdModel> createHousehold(
      String name, String address, String userId) async {
    _isLoading = true;
    notifyListeners();

    final id = _uuid.v4();
    final joinCode = 'SQ-${_uuid.v4().substring(0, 4).toUpperCase()}';
    final household = HouseholdModel(
      id: id,
      name: name,
      address: address,
      joinCode: joinCode,
      memberIds: [userId],
      adminId: userId,
      createdAt: DateTime.now(),
    );

    await _db.collection('households').doc(id).set(household.toJson());
    // Update user's householdId
    await _db.collection('users').doc(userId).update({'householdId': id});

    _household = household;
    _currentHouseholdId = id;
    _isLoading = false;
    notifyListeners();
    return household;
  }

  Future<bool> joinHousehold(String code, String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snap = await _db
          .collection('households')
          .where('joinCode', isEqualTo: code.toUpperCase())
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final doc = snap.docs.first;
      final household = HouseholdModel.fromJson(doc.data());
      final updatedMemberIds = [...household.memberIds, userId];

      await _db.collection('households').doc(household.id).update({
        'memberIds': updatedMemberIds,
      });
      await _db.collection('users').doc(userId).update({
        'householdId': household.id,
      });

      _currentHouseholdId = household.id;
      await _load(household.id);
      return true;
    } catch (e) {
      debugPrint('joinHousehold error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> markBillPaid(String billId) async {
    final idx = _bills.indexWhere((b) => b.id == billId);
    if (idx == -1 || _currentHouseholdId == null) return;
    _bills[idx] = _bills[idx].copyWith(isPaid: true);
    notifyListeners();
    await _db
        .collection('households')
        .doc(_currentHouseholdId)
        .collection('bills')
        .doc(billId)
        .update({'isPaid': true});
  }

  Future<void> addBill(BillModel bill) async {
    if (_currentHouseholdId == null) return;
    final newBill = bill.copyWith(id: _uuid.v4());
    _bills = [..._bills, newBill];
    notifyListeners();
    await _db
        .collection('households')
        .doc(_currentHouseholdId)
        .collection('bills')
        .doc(newBill.id)
        .set(newBill.toJson());
  }

  UserModel? memberById(String id) {
    try {
      return _members.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }
}
