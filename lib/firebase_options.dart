// File generated for Firebase integration.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA_sampleApiKeyWeb1234567890abcdef',
    appId: '1:100000000000:web:abcdef1234567890abcdef',
    messagingSenderId: '100000000000',
    projectId: 'pyp-pickyourphotographer',
    authDomain: 'pyp-pickyourphotographer.firebaseapp.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA_sampleApiKeyAndroid1234567890abc',
    appId: '1:100000000000:android:abcdef1234567890abcdef',
    messagingSenderId: '100000000000',
    projectId: 'pyp-pickyourphotographer',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA_sampleApiKeyIos1234567890abcdefg',
    appId: '1:100000000000:ios:abcdef1234567890abcdef',
    messagingSenderId: '100000000000',
    projectId: 'pyp-pickyourphotographer',
    iosBundleId: 'com.pyp.lensmatch',
  );
}
