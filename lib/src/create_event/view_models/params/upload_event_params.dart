import 'dart:io';

import 'package:equatable/equatable.dart';

class UploadEventParams extends Equatable {
  final File imageUrl;
  final String title;
  final String location;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final double price;
  final String description;
  final String category;

  const UploadEventParams({
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.price,
    required this.description,
    required this.category,
  });

  @override
  List<Object?> get props => [
    imageUrl,
    location,
    date,
    startTime,
    endTime,
    title,
    price,
    description,
    category,
  ];
}
