import 'dart:io';

import 'package:equatable/equatable.dart';

class UploadEventParams extends Equatable {
  final File eventImage;
  final String eventName;
  final DateTime eventDate;
  final String eventLocation;
  final double ticketPrice;
  final String eventDetail;

  const UploadEventParams({
    required this.eventImage,
    required this.eventName,
    required this.eventDate,
    required this.eventLocation,
    required this.ticketPrice,
    required this.eventDetail,
  });

  @override
  List<Object?> get props => [
    eventImage,
    eventDate,
    eventLocation,
    eventName,
    ticketPrice,
    eventDetail,
  ];
}
