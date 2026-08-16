import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventee/src/event/model/booking.dart';

class EventHistoryModel {
  final String uid;
  final String organizerId;
  final String bookingId;
  final String eventId;
  final String imageUrl;
  final String title;
  final String organization;
  final String organizer;
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
    required this.uid,
    required this.organizerId,
    required this.bookingId,
    required this.eventId,
    required this.imageUrl,
    required this.location,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.title,
    required this.organization,
    required this.organizer,
    required this.price,
    required this.description,
    required this.total,
    required this.quantity,
    required this.status,
    required this.bookedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'organizerId': organizerId,
      'bookingId': bookingId,
      'eventId': eventId,
      'imageUrl': imageUrl,
      'title': title,
      'organization': organization,
      'organizer': organizer,
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
      uid: map['uid'] ?? '',
      organizerId: map['organizerId'] ?? '',
      bookingId: map['bookingId'] ?? '',
      eventId: map['eventId'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      title: map['title'] ?? 'Unnamed Event',
      organization: map['organization'] ?? '',
      organizer: map['organizer'] ?? '',
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
    required String uid,
    required String bookingId,
    required BookingModel bookedEvent,
    required DateTime bookedAt,
  }) {
    return EventHistoryModel(
      uid: uid,
      organizerId: bookedEvent.organizerId,
      bookingId: bookingId,
      eventId: bookedEvent.eventId,
      imageUrl: bookedEvent.imageUrl,
      title: bookedEvent.title,
      organization: bookedEvent.organization,
      organizer: bookedEvent.organizer,
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
