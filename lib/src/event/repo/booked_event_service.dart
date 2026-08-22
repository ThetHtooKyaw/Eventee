import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:eventee/src/event/model/event_history.dart';
import 'package:eventee/src/event/model/booking.dart';
import 'package:eventee/src/notification/model/notification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:intl/intl.dart';

class BookedEventService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _functions = FirebaseFunctions.instanceFor(region: 'asia-southeast1');

  static const platform = MethodChannel('com.example.eventee/calendar');

  CollectionReference get _usersCollection => _firestore.collection('users');

  CollectionReference _userBookings(String uid) =>
      _usersCollection.doc(uid).collection('bookings');

  CollectionReference _userNotifications(String uid) =>
      _usersCollection.doc(uid).collection('notifications');

  Future<Object> fetchBookingHistory() async {
    final user = _auth.currentUser;
    if (user == null) {
      return Success(response: Stream.value(<String>{}));
    }

    try {
      final stream = _userBookings(
        user.uid,
      ).orderBy('bookedAt', descending: true).snapshots();

      Stream<List<EventHistoryModel>> eventStrean = stream.map(
        (snapshot) => snapshot.docs
            .map(
              (doc) =>
                  EventHistoryModel.fromMap(doc.data() as Map<String, dynamic>),
            )
            .toList(),
      );

      return Success(response: eventStrean);
    } catch (e) {
      return Failure(response: 'Failed to fetch events');
    }
  }

  Future<Object> updateBookingStatus(String bookingId, String newStatus) async {
    final user = _auth.currentUser;
    if (user == null) {
      return Failure(
        response: 'You must be logged in to update booking status.',
      );
    }

    try {
      await _userBookings(
        user.uid,
      ).doc(bookingId).update({'status': newStatus});

      return Success(response: true);
    } catch (e) {
      return Failure(response: 'Failed to update booking status: $e');
    }
  }

  Future<Object> makePayment({required BookingModel bookedEvent}) async {
    final user = _auth.currentUser;
    if (user == null) {
      return Failure(response: 'You must be logged in to make payments.');
    }

    try {
      // The Handshake (Cloud Function)
      final int amount = (bookedEvent.total * 100).toInt();
      final callable = _functions.httpsCallable('createPaymentIntent');
      final result = await callable.call(<String, dynamic>{
        'organizerId': bookedEvent.organizerId,
        'email': user.email,
        'amount': amount,
        'currency': 'thb',
      });

      if (result.data == null) {
        return Failure(response: 'Cloud function returned null');
      }

      final data = Map<String, dynamic>.from(result.data as dynamic);
      final clientSecret = data['clientSecret'] as String?;

      if (clientSecret == null) {
        return Failure(
          response: 'Client secret missing or invalid from server response',
        );
      }

      // The Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Eventee Shop',
          style: ThemeMode.light,
        ),
      );
      await Stripe.instance.presentPaymentSheet();

      // Save Booking to Firestore
      final saveResult = await _saveBooking(
        user: user,
        bookedEvent: bookedEvent,
      );

      if (saveResult is Failure) {
        await _sendFailurePushNotification(
          userId: user.uid,
          eventId: bookedEvent.eventId,
          eventTitle: bookedEvent.title,
          message:
              'Payment went through, but ticket verification failed. Please contact support.',
        );

        return Failure(
          response:
              'PAYMENT SUCCESSFUL, but saving failed: ${saveResult.response}. Please contact support.',
        );
      }

      await _sendPushNotification(
        userId: user.uid,
        title: 'Booking Confirmed',
        message: 'Your booking for ${bookedEvent.title} has been confirmed.',
      );

      // Add Event to Calendar
      await _sendToCalendar(bookedEvent: bookedEvent);

      return Success(response: 'Ticket purchased successfully!');
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Cloud function error: ${e.message}');
      return Failure(response: 'Cloud function error: ${e.message}');
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        return Failure(response: 'Payment cancelled by user.');
      }

      await _sendFailurePushNotification(
        userId: user.uid,
        eventId: bookedEvent.eventId,
        eventTitle: bookedEvent.title,
        message:
            e.error.localizedMessage ??
            'Card was declined or transaction timed out.',
      );

      return Failure(response: 'Payment failed: ${e.error.localizedMessage}');
    } catch (e) {
      return Failure(response: 'System error: $e.');
    }
  }

  Future<Object> _saveBooking({
    required User user,
    required BookingModel bookedEvent,
  }) async {
    try {
      final newBookingRef = _userBookings(user.uid).doc();
      final newNotificationRef = _userNotifications(user.uid).doc();

      final saveBooking = EventHistoryModel.fromBooking(
        uid: user.uid,
        bookingId: newBookingRef.id,
        bookedEvent: bookedEvent,
        bookedAt: DateTime.now(),
      );

      final saveNotification = NotificationModel.fromMap({
        'uid': user.uid,
        'eventId': bookedEvent.eventId,
        'title': 'Booking Confirmed',
        'message':
            'Your booking for ${bookedEvent.title} on ${DateFormat('dd MMM, yyyy').format(bookedEvent.date)} has been confirmed.',
        'status': 'success',
        'timestamp': DateTime.now().toIso8601String(),
        'isRead': false,
      });

      await newBookingRef.set(saveBooking.toMap());
      await newNotificationRef.set(saveNotification.toMap());

      return Success(response: 'Booking saved successfully');
    } catch (e) {
      return Failure(response: 'failed to save booking: $e');
    }
  }

  Future<void> _sendToCalendar({required BookingModel bookedEvent}) async {
    try {
      await platform.invokeMethod('addToCalendar', {
        'title': bookedEvent.title,
        'description': bookedEvent.description,
        'startTime': bookedEvent.date.millisecondsSinceEpoch,
        'endTime': bookedEvent.endTime.millisecondsSinceEpoch,
      });
    } on PlatformException catch (e) {
      debugPrint("Native error: ${e.message}");
    } catch (e) {
      debugPrint("Failed to send event to calendar: ${e.toString()}");
    }
  }

  Future<void> _sendFailurePushNotification({
    required String userId,
    required String eventId,
    required String eventTitle,
    required String message,
  }) async {
    try {
      final newNotificationRef = _userNotifications(userId).doc();

      final saveNotification = NotificationModel.fromMap({
        'uid': userId,
        'eventId': eventId,
        'title': 'Booking Failed',
        'message': 'Your booking for $eventTitle failed. Reason: $message',
        'status': 'failure',
        'timestamp': DateTime.now().toIso8601String(),
        'isRead': false,
      });

      await newNotificationRef.set(saveNotification.toMap());

      await _sendPushNotification(
        userId: userId,
        title: 'Booking Failed',
        message: 'Your booking for $eventTitle was not successful.',
      );
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Cloud function error: ${e.message}');
    } catch (e) {
      debugPrint('Failed to send push notification: $e');
    }
  }

  Future<void> _sendPushNotification({
    required String userId,
    required String title,
    required String message,
  }) async {
    try {
      final pushCallable = _functions.httpsCallable(
        'sendBookingPushNotification',
      );
      await pushCallable.call(<String, dynamic>{
        'userId': userId,
        'title': title,
        'message': message,
        'channelId': 'booking_channel_id',
      });
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Cloud function error: ${e.message}');
    } catch (e) {
      debugPrint('Failed to send push notification: $e');
    }
  }
}
