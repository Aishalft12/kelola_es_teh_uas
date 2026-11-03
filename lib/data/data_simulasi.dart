/// Data simulasi untuk Aplikasi Es Teh
/// Data ini menggantikan Firebase sementara (sesuai batasan Minggu 6).
///
/// Sejak Minggu 8 lapisan data ini juga memuat logika inti aplikasi:
/// - B1: pengurangan stok bahan otomatis saat penjualan disimpan
/// - B2: perhitungan laba kotor dari resep × harga beli bahan
/// - B3: validasi kecukupan stok sebelum penjualan disimpan
library;

import 'package:flutter/foundation.dart';

/// Penanda versi data.
/// Dinaikkan setiap kali stok atau daftar penjualan berubah, supaya halaman
/// yang sedang tidak aktif ikut dibangun ulang saat dibuka kembali.
/// Di versi Firebase, ini digantikan stream dari Cloud Firestore.
final ValueNotifier<int> versiData = ValueNotifier<int>(0);

/// Umumkan bahwa data berubah.
void tandaiDataBerubah() {
  versiData.value++;
}

// ===== Model =====

class Menu {
  final String id;
  final String nama;
  final String kategori;
  final int harga;
  final bool ketersediaan;

  const Menu({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.harga,
    required this.ketersediaan,
  });
}

class Bahan {
  final String id;
  final String nama;
  final String satuan;
  double stok;
  final double stokMinimum;

  /// Harga satu kemasan beli (mis. 1 pack teh 500 gram = Rp 25.000).
  final int hargaBeli;

  /// Jumlah satuan di dalam satu kemasan (mis. 500 gram per pack).
  final double isiKemasan;

  Bahan({
    required this.id,
    required this.nama,
    required this.satuan,
    required this.stok,
    required this.stokMinimum,
    required this.hargaBeli,
    required this.isiKemasan,
  });

  /// Biaya satu satuan bahan (rupiah per gram / ml / pcs).
  /// Dipakai untuk menghitung biaya bahan per gelas dari resep.
  double get biayaPerSatuan => hargaBeli / isiKemasan;
}

class ResepItem {
  final String menuId;
  final String bahanId;
  final String namaBahan;
  final double jumlahPerGelas;

  const ResepItem({
    required this.menuId,
    required this.bahanId,
    required this.namaBahan,
    required this.jumlahPerGelas,
  });
}

class PenjualanItem {
  final String menuId;
  final String namaMenu;
  final int jumlah;
  final String tingkatGula;
  final int subtotal;

  /// Biaya bahan untuk baris ini, dihitung dari resep × biaya per satuan.
  /// Disimpan agar laba kotor bisa ditelusuri, bukan diestimasi ulang.
  final int biayaBahan;

  const PenjualanItem({
    required this.menuId,
    required this.namaMenu,
    required this.jumlah,
    required this.tingkatGula,
    required this.subtotal,
    required this.biayaBahan,
  });

  /// Laba kotor baris ini.
  int get labaKotor => subtotal - biayaBahan;
}

class Penjualan {
  final DateTime tanggal;
  final List<PenjualanItem> items;
  final int total;

  const Penjualan({
    required this.tanggal,
    required this.items,
    required this.total,
  });

  /// Total biaya bahan seluruh baris.
  int get totalBiayaBahan =>
      items.fold(0, (sum, item) => sum + item.biayaBahan);

  /// Laba kotor = total penjualan − total biaya bahan.
  int get labaKotor => total - totalBiayaBahan;
}

/// Hasil percobaan menyimpan penjualan.
class HasilSimpan {
  final bool berhasil;
  final String pesan;

  const HasilSimpan(this.berhasil, this.pesan);
}

// ===== List data simulasi =====

/// Daftar menu — mutable untuk Minggu 7 (form Tambah Menu)
/// Ubah list ini ke [] untuk menguji keadaan kosong
final List<Menu> daftarMenu = [
  Menu(
    id: 'menu1',
    nama: 'Es Teh Manis',
    kategori: 'Es Teh',
    harga: 5000,
    ketersediaan: true,
  ),
  Menu(
    id: 'menu2',
    nama: 'Es Teh Susu',
    kategori: 'Es Teh Susu',
    harga: 7000,
    ketersediaan: true,
  ),
  Menu(
    id: 'menu3',
    nama: 'Es Teh Lemon',
    kategori: 'Es Teh Lemon',
    harga: 8000,
    ketersediaan: true,
  ),
  Menu(
    id: 'menu4',
    nama: 'Es Teh Tarik',
    kategori: 'Es Teh Tarik',
    harga: 8000,
    ketersediaan: false,
  ),
];

/// Daftar bahan baku — mutable: stok berubah saat penjualan disimpan.
/// Nilai awal sengaja dibuat mendekati batas minimum supaya peringatan
/// stok menipis benar-benar muncul saat demo.
/// Ubah list ini ke [] untuk menguji keadaan kosong
final List<Bahan> daftarBahan = [
  Bahan(
    id: 'bahan1',
    nama: 'Teh',
    satuan: 'gram',
    stok: 110,
    stokMinimum: 100,
    hargaBeli: 25000,
    isiKemasan: 500,
  ),
  Bahan(
    id: 'bahan2',
    nama: 'Gula',
    satuan: 'gram',
    stok: 110,
    stokMinimum: 200,
    hargaBeli: 15000,
    isiKemasan: 1000,
  ),
  Bahan(
    id: 'bahan3',
    nama: 'Susu',
    satuan: 'ml',
    stok: 500,
    stokMinimum: 100,
    hargaBeli: 18000,
    isiKemasan: 1000,
  ),
  Bahan(
    id: 'bahan4',
    nama: 'Gelas',
    satuan: 'pcs',
    stok: 200,
    stokMinimum: 50,
    hargaBeli: 15000,
    isiKemasan: 50,
  ),
];

/// Resep: jembatan antara menu dan bahan baku.
/// Mutable untuk Minggu 7 (resep menu baru bisa ditambah)
final List<ResepItem> daftarResep = [
  ResepItem(menuId: 'menu1', bahanId: 'bahan1', namaBahan: 'Teh', jumlahPerGelas: 5),
  ResepItem(menuId: 'menu1', bahanId: 'bahan2', namaBahan: 'Gula', jumlahPerGelas: 15),
  ResepItem(menuId: 'menu1', bahanId: 'bahan4', namaBahan: 'Gelas', jumlahPerGelas: 1),
  ResepItem(menuId: 'menu2', bahanId: 'bahan1', namaBahan: 'Teh', jumlahPerGelas: 5),
  ResepItem(menuId: 'menu2', bahanId: 'bahan3', namaBahan: 'Susu', jumlahPerGelas: 30),
  ResepItem(menuId: 'menu2', bahanId: 'bahan4', namaBahan: 'Gelas', jumlahPerGelas: 1),
  ResepItem(menuId: 'menu3', bahanId: 'bahan1', namaBahan: 'Teh', jumlahPerGelas: 5),
  ResepItem(menuId: 'menu3', bahanId: 'bahan2', namaBahan: 'Gula', jumlahPerGelas: 10),
  ResepItem(menuId: 'menu3', bahanId: 'bahan4', namaBahan: 'Gelas', jumlahPerGelas: 1),
];

/// Data penjualan simulasi untuk Laporan.
/// biayaBahan tiap baris = resep × biaya per satuan (lihat biayaBahanMenu).
///   Es Teh Manis : 5 g teh (Rp 250) + 15 g gula (Rp 225) + 1 gelas (Rp 300) = Rp 775
///   Es Teh Susu  : 5 g teh (Rp 250) + 30 ml susu (Rp 540) + 1 gelas (Rp 300) = Rp 1.090
///   Es Teh Lemon : 5 g teh (Rp 250) + 10 g gula (Rp 150) + 1 gelas (Rp 300) = Rp 700
/// Ubah list ini ke [] untuk menguji keadaan kosong
final List<Penjualan> daftarPenjualan = [
  Penjualan(
    tanggal: DateTime.now().subtract(const Duration(days: 1)),
    items: const [
      PenjualanItem(
        menuId: 'menu1',
        namaMenu: 'Es Teh Manis',
        jumlah: 10,
        tingkatGula: 'Normal',
        subtotal: 50000,
        biayaBahan: 7750,
      ),
      PenjualanItem(
        menuId: 'menu2',
        namaMenu: 'Es Teh Susu',
        jumlah: 5,
        tingkatGula: 'Less',
        subtotal: 35000,
        biayaBahan: 5450,
      ),
    ],
    total: 85000,
  ),
  Penjualan(
    tanggal: DateTime.now().subtract(const Duration(days: 2)),
    items: const [
      PenjualanItem(
        menuId: 'menu3',
        namaMenu: 'Es Teh Lemon',
        jumlah: 8,
        tingkatGula: 'Extra',
        subtotal: 64000,
        biayaBahan: 5600,
      ),
      PenjualanItem(
        menuId: 'menu1',
        namaMenu: 'Es Teh Manis',
        jumlah: 12,
        tingkatGula: 'Normal',
        subtotal: 60000,
        biayaBahan: 9300,
      ),
    ],
    total: 124000,
  ),
  Penjualan(
    tanggal: DateTime.now().subtract(const Duration(days: 3)),
    items: const [
      PenjualanItem(
        menuId: 'menu2',
        namaMenu: 'Es Teh Susu',
        jumlah: 7,
        tingkatGula: 'Normal',
        subtotal: 49000,
        biayaBahan: 7630,
      ),
    ],
    total: 49000,
  ),
];

// ===== Fungsi bantu =====

/// Format rupiah sederhana
String formatRupiah(int nilai) {
  String str = nilai.toString();
  String hasil = '';
  int count = 0;
  for (int i = str.length - 1; i >= 0; i--) {
    if (count > 0 && count % 3 == 0) {
      hasil = '.$hasil';
    }
    hasil = str[i] + hasil;
    count++;
  }
  return 'Rp $hasil';
}

/// Format angka desimal tanpa nol di belakang koma (110.0 -> "110")
String formatJumlah(double nilai) {
  if (nilai == nilai.roundToDouble()) return nilai.toStringAsFixed(0);
  return nilai.toStringAsFixed(1);
}

/// Hitung status stok bahan
/// return: 'Aman', 'Menipis', atau 'Habis'
String statusStok(Bahan bahan) {
  if (bahan.stok <= 0) return 'Habis';
  if (bahan.stok <= bahan.stokMinimum) return 'Menipis';
  return 'Aman';
}

/// Cari bahan berdasarkan id
Bahan? bahanById(String id) {
  for (final b in daftarBahan) {
    if (b.id == id) return b;
  }
  return null;
}

/// Cari menu berdasarkan id
Menu? menuById(String id) {
  for (final m in daftarMenu) {
    if (m.id == id) return m;
  }
  return null;
}

/// Resep milik satu menu
List<ResepItem> resepUntukMenu(String menuId) =>
    daftarResep.where((r) => r.menuId == menuId).toList();

/// Biaya bahan untuk satu gelas menu, dihitung dari resep × biaya per satuan.
/// Mengembalikan 0 kalau menu belum punya resep.
int biayaBahanMenu(String menuId) {
  double biaya = 0;
  for (final r in resepUntukMenu(menuId)) {
    final bahan = bahanById(r.bahanId);
    if (bahan == null) continue;
    biaya += bahan.biayaPerSatuan * r.jumlahPerGelas;
  }
  return biaya.round();
}

/// Kebutuhan tiap bahan untuk sejumlah gelas satu menu.
/// Hasil: bahanId -> jumlah yang dibutuhkan.
Map<String, double> kebutuhanBahan(String menuId, int jumlahGelas) {
  final hasil = <String, double>{};
  for (final r in resepUntukMenu(menuId)) {
    hasil[r.bahanId] =
        (hasil[r.bahanId] ?? 0) + r.jumlahPerGelas * jumlahGelas;
  }
  return hasil;
}

/// B3 — periksa kecukupan stok untuk seluruh keranjang.
/// Mengembalikan null kalau semua cukup, atau pesan kekurangan kalau tidak.
String? cekKecukupanStok(Map<String, int> keranjang) {
  for (final entry in keranjang.entries) {
    if (entry.value <= 0) continue;
    final kebutuhan = kebutuhanBahan(entry.key, entry.value);
    for (final butuh in kebutuhan.entries) {
      final bahan = bahanById(butuh.key);
      if (bahan == null) continue;
      if (bahan.stok < butuh.value) {
        final kurang = butuh.value - bahan.stok;
        return 'Stok bahan tidak cukup — ${bahan.nama} kurang '
            '${formatJumlah(kurang)} ${bahan.satuan}';
      }
    }
  }
  return null;
}

/// B1 + B2 + B3 — simpan penjualan.
///
/// Langkah:
/// 1. Validasi kecukupan stok (B3). Kalau kurang, tidak ada data yang berubah.
/// 2. Hitung subtotal dan biaya bahan tiap baris dari resep (B2).
/// 3. Kurangi stok bahan sesuai resep (B1).
/// 4. Tambah satu entri penjualan ke daftarPenjualan.
///
/// Di Firestore nanti langkah 3 dan 4 ditulis dalam satu batch, supaya stok
/// tidak pernah berkurang tanpa penjualan yang sah.
HasilSimpan simpanPenjualan({
  required Map<String, int> keranjang,
  required Map<String, String> gula,
}) {
  final itemTerpilih =
      keranjang.entries.where((e) => e.value > 0).toList(growable: false);
  if (itemTerpilih.isEmpty) {
    return const HasilSimpan(false, 'Lengkapi data — pilih minimal 1 menu');
  }

  // 1. B3 — validasi dulu, sebelum satu pun data diubah
  final kekurangan = cekKecukupanStok(keranjang);
  if (kekurangan != null) {
    return HasilSimpan(false, kekurangan);
  }

  // 2. B2 — susun baris penjualan lengkap dengan biaya bahan
  final items = <PenjualanItem>[];
  int total = 0;
  for (final entry in itemTerpilih) {
    final menu = menuById(entry.key);
    if (menu == null) continue;
    final subtotal = menu.harga * entry.value;
    final biaya = biayaBahanMenu(menu.id) * entry.value;
    items.add(
      PenjualanItem(
        menuId: menu.id,
        namaMenu: menu.nama,
        jumlah: entry.value,
        tingkatGula: gula[menu.id] ?? 'Normal',
        subtotal: subtotal,
        biayaBahan: biaya,
      ),
    );
    total += subtotal;
  }

  if (items.isEmpty) {
    return const HasilSimpan(false, 'Lengkapi data — menu tidak ditemukan');
  }

  // 3. B1 — kurangi stok bahan sesuai resep
  for (final item in items) {
    final kebutuhan = kebutuhanBahan(item.menuId, item.jumlah);
    for (final butuh in kebutuhan.entries) {
      final bahan = bahanById(butuh.key);
      if (bahan == null) continue;
      bahan.stok -= butuh.value;
      if (bahan.stok < 0) bahan.stok = 0;
    }
  }

  // 4. Catat penjualan
  daftarPenjualan.add(
    Penjualan(tanggal: DateTime.now(), items: items, total: total),
  );

  // 5. Beri tahu tampilan bahwa stok dan penjualan sudah berubah
  tandaiDataBerubah();

  return HasilSimpan(true, 'Penjualan tersimpan — Total ${formatRupiah(total)}');
}
