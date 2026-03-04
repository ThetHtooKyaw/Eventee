import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:eventee/src/booking/models/event_history.dart';
import 'package:eventee/src/booking/models/booking.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class BookingService {
  final _firestore = FirebaseFirestore.instance;
  final _functions = FirebaseFunctions.instance;
  final _auth = FirebaseAuth.instance;

  static const platform = MethodChannel('com.example.eventee/calendar');

  CollectionReference get _usersCollection => _firestore.collection('users');

  CollectionReference _userBookings(String uid) =>
      _usersCollection.doc(uid).collection('bookings');

  Future<Object> fetchBookingHistory() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return Failure(response: 'User not logged in');

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

  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _userBookings(
        user.uid,
      ).doc(bookingId).update({'status': newStatus});
    } catch (e) {
      debugPrint(
        "Background Sync Error: Failed to update booking $bookingId: $e",
      );
    }
  }

  Future<Object> makePayment({required BookingModel bookedEvent}) async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        return Failure(response: 'User not logged in!');
      }

      // The Handshake (Cloud Function)
      final int amount = (bookedEvent.total * 100).toInt();
      final HttpsCallable callable = _functions.httpsCallable(
        'createPaymentIntent',
      );
      final result = await callable.call(<String, dynamic>{
        'amount': amount,
        'currency': 'thb',
        'email': user.email,
      });

      if (result.data == null) {
        return Failure(response: 'Cloud function returned null');
      }

      final data = Map<String, dynamic>.from(result.data as dynamic);
      final clientSecret = data['clientSecret'];

      if (clientSecret == null) {
        return Failure(response: 'Client secret missing from server response');
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
        return Failure(
          response:
              'PAYMENT SUCCESSFUL, but saving failed: ${saveResult.response}. Please contact support.',
        );
      }

      // Add Event to Calendar
      await _sendToCalendar(bookedEvent: bookedEvent);

      return Success(response: 'Make payment successfully!');
    } on FirebaseFunctionsException catch (e) {
      return Failure(response: 'Cloud function error: ${e.message}');
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        return Failure(response: 'Payment cancelled by user.');
      }

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

      final saveBooking = EventHistoryModel.fromBooking(
        userId: user.uid,
        bookingId: newBookingRef.id,
        bookedEvent: bookedEvent,
        bookedAt: DateTime.now(),
      );

      await newBookingRef.set(saveBooking.toMap());

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
}
