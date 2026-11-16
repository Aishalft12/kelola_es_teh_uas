import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'pages/cek_status_login.dart';
import 'services/layanan_es_teh.dart';
import 'services/layanan_firestore.dart';
import 'theme/app_theme.dart';

/// Aplikasi Es Teh — Penjualan dan Persediaan Bahan Baku UMKM Es Teh
/// Mobile and Web Application Development — Minggu 10 (Cloud Firestore)
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

  runApp(EsTehApp(layanan: LayananFirestore()));
}

class EsTehApp extends StatelessWidget {
  /// Sumber data: LayananFirestore (aplikasi asli) atau LayananMemori (test).
  final LayananEsTeh layanan;

  /// Halaman pertama. Default: CekStatusLogin (mengikuti status login).
  /// Widget test mengisi HalamanUtama/MasukPage agar tidak memanggil Firebase.
  final Widget halamanAwal;

  const EsTehApp({
    super.key,
    required this.layanan,
    this.halamanAwal = const CekStatusLogin(),
  });

  @override
  Widget build(BuildContext context) {
    // LayananScope diletakkan di atas MaterialApp agar semua halaman,
    // termasuk yang dibuka lewat Navigator.push, bisa memakainya.
    return LayananScope(
      layanan: layanan,
      child: MaterialApp(
        title: 'Es Teh App',
        theme: AppTheme.light,
        home: halamanAwal,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
