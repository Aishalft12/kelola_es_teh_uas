import 'package:flutter_test/flutter_test.dart';

import 'package:es_teh_app/data/data_simulasi.dart';
import 'package:es_teh_app/services/layanan_memori.dart';

/// Pengujian logika inti (tanpa Firebase):
/// B1 pengurangan stok, B2 laba kotor dari resep, B3 validasi stok,
/// serta isolasi penjualan antar-pengguna (Minggu 10).
void main() {
  Menu menu(String id) => cariMenu(menuAwal, id)!;
  Bahan bahan(LayananMemori l, String id) => l.bahanSaatIni.firstWhere((b) => b.id == id);

  test('B2 — biaya bahan per gelas dihitung dari resep × biaya per satuan', () {
    // Es Teh Manis: 5 g teh (Rp 250) + 15 g gula (Rp 225) + 1 gelas (Rp 300)
    expect(biayaBahanMenu(menu('menu1'), bahanAwal), 775);
    // Es Teh Susu: 5 g teh + 30 ml susu (Rp 540) + 1 gelas
    expect(biayaBahanMenu(menu('menu2'), bahanAwal), 1090);
    // Es Teh Lemon: 5 g teh + 10 g gula (Rp 150) + 1 gelas
    expect(biayaBahanMenu(menu('menu3'), bahanAwal), 700);
    // Menu tanpa resep tidak punya biaya bahan
    expect(biayaBahanMenu(menu('menu4'), bahanAwal), 0);
  });

  test('Model menu & penjualan bolak-balik toMap/fromMap tanpa kehilangan data', () {
    final m = menu('menu1');
    final kembali = Menu.fromMap(m.id, m.toMap());
    expect(kembali.nama, m.nama);
    expect(kembali.harga, m.harga);
    expect(kembali.resep.length, 3);
    expect(kembali.resep[1].namaBahan, 'Gula');
    expect(kembali.resep[1].jumlahPerGelas, 15);

    final b = Bahan.fromMap('bahan2', bahanAwal[1].toMap());
    expect(b.stok, 110);
    expect(b.biayaPerSatuan, 15);
  });

  test('B1 — menyimpan penjualan mengurangi stok sesuai resep', () async {
    final layanan = LayananMemori();

    // Dua gelas Es Teh Manis
    final hasil = await layanan.simpanPenjualan(
      keranjang: {'menu1': 2},
      gula: {'menu1': 'Normal'},
      daftarMenu: menuAwal,
    );

    expect(hasil.berhasil, isTrue);
    expect(bahan(layanan, 'bahan1').stok, 100); // teh 110 − 2 × 5
    expect(bahan(layanan, 'bahan2').stok, 80); // gula 110 − 2 × 15
    expect(bahan(layanan, 'bahan4').stok, 198); // gelas 200 − 2
  });

  test('B1 + B2 — penjualan tercatat dengan total dan laba kotor benar', () async {
    final layanan = LayananMemori();
    await layanan.simpanPenjualan(
      keranjang: {'menu1': 2},
      gula: {'menu1': 'Normal'},
      daftarMenu: menuAwal,
    );

    expect(layanan.semuaPenjualan.length, 1);
    final p = layanan.semuaPenjualan.single;
    expect(p.total, 10000); // 2 × Rp 5.000
    expect(p.totalBiayaBahan, 1550); // 2 × Rp 775
    expect(p.labaKotor, 8450);
    expect(p.idPengguna, 'uji-1');
  });

  test('B3 — stok tidak cukup ditolak, data tidak berubah', () async {
    final layanan = LayananMemori();
    final stokSebelum = {for (final b in layanan.bahanSaatIni) b.id: b.stok};

    // Delapan gelas butuh 120 gram gula — melebihi stok 110 gram.
    final hasil = await layanan.simpanPenjualan(
      keranjang: {'menu1': 8},
      gula: {'menu1': 'Normal'},
      daftarMenu: menuAwal,
    );

    expect(hasil.berhasil, isFalse);
    expect(hasil.pesan, 'Stok bahan tidak cukup — Gula kurang 10 gram');
    for (final b in layanan.bahanSaatIni) {
      expect(b.stok, stokSebelum[b.id]);
    }
    expect(layanan.semuaPenjualan, isEmpty);
  });

  test('Keranjang kosong ditolak dengan pesan Lengkapi data', () async {
    final layanan = LayananMemori();
    final hasil = await layanan.simpanPenjualan(keranjang: {}, gula: {}, daftarMenu: menuAwal);

    expect(hasil.berhasil, isFalse);
    expect(hasil.pesan, contains('Lengkapi data'));
    expect(layanan.semuaPenjualan, isEmpty);
  });

  test('Isolasi akun — penjualan akun pertama tidak tampil di akun kedua', () async {
    final layanan = LayananMemori(uidAktif: 'akun-a');
    await layanan.simpanPenjualan(keranjang: {'menu1': 1}, gula: {}, daftarMenu: menuAwal);

    expect((await layanan.streamPenjualanSaya().first).length, 1);

    layanan.uidAktif = 'akun-b';
    expect(await layanan.streamPenjualanSaya().first, isEmpty);
  });

  test('Status stok mengikuti batas minimum', () {
    final teh = bahanAwal.first; // minimum 100
    expect(statusStok(teh.denganStok(50)), 'Menipis');
    expect(statusStok(teh.denganStok(0)), 'Habis');
    expect(statusStok(teh.denganStok(500)), 'Aman');
  });

  test('Profil pengguna: nama dari mode Daftar disimpan', () async {
    final layanan = LayananMemori(uidAktif: 'akun-a');
    await layanan.simpanPenggunaSaatLogin(uid: 'akun-a', email: 'pemilik@esteh.id', namaLengkap: 'Bu Rina');
    final profil = await layanan.streamPenggunaSaya().first;
    expect(profil?.namaLengkap, 'Bu Rina');

    // Masuk ulang tanpa nama tidak menimpa nama yang sudah ada
    await layanan.simpanPenggunaSaatLogin(uid: 'akun-a', email: 'pemilik@esteh.id');
    expect((await layanan.streamPenggunaSaya().first)?.namaLengkap, 'Bu Rina');
  });

  group('Minggu 11 — ubah & hapus penjualan', () {
    Future<String> jual(LayananMemori l, Map<String, int> keranjang) async {
      final hasil = await l.simpanPenjualan(keranjang: keranjang, gula: {}, daftarMenu: menuAwal);
      expect(hasil.berhasil, isTrue, reason: hasil.pesan);
      return l.semuaPenjualan.last.id;
    }

    test('Ubah valid — stok disesuaikan, pemilik & tanggal tetap', () async {
      final l = LayananMemori(uidAktif: 'akun-a');
      final id = await jual(l, {'menu1': 2}); // gula 110 → 80
      final tanggalAwal = l.semuaPenjualan.single.tanggal;

      final hasil = await l.ubahPenjualan(
        idPenjualan: id,
        keranjang: {'menu1': 3},
        gula: {'menu1': 'Less'},
        daftarMenu: menuAwal,
      );

      expect(hasil.berhasil, isTrue, reason: hasil.pesan);
      final p = l.semuaPenjualan.single;
      expect(p.total, 15000);
      expect(p.items.single.tingkatGula, 'Less');
      expect(p.idPengguna, 'akun-a'); // field audit tetap
      expect(p.tanggal, tanggalAwal);
      expect(p.status, statusTercatat);
      expect(p.diubahPada, isNotNull);
      expect(bahan(l, 'bahan2').stok, 65); // 110 − 3 × 15
      expect(bahan(l, 'bahan1').stok, 95); // 110 − 3 × 5
    });

    test('Ubah tanpa menambah jumlah tidak ditolak (stok lama dikembalikan dulu)', () async {
      final l = LayananMemori();
      final id = await jual(l, {'menu1': 2}); // gula 80
      await jual(l, {'menu1': 5}); // gula 5

      // Tetap 2 gelas: butuh 30 g, stok tinggal 5 g + 30 g milik penjualan ini
      final hasil = await l.ubahPenjualan(
        idPenjualan: id,
        keranjang: {'menu1': 2},
        gula: {'menu1': 'Extra'},
        daftarMenu: menuAwal,
      );

      expect(hasil.berhasil, isTrue, reason: hasil.pesan);
      expect(bahan(l, 'bahan2').stok, 5);
    });

    test('Ubah melebihi stok ditolak, data lama utuh', () async {
      final l = LayananMemori();
      final id = await jual(l, {'menu1': 2}); // gula 80

      final hasil = await l.ubahPenjualan(
        idPenjualan: id,
        keranjang: {'menu1': 8}, // butuh 120 g, tersedia 80 + 30 = 110 g
        gula: {},
        daftarMenu: menuAwal,
      );

      expect(hasil.berhasil, isFalse);
      expect(hasil.pesan, 'Stok bahan tidak cukup — Gula kurang 10 gram');
      expect(l.semuaPenjualan.single.total, 10000);
      expect(bahan(l, 'bahan2').stok, 80);
    });

    test('Ubah ke menu lain — bahan yang tidak dipakai lagi dikembalikan', () async {
      final l = LayananMemori();
      final id = await jual(l, {'menu1': 2}); // gula 80, susu 500

      final hasil = await l.ubahPenjualan(
        idPenjualan: id,
        keranjang: {'menu2': 1}, // Es Teh Susu: tanpa gula, 30 ml susu
        gula: {},
        daftarMenu: menuAwal,
      );

      expect(hasil.berhasil, isTrue, reason: hasil.pesan);
      expect(bahan(l, 'bahan2').stok, 110); // gula kembali utuh
      expect(bahan(l, 'bahan3').stok, 470);
    });

    test('Hapus mengembalikan stok dan menghilangkan penjualan', () async {
      final l = LayananMemori();
      final id = await jual(l, {'menu1': 2});

      final hasil = await l.hapusPenjualan(idPenjualan: id, daftarMenu: menuAwal);

      expect(hasil.berhasil, isTrue);
      expect(l.semuaPenjualan, isEmpty);
      expect(bahan(l, 'bahan2').stok, 110);
      expect(bahan(l, 'bahan4').stok, 200);
    });

    test('Status Dikunci tidak bisa diubah maupun dihapus', () async {
      final l = LayananMemori();
      final id = await jual(l, {'menu1': 1});
      l.aturStatusPenjualan(id, statusDikunci);

      final ubah = await l.ubahPenjualan(idPenjualan: id, keranjang: {'menu1': 2}, gula: {}, daftarMenu: menuAwal);
      final hapus = await l.hapusPenjualan(idPenjualan: id, daftarMenu: menuAwal);

      expect(ubah.berhasil, isFalse);
      expect(ubah.pesan, 'Penjualan berstatus Dikunci tidak bisa diubah.');
      expect(hapus.berhasil, isFalse);
      expect(l.semuaPenjualan.single.bisaDiubah, isFalse);
    });

    test('Penjualan milik akun lain ditolak', () async {
      final l = LayananMemori(uidAktif: 'akun-a');
      final id = await jual(l, {'menu1': 1});

      l.uidAktif = 'akun-b';
      final hasil = await l.hapusPenjualan(idPenjualan: id, daftarMenu: menuAwal);

      expect(hasil.berhasil, isFalse);
      expect(hasil.pesan, 'Penjualan ini bukan milik Anda, tidak bisa dihapus.');
      expect(l.semuaPenjualan.length, 1);
    });
  });
}
