import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/mock_data.dart';
import '../../models/expense_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/household_provider.dart';
import '../../widgets/expenses/expense_card.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t         = Theme.of(context);
    final isDark    = t.brightness == Brightness.dark;
    final expenses  = context.watch<ExpenseProvider>();
    final auth      = context.watch<AuthProvider>();
    final household = context.watch<HouseholdProvider>();
    final uid       = auth.currentUser?.id ?? '';
    final balance   = expenses.balanceForUser(uid);
    final isOwed    = balance > 0;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            title: const Text('Expenses'),
            actions: [
              IconButton(
                icon: const Icon(Icons.bar_chart_rounded),
                onPressed: () => context.push('/analytics'),
              ),
              const SizedBox(width: 4),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Balance hero ──────────────────────────────────────────
                _BalanceCard(balance: balance, isOwed: isOwed, isDark: isDark),
                const SizedBox(height: 18),

                // ── Per-member settlement ─────────────────────────────────
                _SettlementRow(
                  expenses: expenses,
                  household: household,
                  currentUserId: uid,
                  isDark: isDark,
                ),
                const SizedBox(height: 20),

                // ── Category filter ───────────────────────────────────────
                _CategoryFilter(
                  selected: expenses.filterCategory,
                  onSelected: expenses.setFilter,
                ),
                const SizedBox(height: 16),

                // ── List ──────────────────────────────────────────────────
                if (expenses.expenses.isEmpty)
                  _EmptyState()
                else ...[
                  Row(
                    children: [
                      Text('${expenses.expenses.length} transactions', style: t.textTheme.labelMedium),
                      const Spacer(),
                      Text(
                        '\$${expenses.totalAmount.toStringAsFixed(2)} total',
                        style: t.textTheme.labelMedium?.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...expenses.expenses.asMap().entries.map((e) {
                    final exp    = e.value;
                    final paidBy = household.memberById(exp.paidById) ?? MockData.userById(exp.paidById);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ExpenseCard(
                        expense: exp,
                        paidBy: paidBy,
                        currentUserId: uid,
                        onSettle: () => expenses.settleExpense(exp.id),
                      )
                          .animate()
                          .fadeIn(delay: (e.key * 40).ms, duration: 350.ms)
                          .slideX(begin: 0.04, end: 0),
                    );
                  }),
                ],
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-expense'),
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text('Add Expense', style: TextStyle(fontWeight: FontWeight.w600)),
      ).animate().scale(delay: 250.ms, duration: 400.ms, curve: Curves.elasticOut),
    );
  }
}

// ── Balance hero card ─────────────────────────────────────────────────────────
class _BalanceCard extends StatelessWidget {
  final double balance;
  final bool isOwed;
  final bool isDark;
  const _BalanceCard({required this.balance, required this.isOwed, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final grad = isOwed ? AppColors.teal : AppColors.coral;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: grad,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: (isOwed ? AppColors.secondary : AppColors.accent).withValues(alpha: 0.35),
            blurRadius: 22,
            offset: const Offset(0, 8),
            spreadRadius: -3,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOwed ? 'You are owed' : 'You owe',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${balance.abs().toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isOwed ? 'across housemates' : 'to your housemates',
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isOwed ? Icons.trending_up_rounded : Icons.trending_down_rounded,
              color: Colors.white, size: 26,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 450.ms)
        .slideY(begin: 0.08, end: 0);
  }
}

// ── Per-member settlement ─────────────────────────────────────────────────────
class _SettlementRow extends StatelessWidget {
  final ExpenseProvider expenses;
  final HouseholdProvider household;
  final String currentUserId;
  final bool isDark;

  const _SettlementRow({
    required this.expenses,
    required this.household,
    required this.currentUserId,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final t       = Theme.of(context);
    final balances = expenses.balanceSummary(household.members.map((m) => m.id).toList());
    final others   = household.members.where((m) => m.id != currentUserId).toList();

    if (others.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Settlement', style: t.textTheme.titleLarge),
        const SizedBox(height: 10),
        Row(
          children: others.map((member) {
            final b     = balances[member.id] ?? 0;
            final owes  = b < 0; // they owe you
            final amt   = b.abs();
            final color = amt < 0.01 ? AppColors.success : (owes ? AppColors.secondary : AppColors.accent);

            return Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: color.withValues(alpha: isDark ? 0.3 : 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: member.color.withValues(alpha: 0.14),
                      child: Text(
                        member.initials,
                        style: TextStyle(color: member.color, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      member.name.split(' ').first,
                      style: t.textTheme.labelSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      amt < 0.01 ? 'Even' : '\$${amt.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    if (amt >= 0.01)
                      Text(
                        owes ? 'owes you' : 'you owe',
                        style: TextStyle(fontSize: 10, color: isDark ? AppColors.t3Dark : AppColors.t3Light),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── Category filter ───────────────────────────────────────────────────────────
class _CategoryFilter extends StatelessWidget {
  final ExpenseCategory? selected;
  final void Function(ExpenseCategory?) onSelected;
  const _CategoryFilter({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _Chip(label: 'All', emoji: '🌐', active: selected == null, onTap: () => onSelected(null)),
          ...ExpenseCategory.values.map((c) =>
            _Chip(
              label: c.label,
              emoji: c.emoji,
              active: selected == c,
              onTap: () => onSelected(selected == c ? null : c),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final String emoji;
  final bool active;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.emoji, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 200.ms,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
        decoration: BoxDecoration(
          gradient: active ? AppColors.brand : null,
          color: active ? null : (isDark ? AppColors.cardDark : AppColors.cardLight),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? Colors.transparent : (isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          boxShadow: active
              ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : null,
                fontSize: 12,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            const Text('💸', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 14),
            Text('No expenses yet', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('Add your first shared expense', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
