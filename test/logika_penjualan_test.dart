import 'package:flutter_test/flutter_test.dart';

import 'package:es_teh_app/data/data_simulasi.dart';

/// Pengujian logika inti Minggu 8:
/// B1 pengurangan stok otomatis, B2 laba kotor dari resep,
/// B3 validasi kecukupan stok.
void main() {
  // Simpan kondisi awal supaya tiap tes mulai dari angka yang sama
  late Map<String, double> stokAwal;
  late int jumlahPenjualanAwal;

  setUp(() {
    stokAwal = {for (final b in daftarBahan) b.id: b.stok};
    jumlahPenjualanAwal = daftarPenjualan.length;
  });

  tearDown(() {
    for (final b in daftarBahan) {
      b.stok = stokAwal[b.id]!;
    }
    while (daftarPenjualan.length > jumlahPenjualanAwal) {
      daftarPenjualan.removeLast();
    }
  });

  test('B2 — biaya bahan per gelas dihitung dari resep × biaya per satuan', () {
    // Es Teh Manis: 5 g teh (Rp 250) + 15 g gula (Rp 225) + 1 gelas (Rp 300)
    expect(biayaBahanMenu('menu1'), 775);
    // Es Teh Susu: 5 g teh + 30 ml susu (Rp 540) + 1 gelas
    expect(biayaBahanMenu('menu2'), 1090);
    // Es Teh Lemon: 5 g teh + 10 g gula (Rp 150) + 1 gelas
    expect(biayaBahanMenu('menu3'), 700);
    // Menu tanpa resep tidak punya biaya bahan
    expect(biayaBahanMenu('menu4'), 0);
  });

  test('Data penjualan simulasi konsisten dengan resep', () {
    for (final p in daftarPenjualan) {
      for (final item in p.items) {
        expect(
          item.biayaBahan,
          biayaBahanMenu(item.menuId) * item.jumlah,
          reason: 'biaya bahan ${item.namaMenu} tidak cocok dengan resep',
        );
        expect(item.subtotal, item.jumlah * (menuById(item.menuId)!.harga));
      }
      expect(p.labaKotor, p.total - p.totalBiayaBahan);
    }
  });

  test('B1 — menyimpan penjualan mengurangi stok sesuai resep', () {
    final teh = bahanById('bahan1')!;
    final gula = bahanById('bahan2')!;
    final gelas = bahanById('bahan4')!;

    final stokTehAwal = teh.stok;
    final stokGulaAwal = gula.stok;
    final stokGelasAwal = gelas.stok;

    // Dua gelas Es Teh Manis
    final hasil = simpanPenjualan(
      keranjang: {'menu1': 2},
      gula: {'menu1': 'Normal'},
    );

    expect(hasil.berhasil, isTrue);
    expect(teh.stok, stokTehAwal - 10); // 2 × 5 gram
    expect(gula.stok, stokGulaAwal - 30); // 2 × 15 gram
    expect(gelas.stok, stokGelasAwal - 2); // 2 × 1 gelas
  });

  test('B1 + B2 — penjualan tercatat dengan total dan laba kotor benar', () {
    final hasil = simpanPenjualan(
      keranjang: {'menu1': 2},
      gula: {'menu1': 'Normal'},
    );

    expect(hasil.berhasil, isTrue);
    expect(daftarPenjualan.length, jumlahPenjualanAwal + 1);

    final terakhir = daftarPenjualan.last;
    expect(terakhir.total, 10000); // 2 × Rp 5.000
    expect(terakhir.totalBiayaBahan, 1550); // 2 × Rp 775
    expect(terakhir.labaKotor, 8450);
  });

  test('B3 — stok tidak cukup ditolak, data tidak berubah', () {
    // Setelah dua gelas terjual, stok gula tinggal 80 gram.
    simpanPenjualan(keranjang: {'menu1': 2}, gula: {'menu1': 'Normal'});

    final stokSebelum = {for (final b in daftarBahan) b.id: b.stok};
    final penjualanSebelum = daftarPenjualan.length;

    // Enam gelas butuh 90 gram gula — melebihi stok 80 gram.
    final hasil = simpanPenjualan(
      keranjang: {'menu1': 6},
      gula: {'menu1': 'Normal'},
    );

    expect(hasil.berhasil, isFalse);
    expect(hasil.pesan, contains('Stok bahan tidak cukup'));
    expect(hasil.pesan, contains('Gula'));

    // Tidak ada stok yang berkurang dan tidak ada penjualan tercatat
    for (final b in daftarBahan) {
      expect(b.stok, stokSebelum[b.id]);
    }
    expect(daftarPenjualan.length, penjualanSebelum);
  });

  test('Keranjang kosong ditolak dengan pesan Lengkapi data', () {
    final hasil = simpanPenjualan(keranjang: {}, gula: {});

    expect(hasil.berhasil, isFalse);
    expect(hasil.pesan, contains('Lengkapi data'));
    expect(daftarPenjualan.length, jumlahPenjualanAwal);
  });

  test('Status stok mengikuti batas minimum', () {
    final teh = bahanById('bahan1')!;
    teh.stok = 50; // di bawah minimum 100
    expect(statusStok(teh), 'Menipis');

    teh.stok = 0;
    expect(statusStok(teh), 'Habis');

    teh.stok = 500;
    expect(statusStok(teh), 'Aman');
  });
}
