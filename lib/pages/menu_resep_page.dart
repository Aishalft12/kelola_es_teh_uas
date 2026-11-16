import 'package:flutter/material.dart';

import '../data/data_simulasi.dart';
import '../services/layanan_es_teh.dart';
import '../theme/app_colors.dart';
import '../widgets/keadaan_kosong.dart';
import '../widgets/keadaan_stream.dart';
import '../widgets/tombol_keluar.dart';
import 'menu_form_page.dart';
import 'resep_page.dart';

/// Halaman Menu dan Resep — frame Must dari wireframe Figma
///
/// Minggu 10: daftar menu dibaca real-time dari collection `menu`
/// (StreamBuilder), sapaan dibaca dari dokumen `users/{uid}`.
class MenuResepPage extends StatefulWidget {
  const MenuResepPage({super.key});

  @override
  State<MenuResepPage> createState() => _MenuResepPageState();
}

class _MenuResepPageState extends State<MenuResepPage> {
  Stream<List<Menu>>? _streamMenu;
  Stream<Pengguna?>? _streamPengguna;
  List<Menu> _menuTerakhir = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Stream dibuat sekali, bukan di setiap build
    final layanan = LayananScope.of(context);
    _streamMenu ??= layanan.streamMenu();
    _streamPengguna ??= layanan.streamPenggunaSaya();
  }

  Future<void> _bukaFormTambahMenu() async {
    // Daftar menu saat ini dikirim untuk validasi nama duplikat.
    // Setelah tersimpan, StreamBuilder otomatis menampilkan menu baru.
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => MenuFormPage(daftarMenu: _menuTerakhir)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu dan Resep'),
        actions: const [TombolKeluar()],
      ),
      body: Column(
        children: [
          // Sapaan dari collection users
          StreamBuilder<Pengguna?>(
            stream: _streamPengguna,
            builder: (context, snapshot) {
              final nama = snapshot.data?.namaLengkap;
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                color: AppColors.primary.withValues(alpha: 0.08),
                child: Text(
                  nama == null || nama.isEmpty ? 'Halo, selamat datang' : 'Halo, $nama',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              );
            },
          ),
          Expanded(
            child: StreamBuilder<List<Menu>>(
              stream: _streamMenu,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                  return const MemuatData();
                }
                if (snapshot.hasError) return const GagalMemuat();

                final daftarMenu = snapshot.data ?? const <Menu>[];
                _menuTerakhir = daftarMenu;
                if (daftarMenu.isEmpty) {
                  return const KeadaanKosong(
                    ikon: Icons.local_cafe_outlined,
                    pesan: 'Belum ada menu.\nTambahkan menu pertama Anda.',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: daftarMenu.length,
                  itemBuilder: (context, i) {
                    final menu = daftarMenu[i];
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.local_cafe,
                          color: menu.ketersediaan ? AppColors.primary : AppColors.textSecondary,
                        ),
                        title: Text(menu.nama, style: const TextStyle(fontSize: 16)),
                        subtitle: Text(
                          '${menu.kategori} • ${formatRupiah(menu.harga)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        trailing: Text(
                          menu.ketersediaan ? 'Tersedia' : 'Habis',
                          style: TextStyle(
                            fontSize: 12,
                            color: menu.ketersediaan ? AppColors.success : AppColors.error,
                          ),
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ResepPage(menu: menu)),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed: _bukaFormTambahMenu,
              icon: const Icon(Icons.add),
              label: const Text('Tambah Menu'),
            ),
          ),
        ],
      ),
    );
  }
}
