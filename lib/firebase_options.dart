import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBzafW_8P40LWnAJkfzoBq1Diujpnl1OKg',
    appId: '1:516082565964:web:8a3c62e5877f1d8b6345e9',
    messagingSenderId: '516082565964',
    projectId: 'eu-paintroom-paintroom',
    authDomain: 'eu-paintroom-paintroom.firebaseapp.com',
    storageBucket: 'eu-paintroom-paintroom.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBzafW_8P40LWnAJkfzoBq1Diujpnl1OKg',
    appId: '1:516082565964:android:8a3c62e5877f1d8b6345e9',
    messagingSenderId: '516082565964',
    projectId: 'eu-paintroom-paintroom',
    authDomain: 'eu-paintroom-paintroom.firebaseapp.com',
    storageBucket: 'eu-paintroom-paintroom.firebasestorage.app',
  );
}
