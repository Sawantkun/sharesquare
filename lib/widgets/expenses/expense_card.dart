import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/expense_model.dart';
import '../../models/user_model.dart';
import '../../core/theme/app_colors.dart';
import '../common/app_card.dart';

class ExpenseCard extends StatelessWidget {
  final ExpenseModel expense;
  final UserModel paidBy;
  final String currentUserId;
  final VoidCallback? onTap;
  final VoidCallback? onSettle;

  const ExpenseCard({
    super.key,
    required this.expense,
    required this.paidBy,
    required this.currentUserId,
    this.onTap,
    this.onSettle,
  });

  @override
  Widget build(BuildContext context) {
    final t      = Theme.of(context);
    final isDark = t.brightness == Brightness.dark;
    final isMe   = expense.paidById == currentUserId;
    final per    = expense.perPersonAmount;

    // Status
    Color statusColor;
    String statusLabel;
    if (expense.isSettled) {
      statusColor = AppColors.success;
      statusLabel = 'Settled';
    } else if (isMe) {
      statusColor = AppColors.secondary;
      statusLabel = 'You paid';
    } else {
      statusColor = AppColors.accent;
      statusLabel = 'You owe';
    }

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Emoji icon
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(expense.category.emoji, style: const TextStyle(fontSize: 21)),
            ),
          ),
          const SizedBox(width: 13),

          // Middle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.title, style: t.textTheme.titleMedium),
                const SizedBox(height: 3),
                Row(
                  children: [
                    // Payer dot
                    Container(
                      width: 14, height: 14,
                      decoration: BoxDecoration(
                        color: paidBy.color.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(paidBy.initials[0],
                          style: TextStyle(color: paidBy.color, fontSize: 8, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        isMe ? 'Paid by you' : '${paidBy.name.split(' ').first} paid',
                        style: t.textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('·', style: t.textTheme.bodySmall),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('MMM d').format(expense.date),
                      style: t.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Right: amount + badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${expense.amount.toStringAsFixed(2)}',
                style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: isDark ? 0.15 : 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  expense.isSettled
                      ? statusLabel
                      : '$statusLabel \$${per.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (!expense.isSettled && !isMe && onSettle != null) ...[
                const SizedBox(height: 5),
                GestureDetector(
                  onTap: onSettle,
                  child: const Text(
                    'Mark paid',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
