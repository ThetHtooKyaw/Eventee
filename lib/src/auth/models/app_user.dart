import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String stripeAccountId;
  final String photoUrl;
  final String username;
  final String email;
  final String phoneNumber;
  final DateTime? dateOfBirth;
  final String address;

  const AppUser({
    required this.uid,
    required this.stripeAccountId,
    required this.photoUrl,
    required this.username,
    required this.email,
    required this.phoneNumber,
    this.dateOfBirth,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'stripeAccountId': stripeAccountId,
      'photoUrl': photoUrl,
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth != null
          ? Timestamp.fromDate(dateOfBirth!)
          : null,
      'address': address,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'],
      stripeAccountId: map['stripeAccountId'],
      photoUrl: map['photoUrl'],
      username: map['username'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      dateOfBirth: map['dateOfBirth'] != null
          ? (map['dateOfBirth'] as Timestamp).toDate()
          : null,
      address: map['address'],
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
