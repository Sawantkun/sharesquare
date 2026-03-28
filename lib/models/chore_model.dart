enum ChoreFrequency { once, daily, weekly, biweekly, monthly }

extension ChoreFrequencyExt on ChoreFrequency {
  String get label {
    switch (this) {
      case ChoreFrequency.once: return 'Once';
      case ChoreFrequency.daily: return 'Daily';
      case ChoreFrequency.weekly: return 'Weekly';
      case ChoreFrequency.biweekly: return 'Bi-weekly';
      case ChoreFrequency.monthly: return 'Monthly';
    }
  }
}

class ChoreModel {
  final String id;
  final String title;
  final String description;
  final String assignedToId;
  final DateTime dueDate;
  final bool isCompleted;
  final ChoreFrequency frequency;
  final String? emoji;
  final String householdId;
  final DateTime createdAt;

  const ChoreModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.assignedToId,
    required this.dueDate,
    this.isCompleted = false,
    this.frequency = ChoreFrequency.once,
    this.emoji,
    required this.householdId,
    required this.createdAt,
  });

  bool get isOverdue => !isCompleted && dueDate.isBefore(DateTime.now());

  bool get isDueToday {
    final now = DateTime.now();
    return dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day;
  }

  ChoreModel copyWith({
    String? id, String? title, String? description, String? assignedToId,
    DateTime? dueDate, bool? isCompleted, ChoreFrequency? frequency,
    String? emoji, String? householdId, DateTime? createdAt,
  }) {
    return ChoreModel(
      id: id ?? this.id, title: title ?? this.title,
      description: description ?? this.description,
      assignedToId: assignedToId ?? this.assignedToId,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      frequency: frequency ?? this.frequency,
      emoji: emoji ?? this.emoji,
      householdId: householdId ?? this.householdId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'assignedToId': assignedToId,
    'dueDate': dueDate.toIso8601String(),
    'isCompleted': isCompleted,
    'frequency': frequency.name,
    'emoji': emoji,
    'householdId': householdId,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ChoreModel.fromJson(Map<String, dynamic> json) => ChoreModel(
    id: (json['id'] as String?) ?? '',
    title: (json['title'] as String?) ?? '',
    description: (json['description'] as String?) ?? '',
    assignedToId: (json['assignedToId'] as String?) ?? '',
    dueDate: json['dueDate'] != null
        ? DateTime.tryParse(json['dueDate'] as String) ?? DateTime.now()
        : DateTime.now(),
    isCompleted: json['isCompleted'] as bool? ?? false,
    frequency: ChoreFrequency.values.firstWhere(
      (f) => f.name == json['frequency'],
      orElse: () => ChoreFrequency.once,
    ),
    emoji: json['emoji'] as String?,
    householdId: (json['householdId'] as String?) ?? '',
    createdAt: json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
        : DateTime.now(),
  );
}
