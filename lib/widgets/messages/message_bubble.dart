import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/message_model.dart';
import '../../models/user_model.dart';
import '../../core/theme/app_colors.dart';
import '../common/member_avatar.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final UserModel sender;
  final bool isMe;
  final void Function(String optionId)? onVote;
  final String currentUserId;

  const MessageBubble({
    super.key,
    required this.message,
    required this.sender,
    required this.isMe,
    required this.currentUserId,
    this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    if (message.type == MessageType.system) {
      return _SystemMessage(message: message);
    }

    if (message.type == MessageType.poll) {
      return _PollBubble(
        message: message,
        sender: sender,
        isMe: isMe,
        currentUserId: currentUserId,
        onVote: onVote,
      );
    }

    return _TextBubble(message: message, sender: sender, isMe: isMe);
  }
}

class _TextBubble extends StatelessWidget {
  final MessageModel message;
  final UserModel sender;
  final bool isMe;

  const _TextBubble({
    required this.message,
    required this.sender,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            MemberAvatar(user: sender, size: 28),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2),
                    child: Text(
                      sender.name.split(' ').first,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: sender.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isMe ? AppColors.brand : null,
                    color: isMe
                        ? null
                        : (isDark ? AppColors.cardDark : Colors.white),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(4),
                      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isMe ? AppColors.primary : Colors.black)
                            .withValues(alpha: isDark ? 0.2 : 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isMe ? Colors.white : null,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
                  child: Text(
                    DateFormat('h:mm a').format(message.timestamp),
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _PollBubble extends StatelessWidget {
  final MessageModel message;
  final UserModel sender;
  final bool isMe;
  final String currentUserId;
  final void Function(String optionId)? onVote;

  const _PollBubble({
    required this.message,
    required this.sender,
    required this.isMe,
    required this.currentUserId,
    this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final totalVotes = message.totalVotes;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(left: 36, bottom: 4),
              child: Text(
                sender.name.split(' ').first,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: sender.color, fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) ...[
                MemberAvatar(user: sender, size: 28),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              gradient: AppColors.violet,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'POLL',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$totalVotes vote${totalVotes != 1 ? 's' : ''}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message.pollQuestion ?? message.content,
                        style: theme.textTheme.titleSmall,
                      ),
                      const SizedBox(height: 10),
                      ...message.pollOptions!.map((opt) {
                        final hasVoted = opt.voterIds.contains(currentUserId);
                        final percent = totalVotes == 0
                            ? 0.0
                            : opt.voteCount / totalVotes;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GestureDetector(
                            onTap: () => onVote?.call(opt.id),
                            child: Stack(
                              children: [
                                Container(
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.surfaceDark
                                        : AppColors.bgLight,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: hasVoted
                                          ? AppColors.primary
                                          : (isDark
                                              ? AppColors.borderDark
                                              : AppColors.borderLight),
                                      width: hasVoted ? 1.5 : 1,
                                    ),
                                  ),
                                ),
                                // Progress fill
                                FractionallySizedBox(
                                  widthFactor: percent,
                                  child: Container(
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                  ),
                                ),
                                // Label
                                Positioned.fill(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: Row(
                                      children: [
                                        if (hasVoted)
                                          const Icon(Icons.check_circle_rounded,
                                              color: AppColors.primary, size: 14),
                                        if (hasVoted) const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            opt.text,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              fontWeight: hasVoted
                                                  ? FontWeight.w600
                                                  : null,
                                              color: hasVoted
                                                  ? AppColors.primary
                                                  : null,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${opt.voteCount}',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SystemMessage extends StatelessWidget {
  final MessageModel message;
  const _SystemMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            message.content,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ),
    );
  }
}
