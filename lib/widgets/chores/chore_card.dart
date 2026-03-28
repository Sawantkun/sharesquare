import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../models/chore_model.dart';
import '../../models/user_model.dart';
import '../../core/theme/app_colors.dart';

class ChoreCard extends StatelessWidget {
  final ChoreModel chore;
  final UserModel assignedTo;
  final VoidCallback? onToggle;
  final VoidCallback? onTap;

  const ChoreCard({
    super.key,
    required this.chore,
    required this.assignedTo,
    this.onToggle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t      = Theme.of(context);
    final isDark = t.brightness == Brightness.dark;

    // State colours
    Color borderColor;
    Color bgColor;
    Color accentColor;
    if (chore.isCompleted) {
      accentColor = AppColors.success;
      borderColor = AppColors.success.withValues(alpha: isDark ? 0.30 : 0.22);
      bgColor     = AppColors.success.withValues(alpha: isDark ? 0.06 : 0.03);
    } else if (chore.isOverdue) {
      accentColor = AppColors.accent;
      borderColor = AppColors.accent.withValues(alpha: isDark ? 0.32 : 0.22);
      bgColor     = AppColors.accent.withValues(alpha: isDark ? 0.06 : 0.03);
    } else if (chore.isDueToday) {
      accentColor = AppColors.gold;
      borderColor = AppColors.gold.withValues(alpha: isDark ? 0.32 : 0.22);
      bgColor     = AppColors.gold.withValues(alpha: isDark ? 0.06 : 0.03);
    } else {
      accentColor = AppColors.primary;
      borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
      bgColor     = isDark ? AppColors.cardDark : AppColors.cardLight;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 230.ms,
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: isDark ? 0.08 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Check circle
            GestureDetector(
              onTap: onToggle,
              child: AnimatedContainer(
                duration: 200.ms,
                width: 28, height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: chore.isCompleted ? AppColors.teal : null,
                  color: chore.isCompleted ? null : Colors.transparent,
                  border: Border.all(
                    color: chore.isCompleted
                        ? Colors.transparent
                        : (chore.isOverdue
                            ? AppColors.accent
                            : isDark ? AppColors.borderDark : AppColors.borderLight),
                    width: 1.5,
                  ),
                ),
                child: chore.isCompleted
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 15)
                    : null,
              ),
            ),
            const SizedBox(width: 11),

            // Emoji
            Text(chore.emoji ?? '📋', style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chore.title,
                    style: t.textTheme.titleSmall?.copyWith(
                      decoration: chore.isCompleted ? TextDecoration.lineThrough : null,
                      color: chore.isCompleted ? (isDark ? AppColors.t3Dark : AppColors.t3Light) : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // Due label
                      _PillLabel(
                        label: chore.isCompleted
                            ? 'Done'
                            : chore.isOverdue
                                ? 'Overdue'
                                : chore.isDueToday
                                    ? 'Today'
                                    : DateFormat('MMM d').format(chore.dueDate),
                        color: accentColor,
                        icon: chore.isOverdue && !chore.isCompleted
                            ? Icons.warning_amber_rounded
                            : chore.isCompleted
                                ? Icons.check_circle_rounded
                                : chore.isDueToday
                                    ? Icons.schedule_rounded
                                    : Icons.calendar_today_rounded,
                      ),
                      const SizedBox(width: 6),
                      _PillLabel(
                        label: chore.frequency.label,
                        color: isDark ? AppColors.t3Dark : AppColors.t3Light,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Assignee avatar
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                color: assignedTo.color.withValues(alpha: isDark ? 0.18 : 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  assignedTo.initials,
                  style: TextStyle(
                    color: assignedTo.color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PillLabel extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _PillLabel({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.14 : 0.09),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
