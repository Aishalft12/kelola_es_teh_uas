import 'package:flutter/material.dart';

import '../data/data_simulasi.dart';
import '../theme/app_colors.dart';
import '../widgets/keadaan_kosong.dart';
import '../widgets/status_badge.dart';

/// Halaman Stok Bahan — frame Must dari wireframe Figma
/// Menampilkan: daftar bahan (stok, batas minimum, status Aman/Menipis),
/// tombol Catat Pembelian, keadaan kosong
class StokBahanPage extends StatelessWidget {
  const StokBahanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stok Bahan')),
      body: Column(
        children: [
          // Area konten yang bisa digulir
          Expanded(
            child: daftarBahan.isEmpty
                ? const KeadaanKosong(
                    ikon: Icons.inventory_2_outlined,
                    pesan: 'Belum ada bahan.\nTambahkan bahan baku pertama.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: daftarBahan.length,
                    itemBuilder: (context, i) {
                      final bahan = daftarBahan[i];
                      final status = statusStok(bahan);
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.inventory_2),
                          title: Text(
                            bahan.nama,
                            style: const TextStyle(fontSize: 16),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Stok: ${bahan.stok.toStringAsFixed(0)} ${bahan.satuan} • Min: ${bahan.stokMinimum.toStringAsFixed(0)} ${bahan.satuan}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              StatusBadge(status: status),
                            ],
                          ),
                          trailing: Text(
                            formatRupiah(bahan.hargaBeli),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // Aksi utama di bawah
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed: () {
                // TODO: Minggu 7 — buka form Catat Pembelian
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Form Catat Pembelian akan dibuat pada Minggu 7'),
                  ),
                );
              },
              icon: const Icon(Icons.shopping_cart),
              label: const Text('Catat Pembelian'),
            ),
          ),
        ],
      ),
    );
  }
}
