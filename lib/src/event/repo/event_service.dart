import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:eventee/src/event/model/event.dart';

class EventService {
  final _firestore = FirebaseFirestore.instance;

  CollectionReference get _eventsCollection => _firestore.collection('events');

  Future<Object> fetchAllEvents() async {
    try {
      Stream<List<EventModel>> stream = _eventsCollection.snapshots().map(
        (snapshot) => snapshot.docs
            .map(
              (doc) => EventModel.fromMap(doc.data() as Map<String, dynamic>),
            )
            .toList(),
      );

      return Success(response: stream);
    } catch (e) {
      return Failure(response: 'Fails to fetch all events: $e.');
    }
  }
}
