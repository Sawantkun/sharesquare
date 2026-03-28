import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../models/chore_model.dart';
import '../../providers/chore_provider.dart';
import '../../providers/household_provider.dart';
import '../../widgets/common/gradient_button.dart';
import '../../widgets/common/custom_text_field.dart';

class AddChoreScreen extends StatefulWidget {
  const AddChoreScreen({super.key});

  @override
  State<AddChoreScreen> createState() => _AddChoreScreenState();
}

class _AddChoreScreenState extends State<AddChoreScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String _selectedEmoji = '📋';
  late String _assignedToId;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  ChoreFrequency _frequency = ChoreFrequency.once;
  bool _isLoading = false;

  final _emojis = ['📋', '🧹', '🗑️', '🚿', '🍽️', '🧺', '🧽', '🌿', '💳', '🛒', '🔧', '🏠'];

  @override
  void initState() {
    super.initState();
    final household = context.read<HouseholdProvider>();
    _assignedToId = household.members.isNotEmpty
        ? household.members.first.id
        : '';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: AppColors.primary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);

    final household = context.read<HouseholdProvider>().household!;
    final chore = ChoreModel(
      id: const Uuid().v4(),
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      assignedToId: _assignedToId,
      dueDate: _dueDate,
      frequency: _frequency,
      emoji: _selectedEmoji,
      householdId: household.id,
      createdAt: DateTime.now(),
    );

    await context.read<ChoreProvider>().addChore(chore);

    if (mounted) {
      setState(() => _isLoading = false);
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Chore added!'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final household = context.watch<HouseholdProvider>();
    final members = household.members;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Chore'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Emoji picker
            Text('Pick an icon', style: theme.textTheme.labelLarge),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _emojis.map((emoji) {
                final isSelected = emoji == _selectedEmoji;
                return GestureDetector(
                  onTap: () => setState(() => _selectedEmoji = emoji),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : (theme.dividerTheme.color ?? AppColors.borderLight),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                );
              }).toList(),
            ).animate().fadeIn(delay: 50.ms),
            const SizedBox(height: 20),

            CustomTextField(
              label: 'Chore title',
              hint: 'Vacuum living room',
              controller: _titleCtrl,
              prefixIcon: Icons.label_outline_rounded,
              textCapitalization: TextCapitalization.sentences,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Title is required';
                return null;
              },
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 16),

            CustomTextField(
              label: 'Description (optional)',
              hint: 'Any additional details...',
              controller: _descCtrl,
              prefixIcon: Icons.notes_rounded,
              maxLines: 2,
            ).animate().fadeIn(delay: 150.ms),
            const SizedBox(height: 20),

            // Assign to
            Text('Assign to', style: theme.textTheme.labelLarge),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: members.map((member) {
                final isSelected = _assignedToId == member.id;
                return GestureDetector(
                  onTap: () => setState(() => _assignedToId = member.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? member.color.withValues(alpha: 0.15)
                          : theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected ? member.color : (theme.dividerTheme.color ?? AppColors.borderLight),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: member.color.withValues(alpha: 0.2),
                          child: Text(
                            member.initials,
                            style: TextStyle(color: member.color, fontSize: 10, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          member.name.split(' ').first,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? member.color : null,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 20),

            // Due date
            Text('Due date', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: theme.inputDecorationTheme.fillColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: theme.dividerTheme.color ?? AppColors.borderLight,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Text(
                      '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 250.ms),
            const SizedBox(height: 20),

            // Frequency
            Text('Repeat', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ChoreFrequency.values.map((freq) {
                final isSelected = _frequency == freq;
                return GestureDetector(
                  onTap: () => setState(() => _frequency = freq),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppColors.brand : null,
                      color: isSelected ? null : theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : (theme.dividerTheme.color ?? AppColors.borderLight),
                      ),
                    ),
                    child: Text(
                      freq.label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : null,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 32),

            GradientButton(
              label: 'Add Chore',
              onPressed: _submit,
              isLoading: _isLoading,
              icon: Icons.add_rounded,
            ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.1, end: 0),
          ],
        ),
      ),
    );
  }
}
