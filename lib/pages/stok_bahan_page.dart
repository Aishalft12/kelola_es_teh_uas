import 'package:flutter/material.dart';

import '../data/data_simulasi.dart';
import '../services/layanan_es_teh.dart';
import '../theme/app_colors.dart';
import '../widgets/keadaan_kosong.dart';
import '../widgets/keadaan_stream.dart';
import '../widgets/status_badge.dart';
import '../widgets/tombol_keluar.dart';

/// Halaman Stok Bahan — frame Must dari wireframe Figma
/// Menampilkan: daftar bahan (stok, batas minimum, status Aman/Menipis),
/// tombol Catat Pembelian, keadaan kosong
/// Minggu 10: stok dibaca real-time dari collection `bahan`.
class StokBahanPage extends StatefulWidget {
  const StokBahanPage({super.key});

  @override
  State<StokBahanPage> createState() => _StokBahanPageState();
}

class _StokBahanPageState extends State<StokBahanPage> {
  Stream<List<Bahan>>? _streamBahan;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _streamBahan ??= LayananScope.of(context).streamBahan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stok Bahan'),
        actions: const [TombolKeluar()],
      ),
      body: Column(
        children: [
          // Area konten yang bisa digulir
          Expanded(
            child: StreamBuilder<List<Bahan>>(
              stream: _streamBahan,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return const MemuatData();
                }
                if (snapshot.hasError) return const GagalMemuat();
                final daftarBahan = snapshot.data ?? const <Bahan>[];
                return daftarBahan.isEmpty
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
                                'Stok: ${formatJumlah(bahan.stok)} ${bahan.satuan} • Min: ${formatJumlah(bahan.stokMinimum)} ${bahan.satuan}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              StatusBadge(status: status),
                            ],
                          ),
                          // Biaya per satuan — dasar perhitungan laba kotor
                          trailing: Text(
                            '${formatRupiah(bahan.biayaPerSatuan.round())}/${bahan.satuan}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    },
                  );
              },
            ),
          ),
          // Aksi utama di bawah
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed: () {
                // Form Catat Pembelian (menambah stok) dibuat setelah CRUD
                // lengkap, sesuai rencana pada proposal.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Form Catat Pembelian sedang dikembangkan'),
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
