import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/message_model.dart';

class ChatProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  List<MessageModel> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _householdId;
  StreamSubscription<QuerySnapshot>? _sub;

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  int get unreadCount => _messages.where((m) => !m.isRead).length;

  void syncFromAuth(String? householdId) {
    if (householdId == _householdId) return;
    _householdId = householdId;
    _sub?.cancel();
    if (householdId != null && householdId.isNotEmpty) {
      _subscribe(householdId);
    } else {
      clear();
    }
  }

  void clear() {
    _messages = [];
    _isLoading = false;
    _isSending = false;
    _householdId = null;
    notifyListeners();
  }

  void _subscribe(String householdId) {
    _isLoading = true;
    notifyListeners();
    _sub = _db
        .collection('households')
        .doc(householdId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .listen((snap) {
      _messages = snap.docs.map((d) => MessageModel.fromJson(d.data())).toList();
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      debugPrint('ChatProvider stream error: $e');
      _isLoading = false;
      notifyListeners();
    });
  }

  // Legacy method
  void loadMessages() {
    if (_householdId != null) _subscribe(_householdId!);
  }

  Future<void> sendMessage(
      String content, String senderId, String householdId) async {
    if (content.trim().isEmpty) return;
    _isSending = true;
    notifyListeners();

    final msg = MessageModel(
      id: _uuid.v4(),
      senderId: senderId,
      householdId: householdId,
      content: content.trim(),
      timestamp: DateTime.now(),
      isRead: true,
    );

    await _db
        .collection('households')
        .doc(householdId)
        .collection('messages')
        .doc(msg.id)
        .set(msg.toJson());

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

    final pollOptions =
        options.map((opt) => PollOption(id: _uuid.v4(), text: opt)).toList();

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

    await _db
        .collection('households')
        .doc(householdId)
        .collection('messages')
        .doc(msg.id)
        .set(msg.toJson());

    _isSending = false;
    notifyListeners();
  }

  Future<void> vote(String messageId, String optionId, String userId) async {
    if (_householdId == null) return;
    final msgIdx = _messages.indexWhere((m) => m.id == messageId);
    if (msgIdx == -1 || _messages[msgIdx].pollOptions == null) return;

    final updatedOptions = _messages[msgIdx].pollOptions!.map((opt) {
      final voters = List<String>.from(opt.voterIds)..remove(userId);
      if (opt.id == optionId) voters.add(userId);
      return opt.copyWith(voterIds: voters);
    }).toList();

    _messages[msgIdx] = _messages[msgIdx].copyWith(pollOptions: updatedOptions);
    notifyListeners();

    await _db
        .collection('households')
        .doc(_householdId)
        .collection('messages')
        .doc(messageId)
        .update({
      'pollOptions': updatedOptions.map((o) => o.toJson()).toList(),
    });
  }

  void markAllRead() {
    _messages = _messages.map((m) => m.copyWith(isRead: true)).toList();
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
