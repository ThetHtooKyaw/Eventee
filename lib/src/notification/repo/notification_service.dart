import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:eventee/src/notification/model/notification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _messaging = FirebaseMessaging.instance;

  CollectionReference get _usersCollection => _firestore.collection('users');

  CollectionReference _userNotifications(String uid) =>
      _usersCollection.doc(uid).collection('notifications');

  Future<Object> requestNotificationPermission() async {
    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        return Failure(response: 'Notification permission denied.');
      }

      return Success(response: 'Notification permission grantedz!');
    } catch (e) {
      return Failure(
        response: 'Failed to request notification permission: $e.',
      );
    }
  }

  Future<Object> fetchAllEvents() async {
    final user = _auth.currentUser;
    if (user == null) {
      return Failure(response: 'You must be logged in to view notifications.');
    }

    try {
      Stream<List<NotificationModel>>
      stream = _userNotifications(user.uid).snapshots().map(
        (snapshot) => snapshot.docs
            .map(
              (doc) =>
                  NotificationModel.fromMap(doc.data() as Map<String, dynamic>),
            )
            .toList(),
      );

      return Success(response: stream);
    } catch (e) {
      return Failure(response: 'Fails to fetch all notifications: $e.');
    }
  }
}
