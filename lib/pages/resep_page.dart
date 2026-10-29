import 'package:flutter/material.dart';

import '../data/data_simulasi.dart';
import '../theme/app_colors.dart';
import '../widgets/keadaan_kosong.dart';

/// Halaman turunan: Resep untuk satu menu
/// Dibuka dengan Navigator.push dari MenuResepPage
/// Kembali dengan Navigator.pop (tombol back AppBar)
class ResepPage extends StatelessWidget {
  final Menu menu;

  const ResepPage({super.key, required this.menu});

  @override
  Widget build(BuildContext context) {
    // Filter resep untuk menu ini
    final resepMenu =
        daftarResep.where((r) => r.menuId == menu.id).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Resep ${menu.nama}')),
      body: Column(
        children: [
          // Info menu di atas
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.primary.withValues(alpha: 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menu.nama,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${menu.kategori} • ${formatRupiah(menu.harga)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Daftar bahan resep
          Expanded(
            child: resepMenu.isEmpty
                ? const KeadaanKosong(
                    ikon: Icons.receipt_long_outlined,
                    pesan: 'Belum ada resep untuk menu ini.\nTambahkan bahan pertama.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: resepMenu.length,
                    itemBuilder: (context, i) {
                      final resep = resepMenu[i];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.science_outlined),
                          title: Text(
                            resep.namaBahan,
                            style: const TextStyle(fontSize: 16),
                          ),
                          subtitle: Text(
                            '${resep.jumlahPerGelas.toStringAsFixed(0)} per gelas',
                            style: const TextStyle(fontSize: 14),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                        ),
                      );
                    },
                  ),
          ),
          // Tombol kembali
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kembali'),
            ),
          ),
        ],
      ),
    );
  }
}
