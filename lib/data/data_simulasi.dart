/// Model data dan logika inti Aplikasi Es Teh.
///
/// Sejak Minggu 10 data disimpan di Cloud Firestore. File ini berisi:
/// - model + toMap()/fromMap() untuk dokumen Firestore
/// - data awal (dipakai untuk auto-seed collection menu & bahan)
/// - logika murni tanpa Firebase, sehingga bisa diuji dengan unit test:
///   B1 pengurangan stok sesuai resep, B2 laba kotor dari resep,
///   B3 validasi kecukupan stok.
library;

// ===== Bantu konversi angka dari Firestore =====
// Firestore bisa mengembalikan int atau double untuk field angka.
double _keDouble(Object? v) => (v as num?)?.toDouble() ?? 0;
int _keInt(Object? v) => (v as num?)?.toInt() ?? 0;

// ===== Model =====

/// Profil pengguna — collection `users`, Document ID = uid Firebase Auth.
class Pengguna {
  final String idPengguna;
  final String namaLengkap;
  final String email;
  final String peran;

  const Pengguna({
    required this.idPengguna,
    required this.namaLengkap,
    required this.email,
    this.peran = 'pemilik',
  });

  factory Pengguna.fromMap(String id, Map<String, dynamic> d) => Pengguna(
        idPengguna: id,
        namaLengkap: (d['nama_lengkap'] as String?) ?? '',
        email: (d['email'] as String?) ?? '',
        peran: (d['peran'] as String?) ?? 'pemilik',
      );
}

/// Satu baris resep: kebutuhan satu bahan untuk satu gelas.
/// Disimpan DI DALAM dokumen menu (denormalisasi): nama_bahan ikut disalin
/// supaya halaman Resep tidak perlu membaca collection bahan lagi.
class ResepItem {
  final String bahanId;
  final String namaBahan;
  final double jumlahPerGelas;

  const ResepItem({
    required this.bahanId,
    required this.namaBahan,
    required this.jumlahPerGelas,
  });

  Map<String, dynamic> toMap() => {
        'id_bahan': bahanId,
        'nama_bahan': namaBahan,
        'jumlah_per_gelas': jumlahPerGelas,
      };

  factory ResepItem.fromMap(Map<String, dynamic> d) => ResepItem(
        bahanId: (d['id_bahan'] as String?) ?? '',
        namaBahan: (d['nama_bahan'] as String?) ?? '',
        jumlahPerGelas: _keDouble(d['jumlah_per_gelas']),
      );
}

/// Menu — collection `menu`.
class Menu {
  final String id;
  final String nama;
  final String kategori;
  final int harga;
  final bool ketersediaan;
  final List<ResepItem> resep;
  final DateTime? dibuatPada;

  const Menu({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.harga,
    required this.ketersediaan,
    this.resep = const [],
    this.dibuatPada,
  });

  Map<String, dynamic> toMap() => {
        'id_menu': id,
        'nama': nama,
        'kategori': kategori,
        'harga': harga,
        'tersedia': ketersediaan,
        'resep': resep.map((r) => r.toMap()).toList(),
      };

  factory Menu.fromMap(String id, Map<String, dynamic> d, {DateTime? dibuatPada}) =>
      Menu(
        id: id,
        nama: (d['nama'] as String?) ?? '',
        kategori: (d['kategori'] as String?) ?? '',
        harga: _keInt(d['harga']),
        ketersediaan: (d['tersedia'] as bool?) ?? true,
        resep: ((d['resep'] as List?) ?? const [])
            .map((r) => ResepItem.fromMap(Map<String, dynamic>.from(r as Map)))
            .toList(),
        dibuatPada: dibuatPada,
      );
}

/// Bahan baku — collection `bahan`.
class Bahan {
  final String id;
  final String nama;
  final String satuan;
  final double stok;
  final double stokMinimum;

  /// Harga satu kemasan beli (mis. 1 pack teh 500 gram = Rp 25.000).
  final int hargaBeli;

  /// Jumlah satuan di dalam satu kemasan (mis. 500 gram per pack).
  final double isiKemasan;

  const Bahan({
    required this.id,
    required this.nama,
    required this.satuan,
    required this.stok,
    required this.stokMinimum,
    required this.hargaBeli,
    required this.isiKemasan,
  });

  /// Biaya satu satuan bahan (rupiah per gram / ml / pcs).
  double get biayaPerSatuan => isiKemasan == 0 ? 0 : hargaBeli / isiKemasan;

  Bahan denganStok(double stokBaru) => Bahan(
        id: id,
        nama: nama,
        satuan: satuan,
        stok: stokBaru,
        stokMinimum: stokMinimum,
        hargaBeli: hargaBeli,
        isiKemasan: isiKemasan,
      );

  Map<String, dynamic> toMap() => {
        'id_bahan': id,
        'nama': nama,
        'satuan': satuan,
        'stok': stok,
        'stok_minimum': stokMinimum,
        'harga_beli': hargaBeli,
        'isi_kemasan': isiKemasan,
      };

  factory Bahan.fromMap(String id, Map<String, dynamic> d) => Bahan(
        id: id,
        nama: (d['nama'] as String?) ?? '',
        satuan: (d['satuan'] as String?) ?? '',
        stok: _keDouble(d['stok']),
        stokMinimum: _keDouble(d['stok_minimum']),
        hargaBeli: _keInt(d['harga_beli']),
        isiKemasan: _keDouble(d['isi_kemasan']),
      );
}

/// Satu baris penjualan. nama_menu disalin (denormalisasi) supaya Laporan
/// tidak perlu membaca collection menu; biaya_bahan disimpan agar laba kotor
/// tetap benar walau harga bahan berubah di kemudian hari.
class PenjualanItem {
  final String menuId;
  final String namaMenu;
  final int jumlah;
  final String tingkatGula;
  final int subtotal;
  final int biayaBahan;

  const PenjualanItem({
    required this.menuId,
    required this.namaMenu,
    required this.jumlah,
    required this.tingkatGula,
    required this.subtotal,
    required this.biayaBahan,
  });

  int get labaKotor => subtotal - biayaBahan;

  Map<String, dynamic> toMap() => {
        'id_menu': menuId,
        'nama_menu': namaMenu,
        'jumlah': jumlah,
        'tingkat_gula': tingkatGula,
        'subtotal': subtotal,
        'biaya_bahan': biayaBahan,
      };

  factory PenjualanItem.fromMap(Map<String, dynamic> d) => PenjualanItem(
        menuId: (d['id_menu'] as String?) ?? '',
        namaMenu: (d['nama_menu'] as String?) ?? '',
        jumlah: _keInt(d['jumlah']),
        tingkatGula: (d['tingkat_gula'] as String?) ?? 'Normal',
        subtotal: _keInt(d['subtotal']),
        biayaBahan: _keInt(d['biaya_bahan']),
      );
}

/// Penjualan — collection `penjualan`, satu dokumen per transaksi.
class Penjualan {
  final String id;
  final String idPengguna;
  final DateTime tanggal;
  final List<PenjualanItem> items;
  final int total;

  const Penjualan({
    this.id = '',
    this.idPengguna = '',
    required this.tanggal,
    required this.items,
    required this.total,
  });

  int get totalBiayaBahan => items.fold(0, (sum, item) => sum + item.biayaBahan);

  /// Laba kotor = total penjualan − total biaya bahan.
  int get labaKotor => total - totalBiayaBahan;

  Map<String, dynamic> toMap() => {
        'id_penjualan': id,
        'id_pengguna': idPengguna,
        'total': total,
        'biaya_bahan': totalBiayaBahan,
        'laba_kotor': labaKotor,
        'items': items.map((i) => i.toMap()).toList(),
      };

  factory Penjualan.fromMap(String id, Map<String, dynamic> d, {required DateTime tanggal}) =>
      Penjualan(
        id: id,
        idPengguna: (d['id_pengguna'] as String?) ?? '',
        tanggal: tanggal,
        total: _keInt(d['total']),
        items: ((d['items'] as List?) ?? const [])
            .map((i) => PenjualanItem.fromMap(Map<String, dynamic>.from(i as Map)))
            .toList(),
      );
}

/// Hasil percobaan menyimpan penjualan.
class HasilSimpan {
  final bool berhasil;
  final String pesan;

  const HasilSimpan(this.berhasil, this.pesan);
}

// ===== Data awal (auto-seed Firestore & data uji) =====

/// Menu awal. Resep ada di dalam setiap menu.
const List<Menu> menuAwal = [
  Menu(
    id: 'menu1',
    nama: 'Es Teh Manis',
    kategori: 'Es Teh',
    harga: 5000,
    ketersediaan: true,
    resep: [
      ResepItem(bahanId: 'bahan1', namaBahan: 'Teh', jumlahPerGelas: 5),
      ResepItem(bahanId: 'bahan2', namaBahan: 'Gula', jumlahPerGelas: 15),
      ResepItem(bahanId: 'bahan4', namaBahan: 'Gelas', jumlahPerGelas: 1),
    ],
  ),
  Menu(
    id: 'menu2',
    nama: 'Es Teh Susu',
    kategori: 'Es Teh Susu',
    harga: 7000,
    ketersediaan: true,
    resep: [
      ResepItem(bahanId: 'bahan1', namaBahan: 'Teh', jumlahPerGelas: 5),
      ResepItem(bahanId: 'bahan3', namaBahan: 'Susu', jumlahPerGelas: 30),
      ResepItem(bahanId: 'bahan4', namaBahan: 'Gelas', jumlahPerGelas: 1),
    ],
  ),
  Menu(
    id: 'menu3',
    nama: 'Es Teh Lemon',
    kategori: 'Es Teh Lemon',
    harga: 8000,
    ketersediaan: true,
    resep: [
      ResepItem(bahanId: 'bahan1', namaBahan: 'Teh', jumlahPerGelas: 5),
      ResepItem(bahanId: 'bahan2', namaBahan: 'Gula', jumlahPerGelas: 10),
      ResepItem(bahanId: 'bahan4', namaBahan: 'Gelas', jumlahPerGelas: 1),
    ],
  ),
  Menu(
    id: 'menu4',
    nama: 'Es Teh Tarik',
    kategori: 'Es Teh Tarik',
    harga: 8000,
    ketersediaan: false,
  ),
];

/// Bahan awal. Stok gula sengaja di bawah minimum agar status Menipis
/// dan penolakan stok tidak cukup mudah didemokan.
const List<Bahan> bahanAwal = [
  Bahan(id: 'bahan1', nama: 'Teh', satuan: 'gram', stok: 110, stokMinimum: 100, hargaBeli: 25000, isiKemasan: 500),
  Bahan(id: 'bahan2', nama: 'Gula', satuan: 'gram', stok: 110, stokMinimum: 200, hargaBeli: 15000, isiKemasan: 1000),
  Bahan(id: 'bahan3', nama: 'Susu', satuan: 'ml', stok: 500, stokMinimum: 100, hargaBeli: 18000, isiKemasan: 1000),
  Bahan(id: 'bahan4', nama: 'Gelas', satuan: 'pcs', stok: 200, stokMinimum: 50, hargaBeli: 15000, isiKemasan: 50),
];

// ===== Fungsi bantu tampilan =====

/// Format rupiah sederhana: 12500 → "Rp 12.500"
String formatRupiah(int nilai) {
  final negatif = nilai < 0;
  final str = nilai.abs().toString();
  var hasil = '';
  for (var i = 0; i < str.length; i++) {
    if (i > 0 && (str.length - i) % 3 == 0) hasil += '.';
    hasil += str[i];
  }
  return 'Rp ${negatif ? '-' : ''}$hasil';
}

/// Format angka desimal tanpa nol di belakang koma (110.0 → "110")
String formatJumlah(double nilai) {
  if (nilai == nilai.roundToDouble()) return nilai.toStringAsFixed(0);
  return nilai.toStringAsFixed(1);
}

/// Status stok: 'Aman', 'Menipis', atau 'Habis'
String statusStok(Bahan bahan) {
  if (bahan.stok <= 0) return 'Habis';
  if (bahan.stok <= bahan.stokMinimum) return 'Menipis';
  return 'Aman';
}

// ===== Logika inti (murni, tanpa Firebase) =====

Bahan? _cariBahan(List<Bahan> daftar, String id) {
  for (final b in daftar) {
    if (b.id == id) return b;
  }
  return null;
}

Menu? cariMenu(List<Menu> daftar, String id) {
  for (final m in daftar) {
    if (m.id == id) return m;
  }
  return null;
}

/// B2 — biaya bahan satu gelas = Σ (jumlah per gelas × biaya per satuan).
int biayaBahanMenu(Menu menu, List<Bahan> daftarBahan) {
  double biaya = 0;
  for (final r in menu.resep) {
    final bahan = _cariBahan(daftarBahan, r.bahanId);
    if (bahan == null) continue;
    biaya += bahan.biayaPerSatuan * r.jumlahPerGelas;
  }
  return biaya.round();
}

/// Kebutuhan tiap bahan untuk seluruh keranjang: bahanId → jumlah.
Map<String, double> kebutuhanBahanKeranjang(Map<String, int> keranjang, List<Menu> daftarMenu) {
  final hasil = <String, double>{};
  for (final entry in keranjang.entries) {
    if (entry.value <= 0) continue;
    final menu = cariMenu(daftarMenu, entry.key);
    if (menu == null) continue;
    for (final r in menu.resep) {
      hasil[r.bahanId] = (hasil[r.bahanId] ?? 0) + r.jumlahPerGelas * entry.value;
    }
  }
  return hasil;
}

/// B3 — null bila stok cukup; pesan kekurangan bila tidak.
String? cekKecukupanStok(Map<String, int> keranjang, List<Menu> daftarMenu, List<Bahan> daftarBahan) {
  final kebutuhan = kebutuhanBahanKeranjang(keranjang, daftarMenu);
  for (final butuh in kebutuhan.entries) {
    final bahan = _cariBahan(daftarBahan, butuh.key);
    if (bahan == null) continue;
    if (bahan.stok < butuh.value) {
      final kurang = butuh.value - bahan.stok;
      return 'Stok bahan tidak cukup — ${bahan.nama} kurang '
          '${formatJumlah(kurang)} ${bahan.satuan}';
    }
  }
  return null;
}

/// Rencana penulisan satu penjualan: data penjualan + stok baru tiap bahan.
/// Dipakai oleh LayananFirestore (di dalam transaction) dan LayananMemori.
class RencanaPenjualan {
  final Penjualan penjualan;

  /// bahanId → stok setelah dikurangi resep (B1)
  final Map<String, double> stokBaru;

  const RencanaPenjualan(this.penjualan, this.stokBaru);
}

/// Hasil penyusunan: berisi rencana bila valid, atau pesan penolakan.
class HasilSusun {
  final RencanaPenjualan? rencana;
  final String? pesanGagal;

  const HasilSusun.berhasil(RencanaPenjualan this.rencana) : pesanGagal = null;
  const HasilSusun.gagal(String this.pesanGagal) : rencana = null;
}

/// B1 + B2 + B3 — susun penjualan dari keranjang tanpa mengubah data apa pun.
HasilSusun susunPenjualan({
  required Map<String, int> keranjang,
  required Map<String, String> gula,
  required List<Menu> daftarMenu,
  required List<Bahan> daftarBahan,
  required String idPengguna,
  DateTime? tanggal,
}) {
  final terpilih = keranjang.entries.where((e) => e.value > 0).toList();
  if (terpilih.isEmpty) {
    return const HasilSusun.gagal('Lengkapi data — pilih minimal 1 menu');
  }

  // B3 — validasi dulu sebelum menyusun perubahan
  final kekurangan = cekKecukupanStok(keranjang, daftarMenu, daftarBahan);
  if (kekurangan != null) return HasilSusun.gagal(kekurangan);

  // B2 — baris penjualan beserta biaya bahan
  final items = <PenjualanItem>[];
  var total = 0;
  for (final e in terpilih) {
    final menu = cariMenu(daftarMenu, e.key);
    if (menu == null) continue;
    final subtotal = menu.harga * e.value;
    items.add(PenjualanItem(
      menuId: menu.id,
      namaMenu: menu.nama,
      jumlah: e.value,
      tingkatGula: gula[menu.id] ?? 'Normal',
      subtotal: subtotal,
      biayaBahan: biayaBahanMenu(menu, daftarBahan) * e.value,
    ));
    total += subtotal;
  }
  if (items.isEmpty) {
    return const HasilSusun.gagal('Lengkapi data — menu tidak ditemukan');
  }

  // B1 — stok baru tiap bahan sesuai resep
  final stokBaru = <String, double>{};
  kebutuhanBahanKeranjang(keranjang, daftarMenu).forEach((bahanId, butuh) {
    final bahan = _cariBahan(daftarBahan, bahanId);
    if (bahan == null) return;
    final sisa = bahan.stok - butuh;
    stokBaru[bahanId] = sisa < 0 ? 0 : sisa;
  });

  return HasilSusun.berhasil(RencanaPenjualan(
    Penjualan(
      idPengguna: idPengguna,
      tanggal: tanggal ?? DateTime.now(),
      items: items,
      total: total,
    ),
    stokBaru,
  ));
}

/// Validasi nama menu baru (dipakai form & layanan).
String? validasiNamaMenu(String? value, List<Menu> daftarMenu) {
  final nama = value?.trim() ?? '';
  if (nama.isEmpty) return 'Nama menu tidak boleh kosong';
  if (nama.length < 3) return 'Nama menu minimal 3 karakter';
  final sudahAda = daftarMenu.any((m) => m.nama.toLowerCase() == nama.toLowerCase());
  if (sudahAda) return 'Nama menu sudah ada, gunakan nama lain';
  return null;
}
