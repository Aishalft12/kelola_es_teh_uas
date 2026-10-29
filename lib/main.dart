import 'package:flutter/material.dart';

import 'pages/halaman_utama.dart';
import 'theme/app_theme.dart';

/// Aplikasi Es Teh — Penjualan dan Persediaan Bahan Baku UMKM Es Teh
/// Mobile and Web Application Development — Minggu 6
///
/// Mahasiswa: Aisha Lufita (23.01.55.0012)
/// Kelas: A1
void main() {
  runApp(const EsTehApp());
}

class EsTehApp extends StatelessWidget {
  const EsTehApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Es Teh App',
      theme: AppTheme.light,
      home: const HalamanUtama(),
      debugShowCheckedModeBanner: false,
    );
  }
}
