class EventModel {
  final String id;
  final String imageUrl;
  final String title;
  final String location;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final double price;
  final String description;
  final String category;

  const EventModel({
    required this.id,
    required this.imageUrl,
    required this.location,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
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
      'category': category,
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      title: map['title'] ?? 'Unnamed Event',
      location: map['location'] ?? '',
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      startTime: DateTime.tryParse(map['startTime'] ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(map['endTime'] ?? '') ?? DateTime.now(),
      price: double.tryParse(map['price']?.toString() ?? '0') ?? 0,
      description: map['description'] ?? '',
      category: map['category'] ?? '',
    );
  }
}
