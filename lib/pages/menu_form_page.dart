import 'package:flutter/material.dart';

import '../data/data_simulasi.dart';
import '../services/layanan_es_teh.dart';
import '../theme/app_colors.dart';

/// Halaman Form Tambah Menu — halaman turunan dari MenuResepPage
///
/// Minggu 7: Form, Validasi Input, dan State Sederhana
/// - Form + GlobalKey FormState
/// - 3+ kolom input: Nama, Kategori (dropdown), Harga, Ketersediaan (switch)
/// - 2+ jenis input: TextFormField, DropdownButtonFormField, Switch
/// - Setiap kolom punya validator (null = valid, string = pesan error)
/// - AutovalidateMode.onUserInteraction
/// - TextEditingController dengan dispose()
/// - Tombol Simpan memvalidasi seluruh form, SnackBar saat sukses
/// - Minggu 10: data valid disimpan ke collection `menu` di Cloud Firestore
class MenuFormPage extends StatefulWidget {
  /// Daftar menu saat ini, untuk validasi nama duplikat di form.
  final List<Menu> daftarMenu;

  const MenuFormPage({super.key, required this.daftarMenu});

  @override
  State<MenuFormPage> createState() => _MenuFormPageState();
}

class _MenuFormPageState extends State<MenuFormPage> {
  // GlobalKey untuk Form — dipakai untuk validasi seluruh form sekaligus
  final _formKey = GlobalKey<FormState>();

  // Controller untuk TextFormField — wajib di-dispose()
  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();

  // State untuk dropdown dan switch
  String? _kategoriDipilih;
  bool _ketersediaan = true;
  bool _sedangMenyimpan = false;

  // Daftar kategori untuk dropdown
  static const List<String> _daftarKategori = [
    'Es Teh',
    'Es Teh Susu',
    'Es Teh Lemon',
    'Es Teh Tarik',
    'Es Teh Herbal',
    'Es Teh Spesial',
  ];

  @override
  void dispose() {
    // Wajib dispose controller untuk mencegah memory leak
    _namaController.dispose();
    _hargaController.dispose();
    super.dispose();
  }

  /// Validator untuk nama menu
  /// - Tidak boleh kosong
  /// - Minimal 3 karakter
  /// - Tidak boleh duplikat dengan menu yang sudah ada
  String? _validasiNama(String? value) => validasiNamaMenu(value, widget.daftarMenu);

  /// Validator untuk kategori (dropdown)
  /// - Tidak boleh null/kosong
  String? _validasiKategori(String? value) {
    if (value == null || value.isEmpty) {
      return 'Pilih kategori menu';
    }
    return null;
  }

  /// Validator untuk harga
  /// - Tidak boleh kosong
  /// - Harus angka valid
  /// - Minimal Rp 1.000
  /// - Maksimal Rp 1.000.000
  String? _validasiHarga(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) {
      return 'Harga tidak boleh kosong';
    }
    // Cek apakah angka valid (hanya digit, tanpa titik/koma)
    final harga = int.tryParse(input);
    if (harga == null) {
      return 'Harga harus berupa angka';
    }
    if (harga < 1000) {
      return 'Harga minimal Rp 1.000';
    }
    if (harga > 1000000) {
      return 'Harga maksimal Rp 1.000.000';
    }
    return null;
  }

  /// Aksi tombol Simpan
  /// Validasi form → simpan ke Firestore → SnackBar → kembali ke daftar
  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Periksa kembali data yang dimasukkan'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final nama = _namaController.text.trim();
    setState(() => _sedangMenyimpan = true);
    try {
      await LayananScope.of(context).tambahMenu(
        nama: nama,
        kategori: _kategoriDipilih!,
        harga: int.parse(_hargaController.text.trim()),
        ketersediaan: _ketersediaan,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Menu "$nama" berhasil ditambahkan'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true);
    } on NamaMenuDuplikatException catch (e) {
      _tampilkanGagal(e.pesan);
    } catch (_) {
      _tampilkanGagal('Gagal menyimpan menu. Periksa koneksi lalu coba lagi.');
    } finally {
      if (mounted) setState(() => _sedangMenyimpan = false);
    }
  }

  void _tampilkanGagal(String pesan) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Menu')),
      body: Form(
        key: _formKey,
        // Validasi otomatis saat user berinteraksi dengan field
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- Field 1: Nama Menu (TextFormField) ---
            TextFormField(
              controller: _namaController,
              decoration: const InputDecoration(
                labelText: 'Nama Menu',
                hintText: 'Contoh: Es Teh Melon',
                prefixIcon: Icon(Icons.local_cafe),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: _validasiNama,
            ),
            const SizedBox(height: 16),

            // --- Field 2: Kategori (DropdownButtonFormField) ---
            DropdownButtonFormField<String>(
              initialValue: _kategoriDipilih,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              hint: const Text('Pilih kategori'),
              items: _daftarKategori.map((String kategori) {
                return DropdownMenuItem<String>(
                  value: kategori,
                  child: Text(kategori),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  _kategoriDipilih = value;
                });
              },
              validator: _validasiKategori,
            ),
            const SizedBox(height: 16),

            // --- Field 3: Harga (TextFormField dengan keyboard angka) ---
            TextFormField(
              controller: _hargaController,
              decoration: const InputDecoration(
                labelText: 'Harga (Rp)',
                hintText: 'Contoh: 6000',
                prefixIcon: Icon(Icons.attach_money),
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              validator: _validasiHarga,
            ),
            const SizedBox(height: 16),

            // --- Field 4: Ketersediaan (Switch) ---
            Card(
              child: SwitchListTile(
                title: const Text('Ketersediaan'),
                subtitle: Text(
                  _ketersediaan
                      ? 'Menu tersedia untuk dijual'
                      : 'Menu tidak tersedia (habis)',
                  style: const TextStyle(fontSize: 14),
                ),
                value: _ketersediaan,
                onChanged: (bool value) {
                  setState(() {
                    _ketersediaan = value;
                  });
                },
                activeThumbColor: AppColors.success,
              ),
            ),
            const SizedBox(height: 24),

            // --- Tombol Simpan ---
            FilledButton.icon(
              onPressed: _sedangMenyimpan ? null : _simpan,
              icon: _sedangMenyimpan
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save),
              label: const Text('Simpan Menu'),
            ),
            const SizedBox(height: 8),

            // --- Tombol Batal ---
            OutlinedButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
          ],
        ),
      ),
    );
  }
}
