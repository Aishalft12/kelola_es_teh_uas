import 'package:flutter/material.dart';

import '../data/data_simulasi.dart';
import '../theme/app_colors.dart';
import '../widgets/keadaan_kosong.dart';
import 'menu_form_page.dart';
import 'resep_page.dart';

/// Halaman Menu dan Resep — frame Must dari wireframe Figma
/// Menampilkan: daftar menu (nama, harga), tombol Resep per menu,
/// tombol Tambah Menu, keadaan kosong
///
/// Minggu 7: StatefulWidget agar daftar menu bisa di-refresh
/// setelah menambah menu baru dari MenuFormPage.
class MenuResepPage extends StatefulWidget {
  const MenuResepPage({super.key});

  @override
  State<MenuResepPage> createState() => _MenuResepPageState();
}

class _MenuResepPageState extends State<MenuResepPage> {
  // Method untuk membuka form Tambah Menu dan refresh daftar setelah ditutup
  Future<void> _bukaFormTambahMenu() async {
    // Navigator.push mengembalikan nilai dari Navigator.pop (true/false)
    final bool? berhasil = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const MenuFormPage(),
      ),
    );

    // Jika form mengembalikan true (menu baru disimpan), refresh daftar
    if (berhasil == true && mounted) {
      setState(() {
        // setState memicu rebuild sehingga menu baru muncul di daftar
        // Tidak perlu kode tambahan — daftarMenu sudah diperbarui di form
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu dan Resep')),
      body: Column(
        children: [
          // Area konten yang bisa digulir
          Expanded(
            child: daftarMenu.isEmpty
                ? const KeadaanKosong(
                    ikon: Icons.local_cafe_outlined,
                    pesan: 'Belum ada menu.\nTambahkan menu pertama Anda.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: daftarMenu.length,
                    itemBuilder: (context, i) {
                      final menu = daftarMenu[i];
                      return Card(
                        child: ListTile(
                          leading: Icon(
                            Icons.local_cafe,
                            color: menu.ketersediaan
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          title: Text(
                            menu.nama,
                            style: const TextStyle(fontSize: 16),
                          ),
                          subtitle: Text(
                            '${menu.kategori} • ${formatRupiah(menu.harga)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          trailing: menu.ketersediaan
                              ? const Text(
                                  'Tersedia',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.success,
                                  ),
                                )
                              : const Text(
                                  'Habis',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.error,
                                  ),
                                ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ResepPage(
                                  menu: menu,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
          // Aksi utama di bawah
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
