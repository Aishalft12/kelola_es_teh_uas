import 'package:flutter/material.dart';

import '../data/data_simulasi.dart';
import 'laporan_page.dart';
import 'menu_resep_page.dart';
import 'penjualan_page.dart';
import 'stok_bahan_page.dart';

/// Halaman utama — shell dengan NavigationBar (mobile) atau NavigationRail (web)
/// Mengelola indeks halaman aktif dengan setState
class HalamanUtama extends StatefulWidget {
  const HalamanUtama({super.key});

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  int _indeks = 0;

  /// Halaman dibuat ulang setiap kali versi data berubah (mis. setelah
  /// penjualan disimpan), supaya angka stok dan laporan langsung ikut
  /// ter-update saat tab dibuka. Kunci `versi` memaksa Flutter membangun
  /// ulang halaman, bukan memakai widget lama.
  List<Widget> _halaman(int versi) => [
        MenuResepPage(key: ValueKey('menu-$versi')),
        PenjualanPage(key: ValueKey('jual-$versi')),
        StokBahanPage(key: ValueKey('stok-$versi')),
        LaporanPage(key: ValueKey('laporan-$versi')),
      ];

  static const List<NavigationDestination> _tujuan = [
    NavigationDestination(
      icon: Icon(Icons.menu_book),
      selectedIcon: Icon(Icons.menu_book),
      label: 'Menu',
    ),
    NavigationDestination(
      icon: Icon(Icons.point_of_sale),
      selectedIcon: Icon(Icons.point_of_sale),
      label: 'Penjualan',
    ),
    NavigationDestination(
      icon: Icon(Icons.inventory_2),
      selectedIcon: Icon(Icons.inventory_2),
      label: 'Stok',
    ),
    NavigationDestination(
      icon: Icon(Icons.bar_chart),
      selectedIcon: Icon(Icons.bar_chart),
      label: 'Laporan',
    ),
  ];

  static const List<NavigationRailDestination> _tujuanRail = [
    NavigationRailDestination(
      icon: Icon(Icons.menu_book),
      selectedIcon: Icon(Icons.menu_book),
      label: Text('Menu'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.point_of_sale),
      selectedIcon: Icon(Icons.point_of_sale),
      label: Text('Penjualan'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.inventory_2),
      selectedIcon: Icon(Icons.inventory_2),
      label: Text('Stok'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.bar_chart),
      selectedIcon: Icon(Icons.bar_chart),
      label: Text('Laporan'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bool layarLebar = MediaQuery.sizeOf(context).width >= 600;

    // Dengarkan versiData: setiap penjualan tersimpan, seluruh halaman
    // dibangun ulang sehingga stok dan laporan menampilkan angka terbaru.
    return ValueListenableBuilder<int>(
      valueListenable: versiData,
      builder: (context, versi, _) {
        final halaman = _halaman(versi);

        if (layarLebar) {
          // Layout web: NavigationRail di kiri + konten
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _indeks,
                  onDestinationSelected: (i) => setState(() => _indeks = i),
                  destinations: _tujuanRail,
                  extended: MediaQuery.sizeOf(context).width >= 900,
                ),
                const VerticalDivider(width: 1),
                // Batasi lebar konten agar tidak terlalu lebar
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: halaman[_indeks],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Layout mobile: NavigationBar di bawah
        return Scaffold(
          body: halaman[_indeks],
          bottomNavigationBar: NavigationBar(
            selectedIndex: _indeks,
            onDestinationSelected: (i) => setState(() => _indeks = i),
            destinations: _tujuan,
          ),
        );
      },
    );
  }
}
