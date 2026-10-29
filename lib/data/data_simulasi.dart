/// Data simulasi untuk Aplikasi Es Teh
/// Data ini menggantikan Firebase sementara (sesuai batasan Minggu 6)
library;


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
  final double stok;
  final double stokMinimum;
  final int hargaBeli;

  const Bahan({
    required this.id,
    required this.nama,
    required this.satuan,
    required this.stok,
    required this.stokMinimum,
    required this.hargaBeli,
  });
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
  final String namaMenu;
  final int jumlah;
  final String tingkatGula;
  final int subtotal;

  const PenjualanItem({
    required this.namaMenu,
    required this.jumlah,
    required this.tingkatGula,
    required this.subtotal,
  });
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

/// Daftar bahan baku — mutable untuk persiapan Minggu 8+
/// Ubah list ini ke [] untuk menguji keadaan kosong
final List<Bahan> daftarBahan = [
  Bahan(
    id: 'bahan1',
    nama: 'Teh',
    satuan: 'gram',
    stok: 500,
    stokMinimum: 100,
    hargaBeli: 5000,
  ),
  Bahan(
    id: 'bahan2',
    nama: 'Gula',
    satuan: 'gram',
    stok: 80,
    stokMinimum: 200,
    hargaBeli: 3000,
  ),
  Bahan(
    id: 'bahan3',
    nama: 'Susu',
    satuan: 'ml',
    stok: 500,
    stokMinimum: 100,
    hargaBeli: 8000,
  ),
  Bahan(
    id: 'bahan4',
    nama: 'Gelas',
    satuan: 'pcs',
    stok: 200,
    stokMinimum: 50,
    hargaBeli: 500,
  ),
];

/// Resep untuk menu yang ada (contoh: Es Teh Manis)
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

/// Data penjualan simulasi untuk Laporan
/// Ubah list ini ke [] untuk menguji keadaan kosong
final List<Penjualan> daftarPenjualan = [
  Penjualan(
    tanggal: DateTime.now().subtract(const Duration(days: 1)),
    items: [
      const PenjualanItem(namaMenu: 'Es Teh Manis', jumlah: 10, tingkatGula: 'Normal', subtotal: 50000),
      const PenjualanItem(namaMenu: 'Es Teh Susu', jumlah: 5, tingkatGula: 'Less', subtotal: 35000),
    ],
    total: 85000,
  ),
  Penjualan(
    tanggal: DateTime.now().subtract(const Duration(days: 2)),
    items: [
      const PenjualanItem(namaMenu: 'Es Teh Lemon', jumlah: 8, tingkatGula: 'Extra', subtotal: 64000),
      const PenjualanItem(namaMenu: 'Es Teh Manis', jumlah: 12, tingkatGula: 'Normal', subtotal: 60000),
    ],
    total: 124000,
  ),
  Penjualan(
    tanggal: DateTime.now().subtract(const Duration(days: 3)),
    items: [
      const PenjualanItem(namaMenu: 'Es Teh Susu', jumlah: 7, tingkatGula: 'Normal', subtotal: 49000),
    ],
    total: 49000,
  ),
];

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

/// Hitung status stok bahan
/// return: 'Aman', 'Menipis', atau 'Habis'
String statusStok(Bahan bahan) {
  if (bahan.stok <= 0) return 'Habis';
  if (bahan.stok <= bahan.stokMinimum) return 'Menipis';
  return 'Aman';
}
