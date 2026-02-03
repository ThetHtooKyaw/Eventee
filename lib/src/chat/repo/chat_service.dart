import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final _firebaseAuth = FirebaseAuth.instance;

  Future<Object> getCurrentUser() async {
    try {
      final userId = _firebaseAuth.currentUser?.uid;
      if (userId == null) {
        return Failure(response: 'No user logged in');
      }
      return Success(response: userId);
    } catch (e) {
      return Failure(response: 'Fail to get current user id: $e.');
    }
  }

  Future<Object> geminiAIResponse({required String promptText}) async {
    try {
      final model = FirebaseAI.googleAI().generativeModel(
        model: 'gemini-2.5-flash',
      );

      final prompt = [Content.text(promptText)];

      final response = await model.generateContent(prompt);

      return Success(response: response);
    } catch (e) {
      return Failure(response: 'Fail to get AI response: $e.');
    }
  }
}
