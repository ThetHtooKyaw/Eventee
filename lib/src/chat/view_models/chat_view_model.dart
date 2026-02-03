import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:eventee/src/chat/models/chat_error.dart';
import 'package:eventee/src/chat/models/message.dart';
import 'package:eventee/src/chat/repo/chat_service.dart';
import 'package:flutter/widgets.dart';

class ChatViewModel extends ChangeNotifier {
  // Dependencies
  final ChatService _chatService;
  ChatViewModel(this._chatService);

  // Variables
  bool _loading = false;
  ChatError? _chatError;
  String? _currentUserId;
  List<Message> _messages = [];

  // Getters
  bool get loading => _loading;
  ChatError? get chatError => _chatError;
  String? get currentUserId => _currentUserId;
  List<Message> get messages => _messages;

  // Setters
  void setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  void setChatError(ChatError chatError) {
    _chatError = chatError;
    notifyListeners();
  }

  void clearChatError() {
    _chatError = null;
    notifyListeners();
  }

  // Use Cases
  Future<void> getCurrentUser() async {
    setLoading(true);
    clearChatError();

    final response = await _chatService.getCurrentUser();

    if (response is Success) {
      _currentUserId = response.response as String;
    } else if (response is Failure) {
      setChatError(ChatError(message: response.response.toString()));
    }

    setLoading(false);
  }

  Future<void> sendMessage({required String text}) async {
    final message = Message(
      senderId: _currentUserId ?? 'unknown-user',
      text: text,
      date: DateTime.now(),
      isSentByMe: true,
    );
    _messages.add(message);
    notifyListeners();

    final loadingMessage = Message(
      senderId: 'gemini-ai',
      text: 'Thinking...',
      date: DateTime.now(),
      isSentByMe: false,
      isLoading: true,
    );
    _messages.add(loadingMessage);

    await getAIResponse(promptText: message.text);
  }

  Future<void> getAIResponse({required String promptText}) async {
    clearChatError();

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
      setChatError(ChatError(message: response.response.toString()));
      print(response.response.toString());
    }

    notifyListeners();
  }
}
