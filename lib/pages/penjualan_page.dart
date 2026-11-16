import 'package:flutter/material.dart';

import '../data/data_simulasi.dart';
import '../services/layanan_es_teh.dart';
import '../theme/app_colors.dart';
import '../widgets/keadaan_kosong.dart';
import '../widgets/keadaan_stream.dart';
import '../widgets/tombol_keluar.dart';

/// Halaman Penjualan — frame Must dari wireframe Figma
/// Menampilkan: daftar menu dengan pengatur jumlah, pilihan tingkat gula,
/// total, tombol Simpan Penjualan
/// Minggu 10: menu & bahan dibaca real-time dari Firestore; penjualan disimpan
/// ke collection `penjualan` dengan validasi stok (ditolak bila tidak cukup).
class PenjualanPage extends StatefulWidget {
  const PenjualanPage({super.key});

  @override
  State<PenjualanPage> createState() => _PenjualanPageState();
}

class _PenjualanPageState extends State<PenjualanPage> {
  // Map menuId -> jumlah yang dipilih
  final Map<String, int> _jumlahDipilih = {};
  // Map menuId -> tingkat gula
  final Map<String, String> _gulaDipilih = {};

  Stream<List<Menu>>? _streamMenu;
  Stream<List<Bahan>>? _streamBahan;
  bool _sedangMenyimpan = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final layanan = LayananScope.of(context);
    _streamMenu ??= layanan.streamMenu();
    _streamBahan ??= layanan.streamBahan();
  }

  int _total(List<Menu> daftarMenu) {
    int total = 0;
    for (final menu in daftarMenu) {
      total += menu.harga * (_jumlahDipilih[menu.id] ?? 0);
    }
    return total;
  }

  /// Biaya bahan keranjang saat ini (dari resep) — laba kotor terlihat sejak awal.
  int _biayaBahan(List<Menu> daftarMenu, List<Bahan> daftarBahan) {
    int biaya = 0;
    for (final menu in daftarMenu) {
      final jumlah = _jumlahDipilih[menu.id] ?? 0;
      if (jumlah == 0) continue;
      biaya += biayaBahanMenu(menu, daftarBahan) * jumlah;
    }
    return biaya;
  }

  Future<void> _simpanPenjualan(List<Menu> daftarMenu) async {
    setState(() => _sedangMenyimpan = true);
    // Layanan memeriksa stok terbaru di server (B3), mengurangi stok (B1),
    // dan mencatat penjualan beserta biaya bahan (B2) dalam satu transaksi.
    final hasil = await LayananScope.of(context).simpanPenjualan(
      keranjang: Map.of(_jumlahDipilih),
      gula: Map.of(_gulaDipilih),
      daftarMenu: daftarMenu,
    );
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(hasil.pesan),
        backgroundColor: hasil.berhasil ? AppColors.success : AppColors.error,
      ),
    );

    setState(() {
      _sedangMenyimpan = false;
      // Bila ditolak, keranjang dibiarkan supaya jumlahnya bisa diperbaiki.
      if (hasil.berhasil) {
        _jumlahDipilih.clear();
        _gulaDipilih.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Penjualan'),
        actions: const [TombolKeluar()],
      ),
      body: StreamBuilder<List<Menu>>(
        stream: _streamMenu,
        builder: (context, snapMenu) {
          return StreamBuilder<List<Bahan>>(
            stream: _streamBahan,
            builder: (context, snapBahan) {
              final menunggu = (snapMenu.connectionState == ConnectionState.waiting && !snapMenu.hasData) ||
                  (snapBahan.connectionState == ConnectionState.waiting && !snapBahan.hasData);
              if (menunggu) return const MemuatData();
              if (snapMenu.hasError || snapBahan.hasError) return const GagalMemuat();
              final daftarMenu = snapMenu.data ?? const <Menu>[];
              final daftarBahan = snapBahan.data ?? const <Bahan>[];
              return _isi(daftarMenu, daftarBahan);
            },
          );
        },
      ),
    );
  }

  Widget _isi(List<Menu> daftarMenu, List<Bahan> daftarBahan) {
    final total = _total(daftarMenu);
    final biayaBahan = _biayaBahan(daftarMenu, daftarBahan);
    return Column(
        children: [
          Expanded(
            child: daftarMenu.isEmpty
                ? const KeadaanKosong(
                    ikon: Icons.point_of_sale_outlined,
                    pesan: 'Belum ada menu tersedia.\nTambahkan menu terlebih dahulu.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: daftarMenu.length,
                    itemBuilder: (context, i) {
                      final menu = daftarMenu[i];
                      final jumlah = _jumlahDipilih[menu.id] ?? 0;
                      final gula = _gulaDipilih[menu.id] ?? 'Normal';

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Nama menu & harga
                              Row(
                                children: [
                                  Icon(
                                    Icons.local_cafe,
                                    color: menu.ketersediaan
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      menu.nama,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  Text(
                                    formatRupiah(menu.harga),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Pengatur jumlah
                              Row(
                                children: [
                                  const Text(
                                    'Jumlah: ',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  IconButton(
                                    onPressed: menu.ketersediaan
                                        ? () {
                                            setState(() {
                                              final current =
                                                  _jumlahDipilih[menu.id] ?? 0;
                                              if (current > 0) {
                                                _jumlahDipilih[menu.id] =
                                                    current - 1;
                                              }
                                            });
                                          }
                                        : null,
                                    icon: const Icon(Icons.remove_circle_outline),
                                  ),
                                  Text(
                                    '$jumlah',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: menu.ketersediaan
                                        ? () {
                                            setState(() {
                                              final current =
                                                  _jumlahDipilih[menu.id] ?? 0;
                                              _jumlahDipilih[menu.id] =
                                                  current + 1;
                                            });
                                          }
                                        : null,
                                    icon: const Icon(Icons.add_circle_outline),
                                  ),
                                  const Spacer(),
                                  if (!menu.ketersediaan)
                                    const Text(
                                      'Habis',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.error,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Pilihan tingkat gula
                              if (menu.ketersediaan && jumlah > 0) ...[
                                const Text(
                                  'Tingkat Gula:',
                                  style: TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  children: ['Normal', 'Less', 'Extra']
                                      .map((g) {
                                    final isSelected = gula == g;
                                    return ChoiceChip(
                                      label: Text(g),
                                      selected: isSelected,
                                      onSelected: (_) {
                                        setState(() {
                                          _gulaDipilih[menu.id] = g;
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // Total dan tombol simpan
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: AppColors.divider),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      formatRupiah(total),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                // Biaya bahan dihitung dari resep, bukan persentase tetap
                if (total > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Biaya bahan · laba kotor',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${formatRupiah(biayaBahan)} · '
                        '${formatRupiah(total - biayaBahan)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _sedangMenyimpan ? null : () => _simpanPenjualan(daftarMenu),
                  icon: _sedangMenyimpan
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save),
                  label: const Text('Simpan Penjualan'),
                ),
              ],
            ),
          ),
        ],
      );
  }
}
