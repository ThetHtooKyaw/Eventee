import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventee/src/booking/models/booking.dart';

class EventHistoryModel {
  final String userId;
  final String bookingId;
  final String eventId;
  final String imageUrl;
  final String title;
  final String location;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final double price;
  final String description;
  final double total;
  final int quantity;
  final String status;
  final DateTime bookedAt;

  const EventHistoryModel({
    required this.userId,
    required this.bookingId,
    required this.eventId,
    required this.imageUrl,
    required this.location,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.title,
    required this.price,
    required this.description,
    required this.total,
    required this.quantity,
    required this.status,
    required this.bookedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'bookingId': bookingId,
      'eventId': eventId,
      'imageUrl': imageUrl,
      'title': title,
      'location': location,
      'date': date.toIso8601String(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'price': price,
      'description': description,
      'total': total,
      'quantity': quantity,
      'status': status,
      'bookedAt': FieldValue.serverTimestamp(),
    };
  }

  factory EventHistoryModel.fromMap(Map<String, dynamic> map) {
    return EventHistoryModel(
      userId: map['userId'],
      bookingId: map['bookingId'] ?? '',
      eventId: map['eventId'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      title: map['title'] ?? 'Unnamed Event',
      location: map['location'] ?? '',
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      startTime: DateTime.tryParse(map['startTime'] ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(map['endTime'] ?? '') ?? DateTime.now(),
      price: double.tryParse(map['price']?.toString() ?? '0') ?? 0,
      description: map['description'] ?? '',
      total: double.tryParse(map['total']?.toString() ?? '0') ?? 0,
      quantity: int.tryParse(map['quantity']?.toString() ?? '0') ?? 0,
      status: map['status'] ?? 'unknown',
      bookedAt: (map['bookedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory EventHistoryModel.fromBooking({
    required String userId,
    required String bookingId,
    required BookingModel bookedEvent,
    required DateTime bookedAt,
  }) {
    return EventHistoryModel(
      userId: userId,
      bookingId: bookingId,
      eventId: bookedEvent.id,
      imageUrl: bookedEvent.imageUrl,
      title: bookedEvent.title,
      location: bookedEvent.location,
      date: bookedEvent.date,
      startTime: bookedEvent.startTime,
      endTime: bookedEvent.endTime,
      price: bookedEvent.price,
      description: bookedEvent.description,
      total: bookedEvent.total,
      quantity: bookedEvent.quantity,
      status: bookedEvent.status,
      bookedAt: bookedAt,
    );
  }
}
