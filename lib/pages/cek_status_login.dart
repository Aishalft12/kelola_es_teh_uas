import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'halaman_utama.dart';
import 'masuk_page.dart';

/// Menentukan halaman yang tampil berdasarkan status login.
/// authStateChanges() memberi nilai baru setiap kali pengguna masuk/keluar,
/// dan Firebase menyimpan sesi sehingga tetap masuk setelah refresh.
class CekStatusLogin extends StatelessWidget {
  const CekStatusLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Menunggu Firebase memeriksa sesi yang tersimpan
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // Sudah masuk → halaman utama (terlindungi)
        if (snapshot.hasData) {
          return const HalamanUtama();
        }
        // Belum masuk → halaman Masuk / Daftar
        return const MasukPage();
      },
    );
  }
}
