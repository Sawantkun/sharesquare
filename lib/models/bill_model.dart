enum BillCategory { rent, electricity, water, gas, internet, streaming, insurance, other }

extension BillCategoryExt on BillCategory {
  String get label {
    switch (this) {
      case BillCategory.rent: return 'Rent';
      case BillCategory.electricity: return 'Electricity';
      case BillCategory.water: return 'Water';
      case BillCategory.gas: return 'Gas';
      case BillCategory.internet: return 'Internet';
      case BillCategory.streaming: return 'Streaming';
      case BillCategory.insurance: return 'Insurance';
      case BillCategory.other: return 'Other';
    }
  }

  String get emoji {
    switch (this) {
      case BillCategory.rent: return '🏠';
      case BillCategory.electricity: return '⚡';
      case BillCategory.water: return '💧';
      case BillCategory.gas: return '🔥';
      case BillCategory.internet: return '📶';
      case BillCategory.streaming: return '📺';
      case BillCategory.insurance: return '🛡️';
      case BillCategory.other: return '📄';
    }
  }
}

class BillModel {
  final String id;
  final String title;
  final double amount;
  final DateTime dueDate;
  final bool isPaid;
  final BillCategory category;
  final String householdId;
  final bool isRecurring;
  final List<String>? splitAmongIds;

  const BillModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
    this.isPaid = false,
    required this.category,
    required this.householdId,
    this.isRecurring = false,
    this.splitAmongIds,
  });

  bool get isOverdue => !isPaid && dueDate.isBefore(DateTime.now());

  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;

  BillModel copyWith({
    String? id, String? title, double? amount, DateTime? dueDate,
    bool? isPaid, BillCategory? category, String? householdId,
    bool? isRecurring, List<String>? splitAmongIds,
  }) {
    return BillModel(
      id: id ?? this.id, title: title ?? this.title,
      amount: amount ?? this.amount, dueDate: dueDate ?? this.dueDate,
      isPaid: isPaid ?? this.isPaid, category: category ?? this.category,
      householdId: householdId ?? this.householdId,
      isRecurring: isRecurring ?? this.isRecurring,
      splitAmongIds: splitAmongIds ?? this.splitAmongIds,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'dueDate': dueDate.toIso8601String(),
    'isPaid': isPaid,
    'category': category.name,
    'householdId': householdId,
    'isRecurring': isRecurring,
    'splitAmongIds': splitAmongIds,
  };

  factory BillModel.fromJson(Map<String, dynamic> json) => BillModel(
    id: (json['id'] as String?) ?? '',
    title: (json['title'] as String?) ?? '',
    amount: (json['amount'] as num?)?.toDouble() ?? 0,
    dueDate: json['dueDate'] != null
        ? DateTime.tryParse(json['dueDate'] as String) ?? DateTime.now()
        : DateTime.now(),
    isPaid: json['isPaid'] as bool? ?? false,
    category: BillCategory.values.firstWhere(
      (c) => c.name == json['category'],
      orElse: () => BillCategory.other,
    ),
    householdId: (json['householdId'] as String?) ?? '',
    isRecurring: json['isRecurring'] as bool? ?? false,
    splitAmongIds: json['splitAmongIds'] != null
        ? List<String>.from(json['splitAmongIds'] as List)
        : null,
  );
}
