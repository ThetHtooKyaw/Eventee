class EventHistoryModel {
  final String userId;
  final String eventId;
  final String eventImage;
  final String eventName;
  final DateTime eventDate;
  final String eventLocation;
  final double ticketPrice;
  final double totalAmount;
  final int quantity;

  const EventHistoryModel({
    required this.userId,
    required this.eventId,
    required this.eventImage,
    required this.eventDate,
    required this.eventLocation,
    required this.eventName,
    required this.ticketPrice,
    required this.totalAmount,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'eventId': eventId,
      'eventImage': eventImage,
      'eventName': eventName,
      'eventDate': eventDate.toIso8601String(),
      'eventLocation': eventLocation,
      'ticketPrice': ticketPrice,
      'totalAmount': totalAmount,
      'quantity': quantity,
    };
  }

  factory EventHistoryModel.fromMap(Map<String, dynamic> map) {
    return EventHistoryModel(
      userId: map['userId'],
      eventId: map['eventId'] ?? '',
      eventImage: map['eventImage'] ?? '',
      eventName: map['eventName'] ?? 'Unnamed Event',
      eventDate: DateTime.tryParse(map['eventDate'] ?? '') ?? DateTime.now(),
      eventLocation: map['eventLocation'] ?? '',
      ticketPrice: double.tryParse(map['ticketPrice']?.toString() ?? '0') ?? 0,
      totalAmount: double.tryParse(map['totalAmount']?.toString() ?? '0') ?? 0,
      quantity: int.tryParse(map['quantity']?.toString() ?? '0') ?? 0,
    );
  }
}
