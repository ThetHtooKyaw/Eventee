import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventee/src/auth/view_models/params/signup_params.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eventee/core/status/failure.dart';
import 'package:eventee/core/status/success.dart';
import 'package:eventee/src/auth/models/app_user.dart';
import 'package:eventee/src/auth/view_models/params/login_params.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _googleSignIn = GoogleSignIn();

  CollectionReference get _usersCollection => _firestore.collection('users');

  Future<Object?> createUser({required SignUpParams params}) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: params.email,
            password: params.password,
          );

      final user = AppUser(
        username: params.username,
        email: params.email,
        phoneNumber: params.phoneNumber,
        photoUrl: '',
        address: params.address,
        createdAt: DateTime.now(),
      );

      await _usersCollection.doc(userCredential.user!.uid).set(user.toMap());

      return Success(response: 'User created successfully!');
    } on FirebaseAuthException catch (e) {
      return Failure(
        response: 'FirebaseAuthException: ${e.code} - ${e.message}',
      );
    } catch (e) {
      return Failure(response: 'Failed to create user: $e.');
    }
  }

  Future<Object?> signUpWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await _googleSignIn
          .signIn();

      if (googleSignInAccount == null) {
        return Failure(response: 'Google sign-in was cancelled.');
      }

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      if (googleSignInAuthentication.idToken == null ||
          googleSignInAuthentication.accessToken == null) {
        return Failure(response: 'Google authentication failed.');
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);

      User? userDetail = result.user;

      if (userDetail == null) {
        return Failure(response: 'User authentication failed.');
      }

      final user = AppUser(
        username: userDetail.displayName ?? '',
        email: userDetail.email ?? '',
        phoneNumber: '',
        photoUrl: userDetail.photoURL ?? '',
        address: '',
        createdAt: DateTime.now(),
      );

      await _usersCollection.doc(userDetail.uid).set(user.toMap());

      return Success(response: 'User created successfully!');
    } on FirebaseAuthException catch (e) {
      return Failure(
        response: 'FirebaseAuthException: ${e.code} - ${e.message}',
      );
    } catch (e) {
      return Failure(response: 'Failed to create user: $e.');
    }
  }

  Future<Object?> loginUser({required LoginParams params}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: params.email,
        password: params.password,
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

  Future<Object> getUser() async {
    try {
      final userData = _auth.currentUser;

      if (userData == null) {
        throw Failure(response: 'No authenticated user found.');
      }
      DocumentSnapshot snapshot = await _usersCollection
          .doc(userData.uid)
          .get();

      if (!snapshot.exists) {
        return Failure(response: 'User data not found.');
      }

      final user = AppUser.fromMap(snapshot.data() as Map<String, dynamic>);

      return Success(response: user);
    } catch (e) {
      return Failure(response: 'Failed to fetch user data: $e.');
    }
  }
}
