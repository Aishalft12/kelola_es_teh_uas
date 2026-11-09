import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Tombol Keluar di AppBar. Setelah signOut, CekStatusLogin otomatis
/// menampilkan halaman Masuk (tidak perlu Navigator).
class TombolKeluar extends StatelessWidget {
  const TombolKeluar({super.key});

  Future<void> _keluar(BuildContext context) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar dari aplikasi?'),
        content: const Text('Anda perlu masuk lagi untuk membuka aplikasi.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (yakin == true) {
      await FirebaseAuth.instance.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout),
      tooltip: 'Keluar',
      onPressed: () => _keluar(context),
    );
  }
}
