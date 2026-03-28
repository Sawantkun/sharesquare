import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/mock_data.dart';
import '../../providers/chore_provider.dart';
import '../../providers/household_provider.dart';
import '../../widgets/chores/chore_card.dart';

class ChoresScreen extends StatefulWidget {
  const ChoresScreen({super.key});

  @override
  State<ChoresScreen> createState() => _ChoresScreenState();
}

class _ChoresScreenState extends State<ChoresScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chores = context.watch<ChoreProvider>();
    final household = context.watch<HouseholdProvider>();

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            floating: true,
            title: const Text('Chores'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _CompletionBadge(rate: chores.completionRate()),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: theme.textTheme.bodySmall?.color,
              indicatorColor: AppColors.primary,
              indicatorWeight: 2,
              tabs: [
                Tab(text: 'Pending (${chores.pending.length})'),
                Tab(text: 'Done (${chores.completed.length})'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _ChoresList(
              chores: chores.pending,
              household: household,
              onToggle: (id) => chores.toggleChore(id),
              emptyMessage: '🎉 All chores done!',
              emptySubtext: 'Enjoy your free time',
            ),
            _ChoresList(
              chores: chores.completed,
              household: household,
              onToggle: (id) => chores.toggleChore(id),
              emptyMessage: '📋 No completed chores',
              emptySubtext: 'Complete a chore to see it here',
              isCompleted: true,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-chore'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Chore'),
      ).animate().scale(delay: 300.ms, duration: 400.ms, curve: Curves.elasticOut),
    );
  }
}

class _ChoresList extends StatelessWidget {
  final List chores;
  final HouseholdProvider household;
  final void Function(String) onToggle;
  final String emptyMessage;
  final String emptySubtext;
  final bool isCompleted;

  const _ChoresList({
    required this.chores,
    required this.household,
    required this.onToggle,
    required this.emptyMessage,
    required this.emptySubtext,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    if (chores.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emptyMessage,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(emptySubtext,
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ).animate().fadeIn(duration: 400.ms),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: chores.length,
      itemBuilder: (context, i) {
        final chore = chores[i];
        final assignedTo = household.memberById(chore.assignedToId) ??
            MockData.userById(chore.assignedToId);

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ChoreCard(
            chore: chore,
            assignedTo: assignedTo,
            onToggle: () => onToggle(chore.id),
          )
              .animate()
              .fadeIn(delay: (i * 60).ms, duration: 350.ms)
              .slideX(begin: 0.05, end: 0),
        );
      },
    );
  }
}

class _CompletionBadge extends StatelessWidget {
  final int rate;
  const _CompletionBadge({required this.rate});

  @override
  Widget build(BuildContext context) {
    final color = rate >= 80
        ? AppColors.success
        : rate >= 50
            ? AppColors.gold
            : AppColors.accent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            '$rate%',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
