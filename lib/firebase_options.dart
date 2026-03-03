// File được tạo tự động dựa trên google-services.json
// Dùng để khởi tạo Firebase trong Flutter

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
          'iOS chưa được cấu hình. Vui lòng chạy FlutterFire CLI.',
        );
      default:
        throw UnsupportedError(
          'Nền tảng "$defaultTargetPlatform" chưa được hỗ trợ.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDL9z1IY31TkLaIdufo7LJH2J4Ocnk_Shk',
    appId: '1:620221395304:web:d3feeb06f383a4d80b26dd',
    messagingSenderId: '620221395304',
    projectId: 'call-api-app',
    authDomain: 'call-api-app.firebaseapp.com',
    storageBucket: 'call-api-app.firebasestorage.app',
    measurementId: 'G-RKYGJH12R4',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBCcwwivl4ezZenPoEZzf499T7s_WzuaQ0',
    appId: '1:620221395304:android:da62f1decca558740b26dd',
    messagingSenderId: '620221395304',
    projectId: 'call-api-app',
    storageBucket: 'call-api-app.firebasestorage.app',
  );
}
