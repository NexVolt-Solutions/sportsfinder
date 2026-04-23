
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
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBpWS7fZrrqP9oElNRpkMjY83gr_bNdPu0',
    appId: '1:147032468406:web:45df8ba821b68515e56f17',
    messagingSenderId: '147032468406',
    projectId: 'sportfinding-ttagmu',
    authDomain: 'sportfinding-ttagmu.firebaseapp.com',
    storageBucket: 'sportfinding-ttagmu.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBu_BZ3SA3Mm36f4zRHrAPWyEw9F_2kcKg',
    appId: '1:147032468406:android:76d70e077490946fe56f17',
    messagingSenderId: '147032468406',
    projectId: 'sportfinding-ttagmu',
    storageBucket: 'sportfinding-ttagmu.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBvRb7DkwlU3NAirNeR5xIXorjwTRjCriw',
    appId: '1:147032468406:ios:48e6f59ea536a1b1e56f17',
    messagingSenderId: '147032468406',
    projectId: 'sportfinding-ttagmu',
    storageBucket: 'sportfinding-ttagmu.firebasestorage.app',
    iosClientId: '147032468406-u2dud8ekavnorss76179sf0co7d9bhe1.apps.googleusercontent.com',
    iosBundleId: 'com.sportfinding.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBvRb7DkwlU3NAirNeR5xIXorjwTRjCriw',
    appId: '1:147032468406:ios:48e6f59ea536a1b1e56f17',
    messagingSenderId: '147032468406',
    projectId: 'sportfinding-ttagmu',
    storageBucket: 'sportfinding-ttagmu.firebasestorage.app',
    iosClientId: '147032468406-u2dud8ekavnorss76179sf0co7d9bhe1.apps.googleusercontent.com',
    iosBundleId: 'com.sportfinding.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBpWS7fZrrqP9oElNRpkMjY83gr_bNdPu0',
    appId: '1:147032468406:web:8e155712e33db796e56f17',
    messagingSenderId: '147032468406',
    projectId: 'sportfinding-ttagmu',
    authDomain: 'sportfinding-ttagmu.firebaseapp.com',
    storageBucket: 'sportfinding-ttagmu.firebasestorage.app',
  );
}
