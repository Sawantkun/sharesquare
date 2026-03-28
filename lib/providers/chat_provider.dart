import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/message_model.dart';
import '../data/mock_data.dart';

class ChatProvider extends ChangeNotifier {
  List<MessageModel> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  final _uuid = const Uuid();

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;

  int get unreadCount => _messages.where((m) => !m.isRead).length;

  void loadMessages() {
    _messages = List.from(MockData.messages);
    _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    notifyListeners();
  }

  Future<void> sendMessage(String content, String senderId, String householdId) async {
    if (content.trim().isEmpty) return;
    _isSending = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    final msg = MessageModel(
      id: _uuid.v4(),
      senderId: senderId,
      householdId: householdId,
      content: content.trim(),
      timestamp: DateTime.now(),
      isRead: true,
    );
    _messages = [..._messages, msg];
    _isSending = false;
    notifyListeners();
  }

  Future<void> sendPoll({
    required String question,
    required List<String> options,
    required String senderId,
    required String householdId,
  }) async {
    _isSending = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));

    final pollOptions = options.map((opt) =>
      PollOption(id: _uuid.v4(), text: opt),
    ).toList();

    final msg = MessageModel(
      id: _uuid.v4(),
      senderId: senderId,
      householdId: householdId,
      content: question,
      timestamp: DateTime.now(),
      type: MessageType.poll,
      pollQuestion: question,
      pollOptions: pollOptions,
      isRead: true,
    );
    _messages = [..._messages, msg];
    _isSending = false;
    notifyListeners();
  }

  void vote(String messageId, String optionId, String userId) {
    final msgIdx = _messages.indexWhere((m) => m.id == messageId);
    if (msgIdx == -1) return;

    final msg = _messages[msgIdx];
    if (msg.pollOptions == null) return;

    // Remove any existing vote by this user
    final updatedOptions = msg.pollOptions!.map((opt) {
      final voters = List<String>.from(opt.voterIds)..remove(userId);
      if (opt.id == optionId) voters.add(userId);
      return opt.copyWith(voterIds: voters);
    }).toList();

    _messages[msgIdx] = msg.copyWith(pollOptions: updatedOptions);
    notifyListeners();
  }

  void markAllRead() {
    _messages = _messages.map((m) => m.copyWith(isRead: true)).toList();
    notifyListeners();
  }
}
