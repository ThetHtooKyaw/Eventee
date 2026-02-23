import 'package:eventee/src/admin/model/event.dart';

class BookingModel {
  final String eventId;
  final String eventImage;
  final String eventName;
  final DateTime eventDate;
  final String eventLocation;
  final double ticketPrice;
  final String eventDetail;
  final double totalAmount;
  final int quantity;

  const BookingModel({
    required this.eventId,
    required this.eventImage,
    required this.eventDate,
    required this.eventLocation,
    required this.eventName,
    required this.ticketPrice,
    required this.eventDetail,
    required this.totalAmount,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'eventImage': eventImage,
      'eventName': eventName,
      'eventDate': eventDate.toIso8601String(),
      'eventLocation': eventLocation,
      'ticketPrice': ticketPrice,
      'eventDetail': eventDetail,
      'totalAmount': totalAmount,
      'quantity': quantity,
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      eventId: map['eventId'] ?? '',
      eventImage: map['eventImage'] ?? '',
      eventName: map['eventName'] ?? 'Unnamed Event',
      eventDate: DateTime.tryParse(map['eventDate'] ?? '') ?? DateTime.now(),
      eventLocation: map['eventLocation'] ?? '',
      ticketPrice: double.tryParse(map['ticketPrice']?.toString() ?? '0') ?? 0,
      eventDetail: map['eventDetail'] ?? '',
      totalAmount: double.tryParse(map['totalAmount']?.toString() ?? '0') ?? 0,
      quantity: int.tryParse(map['quantity']?.toString() ?? '0') ?? 0,
    );
  }

  factory BookingModel.fromEvent({
    required EventModel event,
    required double totalAmount,
    required int quantity,
  }) {
    return BookingModel(
      eventId: event.eventId,
      eventImage: event.eventImage,
      eventName: event.eventName,
      eventDate: event.eventDate,
      eventLocation: event.eventLocation,
      ticketPrice: event.ticketPrice,
      eventDetail: event.eventDetail,
      totalAmount: totalAmount,
      quantity: quantity,
    );
  }

}
