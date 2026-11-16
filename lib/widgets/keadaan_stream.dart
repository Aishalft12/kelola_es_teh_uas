import 'package:flutter/material.dart';

import 'keadaan_kosong.dart';

/// Tampilan untuk keadaan "waiting" StreamBuilder (data pertama belum datang).
class MemuatData extends StatelessWidget {
  const MemuatData({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

/// Tampilan untuk keadaan "error" StreamBuilder (koneksi / Security Rules).
class GagalMemuat extends StatelessWidget {
  const GagalMemuat({super.key});

  @override
  Widget build(BuildContext context) => const KeadaanKosong(
        ikon: Icons.cloud_off,
        pesan: 'Data gagal dimuat.\nPeriksa koneksi internet lalu coba lagi.',
      );
}
