class EventHistoryModel {
  final String userId;
  final String eventImage;
  final String eventName;
  final DateTime eventDate;
  final String eventLocation;
  final double ticketPrice;
  final double totalAmount;
  final int quantity;

  const EventHistoryModel({
    required this.userId,
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
      eventImage: map['eventImage'],
      eventName: map['eventName'],
      eventDate: DateTime.parse(map['eventDate']),
      eventLocation: map['eventLocation'],
      ticketPrice: map['ticketPrice'],
      totalAmount: map['totalAmount'],
      quantity: map['quantity'],
    );
  }
}
