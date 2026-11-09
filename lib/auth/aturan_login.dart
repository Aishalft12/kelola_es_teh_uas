/// Aturan validasi form login dan terjemahan kode error Firebase Auth.
/// Dipisah dari halaman supaya bisa diuji tanpa Firebase (unit test).
library;

final RegExp _polaEmail = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

/// Email wajib diisi dan formatnya benar.
String? validasiEmail(String? nilai) {
  final email = (nilai ?? '').trim();
  if (email.isEmpty) return 'Email tidak boleh kosong';
  if (!_polaEmail.hasMatch(email)) return 'Format email belum benar';
  return null;
}

/// Password wajib diisi, minimal 6 karakter (batas minimal Firebase).
String? validasiPassword(String? nilai) {
  final password = nilai ?? '';
  if (password.isEmpty) return 'Password tidak boleh kosong';
  if (password.length < 6) return 'Password minimal 6 karakter';
  return null;
}

/// Kolom "Ulangi password" pada mode Daftar harus sama dengan password.
String? validasiUlangiPassword(String? nilai, String password) {
  if ((nilai ?? '').isEmpty) return 'Ulangi password terlebih dahulu';
  if (nilai != password) return 'Password tidak sama';
  return null;
}

/// Menerjemahkan `FirebaseAuthException.code` menjadi pesan yang dipahami
/// pengguna. Email tidak terdaftar dan password salah sengaja diberi pesan
/// yang sama, agar orang lain tidak bisa menebak email mana yang terdaftar.
String pesanKesalahanAuth(String kode) {
  switch (kode) {
    case 'invalid-credential':
    case 'wrong-password':
    case 'user-not-found':
    case 'invalid-login-credentials':
      return 'Email atau password salah';
    case 'invalid-email':
      return 'Format email belum benar';
    case 'email-already-in-use':
      return 'Email sudah terdaftar. Silakan masuk.';
    case 'weak-password':
      return 'Password terlalu lemah, minimal 6 karakter';
    case 'network-request-failed':
      return 'Tidak dapat terhubung. Periksa koneksi internet.';
    case 'operation-not-allowed':
      return 'Login email/password belum diaktifkan';
    case 'too-many-requests':
      return 'Terlalu banyak percobaan. Coba lagi beberapa saat lagi.';
    case 'user-disabled':
      return 'Akun ini dinonaktifkan. Hubungi pemilik aplikasi.';
    default:
      return 'Terjadi kesalahan ($kode). Silakan coba lagi.';
  }
}
