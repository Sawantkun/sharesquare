import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/mock_data.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/household_provider.dart';
import '../../widgets/messages/message_bubble.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _scrollController = ScrollController();
  final _messageCtrl = TextEditingController();
  bool _showPollComposer = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
      context.read<ChatProvider>().markAllRead();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageCtrl.text.trim();
    if (content.isEmpty) return;

    final auth = context.read<AuthProvider>();
    final household = context.read<HouseholdProvider>();
    _messageCtrl.clear();

    await context.read<ChatProvider>().sendMessage(
      content,
      auth.currentUser!.id,
      household.household!.id,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final chat = context.watch<ChatProvider>();
    final auth = context.watch<AuthProvider>();
    final household = context.watch<HouseholdProvider>();
    final currentUserId = auth.currentUser?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chat'),
            if (household.household != null)
              Text(
                household.household!.name,
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
              ),
          ],
        ),
        actions: [
          // Members online indicator
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: household.members.take(3).map((m) =>
                Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: m.color.withValues(alpha: 0.15),
                    child: Text(
                      m.initials,
                      style: TextStyle(
                        color: m.color, fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ).toList(),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: chat.messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('💬', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text('No messages yet', style: theme.textTheme.titleMedium),
                        Text('Say hi to your housemates!', style: theme.textTheme.bodySmall),
                      ],
                    ).animate().fadeIn(duration: 400.ms),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    itemCount: chat.messages.length,
                    itemBuilder: (context, i) {
                      final message = chat.messages[i];
                      final sender = household.memberById(message.senderId) ??
                          MockData.userById(message.senderId);
                      final isMe = message.senderId == currentUserId;

                      // Date separator
                      Widget? separator;
                      if (i == 0 ||
                          !_isSameDay(
                            chat.messages[i - 1].timestamp,
                            message.timestamp,
                          )) {
                        separator = _DateSeparator(date: message.timestamp);
                      }

                      return Column(
                        children: [
                          if (separator != null) separator,
                          MessageBubble(
                            message: message,
                            sender: sender,
                            isMe: isMe,
                            currentUserId: currentUserId,
                            onVote: (optionId) => chat.vote(
                              message.id,
                              optionId,
                              currentUserId,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),

          // Poll composer
          if (_showPollComposer)
            _PollComposer(
              onSend: (question, options) async {
                final authP = context.read<AuthProvider>();
                final hP = context.read<HouseholdProvider>();
                await context.read<ChatProvider>().sendPoll(
                  question: question,
                  options: options,
                  senderId: authP.currentUser!.id,
                  householdId: hP.household!.id,
                );
                setState(() => _showPollComposer = false);
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
              },
              onCancel: () => setState(() => _showPollComposer = false),
            ).animate().slideY(begin: 1, end: 0, duration: 300.ms),

          // Input bar
          Container(
            padding: EdgeInsets.fromLTRB(
              12, 8, 12, MediaQuery.of(context).padding.bottom + 8,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                // Poll button
                IconButton(
                  onPressed: () => setState(() => _showPollComposer = !_showPollComposer),
                  icon: Icon(
                    Icons.poll_outlined,
                    color: _showPollComposer ? AppColors.primary : null,
                  ),
                  tooltip: 'Create poll',
                ),
                // Text input
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.bgLight,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    child: TextField(
                      controller: _messageCtrl,
                      minLines: 1,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Message ${household.household?.name ?? 'the group'}…',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        isDense: true,
                      ),
                      style: theme.textTheme.bodyMedium,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Send button
                ValueListenableBuilder(
                  valueListenable: _messageCtrl,
                  builder: (_, value, __) {
                    final hasText = value.text.isNotEmpty;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: hasText ? AppColors.brand : null,
                        color: hasText ? null : (isDark ? AppColors.cardDark : AppColors.bgLight),
                        shape: BoxShape.circle,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(21),
                          onTap: hasText ? _sendMessage : null,
                          child: Icon(
                            Icons.send_rounded,
                            color: hasText ? Colors.white : theme.textTheme.bodySmall?.color,
                            size: 20,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DateSeparator extends StatelessWidget {
  final DateTime date;
  const _DateSeparator({required this.date});

  String _format() {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _format(),
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}

class _PollComposer extends StatefulWidget {
  final Future<void> Function(String question, List<String> options) onSend;
  final VoidCallback onCancel;

  const _PollComposer({required this.onSend, required this.onCancel});

  @override
  State<_PollComposer> createState() => _PollComposerState();
}

class _PollComposerState extends State<_PollComposer> {
  final _questionCtrl = TextEditingController();
  final List<TextEditingController> _optionCtrls = [
    TextEditingController(),
    TextEditingController(),
  ];
  bool _isLoading = false;

  @override
  void dispose() {
    _questionCtrl.dispose();
    for (final c in _optionCtrls) c.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final question = _questionCtrl.text.trim();
    final options = _optionCtrls
        .map((c) => c.text.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (question.isEmpty || options.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a question and at least 2 options')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await widget.onSend(question, options);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📊', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text('Create Poll', style: theme.textTheme.titleSmall),
              const Spacer(),
              IconButton(
                onPressed: widget.onCancel,
                icon: const Icon(Icons.close_rounded, size: 20),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _questionCtrl,
            decoration: InputDecoration(
              hintText: 'Ask a question…',
              hintStyle: theme.textTheme.bodySmall,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 8),
          ..._optionCtrls.asMap().entries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: TextField(
              controller: entry.value,
              decoration: InputDecoration(
                hintText: 'Option ${entry.key + 1}',
                hintStyle: theme.textTheme.bodySmall,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
              ),
            ),
          )),
          Row(
            children: [
              TextButton.icon(
                onPressed: _optionCtrls.length < 5
                    ? () => setState(() =>
                        _optionCtrls.add(TextEditingController()))
                    : null,
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Add option'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: _isLoading ? null : _send,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  visualDensity: VisualDensity.compact,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Send Poll'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
