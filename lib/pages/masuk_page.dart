import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth/aturan_login.dart';
import '../theme/app_colors.dart';

/// Halaman Masuk dan Daftar — satu halaman, dua mode.
/// Memakai pola form Minggu 7: Form + GlobalKey + validator.
/// Setelah berhasil tidak ada Navigator: CekStatusLogin yang mengganti halaman.
class MasukPage extends StatefulWidget {
  const MasukPage({super.key});

  @override
  State<MasukPage> createState() => _MasukPageState();
}

class _MasukPageState extends State<MasukPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ulangiController = TextEditingController();

  bool _modeDaftar = false;
  bool _sedangProses = false;
  bool _sembunyikanPassword = true;
  String? _pesanGagal; // pesan dari Firebase (bukan validasi form)

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _ulangiController.dispose();
    super.dispose();
  }

  /// Pesan dari Firebase dihapus begitu pengguna mengubah isian.
  void _hapusPesanGagal(String _) {
    if (_pesanGagal != null) setState(() => _pesanGagal = null);
  }

  void _gantiMode(bool daftar) {
    setState(() {
      _modeDaftar = daftar;
      _pesanGagal = null;
      _ulangiController.clear();
    });
    _formKey.currentState?.reset();
  }

  Future<void> _kirim() async {
    setState(() => _pesanGagal = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _sedangProses = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      if (_modeDaftar) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
      // Berhasil: authStateChanges() memicu CekStatusLogin → HalamanUtama.
    } on FirebaseAuthException catch (e) {
      if (mounted) setState(() => _pesanGagal = pesanKesalahanAuth(e.code));
    } catch (_) {
      if (mounted) {
        setState(() => _pesanGagal = 'Terjadi kesalahan. Silakan coba lagi.');
      }
    } finally {
      if (mounted) setState(() => _sedangProses = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final teks = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Identitas aplikasi
                    const CircleAvatar(
                      radius: 36,
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.local_drink, color: Colors.white, size: 36),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aplikasi Es Teh',
                      textAlign: TextAlign.center,
                      style: teks.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _modeDaftar
                          ? 'Buat akun pemilik usaha'
                          : 'Masuk untuk mengelola penjualan dan stok',
                      textAlign: TextAlign.center,
                      style: teks.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Pilihan mode
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(
                          value: false,
                          label: Text('Masuk'),
                          icon: Icon(Icons.login),
                        ),
                        ButtonSegment(
                          value: true,
                          label: Text('Daftar'),
                          icon: Icon(Icons.person_add),
                        ),
                      ],
                      selected: {_modeDaftar},
                      onSelectionChanged: _sedangProses
                          ? null
                          : (pilihan) => _gantiMode(pilihan.first),
                    ),
                    const SizedBox(height: 20),

                    // Email
                    TextFormField(
                      key: const Key('kolom-email'),
                      controller: _emailController,
                      onChanged: _hapusPesanGagal,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: validasiEmail,
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
                      key: const Key('kolom-password'),
                      controller: _passwordController,
                      onChanged: _hapusPesanGagal,
                      obscureText: _sembunyikanPassword,
                      textInputAction:
                          _modeDaftar ? TextInputAction.next : TextInputAction.done,
                      onFieldSubmitted: (_) => _modeDaftar ? null : _kirim(),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        helperText: _modeDaftar ? 'Minimal 6 karakter' : null,
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          tooltip: _sembunyikanPassword
                              ? 'Tampilkan password'
                              : 'Sembunyikan password',
                          icon: Icon(_sembunyikanPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () => setState(
                              () => _sembunyikanPassword = !_sembunyikanPassword),
                        ),
                      ),
                      validator: validasiPassword,
                    ),

                    // Ulangi password (hanya mode Daftar)
                    if (_modeDaftar) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        key: const Key('kolom-ulangi'),
                        controller: _ulangiController,
                        onChanged: _hapusPesanGagal,
                        obscureText: _sembunyikanPassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _kirim(),
                        decoration: const InputDecoration(
                          labelText: 'Ulangi password',
                          prefixIcon: Icon(Icons.lock_reset),
                          border: OutlineInputBorder(),
                        ),
                        validator: (nilai) =>
                            validasiUlangiPassword(nilai, _passwordController.text),
                      ),
                    ],

                    // Pesan gagal dari Firebase
                    if (_pesanGagal != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        key: const Key('pesan-gagal'),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.08),
                          border: Border.all(color: AppColors.error),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.error),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _pesanGagal!,
                                style: const TextStyle(color: AppColors.error),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Tombol kirim — nonaktif selama proses
                    FilledButton.icon(
                      key: const Key('tombol-kirim'),
                      onPressed: _sedangProses ? null : _kirim,
                      icon: _sedangProses
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(_modeDaftar ? Icons.person_add : Icons.login),
                      label: Text(_modeDaftar ? 'Daftar' : 'Masuk'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _sedangProses ? null : () => _gantiMode(!_modeDaftar),
                      child: Text(_modeDaftar
                          ? 'Sudah punya akun? Masuk'
                          : 'Belum punya akun? Daftar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
