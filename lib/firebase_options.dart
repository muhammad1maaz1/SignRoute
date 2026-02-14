import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web not configured');
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError('Platform not supported');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyDAQ86BLRHadJTMafvwZqNyDaNxd0pBg7E",
    appId: "1:253911329076:android:362b56a09b7e6727e85d61",
    messagingSenderId: "253911329076",
    projectId: "signroute-ec3f3",
    storageBucket: "signroute-ec3f3.firebasestorage.app",
  );
}
