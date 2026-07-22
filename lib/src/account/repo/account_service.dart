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

  String get _currentUserId {
    final user = _auth.currentUser;

    if (user == null) {
      throw 'No authenticated user found.';
    }

    return user.uid;
  }

  Future<Object> getUser() async {
    try {
      final userData = _currentUserId;

      DocumentSnapshot snapshot = await _usersCollection.doc(userData).get();

      if (!snapshot.exists) {
        return Failure(response: 'User data not found.');
      }

      final user = AppUser.fromMap(snapshot.data() as Map<String, dynamic>);

      return Success(response: user);
    } catch (e) {
      return Failure(response: 'Failed to fetch user data: $e.');
    }
  }

  Future<Object> pickProfileImage() async {
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

  Future<Object> updateProfileImage({required File profileFile}) async {
    try {
      final userData = _currentUserId;

      final ref = _storage.ref().child('profile_images/$userData.jpg');

      final snapshot = await ref.putFile(profileFile);
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await _usersCollection.doc(userData).update({'photoUrl': downloadUrl});

      return Success(response: 'Profile image updated successfully!');
    } catch (e) {
      return Failure(response: 'Failed to update profile image: $e');
    }
  }

  Future<Object> updateUsername({required String newUsername}) async {
    try {
      final userData = _currentUserId;
      await _usersCollection.doc(userData).update({'username': newUsername});
      return Success(response: 'Username updated successfully!');
    } catch (e) {
      return Failure(response: 'Failed to update username: $e');
    }
  }

  Future<Object> updatePhoneNumber({required String newPhoneNumber}) async {
    try {
      final userData = _currentUserId;
      await _usersCollection.doc(userData).update({
        'phoneNumber': newPhoneNumber,
      });
      return Success(response: 'Phone number updated successfully!');
    } catch (e) {
      return Failure(response: 'Failed to update phone number: $e');
    }
  }

  Future<Object> updateDateOfBirth({required DateTime newDateOfBirth}) async {
    try {
      final userData = _currentUserId;
      await _usersCollection.doc(userData).update({
        'dateOfBirth': newDateOfBirth,
      });
      return Success(response: 'Date of birth updated successfully!');
    } catch (e) {
      return Failure(response: 'Failed to update date of birth: $e');
    }
  }

  Future<Object> updateLocation({required String newLocation}) async {
    try {
      final userData = _currentUserId;
      await _usersCollection.doc(userData).update({'location': newLocation});
      return Success(response: 'Location updated successfully!');
    } catch (e) {
      return Failure(response: 'Failed to update location: $e');
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
