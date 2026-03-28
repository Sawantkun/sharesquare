enum MessageType { text, image, poll, system }

class PollOption {
  final String id;
  final String text;
  final List<String> voterIds;

  const PollOption({
    required this.id,
    required this.text,
    this.voterIds = const [],
  });

  int get voteCount => voterIds.length;

  PollOption copyWith({String? id, String? text, List<String>? voterIds}) {
    return PollOption(
      id: id ?? this.id,
      text: text ?? this.text,
      voterIds: voterIds ?? this.voterIds,
    );
  }
}

class MessageModel {
  final String id;
  final String senderId;
  final String householdId;
  final String content;
  final DateTime timestamp;
  final MessageType type;
  final String? imageUrl;
  final List<PollOption>? pollOptions;
  final String? pollQuestion;
  final bool isRead;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.householdId,
    required this.content,
    required this.timestamp,
    this.type = MessageType.text,
    this.imageUrl,
    this.pollOptions,
    this.pollQuestion,
    this.isRead = false,
  });

  bool get isPoll => type == MessageType.poll;

  int get totalVotes =>
      pollOptions?.fold(0, (sum, opt) => sum! + opt.voteCount) ?? 0;

  MessageModel copyWith({
    String? id, String? senderId, String? householdId, String? content,
    DateTime? timestamp, MessageType? type, String? imageUrl,
    List<PollOption>? pollOptions, String? pollQuestion, bool? isRead,
  }) {
    return MessageModel(
      id: id ?? this.id, senderId: senderId ?? this.senderId,
      householdId: householdId ?? this.householdId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type, imageUrl: imageUrl ?? this.imageUrl,
      pollOptions: pollOptions ?? this.pollOptions,
      pollQuestion: pollQuestion ?? this.pollQuestion,
      isRead: isRead ?? this.isRead,
    );
  }
}
