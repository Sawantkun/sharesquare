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

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'voterIds': voterIds,
  };

  factory PollOption.fromJson(Map<String, dynamic> json) => PollOption(
    id: (json['id'] as String?) ?? '',
    text: (json['text'] as String?) ?? '',
    voterIds: List<String>.from(json['voterIds'] ?? []),
  );
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'senderId': senderId,
    'householdId': householdId,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
    'type': type.name,
    'imageUrl': imageUrl,
    'pollOptions': pollOptions?.map((o) => o.toJson()).toList(),
    'pollQuestion': pollQuestion,
    'isRead': isRead,
  };

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
    id: (json['id'] as String?) ?? '',
    senderId: (json['senderId'] as String?) ?? '',
    householdId: (json['householdId'] as String?) ?? '',
    content: (json['content'] as String?) ?? '',
    timestamp: json['timestamp'] != null
        ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
        : DateTime.now(),
    type: MessageType.values.firstWhere(
      (t) => t.name == json['type'],
      orElse: () => MessageType.text,
    ),
    imageUrl: json['imageUrl'] as String?,
    pollOptions: (json['pollOptions'] as List<dynamic>?)
        ?.map((o) => PollOption.fromJson(o as Map<String, dynamic>))
        .toList(),
    pollQuestion: json['pollQuestion'] as String?,
    isRead: json['isRead'] as bool? ?? false,
  );
}
