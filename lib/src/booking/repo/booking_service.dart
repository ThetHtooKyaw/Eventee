import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:eventee/src/admin/model/event.dart';
import 'package:eventee/src/admin/model/event_history.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class BookingService {
  final _firestore = FirebaseFirestore.instance;
  final _functions = FirebaseFunctions.instance;
  final _auth = FirebaseAuth.instance;

  CollectionReference get _usersCollection => _firestore.collection('users');

  CollectionReference _userBookings(String uid) =>
      _usersCollection.doc(uid).collection('bookings');

  Future<Object> fetchBookingHistory() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return Failure(response: 'User not logged in');

      return _userBookings(
        user.uid,
      ).orderBy('bookedAt', descending: true).snapshots().map((snapshot) {
        final events = snapshot.docs.map((doc) {
          return EventHistoryModel.fromMap(doc.data() as Map<String, dynamic>);
        }).toList();
        return Success(response: events);
      });
    } catch (e) {
      return Failure(response: 'Failed to fetch events');
    }
  }

  Future<Object> makePayment({
    required EventModel event,
    required double amount,
    required int quantity,
  }) async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        return Failure(response: 'User not logged in!');
      }

      final int amountInSatang = (amount * 100).toInt();

      final result = await _functions.httpsCallable('createPaymentIntent').call(
        {'amount': amountInSatang, 'currency': 'thb'},
      );

      final clientSecret = result.data['clientSecret'];

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Eventee Shop',
          style: ThemeMode.light,
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      // Atomic Operation
      WriteBatch batch = _firestore.batch();

      // Update User Document
      DocumentReference newBookingRef = _userBookings(user.uid).doc();
      batch.update(_usersCollection.doc(user.uid), {
        'hasTicket': true,
        'lastPayment': FieldValue.serverTimestamp(),
      });

      // Create Booked Event Document
      final bookedEvent = EventHistoryModel(
        userId: user.uid,
        eventId: event.eventId,
        eventImage: event.eventImage,
        eventDate: event.eventDate,
        eventLocation: event.eventLocation,
        eventName: event.eventName,
        ticketPrice: event.ticketPrice,
        totalAmount: amount,
        quantity: quantity,
      );

      batch.set(newBookingRef, {
        ...bookedEvent.toMap(),
        'bookingId': newBookingRef.id,
        'bookedAt': FieldValue.serverTimestamp(),
        'status': 'paid',
      });

      await batch.commit();

      return Success(response: 'Make payment successfully!');
    } catch (e) {
      return Failure(response: 'Failed to make payment: $e.');
    }
  }
}
