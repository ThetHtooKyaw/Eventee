import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirebaseOptionsLoader {
  static String _getEnv(String key) {
    final value = dotenv.env[key];
    if (value == null) {
      throw Exception(
        'Missing environment variable: $key. Please check your .env file.',
      );
    }
    return value;
  }

  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static FirebaseOptions get android => FirebaseOptions(
    apiKey: _getEnv('FIREBASE_API_KEY_ANDROID'),
    appId: _getEnv('FIREBASE_APP_ID_ANDROID'),
    messagingSenderId: _getEnv('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: _getEnv('FIREBASE_PROJECT_ID'),
    storageBucket: _getEnv('FIREBASE_STORAGE_BUCKET'),
  );

  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: _getEnv('FIREBASE_API_KEY_IOS'),
    appId: _getEnv('FIREBASE_APP_ID_IOS'),
    messagingSenderId: _getEnv('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: _getEnv('FIREBASE_PROJECT_ID'),
    storageBucket: _getEnv('FIREBASE_STORAGE_BUCKET'),
    iosBundleId: _getEnv('FIREBASE_IOS_BUNDLE_ID'),
  );
}
