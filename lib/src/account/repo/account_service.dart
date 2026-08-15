import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:eventee/src/auth/models/app_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AccountService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _imagePicker = ImagePicker();

  CollectionReference get _usersCollection => _firestore.collection('users');

  Future<Object> getUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      return Failure(response: 'No authenticated user found.');
    }

    try {
      DocumentSnapshot snapshot = await _usersCollection.doc(user.uid).get();

      if (!snapshot.exists) {
        return Failure(response: 'User data not found.');
      }

      final appUser = AppUser.fromMap(snapshot.data() as Map<String, dynamic>);

      return Success(response: appUser);
    } catch (e) {
      return Failure(response: 'Failed to fetch user data: $e.');
    }
  }

  Future<Object> pickProfileAvatar() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 1024,
        maxWidth: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        return Failure(response: 'No image selected.');
      }

      return Success(response: File(pickedFile.path));
    } catch (e) {
      return Failure(response: 'Failed to pick profile image: $e');
    }
  }

  Future<Object> updateProfileAvatar({required File profileFile}) async {
    final user = _auth.currentUser;
    if (user == null) {
      return Failure(
        response: 'You must be logged in to update profile avatar.',
      );
    }

    try {
      final ref = _storage.ref().child('profile_images/${user.uid}.jpg');
      final snapshot = await ref.putFile(profileFile);
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await _usersCollection.doc(user.uid).update({'photoUrl': downloadUrl});

      return Success(response: 'Profile image updated successfully!');
    } catch (e) {
      return Failure(response: 'Failed to update profile image: $e');
    }
  }

  Future<Object> updateUsername({required String newUsername}) async {
    final user = _auth.currentUser;
    if (user == null) {
      return Failure(response: 'You must be logged in to update username.');
    }

    try {
      await _usersCollection.doc(user.uid).update({'username': newUsername});
      return Success(response: 'Username updated successfully!');
    } catch (e) {
      return Failure(response: 'Failed to update username: $e');
    }
  }

  Future<Object> updatePhoneNumber({required String newPhoneNumber}) async {
    final user = _auth.currentUser;
    if (user == null) {
      return Failure(response: 'You must be logged in to update phone number.');
    }

    try {
      await _usersCollection.doc(user.uid).update({
        'phoneNumber': newPhoneNumber,
      });
      return Success(response: 'Phone number updated successfully!');
    } catch (e) {
      return Failure(response: 'Failed to update phone number: $e');
    }
  }

  Future<Object> updateDateOfBirth({required DateTime newDateOfBirth}) async {
    final user = _auth.currentUser;
    if (user == null) {
      return Failure(
        response: 'You must be logged in to update date of birth.',
      );
    }

    try {
      await _usersCollection.doc(user.uid).update({
        'dateOfBirth': newDateOfBirth,
      });
      return Success(response: 'Date of birth updated successfully!');
    } catch (e) {
      return Failure(response: 'Failed to update date of birth: $e');
    }
  }

  Future<Object> updateAddress({required String newAddress}) async {
    final user = _auth.currentUser;
    if (user == null) {
      return Failure(response: 'You must be logged in to update address.');
    }

    try {
      await _usersCollection.doc(user.uid).update({'address': newAddress});
      return Success(response: 'Address updated successfully!');
    } catch (e) {
      return Failure(response: 'Failed to update address: $e');
    }
  }

  Future<Object?> logoutUser() async {
    try {
      await _auth.signOut();
      return Success(response: 'User logged out successfully!');
    } on FirebaseAuthException catch (e) {
      return Failure(
        response: 'FirebaseAuthException: ${e.code} - ${e.message}',
      );
    } catch (e) {
      return Failure(response: 'Failed to logout user: $e.');
    }
  }
}
