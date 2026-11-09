import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:es_teh_app/auth/aturan_login.dart';
import 'package:es_teh_app/main.dart';
import 'package:es_teh_app/pages/masuk_page.dart';

/// Tes Minggu 9 — aturan login dan halaman Masuk/Daftar.
/// Tidak memanggil Firebase: hanya validasi form dan terjemahan kode error.
void main() {
  group('Validasi form login', () {
    test('Email kosong dan format salah ditolak', () {
      expect(validasiEmail(''), 'Email tidak boleh kosong');
      expect(validasiEmail('aisha@'), 'Format email belum benar');
      expect(validasiEmail('aisha.gmail.com'), 'Format email belum benar');
      expect(validasiEmail('pemilik@esteh.id'), isNull);
    });

    test('Password minimal 6 karakter', () {
      expect(validasiPassword(''), 'Password tidak boleh kosong');
      expect(validasiPassword('12345'), 'Password minimal 6 karakter');
      expect(validasiPassword('rahasia1'), isNull);
    });

    test('Ulangi password harus sama', () {
      expect(validasiUlangiPassword('', 'rahasia1'), 'Ulangi password terlebih dahulu');
      expect(validasiUlangiPassword('rahasia2', 'rahasia1'), 'Password tidak sama');
      expect(validasiUlangiPassword('rahasia1', 'rahasia1'), isNull);
    });
  });

  group('Pesan kesalahan Firebase', () {
    test('Email tak terdaftar dan password salah diberi pesan yang sama', () {
      const pesan = 'Email atau password salah';
      expect(pesanKesalahanAuth('invalid-credential'), pesan);
      expect(pesanKesalahanAuth('wrong-password'), pesan);
      expect(pesanKesalahanAuth('user-not-found'), pesan);
    });

    test('Kode lain diterjemahkan', () {
      expect(pesanKesalahanAuth('email-already-in-use'), 'Email sudah terdaftar. Silakan masuk.');
      expect(pesanKesalahanAuth('weak-password'), 'Password terlalu lemah, minimal 6 karakter');
      expect(pesanKesalahanAuth('network-request-failed'), 'Tidak dapat terhubung. Periksa koneksi internet.');
      expect(pesanKesalahanAuth('operation-not-allowed'), 'Login email/password belum diaktifkan');
    });
  });

  group('Halaman Masuk', () {
    Future<void> buka(WidgetTester tester) async {
      await tester.pumpWidget(const EsTehApp(halamanAwal: MasukPage()));
      await tester.pumpAndSettle();
    }

    testWidgets('Kolom kosong — kedua kolom menampilkan pesan', (tester) async {
      await buka(tester);
      await tester.tap(find.byKey(const Key('tombol-kirim')));
      await tester.pumpAndSettle();

      expect(find.text('Email tidak boleh kosong'), findsOneWidget);
      expect(find.text('Password tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('Email tidak valid dan password pendek ditolak', (tester) async {
      await buka(tester);
      await tester.enterText(find.byKey(const Key('kolom-email')), 'aisha@');
      await tester.enterText(find.byKey(const Key('kolom-password')), '123');
      await tester.tap(find.byKey(const Key('tombol-kirim')));
      await tester.pumpAndSettle();

      expect(find.text('Format email belum benar'), findsOneWidget);
      expect(find.text('Password minimal 6 karakter'), findsOneWidget);
    });

    testWidgets('Mode Daftar — ulangi password harus sama', (tester) async {
      await buka(tester);
      await tester.tap(find.text('Belum punya akun? Daftar'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('kolom-ulangi')), findsOneWidget);

      await tester.enterText(find.byKey(const Key('kolom-email')), 'pemilik@esteh.id');
      await tester.enterText(find.byKey(const Key('kolom-password')), 'rahasia1');
      await tester.enterText(find.byKey(const Key('kolom-ulangi')), 'rahasia2');
      await tester.tap(find.byKey(const Key('tombol-kirim')));
      await tester.pumpAndSettle();

      expect(find.text('Password tidak sama'), findsOneWidget);
    });
  });
}
