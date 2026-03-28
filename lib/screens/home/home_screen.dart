import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/bill_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/household_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/chore_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/common/app_card.dart';
import '../../widgets/common/member_avatar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth      = context.watch<AuthProvider>();
    final household = context.watch<HouseholdProvider>();
    final expenses  = context.watch<ExpenseProvider>();
    final chores    = context.watch<ChoreProvider>();
    final tp        = context.watch<ThemeProvider>();
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final user      = auth.currentUser;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── AppBar ────────────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: Row(
              children: [
                // Logo
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    gradient: AppColors.brand,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text('⬡', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'ShareSquare',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: tp.toggle,
                icon: Icon(tp.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, size: 20),
                style: IconButton.styleFrom(
                  foregroundColor: isDark ? AppColors.t2Dark : AppColors.t2Light,
                ),
              ),
              if (user != null)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: GestureDetector(
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        gradient: AppColors.brand,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          user.initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Greeting ─────────────────────────────────────────────────
                _Greeting(name: user?.name ?? 'there'),
                const SizedBox(height: 20),

                // ── Hero stats card ───────────────────────────────────────────
                _HeroCard(expenses: expenses, chores: chores, household: household),
                const SizedBox(height: 24),

                // ── Quick stats row ──────────────────────────────────────────
                _QuickStats(expenses: expenses, chores: chores),
                const SizedBox(height: 28),

                // ── Upcoming bills ────────────────────────────────────────────
                if (household.upcomingBills.isNotEmpty) ...[
                  _SectionHeader(
                    title: 'Upcoming Bills',
                    trailing: '${household.upcomingBills.length} pending',
                  ),
                  const SizedBox(height: 12),
                  ...household.upcomingBills.take(3).map((b) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _BillRow(bill: b),
                  )),
                  const SizedBox(height: 20),
                ],

                // ── Today's chores ────────────────────────────────────────────
                if (chores.dueToday.isNotEmpty) ...[
                  _SectionHeader(
                    title: "Today's Chores",
                    trailing: '${chores.dueToday.length} left',
                  ),
                  const SizedBox(height: 12),
                  ...chores.dueToday.take(3).map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _ChoreRow(title: c.title, emoji: c.emoji ?? '📋'),
                  )),
                  const SizedBox(height: 20),
                ],

                // ── Housemates ────────────────────────────────────────────────
                if (household.members.isNotEmpty) ...[
                  _SectionHeader(title: 'Housemates'),
                  const SizedBox(height: 12),
                  AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: household.members.map((m) =>
                        MemberAvatar(
                          user: m, size: 50, showName: true,
                          showBorder: m.id == auth.currentUser?.id,
                        ),
                      ).toList(),
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 20),
                ],

                // ── House rules ───────────────────────────────────────────────
                if (household.houseRules.isNotEmpty) ...[
                  _SectionHeader(title: 'House Rules'),
                  const SizedBox(height: 12),
                  AppCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: household.houseRules.asMap().entries.map((e) =>
                        Padding(
                          padding: EdgeInsets.only(bottom: e.key < household.houseRules.length - 1 ? 12 : 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 22, height: 22,
                                decoration: BoxDecoration(
                                  gradient: AppColors.brand,
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                child: Center(
                                  child: Text('${e.key + 1}',
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(e.value, style: Theme.of(context).textTheme.bodyMedium),
                              ),
                            ],
                          ),
                        ),
                      ).toList(),
                    ),
                  ).animate().fadeIn(delay: 250.ms),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Greeting ──────────────────────────────────────────────────────────────────
class _Greeting extends StatelessWidget {
  final String name;
  const _Greeting({required this.name});

  @override
  Widget build(BuildContext context) {
    final h  = DateTime.now().hour;
    final g  = h < 12 ? 'Good morning' : h < 17 ? 'Good afternoon' : 'Good evening';
    final t  = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$g,',
          style: t.textTheme.bodyLarge?.copyWith(color: t.textTheme.bodySmall?.color),
        ),
        const SizedBox(height: 2),
        Text(
          '${name.split(' ').first} 👋',
          style: t.textTheme.displaySmall,
        ),
        const SizedBox(height: 2),
        Text(
          DateFormat('EEEE, MMMM d').format(DateTime.now()),
          style: t.textTheme.bodySmall,
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 450.ms)
        .slideY(begin: 0.08, end: 0, curve: Curves.easeOut);
  }
}

// ── Hero card ─────────────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final ExpenseProvider expenses;
  final ChoreProvider chores;
  final HouseholdProvider household;

  const _HeroCard({
    required this.expenses,
    required this.chores,
    required this.household,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.brand,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.40),
            blurRadius: 28,
            offset: const Offset(0, 10),
            spreadRadius: -4,
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Household name row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🏠', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 5),
                    Text(
                      household.household?.name ?? 'My Home',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('MMM yyyy').format(DateTime.now()),
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Total spend
          const Text(
            'Total Expenses',
            style: TextStyle(color: Colors.white60, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            '\$${expenses.totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 20),
          // Divider
          Container(height: 1, color: Colors.white.withValues(alpha: 0.15)),
          const SizedBox(height: 16),
          // Stats row
          Row(
            children: [
              _HeroStat(
                icon: Icons.check_circle_outline_rounded,
                label: 'Chores done',
                value: '${chores.completed.length}',
              ),
              _HeroStatDivider(),
              _HeroStat(
                icon: Icons.pending_actions_rounded,
                label: 'Pending',
                value: '${chores.pending.length}',
              ),
              _HeroStatDivider(),
              _HeroStat(
                icon: Icons.group_rounded,
                label: 'Members',
                value: '${household.members.length}',
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 80.ms, duration: 500.ms)
        .slideY(begin: 0.08, end: 0, curve: Curves.easeOut);
  }
}

class _HeroStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _HeroStat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Icon(icon, color: Colors.white70, size: 17),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11), textAlign: TextAlign.center),
      ],
    ),
  );
}

class _HeroStatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
    Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.15));
}

// ── Quick stats ───────────────────────────────────────────────────────────────
class _QuickStats extends StatelessWidget {
  final ExpenseProvider expenses;
  final ChoreProvider chores;
  const _QuickStats({required this.expenses, required this.chores});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _QuickStatCard(
          emoji: '💸',
          value: '${expenses.unsettled.length}',
          label: 'Unsettled',
          gradient: AppColors.coral,
        )),
        const SizedBox(width: 12),
        Expanded(child: _QuickStatCard(
          emoji: '⚡',
          value: '${chores.overdue.length}',
          label: 'Overdue',
          gradient: AppColors.goldGradient,
        )),
        const SizedBox(width: 12),
        Expanded(child: _QuickStatCard(
          emoji: '🏆',
          value: '${chores.completionRate()}%',
          label: 'On track',
          gradient: AppColors.teal,
        )),
      ],
    )
        .animate()
        .fadeIn(delay: 150.ms, duration: 450.ms)
        .slideY(begin: 0.08, end: 0);
  }
}

class _QuickStatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Gradient gradient;
  const _QuickStatCard({required this.emoji, required this.value, required this.label, required this.gradient});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Extract first color for tinting
    final tintColor = (gradient as LinearGradient).colors.first;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: tintColor.withValues(alpha: isDark ? 0.12 : 0.08),
            blurRadius: 16, offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: tintColor,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? trailing;
  const _SectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Row(
      children: [
        Text(title, style: t.textTheme.titleLarge),
        const Spacer(),
        if (trailing != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              trailing!,
              style: const TextStyle(
                color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

// ── Bill row ──────────────────────────────────────────────────────────────────
class _BillRow extends StatelessWidget {
  final BillModel bill;
  const _BillRow({required this.bill});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final isDark = t.brightness == Brightness.dark;
    final urgentColor = bill.isOverdue
        ? AppColors.accent
        : bill.daysUntilDue <= 3
            ? AppColors.gold
            : AppColors.secondary;

    return AccentCard(
      accentColor: urgentColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: urgentColor.withValues(alpha: isDark ? 0.14 : 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text(bill.category.emoji, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bill.title, style: t.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  bill.isOverdue
                      ? 'Overdue!'
                      : bill.daysUntilDue == 0
                          ? 'Due today'
                          : 'Due in ${bill.daysUntilDue}d',
                  style: TextStyle(color: urgentColor, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Text(
            '\$${bill.amount.toStringAsFixed(0)}',
            style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// ── Chore row ─────────────────────────────────────────────────────────────────
class _ChoreRow extends StatelessWidget {
  final String title;
  final String emoji;
  const _ChoreRow({required this.title, required this.emoji});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final isDark = t.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: t.textTheme.titleSmall)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Today',
              style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
