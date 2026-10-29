import 'package:flutter_test/flutter_test.dart';

import 'package:es_teh_app/main.dart';

void main() {
  testWidgets('Aplikasi menampilkan halaman Menu dan Resep',
      (WidgetTester tester) async {
    await tester.pumpWidget(const EsTehApp());

    // AppBar harus berjudul "Menu dan Resep"
    expect(find.text('Menu dan Resep'), findsOneWidget);

    // Data simulasi menu harus tampil
    expect(find.text('Es Teh Manis'), findsOneWidget);
    expect(find.text('Es Teh Susu'), findsOneWidget);
    expect(find.text('Es Teh Lemon'), findsOneWidget);
  });

  testWidgets('NavigationBar memiliki 4 tujuan utama',
      (WidgetTester tester) async {
    await tester.pumpWidget(const EsTehApp());

    // Cek label NavigationBar
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

    // Tap item menu pertama
    await tester.tap(find.text('Es Teh Manis'));
    await tester.pumpAndSettle();

    // Halaman resep harus tampil dengan judul yang sesuai
    expect(find.text('Resep Es Teh Manis'), findsOneWidget);
    expect(find.text('Kembali'), findsOneWidget);

    // Tap tombol Kembali
    await tester.tap(find.text('Kembali'));
    await tester.pumpAndSettle();

    // Kembali ke halaman Menu
    expect(find.text('Menu dan Resep'), findsOneWidget);
  });
}
