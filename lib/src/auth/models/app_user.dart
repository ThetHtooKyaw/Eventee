import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String username;
  final String email;
  final String phoneNumber;
  final String photoUrl;
  final String address;
  final DateTime createdAt;

  const AppUser({
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.photoUrl,
    required this.address,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'address': address,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      username: map['username'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      photoUrl: map['photoUrl'],
      address: map['address'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
