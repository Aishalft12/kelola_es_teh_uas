import 'package:flutter/material.dart';

import '../data/data_simulasi.dart';
import '../theme/app_colors.dart';
import '../widgets/keadaan_kosong.dart';

/// Halaman Penjualan — frame Must dari wireframe Figma
/// Menampilkan: daftar menu dengan pengatur jumlah, pilihan tingkat gula,
/// total, tombol Simpan Penjualan
/// Untuk Minggu 6: tampilan statis dengan data simulasi (form di Minggu 7)
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

  int get _total {
    int total = 0;
    for (final menu in daftarMenu) {
      final jumlah = _jumlahDipilih[menu.id] ?? 0;
      total += menu.harga * jumlah;
    }
    return total;
  }

  bool get _adaItem => _jumlahDipilih.values.any((v) => v > 0);

  void _simpanPenjualan() {
    if (!_adaItem) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi data — pilih minimal 1 menu'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Penjualan tersimpan — Total ${formatRupiah(_total)}'),
        backgroundColor: AppColors.success,
      ),
    );
    // Reset
    setState(() {
      _jumlahDipilih.clear();
      _gulaDipilih.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Penjualan')),
      body: Column(
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
                      formatRupiah(_total),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _simpanPenjualan,
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan Penjualan'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
