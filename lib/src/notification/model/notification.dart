class NotificationModel {
  final String uid;
  final String eventId;
  final String title;
  final String message;
  final String status;
  final DateTime timestamp;
  final bool isRead;

  const NotificationModel({
    required this.uid,
    required this.eventId,
    required this.title,
    required this.message,
    required this.status,
    required this.timestamp,
    required this.isRead,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'eventId': eventId,
      'title': title,
      'message': message,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      uid: map['uid'] ?? '',
      eventId: map['eventId'] ?? '',
      title: map['title'] ?? 'No Title',
      message: map['message'] ?? 'No Message',
      status: map['status'] ?? '',
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      isRead: map['isRead'] ?? false,
    );
  }
}
