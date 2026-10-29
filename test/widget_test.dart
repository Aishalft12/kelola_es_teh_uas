import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:es_teh_app/main.dart';
import 'package:es_teh_app/data/data_simulasi.dart';

void main() {
  // Helper: pump aplikasi dan navigasi ke halaman Menu
  Future<void> pumpAplikasi(WidgetTester tester) async {
    await tester.pumpWidget(const EsTehApp());
    await tester.pumpAndSettle();
  }

  // Helper: buka form Tambah Menu dari halaman Menu
  Future<void> bukaFormTambahMenu(WidgetTester tester) async {
    await pumpAplikasi(tester);
    await tester.tap(find.text('Tambah Menu'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'Kasus 1: Form kosong — validasi menolak, SnackBar error tampil',
    (WidgetTester tester) async {
      await bukaFormTambahMenu(tester);

      // Tap Simpan tanpa mengisi apa pun
      await tester.tap(find.text('Simpan Menu'));
      await tester.pumpAndSettle();

      // Pesan error validasi harus tampil
      expect(find.text('Nama menu tidak boleh kosong'), findsOneWidget);
      expect(find.text('Pilih kategori menu'), findsOneWidget);
      expect(find.text('Harga tidak boleh kosong'), findsOneWidget);

      // SnackBar error harus tampil
      expect(find.text('Periksa kembali data yang dimasukkan'), findsOneWidget);
    },
  );

  testWidgets(
    'Kasus 2: Nama kurang dari 3 karakter — validasi menolak',
    (WidgetTester tester) async {
      await bukaFormTambahMenu(tester);

      // Isi nama hanya 2 karakter
      await tester.enterText(find.byType(TextFormField).first, 'Es');

      // Pilih kategori
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Es Teh').last);
      await tester.pumpAndSettle();

      // Isi harga valid
      await tester.enterText(
        find.widgetWithIcon(TextFormField, Icons.attach_money),
        '5000',
      );

      // Tap Simpan
      await tester.tap(find.text('Simpan Menu'));
      await tester.pumpAndSettle();

      // Pesan error untuk nama terlalu pendek
      expect(find.text('Nama menu minimal 3 karakter'), findsOneWidget);
    },
  );

  testWidgets(
    'Kasus 3: Harga bukan angka — validasi menolak',
    (WidgetTester tester) async {
      await bukaFormTambahMenu(tester);

      // Isi nama valid
      await tester.enterText(find.byType(TextFormField).first, 'Es Teh Melon');

      // Pilih kategori
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Es Teh').last);
      await tester.pumpAndSettle();

      // Isi harga dengan teks (bukan angka)
      await tester.enterText(
        find.widgetWithIcon(TextFormField, Icons.attach_money),
        'mahal',
      );

      // Tap Simpan
      await tester.tap(find.text('Simpan Menu'));
      await tester.pumpAndSettle();

      // Pesan error untuk harga bukan angka
      expect(find.text('Harga harus berupa angka'), findsOneWidget);
    },
  );

  testWidgets(
    'Kasus 4: Harga di bawah batas minimum (Rp 1.000) — validasi menolak',
    (WidgetTester tester) async {
      await bukaFormTambahMenu(tester);

      // Isi nama valid
      await tester.enterText(find.byType(TextFormField).first, 'Es Teh Murah');

      // Pilih kategori
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Es Teh').last);
      await tester.pumpAndSettle();

      // Isi harga terlalu kecil (di bawah 1000)
      await tester.enterText(
        find.widgetWithIcon(TextFormField, Icons.attach_money),
        '500',
      );

      // Tap Simpan
      await tester.tap(find.text('Simpan Menu'));
      await tester.pumpAndSettle();

      // Pesan error untuk harga terlalu kecil
      expect(find.text('Harga minimal Rp 1.000'), findsOneWidget);
    },
  );

  testWidgets(
    'Kasus 5: Harga di atas batas maksimum (Rp 1.000.000) — validasi menolak',
    (WidgetTester tester) async {
      await bukaFormTambahMenu(tester);

      // Isi nama valid
      await tester.enterText(
          find.byType(TextFormField).first, 'Es Teh Premium');

      // Pilih kategori
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Es Teh Spesial').last);
      await tester.pumpAndSettle();

      // Isi harga terlalu besar (di atas 1.000.000)
      await tester.enterText(
        find.widgetWithIcon(TextFormField, Icons.attach_money),
        '2000000',
      );

      // Tap Simpan
      await tester.tap(find.text('Simpan Menu'));
      await tester.pumpAndSettle();

      // Pesan error untuk harga terlalu besar
      expect(find.text('Harga maksimal Rp 1.000.000'), findsOneWidget);
    },
  );

  testWidgets(
    'Kasus 6: Semua data valid — menu berhasil disimpan dan tampil di daftar',
    (WidgetTester tester) async {
      // Catat jumlah menu sebelum tes
      final jumlahSebelum = daftarMenu.length;

      await bukaFormTambahMenu(tester);

      // Isi semua field dengan data valid
      await tester.enterText(find.byType(TextFormField).first, 'Es Teh Melon');

      // Pilih kategori
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Es Teh').last);
      await tester.pumpAndSettle();

      // Isi harga valid
      await tester.enterText(
        find.widgetWithIcon(TextFormField, Icons.attach_money),
        '6000',
      );

      // Tap Simpan
      await tester.tap(find.text('Simpan Menu'));
      await tester.pumpAndSettle();

      // SnackBar sukses harus tampil
      expect(find.text('Menu "Es Teh Melon" berhasil ditambahkan'),
          findsOneWidget);

      // Kembali ke halaman daftar
      await tester.pumpAndSettle();

      // Menu baru harus tampil di daftar
      expect(find.text('Es Teh Melon'), findsOneWidget);

      // Jumlah menu harus bertambah
      expect(daftarMenu.length, jumlahSebelum + 1);

      // Cleanup: hapus menu yang ditambahkan oleh tes
      daftarMenu.removeWhere((m) => m.nama == 'Es Teh Melon');
    },
  );

  testWidgets(
    'Kasus 7: Nama duplikat — validasi menolak',
    (WidgetTester tester) async {
      await bukaFormTambahMenu(tester);

      // Isi nama yang sudah ada di data simulasi
      await tester.enterText(
          find.byType(TextFormField).first, 'Es Teh Manis');

      // Pilih kategori
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Es Teh').last);
      await tester.pumpAndSettle();

      // Isi harga valid
      await tester.enterText(
        find.widgetWithIcon(TextFormField, Icons.attach_money),
        '5000',
      );

      // Tap Simpan
      await tester.tap(find.text('Simpan Menu'));
      await tester.pumpAndSettle();

      // Pesan error untuk nama duplikat
      expect(find.text('Nama menu sudah ada, gunakan nama lain'),
          findsOneWidget);
    },
  );

  // === Tes dari Minggu 6 (tetap dipertahankan) ===

  testWidgets('Aplikasi menampilkan halaman Menu dan Resep',
      (WidgetTester tester) async {
    await tester.pumpWidget(const EsTehApp());

    expect(find.text('Menu dan Resep'), findsOneWidget);
    expect(find.text('Es Teh Manis'), findsOneWidget);
    expect(find.text('Es Teh Susu'), findsOneWidget);
    expect(find.text('Es Teh Lemon'), findsOneWidget);
  });

  testWidgets('NavigationBar memiliki 4 tujuan utama',
      (WidgetTester tester) async {
    await tester.pumpWidget(const EsTehApp());

    expect(find.text('Menu'), findsWidgets);
    expect(find.text('Penjualan'), findsWidgets);
    expect(find.text('Stok'), findsWidgets);
    expect(find.text('Laporan'), findsWidgets);
  });

  testWidgets('Tombol Tambah Menu tampil di halaman Menu',
      (WidgetTester tester) async {
    await tester.pumpWidget(const EsTehApp());

    expect(find.text('Tambah Menu'), findsOneWidget);
  });

  testWidgets('Klik menu membuka halaman Resep dengan tombol Kembali',
      (WidgetTester tester) async {
    await tester.pumpWidget(const EsTehApp());

    await tester.tap(find.text('Es Teh Manis'));
    await tester.pumpAndSettle();

    expect(find.text('Resep Es Teh Manis'), findsOneWidget);
    expect(find.text('Kembali'), findsOneWidget);

    await tester.tap(find.text('Kembali'));
    await tester.pumpAndSettle();

    expect(find.text('Menu dan Resep'), findsOneWidget);
  });
}
