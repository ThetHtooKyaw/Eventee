import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:eventee/src/auth/models/app_user.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _googleSignIn = GoogleSignIn();

  CollectionReference get _usersCollection => _firestore.collection('users');

  Future<Object> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return Success(response: 'User logged in successfully!');
    } on FirebaseAuthException catch (e) {
      return Failure(
        response: 'FirebaseAuthException: ${e.code} - ${e.message}',
      );
    } catch (e) {
      return Failure(response: 'Failed to login user: $e.');
    }
  }

  Future<Object> signUpUser({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      final newUser = AppUser(
        uid: userCredential.user!.uid,
        username: username,
        email: email,
        photoUrl: '',
        phoneNumber: '',
        address: '',
        dateOfBirth: null,
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

  Future<Object> signUpWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return Failure(response: 'Google sign-in was cancelled.');
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
        return Failure(response: 'Failed to sign in with Google.');
      }

      final userDoc = await _usersCollection.doc(user.uid).get();
      if (!userDoc.exists) {
        final newUser = AppUser(
          uid: user.uid,
          username: user.displayName ?? '',
          email: user.email ?? '',
          photoUrl: user.photoURL ?? '',
          phoneNumber: '',
          address: '',
          dateOfBirth: null,
        );
        await _usersCollection.doc(user.uid).set(newUser.toMap());
      }

      return Success(response: 'User signed in with Google successfully!');
    } catch (e) {
      return Failure(response: 'Failed to sign in with Google: $e');
    }
  }
}
