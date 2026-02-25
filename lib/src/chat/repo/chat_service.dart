import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final _firebaseAuth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  CollectionReference get _eventCollection => _firestore.collection('events');

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

  Future<String> _fetchEventContext() async {
    try {
      final snapshot = await _eventCollection.get();

      if (snapshot.docs.isEmpty) return 'There are no upcoming events.';

      final eventsData = snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            return "Event: ${data['eventName']}, Date: ${data['eventDate']}, Location: ${data['eventLocation']}, Price: ${data['ticketPrice']} Baht, Details: ${data['eventDetail']}, Category: ${data['eventCategory']}";
          })
          .join("\n");

      return eventsData;
    } catch (e) {
      return "Could not fetch event data: $e";
    }
  }

  Future<Object> geminiAIResponse({required String promptText}) async {
    try {
      final eventContext = await _fetchEventContext();

      final fullPromptText =
          '''
You are a helpful AI assistant for an app called "Eventee".
Here is the list of current real-world events available in the database:
$eventContext

User Question: $promptText
1. Answer the user's question based strictly on the event list above. 
2. If the event is not in the list, say "Sorry, I don't have information about that event."
3. If listing miltiple events, use bullet points and keep the answer concise.
4. Use double line breaks between events so they are easy to read.
''';

      final model = FirebaseAI.googleAI().generativeModel(
        model: 'gemini-2.5-flash-lite',
      );

      final prompt = [Content.text(fullPromptText)];

      final response = await model.generateContent(prompt);

      return Success(response: response);
    } catch (e) {
      return Failure(response: 'Fail to get AI response: $e.');
    }
  }
}
