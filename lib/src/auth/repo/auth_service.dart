import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:eventee/src/auth/models/app_user.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  CollectionReference get _usersCollection => _firestore.collection('users');

  Future<Object> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      return Success(response: 'User logged in successfully!');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        return Failure(
          response: 'Invalid email or password. Please try again.',
        );
      }

      return Failure(response: e.message ?? 'An unknown error occurred.');
    } catch (e) {
      return Failure(response: 'Failed to login user: $e.');
    }
  }

  Future<Object> signUpUser({
    required String username,
    required String email,
    required String password,
    required bool tosPrivacyAccepted,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      final newUser = AppUser(
        uid: userCredential.user!.uid,
        stripeAccountId: '',
        username: username,
        email: email,
        photoUrl: '',
        phoneNumber: '',
        address: '',
        dateOfBirth: null,
        tosPrivacyAccepted: tosPrivacyAccepted,
      );

      await _usersCollection.doc(userCredential.user!.uid).set(newUser.toMap());

      return Success(response: 'User signed up successfully!');
    } on FirebaseAuthException catch (e) {
      return Failure(
        response: 'FirebaseAuthException: ${e.code} - ${e.message}',
      );
    } catch (e) {
      return Failure(response: 'Failed to sign up user: $e');
    }
  }

  Future<Object> authenticateWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return Failure(response: 'Google authentication was cancelled.');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        return Failure(
          response: 'Account setup could not be completed. Please try again.',
        );
      }

      final userDoc = await _usersCollection.doc(user.uid).get();
      final isNewUser = !userDoc.exists;

      // Check user is new user
      if (!userDoc.exists) {
        String? downloadUrl;

        if (user.photoURL != null && user.photoURL!.isNotEmpty) {
          final response = await http.get(Uri.parse(user.photoURL!));
          if (response.statusCode == 200) {
            final ref = _storage.ref().child('profile_images/${user.uid}.jpg');
            final snapshot = await ref.putData(response.bodyBytes);
            downloadUrl = await snapshot.ref.getDownloadURL();
          }
        }

        final newUser = AppUser(
          uid: user.uid,
          stripeAccountId: '',
          username: user.displayName ?? '',
          email: user.email ?? '',
          photoUrl: downloadUrl ?? '',
          phoneNumber: '',
          address: '',
          dateOfBirth: null,
        );

        await _usersCollection.doc(user.uid).set(newUser.toMap());
      }

      return Success(
        response: {
          'message': 'User authenticated with Google successfully!',
          'isNewUser': isNewUser,
        },
      );
    } catch (e) {
      return Failure(response: 'Failed to authenticate with Google: $e');
    }
  }
}
