// Konfigurasi project Firebase untuk platform web.
// Nilai diambil dari Firebase Console > Project settings > Your apps (Web).
// Isi file ini adalah pengenal project, bukan password, sehingga boleh di-commit.
// Keamanan data diatur di sisi Firebase (Authentication & Security Rules).

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    throw UnsupportedError(
      'Minggu 9 hanya menargetkan web (Chrome). '
      'Jalankan: flutter run -d chrome',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCrd-MNLHtqUhmEYMbGCnqrQTeGXkS4BWg',
    appId: '1:120154686525:web:d8281e7d53a3904dd09654',
    messagingSenderId: '120154686525',
    projectId: 'es-teh-23010550012',
    authDomain: 'es-teh-23010550012.firebaseapp.com',
    storageBucket: 'es-teh-23010550012.firebasestorage.app',
  );
}
