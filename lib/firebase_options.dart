
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
        return ios;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
      apiKey: "AIzaSyB-giAOBriYsDUkxLcf0itDqO0GWL393F0",
      authDomain: "recipe-app-f7c7e.firebaseapp.com",
      projectId: "recipe-app-f7c7e",
      storageBucket: "recipe-app-f7c7e.firebasestorage.app",
      messagingSenderId: "1003942639352",
      appId: "1:1003942639352:web:0ac2d45fd082e9b5c52d0d",
      measurementId: "G-RZ8DKLZEQW"
  );

  static const FirebaseOptions android = FirebaseOptions(
      apiKey: "AIzaSyB-giAOBriYsDUkxLcf0itDqO0GWL393F0",
      authDomain: "recipe-app-f7c7e.firebaseapp.com",
      projectId: "recipe-app-f7c7e",
      storageBucket: "recipe-app-f7c7e.firebasestorage.app",
      messagingSenderId: "1003942639352",
      appId: "1:1003942639352:web:0ac2d45fd082e9b5c52d0d",
      measurementId: "G-RZ8DKLZEQW");

  static const FirebaseOptions ios = FirebaseOptions(
      apiKey: "AIzaSyB-giAOBriYsDUkxLcf0itDqO0GWL393F0",
      authDomain: "recipe-app-f7c7e.firebaseapp.com",
      projectId: "recipe-app-f7c7e",
      storageBucket: "recipe-app-f7c7e.firebasestorage.app",
      messagingSenderId: "1003942639352",
      appId: "1:1003942639352:web:0ac2d45fd082e9b5c52d0d",
      measurementId: "G-RZ8DKLZEQW");

}
