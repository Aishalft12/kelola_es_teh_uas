import 'package:flutter/material.dart';

import '../data/data_simulasi.dart';
import '../theme/app_colors.dart';
import '../widgets/keadaan_kosong.dart';

/// Halaman Laporan — frame Must dari wireframe Figma
/// Menampilkan: pilihan periode, total penjualan, laba kotor,
/// menu terlaris, keadaan kosong
class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  String _periode = 'minggu';

  @override
  Widget build(BuildContext context) {
    // Hitung data laporan dari daftarPenjualan
    final penjualanPeriode = daftarPenjualan;

    final totalPenjualan =
        penjualanPeriode.fold(0, (sum, p) => sum + p.total);

    // Hitung jumlah gelas terjual dan menu terlaris
    final Map<String, int> menuCount = {};
    int totalGelas = 0;
    for (final p in penjualanPeriode) {
      for (final item in p.items) {
        menuCount[item.namaMenu] =
            (menuCount[item.namaMenu] ?? 0) + item.jumlah;
        totalGelas += item.jumlah;
      }
    }

    // Menu terlaris
    String? menuTerlaris;
    int jumlahTerlaris = 0;
    if (menuCount.isNotEmpty) {
      final sorted = menuCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      menuTerlaris = sorted.first.key;
      jumlahTerlaris = sorted.first.value;
    }

    // Estimasi laba kotor = 60% dari penjualan (data simulasi)
    final labaKotor = (totalPenjualan * 0.6).round();

    return Scaffold(
      appBar: AppBar(title: const Text('Laporan')),
      body: Column(
        children: [
          // Pilihan periode
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Periode: ',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'hari',
                        label: Text('Hari'),
                        icon: Icon(Icons.today),
                      ),
                      ButtonSegment(
                        value: 'minggu',
                        label: Text('Minggu'),
                        icon: Icon(Icons.date_range),
                      ),
                      ButtonSegment(
                        value: 'bulan',
                        label: Text('Bulan'),
                        icon: Icon(Icons.calendar_month),
                      ),
                    ],
                    selected: {_periode},
                    onSelectionChanged: (Set<String> selection) {
                      setState(() {
                        _periode = selection.first;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          // Area konten
          Expanded(
            child: penjualanPeriode.isEmpty
                ? const KeadaanKosong(
                    ikon: Icons.bar_chart_outlined,
                    pesan: 'Belum ada penjualan\npada periode ini.',
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Kartu ringkasan: Total Penjualan
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Penjualan',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                formatRupiah(totalPenjualan),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Kartu ringkasan: Laba Kotor
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Laba Kotor',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                formatRupiah(labaKotor),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Kartu ringkasan: Jumlah Gelas
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Jumlah Gelas Terjual',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$totalGelas gelas',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Menu terlaris
                      if (menuTerlaris != null) ...[
                        const Text(
                          'Menu Terlaris',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Card(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          child: ListTile(
                            leading: const Icon(
                              Icons.emoji_events,
                              color: AppColors.warning,
                            ),
                            title: Text(
                              menuTerlaris,
                              style: const TextStyle(fontSize: 16),
                            ),
                            subtitle: Text(
                              '$jumlahTerlaris gelas terjual',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      // Rincian penjualan per hari
                      const Text(
                        'Rincian Penjualan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (final p in penjualanPeriode)
                        Card(
                          child: ExpansionTile(
                            leading: const Icon(Icons.receipt),
                            title: Text(
                              '${p.tanggal.day}/${p.tanggal.month}/${p.tanggal.year}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            subtitle: Text(
                              formatRupiah(p.total),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.primary,
                              ),
                            ),
                            children: [
                              for (final item in p.items)
                                ListTile(
                                  leading: const Icon(
                                    Icons.local_cafe,
                                    size: 20,
                                  ),
                                  title: Text(
                                    item.namaMenu,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  subtitle: Text(
                                    '${item.jumlah} gelas • Gula: ${item.tingkatGula}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  trailing: Text(
                                    formatRupiah(item.subtotal),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
