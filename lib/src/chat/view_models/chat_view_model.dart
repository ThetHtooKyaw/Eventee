import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:eventee/core/utils/base_view_model.dart';
import 'package:eventee/src/chat/models/message.dart';
import 'package:eventee/src/chat/repo/chat_service.dart';
import 'package:flutter/material.dart';

class ChatViewModel extends BaseViewModel {
  // Dependencies
  final ChatService _chatService;
  ChatViewModel(this._chatService);

  // Controllers
  final TextEditingController textController = TextEditingController();

  // Variables
  String? _currentUserId;
  final List<Message> _messages = [];

  // Getters
  String? get currentUserId => _currentUserId;
  List<Message> get messages => _messages;

  // Use Cases
  Future<void> getCurrentUser() async {
    setScreenLoading(true);
    setError(null);

    final response = await _chatService.getCurrentUser();

    if (response is Success) {
      _currentUserId = response.response as String;
    } else if (response is Failure) {
      setError(response.response.toString());
    }

    setScreenLoading(false);
  }

  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;
    textController.clear();

    final message = Message(
      senderId: _currentUserId ?? 'unknown-user',
      text: text,
      date: DateTime.now(),
      isSentByMe: true,
    );
    _messages.add(message);
    notifyListeners();

    _messages.add(
      Message(
        senderId: 'gemini-ai-loading',
        text: 'Thinking...',
        date: DateTime.now(),
        isSentByMe: false,
        isLoading: true,
      ),
    );
    notifyListeners();

    await getAIResponse(promptText: message.text);
  }

  Future<void> getAIResponse({required String promptText}) async {
    setError(null);

    final response = await _chatService.geminiAIResponse(
      promptText: promptText,
    );

    _messages.removeWhere((m) => m.isLoading == true);

    if (response is Success) {
      final text = (response.response as dynamic).text;

      _messages.add(
        Message(
          senderId: 'gemini-ai',
          text: text,
          date: DateTime.now(),
          isSentByMe: false,
        ),
      );
    } else if (response is Failure) {
      setError(response.response.toString());
    }

    notifyListeners();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }
}
