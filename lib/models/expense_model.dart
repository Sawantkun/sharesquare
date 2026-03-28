enum ExpenseCategory {
  rent, groceries, utilities, internet, food, entertainment, transport, health, other
}

extension ExpenseCategoryExt on ExpenseCategory {
  String get label {
    switch (this) {
      case ExpenseCategory.rent: return 'Rent';
      case ExpenseCategory.groceries: return 'Groceries';
      case ExpenseCategory.utilities: return 'Utilities';
      case ExpenseCategory.internet: return 'Internet';
      case ExpenseCategory.food: return 'Food';
      case ExpenseCategory.entertainment: return 'Entertainment';
      case ExpenseCategory.transport: return 'Transport';
      case ExpenseCategory.health: return 'Health';
      case ExpenseCategory.other: return 'Other';
    }
  }

  String get emoji {
    switch (this) {
      case ExpenseCategory.rent: return '🏠';
      case ExpenseCategory.groceries: return '🛒';
      case ExpenseCategory.utilities: return '💡';
      case ExpenseCategory.internet: return '📶';
      case ExpenseCategory.food: return '🍕';
      case ExpenseCategory.entertainment: return '🎬';
      case ExpenseCategory.transport: return '🚗';
      case ExpenseCategory.health: return '💊';
      case ExpenseCategory.other: return '💰';
    }
  }
}

class ExpenseModel {
  final String id;
  final String title;
  final double amount;
  final String paidById;
  final List<String> splitAmongIds;
  final DateTime date;
  final ExpenseCategory category;
  final bool isSettled;
  final String? note;
  final String householdId;

  const ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.paidById,
    required this.splitAmongIds,
    required this.date,
    required this.category,
    this.isSettled = false,
    this.note,
    required this.householdId,
  });

  double get perPersonAmount =>
      splitAmongIds.isEmpty ? amount : amount / splitAmongIds.length;

  /// Returns what userId owes (positive) or is owed (negative)
  double amountForUser(String userId) {
    if (paidById == userId) {
      return -(amount - perPersonAmount); // paid, so others owe them
    } else if (splitAmongIds.contains(userId)) {
      return perPersonAmount;
    }
    return 0;
  }

  ExpenseModel copyWith({
    String? id, String? title, double? amount, String? paidById,
    List<String>? splitAmongIds, DateTime? date, ExpenseCategory? category,
    bool? isSettled, String? note, String? householdId,
  }) {
    return ExpenseModel(
      id: id ?? this.id, title: title ?? this.title,
      amount: amount ?? this.amount, paidById: paidById ?? this.paidById,
      splitAmongIds: splitAmongIds ?? this.splitAmongIds,
      date: date ?? this.date, category: category ?? this.category,
      isSettled: isSettled ?? this.isSettled, note: note ?? this.note,
      householdId: householdId ?? this.householdId,
    );
  }
}
