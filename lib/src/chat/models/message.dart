import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String senderId;
  final String text;
  final DateTime date;
  final bool isSentByMe;
  final bool isLoading;

  const Message({
    required this.senderId,
    required this.text,
    required this.date,
    required this.isSentByMe,
    this.isLoading = false,
  });

  @override
  List<Object> get props => [senderId, text, senderId, isSentByMe];
}
