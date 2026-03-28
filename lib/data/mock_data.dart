import '../models/user_model.dart';
import '../models/household_model.dart';
import '../models/expense_model.dart';
import '../models/chore_model.dart';
import '../models/message_model.dart';
import '../models/bill_model.dart';
import '../core/theme/app_colors.dart';

class MockData {
  // Users
  static final UserModel currentUser = UserModel(
    id: 'user_1',
    name: 'Alex Morgan',
    email: 'alex@sharesquare.app',
    color: AppColors.avatarColors[0],
    householdId: 'household_1',
    createdAt: DateTime(2024, 1, 15),
  );

  static final List<UserModel> members = [
    currentUser,
    UserModel(
      id: 'user_2',
      name: 'Jamie Chen',
      email: 'jamie@example.com',
      color: AppColors.avatarColors[1],
      householdId: 'household_1',
      createdAt: DateTime(2024, 1, 16),
    ),
    UserModel(
      id: 'user_3',
      name: 'Sam Rivera',
      email: 'sam@example.com',
      color: AppColors.avatarColors[2],
      householdId: 'household_1',
      createdAt: DateTime(2024, 1, 18),
    ),
    UserModel(
      id: 'user_4',
      name: 'Taylor Kim',
      email: 'taylor@example.com',
      color: AppColors.avatarColors[3],
      householdId: 'household_1',
      createdAt: DateTime(2024, 2, 1),
    ),
  ];

  // Household
  static final HouseholdModel household = HouseholdModel(
    id: 'household_1',
    name: 'The Sunset Loft',
    address: '42 Sunset Blvd, Apt 3B, San Francisco, CA',
    joinCode: 'SQ-4X9K',
    memberIds: ['user_1', 'user_2', 'user_3', 'user_4'],
    adminId: 'user_1',
    createdAt: DateTime(2024, 1, 15),
  );

  // Expenses
  static List<ExpenseModel> expenses = [
    ExpenseModel(
      id: 'exp_1',
      title: 'Monthly Rent',
      amount: 3200,
      paidById: 'user_1',
      splitAmongIds: ['user_1', 'user_2', 'user_3', 'user_4'],
      date: DateTime(2026, 3, 1),
      category: ExpenseCategory.rent,
      householdId: 'household_1',
      note: 'March rent',
    ),
    ExpenseModel(
      id: 'exp_2',
      title: 'Whole Foods Run',
      amount: 187.50,
      paidById: 'user_2',
      splitAmongIds: ['user_1', 'user_2', 'user_3', 'user_4'],
      date: DateTime(2026, 3, 20),
      category: ExpenseCategory.groceries,
      householdId: 'household_1',
    ),
    ExpenseModel(
      id: 'exp_3',
      title: 'Electricity Bill',
      amount: 142.30,
      paidById: 'user_3',
      splitAmongIds: ['user_1', 'user_2', 'user_3', 'user_4'],
      date: DateTime(2026, 3, 15),
      category: ExpenseCategory.utilities,
      householdId: 'household_1',
    ),
    ExpenseModel(
      id: 'exp_4',
      title: 'Netflix + Spotify',
      amount: 35.98,
      paidById: 'user_1',
      splitAmongIds: ['user_1', 'user_2', 'user_3', 'user_4'],
      date: DateTime(2026, 3, 10),
      category: ExpenseCategory.entertainment,
      householdId: 'household_1',
    ),
    ExpenseModel(
      id: 'exp_5',
      title: 'Pizza Night',
      amount: 68.40,
      paidById: 'user_4',
      splitAmongIds: ['user_1', 'user_2', 'user_3', 'user_4'],
      date: DateTime(2026, 3, 22),
      category: ExpenseCategory.food,
      householdId: 'household_1',
    ),
    ExpenseModel(
      id: 'exp_6',
      title: 'Internet Bill',
      amount: 79.99,
      paidById: 'user_2',
      splitAmongIds: ['user_1', 'user_2', 'user_3', 'user_4'],
      date: DateTime(2026, 3, 8),
      category: ExpenseCategory.internet,
      householdId: 'household_1',
      isSettled: true,
    ),
    ExpenseModel(
      id: 'exp_7',
      title: 'Kitchen Supplies',
      amount: 54.20,
      paidById: 'user_3',
      splitAmongIds: ['user_1', 'user_2', 'user_3'],
      date: DateTime(2026, 3, 18),
      category: ExpenseCategory.other,
      householdId: 'household_1',
    ),
    ExpenseModel(
      id: 'exp_8',
      title: 'Uber Pool (Airport)',
      amount: 42.00,
      paidById: 'user_1',
      splitAmongIds: ['user_1', 'user_2'],
      date: DateTime(2026, 3, 12),
      category: ExpenseCategory.transport,
      householdId: 'household_1',
    ),
  ];

  // Chores
  static List<ChoreModel> chores = [
    ChoreModel(
      id: 'chore_1',
      title: 'Vacuum Living Room',
      description: 'Including under the sofa',
      assignedToId: 'user_1',
      dueDate: DateTime(2026, 3, 28),
      frequency: ChoreFrequency.weekly,
      emoji: '🧹',
      householdId: 'household_1',
      createdAt: DateTime(2026, 3, 1),
    ),
    ChoreModel(
      id: 'chore_2',
      title: 'Take Out Trash',
      description: 'All bins — kitchen, bathroom, bedroom',
      assignedToId: 'user_2',
      dueDate: DateTime(2026, 3, 27),
      frequency: ChoreFrequency.weekly,
      emoji: '🗑️',
      householdId: 'household_1',
      createdAt: DateTime(2026, 3, 1),
    ),
    ChoreModel(
      id: 'chore_3',
      title: 'Clean Bathroom',
      assignedToId: 'user_3',
      dueDate: DateTime(2026, 3, 29),
      frequency: ChoreFrequency.weekly,
      emoji: '🚿',
      householdId: 'household_1',
      createdAt: DateTime(2026, 3, 1),
    ),
    ChoreModel(
      id: 'chore_4',
      title: 'Do Dishes',
      assignedToId: 'user_4',
      dueDate: DateTime(2026, 3, 27),
      isCompleted: true,
      frequency: ChoreFrequency.daily,
      emoji: '🍽️',
      householdId: 'household_1',
      createdAt: DateTime(2026, 3, 26),
    ),
    ChoreModel(
      id: 'chore_5',
      title: 'Mop Kitchen Floor',
      assignedToId: 'user_1',
      dueDate: DateTime(2026, 3, 26),
      isCompleted: true,
      frequency: ChoreFrequency.weekly,
      emoji: '🧺',
      householdId: 'household_1',
      createdAt: DateTime(2026, 3, 20),
    ),
    ChoreModel(
      id: 'chore_6',
      title: 'Wipe Counters',
      description: 'Kitchen counters and stovetop',
      assignedToId: 'user_2',
      dueDate: DateTime(2026, 3, 28),
      frequency: ChoreFrequency.daily,
      emoji: '🧽',
      householdId: 'household_1',
      createdAt: DateTime(2026, 3, 1),
    ),
    ChoreModel(
      id: 'chore_7',
      title: 'Water Plants',
      assignedToId: 'user_3',
      dueDate: DateTime(2026, 4, 3),
      frequency: ChoreFrequency.biweekly,
      emoji: '🌿',
      householdId: 'household_1',
      createdAt: DateTime(2026, 3, 1),
    ),
    ChoreModel(
      id: 'chore_8',
      title: 'Pay Rent Online',
      description: 'Transfer via bank portal',
      assignedToId: 'user_1',
      dueDate: DateTime(2026, 4, 1),
      frequency: ChoreFrequency.monthly,
      emoji: '💳',
      householdId: 'household_1',
      createdAt: DateTime(2026, 3, 1),
    ),
  ];

  // Bills
  static List<BillModel> bills = [
    BillModel(
      id: 'bill_1',
      title: 'April Rent',
      amount: 3200,
      dueDate: DateTime(2026, 4, 1),
      category: BillCategory.rent,
      householdId: 'household_1',
      isRecurring: true,
    ),
    BillModel(
      id: 'bill_2',
      title: 'Electricity',
      amount: 142.30,
      dueDate: DateTime(2026, 4, 5),
      category: BillCategory.electricity,
      householdId: 'household_1',
      isRecurring: true,
    ),
    BillModel(
      id: 'bill_3',
      title: 'Internet',
      amount: 79.99,
      dueDate: DateTime(2026, 3, 28),
      category: BillCategory.internet,
      householdId: 'household_1',
      isRecurring: true,
    ),
    BillModel(
      id: 'bill_4',
      title: 'Water & Sewage',
      amount: 55.00,
      dueDate: DateTime(2026, 4, 10),
      category: BillCategory.water,
      householdId: 'household_1',
      isRecurring: true,
    ),
    BillModel(
      id: 'bill_5',
      title: 'Renter\'s Insurance',
      amount: 28.50,
      dueDate: DateTime(2026, 3, 15),
      isPaid: true,
      category: BillCategory.insurance,
      householdId: 'household_1',
      isRecurring: true,
    ),
  ];

  // Messages
  static List<MessageModel> messages = [
    MessageModel(
      id: 'msg_1',
      senderId: 'user_2',
      householdId: 'household_1',
      content: 'Hey everyone! Rent is due April 1st. Who\'s collecting this month? 🏠',
      timestamp: DateTime(2026, 3, 27, 9, 15),
    ),
    MessageModel(
      id: 'msg_2',
      senderId: 'user_1',
      householdId: 'household_1',
      content: 'I\'ll handle it! Going to pay online and split through the app',
      timestamp: DateTime(2026, 3, 27, 9, 32),
    ),
    MessageModel(
      id: 'msg_3',
      senderId: 'user_3',
      householdId: 'household_1',
      content: '👍 Sounds good Alex! I already Venmo\'d you my share',
      timestamp: DateTime(2026, 3, 27, 9, 45),
    ),
    MessageModel(
      id: 'msg_4',
      senderId: 'user_4',
      householdId: 'household_1',
      content: 'Order pizza tonight?',
      timestamp: DateTime(2026, 3, 27, 10, 0),
      type: MessageType.poll,
      pollQuestion: '🍕 Pizza night tonight?',
      pollOptions: [
        PollOption(id: 'opt_1', text: 'Yes! 🎉', voterIds: ['user_1', 'user_3']),
        PollOption(id: 'opt_2', text: 'No, I\'m out', voterIds: ['user_2']),
        PollOption(id: 'opt_3', text: 'Maybe later', voterIds: []),
      ],
    ),
    MessageModel(
      id: 'msg_5',
      senderId: 'user_1',
      householdId: 'household_1',
      content: 'Also reminder: bathroom needs cleaning by end of week 🚿',
      timestamp: DateTime(2026, 3, 27, 11, 20),
    ),
    MessageModel(
      id: 'msg_6',
      senderId: 'user_2',
      householdId: 'household_1',
      content: 'On it Sam! I\'ll get it done tomorrow morning',
      timestamp: DateTime(2026, 3, 27, 11, 35),
    ),
    MessageModel(
      id: 'msg_7',
      senderId: 'user_3',
      householdId: 'household_1',
      content: 'BTW I added the electricity bill to expenses — we\'re at \$142 this month 💡',
      timestamp: DateTime(2026, 3, 27, 14, 10),
    ),
    MessageModel(
      id: 'msg_8',
      senderId: 'user_4',
      householdId: 'household_1',
      content: 'Good call! Also going grocery shopping tomorrow, anything you guys need?',
      timestamp: DateTime(2026, 3, 27, 16, 45),
    ),
  ];

  // House rules
  static const List<String> houseRules = [
    'Quiet hours after 10pm on weekdays',
    'Clean up after yourself in the kitchen',
    'No overnight guests without a heads-up',
    'Common areas cleaned by Sunday evening',
    'Groceries split equally each month',
    'Bills paid by the 5th of each month',
  ];

  // Analytics helper — spending per user this month
  static Map<String, double> spendingByUser() {
    final Map<String, double> result = {};
    for (final member in members) {
      result[member.id] = 0;
    }
    for (final expense in expenses) {
      result[expense.paidById] = (result[expense.paidById] ?? 0) + expense.amount;
    }
    return result;
  }

  static double totalMonthlyExpenses() =>
      expenses.fold(0, (sum, e) => sum + e.amount);

  static UserModel userById(String id) =>
      members.firstWhere((m) => m.id == id, orElse: () => currentUser);
}
