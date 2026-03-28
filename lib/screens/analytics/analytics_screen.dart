import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/expense_provider.dart';
import '../../providers/household_provider.dart';
import '../../providers/chore_provider.dart';
import '../../widgets/common/app_card.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final expenses = context.watch<ExpenseProvider>();
    final household = context.watch<HouseholdProvider>();
    final chores = context.watch<ChoreProvider>();

    final spendingByUser = expenses.spendingByUser();
    final spendingByCategory = expenses.spendingByCategory();
    final monthlyTotals = expenses.monthlyTotals();
    final completionByUser = chores.completionByUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Monthly spend trend
          Text('Spending Trend', style: theme.textTheme.titleLarge)
              .animate().fadeIn(),
          const SizedBox(height: 4),
          Text('Last 6 months', style: theme.textTheme.bodySmall)
              .animate().fadeIn(delay: 50.ms),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
            child: SizedBox(
              height: 180,
              child: LineChart(
                _buildLineChart(monthlyTotals, isDark),
                duration: const Duration(milliseconds: 800),
              ),
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 24),

          // Spending by category (pie chart)
          Text('By Category', style: theme.textTheme.titleLarge)
              .animate().fadeIn(delay: 150.ms),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                SizedBox(
                  width: 130,
                  height: 130,
                  child: spendingByCategory.isEmpty
                      ? const Center(child: Text('No data'))
                      : PieChart(
                          _buildPieChart(spendingByCategory),
                        ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _buildCategoryLegend(context, spendingByCategory),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 24),

          // Spending per person
          Text('Who Paid Most', style: theme.textTheme.titleLarge)
              .animate().fadeIn(delay: 250.ms),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.all(20),
            child: spendingByUser.isEmpty
                ? const Text('No data')
                : Column(
                    children: household.members.map((member) {
                      final amount = spendingByUser[member.id] ?? 0;
                      final total = expenses.totalAmount;
                      final percent = total == 0 ? 0.0 : amount / total;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _SpendBar(
                          name: member.name.split(' ').first,
                          amount: amount,
                          percent: percent,
                          color: member.color,
                        ),
                      );
                    }).toList(),
                  ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 24),

          // Chore completion
          Text('Chore Champions', style: theme.textTheme.titleLarge)
              .animate().fadeIn(delay: 350.ms),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.all(20),
            child: completionByUser.isEmpty
                ? const Text('No completed chores yet')
                : Column(
                    children: household.members.map((member) {
                      final count = completionByUser[member.id] ?? 0;
                      final maxCount = completionByUser.values
                          .reduce((a, b) => a > b ? a : b);
                      final percent = maxCount == 0 ? 0.0 : count / maxCount;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _SpendBar(
                          name: member.name.split(' ').first,
                          amount: count.toDouble(),
                          percent: percent,
                          color: member.color,
                          suffix: ' chores',
                          isCurrency: false,
                        ),
                      );
                    }).toList(),
                  ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 24),

          // Summary stats
          Text('Summary', style: theme.textTheme.titleLarge)
              .animate().fadeIn(delay: 450.ms),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  emoji: '💸',
                  value: '\$${expenses.totalAmount.toStringAsFixed(0)}',
                  label: 'Total spent',
                  gradient: AppColors.brand,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  emoji: '⚡',
                  value: '${expenses.unsettled.length}',
                  label: 'Unsettled',
                  gradient: AppColors.coral,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 500.ms),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  emoji: '✅',
                  value: '${chores.completionRate()}%',
                  label: 'Chore rate',
                  gradient: AppColors.teal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  emoji: '👥',
                  value: '${household.members.length}',
                  label: 'Housemates',
                  gradient: AppColors.violet,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 550.ms),
        ],
      ),
    );
  }

  LineChartData _buildLineChart(List<double> data, bool isDark) {
    final spots = data.asMap().entries.map((e) =>
      FlSpot(e.key.toDouble(), e.value),
    ).toList();

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (v) => FlLine(
          color: isDark
              ? AppColors.borderDark
              : AppColors.borderLight,
          strokeWidth: 1,
          dashArray: [4, 4],
        ),
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (v, _) {
              final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                              'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
              final now = DateTime.now();
              final monthIdx = (now.month - 5 + v.toInt()) % 12;
              return Text(
                months[monthIdx],
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? AppColors.t2Dark : AppColors.t2Light,
                ),
              );
            },
            reservedSize: 22,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (v, _) => Text(
              '\$${(v / 1000).toStringAsFixed(0)}k',
              style: TextStyle(
                fontSize: 9,
                color: isDark ? AppColors.t2Dark : AppColors.t2Light,
              ),
            ),
            reservedSize: 32,
          ),
        ),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.4,
          color: AppColors.primary,
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.25),
                AppColors.primary.withValues(alpha: 0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  PieChartData _buildPieChart(Map<dynamic, double> data) {
    final colors = AppColors.avatarColors;
    final entries = data.entries.toList();
    final total = data.values.fold(0.0, (a, b) => a + b);

    return PieChartData(
      sections: entries.asMap().entries.map((entry) {
        final percent = total == 0 ? 0.0 : entry.value.value / total * 100;
        return PieChartSectionData(
          color: colors[entry.key % colors.length],
          value: entry.value.value,
          title: percent >= 10 ? '${percent.toStringAsFixed(0)}%' : '',
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white,
          ),
        );
      }).toList(),
      sectionsSpace: 2,
      centerSpaceRadius: 20,
    );
  }

  List<Widget> _buildCategoryLegend(
      BuildContext context, Map<dynamic, double> data) {
    final colors = AppColors.avatarColors;
    final entries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return entries.take(5).toList().asMap().entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: colors[entry.key % colors.length],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                entry.value.key.label,
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '\$${entry.value.value.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

class _SpendBar extends StatelessWidget {
  final String name;
  final double amount;
  final double percent;
  final Color color;
  final String suffix;
  final bool isCurrency;

  const _SpendBar({
    required this.name,
    required this.amount,
    required this.percent,
    required this.color,
    this.suffix = '',
    this.isCurrency = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: theme.textTheme.titleSmall),
            Text(
              isCurrency
                  ? '\$${amount.toStringAsFixed(2)}'
                  : '${amount.toInt()}$suffix',
              style: theme.textTheme.titleSmall?.copyWith(
                color: color, fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.dividerLight,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percent.clamp(0.0, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withValues(alpha: 0.6)],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Gradient gradient;

  const _StatCard({
    required this.emoji,
    required this.value,
    required this.label,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
