import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/household_model.dart';
import '../models/user_model.dart';
import '../models/bill_model.dart';
import '../data/mock_data.dart';

class HouseholdProvider extends ChangeNotifier {
  HouseholdModel? _household;
  List<UserModel> _members = [];
  List<BillModel> _bills = [];
  bool _isLoading = false;
  final _uuid = const Uuid();

  HouseholdModel? get household => _household;
  List<UserModel> get members => _members;
  List<BillModel> get bills => _bills;
  bool get isLoading => _isLoading;
  bool get hasHousehold => _household != null;

  List<BillModel> get upcomingBills =>
      _bills.where((b) => !b.isPaid).toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  List<BillModel> get overdueBills =>
      _bills.where((b) => b.isOverdue).toList();

  double get totalMonthlyBills =>
      _bills.fold(0, (sum, b) => sum + b.amount);

  void loadHousehold() {
    _household = MockData.household;
    _members = MockData.members;
    _bills = MockData.bills;
    notifyListeners();
  }

  Future<HouseholdModel> createHousehold(String name, String address) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1000));

    final household = HouseholdModel(
      id: _uuid.v4(),
      name: name,
      address: address,
      joinCode: 'SQ-${_uuid.v4().substring(0, 4).toUpperCase()}',
      memberIds: [MockData.currentUser.id],
      adminId: MockData.currentUser.id,
      createdAt: DateTime.now(),
    );

    _household = household;
    _members = [MockData.currentUser];
    _bills = [];
    _isLoading = false;
    notifyListeners();
    return household;
  }

  Future<bool> joinHousehold(String code) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1000));

    // Mock: accept the demo code
    if (code.toUpperCase() == MockData.household.joinCode ||
        code.length >= 4) {
      loadHousehold();
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void markBillPaid(String billId) {
    final idx = _bills.indexWhere((b) => b.id == billId);
    if (idx != -1) {
      _bills[idx] = _bills[idx].copyWith(isPaid: true);
      notifyListeners();
    }
  }

  void addBill(BillModel bill) {
    _bills = [..._bills, bill];
    notifyListeners();
  }

  UserModel? memberById(String id) {
    try {
      return _members.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  List<String> get houseRules => MockData.houseRules;
}
