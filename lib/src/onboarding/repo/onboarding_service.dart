import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _imagePicker = ImagePicker();

  CollectionReference get _usersCollection => _firestore.collection('users');

  User? get _currentUser => _auth.currentUser;

  Future<Object> fetchCurrentProfileAvatar() async {
    final user = _currentUser;
    if (user == null) {
      return Success(response: '');
    }

    try {
      final snapshot = await _usersCollection.doc(user.uid).get();
      final data = snapshot.data() as Map<String, dynamic>;
      final profileAvatar = data['photoUrl'] as String?;

      return Success(response: profileAvatar ?? '');
    } catch (e) {
      return Failure(response: 'Failed to fetch current profile avatar: $e');
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

  Future<Object> submitOnboardingData({
    File? profileFile,
    String? existingPhotoUrl,
    required DateTime dateOfBirth,
    required String phoneNumber,
    required String address,
  }) async {
    final user = _currentUser;
    if (user == null) {
      return Failure(
        response: 'You must be logged in to submit onboarding data.',
      );
    }

    try {
      String? downloadUrl;

      if (profileFile != null) {
        final ref = _storage.ref().child('profile_images/${user.uid}.jpg');
        final snapshot = await ref.putFile(profileFile);
        downloadUrl = await snapshot.ref.getDownloadURL();
      }

      await _usersCollection.doc(user.uid).update({
        'photoUrl': downloadUrl ?? existingPhotoUrl ?? '',
        'dateOfBirth': dateOfBirth,
        'phoneNumber': phoneNumber,
        'address': address,
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboardingComplete', true);

      return Success(response: 'Onboarding data created successfully!');
    } catch (e) {
      return Failure(response: 'Failed to create onboarding data: $e');
    }
  }
}
