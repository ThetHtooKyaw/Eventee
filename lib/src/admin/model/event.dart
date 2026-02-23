class EventModel {
  final String eventId;
  final String eventImage;
  final String eventName;
  final DateTime eventDate;
  final String eventLocation;
  final double ticketPrice;
  final String eventDetail;
  final String eventCategory;

  const EventModel({
    required this.eventId,
    required this.eventImage,
    required this.eventDate,
    required this.eventLocation,
    required this.eventName,
    required this.ticketPrice,
    required this.eventDetail,
    required this.eventCategory,
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
      'eventCategory': eventCategory,
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      eventId: map['eventId'] ?? '',
      eventImage: map['eventImage'] ?? '',
      eventName: map['eventName'] ?? 'Unnamed Event',
      eventDate: DateTime.tryParse(map['eventDate'] ?? '') ?? DateTime.now(),
      eventLocation: map['eventLocation'] ?? '',
      ticketPrice: double.tryParse(map['ticketPrice']?.toString() ?? '0') ?? 0,
      eventDetail: map['eventDetail'] ?? '',
      eventCategory: map['eventCategory'] ?? '',
    );
  }
}
