import 'package:flutter/widgets.dart';

import '../data/data_simulasi.dart';

/// Kontrak layanan data Aplikasi Es Teh.
///
/// Halaman hanya memanggil metode di sini dan tidak tahu apakah datanya
/// berasal dari Cloud Firestore (aplikasi asli) atau dari memori (widget test).
abstract class LayananEsTeh {
  /// Profil pengguna yang sedang login (collection users).
  Stream<Pengguna?> streamPenggunaSaya();

  /// Daftar menu beserta resepnya (collection menu), terbaru di atas.
  Stream<List<Menu>> streamMenu();

  /// Daftar bahan baku (collection bahan).
  Stream<List<Bahan>> streamBahan();

  /// Penjualan milik pengguna yang login (collection penjualan), terbaru di atas.
  Stream<List<Penjualan>> streamPenjualanSaya();

  /// Buat dokumen users/{uid} bila belum ada. Bila [namaLengkap] diisi
  /// (mode Daftar), nama itu yang disimpan.
  Future<void> simpanPenggunaSaatLogin({
    required String uid,
    required String email,
    String? namaLengkap,
  });

  /// Auto-seed: isi collection menu & bahan sekali saja bila masih kosong.
  Future<void> isiDataAwalJikaKosong();

  /// Dipanggil saat Halaman Utama dibuka: pastikan dokumen users/{uid} ada
  /// lalu jalankan auto-seed.
  Future<void> siapkanSesi();

  /// Tambah menu baru. Melempar [NamaMenuDuplikatException] bila nama sudah ada.
  Future<void> tambahMenu({
    required String nama,
    required String kategori,
    required int harga,
    required bool ketersediaan,
  });

  /// Simpan penjualan: cek stok (B3), kurangi stok (B1), catat penjualan
  /// beserta biaya bahan (B2). Bila stok tidak cukup, tidak ada data berubah.
  Future<HasilSimpan> simpanPenjualan({
    required Map<String, int> keranjang,
    required Map<String, String> gula,
    required List<Menu> daftarMenu,
  });

  /// Minggu 11 — ubah penjualan milik sendiri yang masih Tercatat.
  /// Stok penjualan lama dikembalikan dulu, lalu keranjang baru diperiksa.
  /// Hanya field isi penjualan yang diubah (update), id_pengguna, tanggal,
  /// dan status tetap.
  Future<HasilSimpan> ubahPenjualan({
    required String idPenjualan,
    required Map<String, int> keranjang,
    required Map<String, String> gula,
    required List<Menu> daftarMenu,
  });

  /// Minggu 11 — hapus (batalkan) penjualan milik sendiri yang masih
  /// Tercatat. Stok bahan dikembalikan sesuai resep.
  Future<HasilSimpan> hapusPenjualan({
    required String idPenjualan,
    required List<Menu> daftarMenu,
  });
}

class NamaMenuDuplikatException implements Exception {
  final String pesan;
  const NamaMenuDuplikatException(this.pesan);
  @override
  String toString() => pesan;
}

/// Menyediakan [LayananEsTeh] ke seluruh halaman di bawahnya.
class LayananScope extends InheritedWidget {
  final LayananEsTeh layanan;

  const LayananScope({super.key, required this.layanan, required super.child});

  static LayananEsTeh of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LayananScope>();
    assert(scope != null, 'LayananScope tidak ditemukan di atas widget ini');
    return scope!.layanan;
  }

  @override
  bool updateShouldNotify(LayananScope oldWidget) => layanan != oldWidget.layanan;
}
