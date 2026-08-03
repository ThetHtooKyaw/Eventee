import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavouriteService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  CollectionReference get _userCollection => _firestore.collection('users');

  CollectionReference _userFavourites(String uid) =>
      _userCollection.doc(uid).collection('favourites');

  User? get _currentUser => _auth.currentUser;

  Future<Object> fetchFavouritedEventId() async {
    final user = _currentUser;
    if (user == null) {
      return Success(response: Stream.value(<String>{}));
    }

    try {
      final snapshots = _userFavourites(user.uid).snapshots();

      final idStream = snapshots.map(
        (snapshot) => snapshot.docs.map((doc) => doc.id).toSet(),
      );

      return Success(response: idStream);
    } catch (e) {
      return Failure(response: 'Failed to fetch favourited event IDs.');
    }
  }

  Future<Object> addFavourite(String eventId) async {
    final user = _currentUser;
    if (user == null) {
      return Failure(response: 'You must be logged in to add favourites.');
    }

    try {
      await _userFavourites(
        user.uid,
      ).doc(eventId).set({'favoritedAt': FieldValue.serverTimestamp()});
      return Success(response: true);
    } catch (e) {
      return Failure(response: 'Failed to add favourite.');
    }
  }

  Future<Object> removeFavourite(String eventId) async {
    final user = _currentUser;
    if (user == null) {
      return Failure(response: 'You must be logged in to remove favourites.');
    }
    
    try {
      await _userFavourites(user.uid).doc(eventId).delete();
      return Success(response: true);
    } catch (e) {
      return Failure(response: 'Failed to remove favourite.');
    }
  }
}
