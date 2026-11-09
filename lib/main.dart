import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'pages/cek_status_login.dart';
import 'theme/app_theme.dart';

/// Aplikasi Es Teh — Penjualan dan Persediaan Bahan Baku UMKM Es Teh
/// Mobile and Web Application Development — Minggu 9 (Firebase & Login)
///
/// Mahasiswa: Aisha Lufita (23.01.55.0012)
/// Kelas: A1
Future<void> main() async {
  // Wajib sebelum await apa pun di main
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase harus siap sebelum runApp
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const EsTehApp());
}

class EsTehApp extends StatelessWidget {
  /// Halaman pertama. Default: CekStatusLogin (mengikuti status login).
  /// Widget test mengisi HalamanUtama/MasukPage agar tidak memanggil Firebase.
  final Widget halamanAwal;

  const EsTehApp({super.key, this.halamanAwal = const CekStatusLogin()});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Es Teh App',
      theme: AppTheme.light,
      home: halamanAwal,
      debugShowCheckedModeBanner: false,
    );
  }
}
