// File generated for Firebase integration.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] configured with live Firebase Project 'pyp-app-fc631'.
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
    apiKey: 'AIzaSyCq_UibliO1Q_5Bp9vFzxZqcAv2bAJ-kro',
    appId: '1:951546987988:web:ce4ecf9d98eb5bb01f8241',
    messagingSenderId: '951546987988',
    projectId: 'pyp-app-fc631',
    authDomain: 'pyp-app-fc631.firebaseapp.com',
    storageBucket: 'pyp-app-fc631.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCq_UibliO1Q_5Bp9vFzxZqcAv2bAJ-kro',
    appId: '1:951546987988:android:ce4ecf9d98eb5bb01f8241',
    messagingSenderId: '951546987988',
    projectId: 'pyp-app-fc631',
    storageBucket: 'pyp-app-fc631.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCq_UibliO1Q_5Bp9vFzxZqcAv2bAJ-kro',
    appId: '1:951546987988:ios:ce4ecf9d98eb5bb01f8241',
    messagingSenderId: '951546987988',
    projectId: 'pyp-app-fc631',
    storageBucket: 'pyp-app-fc631.firebasestorage.app',
    iosBundleId: 'com.pyp.lensmatch',
  );
}
