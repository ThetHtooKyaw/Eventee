import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String photoUrl;
  final String username;
  final String email;
  final String phoneNumber;
  final DateTime? dateOfBirth;
  final String address;
  final DateTime createdAt;

  const AppUser({
    required this.photoUrl,
    required this.username,
    required this.email,
    required this.phoneNumber,
    this.dateOfBirth,
    required this.address,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'photoUrl': photoUrl,
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth != null
          ? Timestamp.fromDate(dateOfBirth!)
          : null,
      'address': address,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      photoUrl: map['photoUrl'],
      username: map['username'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      dateOfBirth: (map['dateOfBirth'] as Timestamp).toDate(),
      address: map['address'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  String get shortAddress {
    if (address.isEmpty) return 'Unknown Location';

    final parts = address.split(',').map((e) => e.trim()).toList();
    if (parts.length >= 2) {
      return '${parts[parts.length - 2]}, ${parts.last}';
    }
    return address;
  }
}
