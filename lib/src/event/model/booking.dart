import 'package:eventee/src/event/model/event.dart';

class BookingModel {
  final String id;
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

  const BookingModel({
    required this.id,
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
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
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
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'] ?? '',
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
    );
  }

  factory BookingModel.fromEvent({
    required EventModel event,
    required double total,
    required int quantity,
    required String status,
  }) {
    return BookingModel(
      id: event.id,
      imageUrl: event.imageUrl,
      title: event.title,
      location: event.location,
      date: event.date,
      startTime: event.startTime,
      endTime: event.endTime,
      price: event.price,
      description: event.description,
      total: total,
      quantity: quantity,
      status: status,
    );
  }
}
