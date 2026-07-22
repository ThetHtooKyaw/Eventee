import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
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
    if (kIsWeb) {
      return web;
    }
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

  static FirebaseOptions get web => FirebaseOptions(
    apiKey: _getEnv('FIREBASE_API_KEY_WEB'),
    appId: _getEnv('FIREBASE_APP_ID_WEB'),
    messagingSenderId: _getEnv('FIREBASE_MESSAGING_SENDER_ID'),
    projectId: _getEnv('FIREBASE_PROJECT_ID'),
    authDomain: _getEnv('FIREBASE_AUTH_DOMAIN'),
    storageBucket: _getEnv('FIREBASE_STORAGE_BUCKET'),
  );

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
