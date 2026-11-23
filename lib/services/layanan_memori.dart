import 'dart:async';

import '../data/data_simulasi.dart';
import 'layanan_es_teh.dart';

/// Implementasi di memori — dipakai widget test dan unit test supaya tidak
/// membutuhkan koneksi internet atau Firebase asli.
class LayananMemori implements LayananEsTeh {
  /// uid pengguna yang dianggap sedang login. Bisa diganti untuk menguji
  /// isolasi data antar-akun.
  String uidAktif;

  final Map<String, Pengguna> _pengguna = {};
  final List<Menu> _menu;
  final List<Bahan> _bahan;
  final List<Penjualan> _penjualan = [];
  final _berubah = StreamController<void>.broadcast();
  int _nomor = 0;

  LayananMemori({
    this.uidAktif = 'uji-1',
    List<Menu> menu = menuAwal,
    List<Bahan> bahan = bahanAwal,
  })  : _menu = List.of(menu),
        _bahan = List.of(bahan);

  // Akses langsung untuk pemeriksaan di tes
  List<Menu> get menuSaatIni => List.unmodifiable(_menu);
  List<Bahan> get bahanSaatIni => List.unmodifiable(_bahan);
  List<Penjualan> get semuaPenjualan => List.unmodifiable(_penjualan);

  void _beriTahu() => _berubah.add(null);

  /// Stream yang langsung memberi nilai saat ini, lalu nilai baru tiap ada perubahan.
  Stream<T> _pantau<T>(T Function() ambil) async* {
    yield ambil();
    await for (final _ in _berubah.stream) {
      yield ambil();
    }
  }

  @override
  Stream<Pengguna?> streamPenggunaSaya() => _pantau(() => _pengguna[uidAktif]);

  @override
  Stream<List<Menu>> streamMenu() => _pantau(() => List<Menu>.unmodifiable(_menu));

  @override
  Stream<List<Bahan>> streamBahan() => _pantau(() => List<Bahan>.unmodifiable(_bahan));

  @override
  Stream<List<Penjualan>> streamPenjualanSaya() => _pantau(() {
        final milikSaya = _penjualan.where((p) => p.idPengguna == uidAktif).toList()
          ..sort((a, b) => b.tanggal.compareTo(a.tanggal));
        return List<Penjualan>.unmodifiable(milikSaya);
      });

  @override
  Future<void> simpanPenggunaSaatLogin({
    required String uid,
    required String email,
    String? namaLengkap,
  }) async {
    final nama = (namaLengkap ?? '').trim();
    if (_pengguna.containsKey(uid) && nama.isEmpty) return;
    _pengguna[uid] = Pengguna(
      idPengguna: uid,
      namaLengkap: nama.isNotEmpty ? nama : email.split('@').first,
      email: email,
    );
    _beriTahu();
  }

  @override
  Future<void> isiDataAwalJikaKosong() async {}

  @override
  Future<void> siapkanSesi() async {}

  @override
  Future<void> tambahMenu({
    required String nama,
    required String kategori,
    required int harga,
    required bool ketersediaan,
  }) async {
    final pesan = validasiNamaMenu(nama, _menu);
    if (pesan != null) throw NamaMenuDuplikatException(pesan);
    _menu.insert(
      0,
      Menu(
        id: 'menu-${DateTime.now().microsecondsSinceEpoch}',
        nama: nama.trim(),
        kategori: kategori,
        harga: harga,
        ketersediaan: ketersediaan,
        dibuatPada: DateTime.now(),
      ),
    );
    _beriTahu();
  }

  @override
  Future<HasilSimpan> simpanPenjualan({
    required Map<String, int> keranjang,
    required Map<String, String> gula,
    required List<Menu> daftarMenu,
  }) async {
    final hasil = susunPenjualan(
      keranjang: keranjang,
      gula: gula,
      daftarMenu: daftarMenu,
      daftarBahan: _bahan,
      idPengguna: uidAktif,
    );
    final rencana = hasil.rencana;
    if (rencana == null) return HasilSimpan(false, hasil.pesanGagal!);

    for (var i = 0; i < _bahan.length; i++) {
      final baru = rencana.stokBaru[_bahan[i].id];
      if (baru != null) _bahan[i] = _bahan[i].denganStok(baru);
    }
    _penjualan.add(rencana.penjualan.salin(id: 'jual-${++_nomor}'));
    _beriTahu();
    return HasilSimpan(true, 'Penjualan tersimpan — Total ${formatRupiah(rencana.penjualan.total)}');
  }

  /// Khusus tes: mengganti status penjualan (di aplikasi asli lewat Console).
  void aturStatusPenjualan(String idPenjualan, String status) {
    final i = _penjualan.indexWhere((p) => p.id == idPenjualan);
    if (i < 0) return;
    _penjualan[i] = _penjualan[i].salin(status: status);
    _beriTahu();
  }

  void _terapkanStok(Map<String, double> stokBaru) {
    for (var i = 0; i < _bahan.length; i++) {
      final baru = stokBaru[_bahan[i].id];
      if (baru != null) _bahan[i] = _bahan[i].denganStok(baru);
    }
  }

  @override
  Future<HasilSimpan> ubahPenjualan({
    required String idPenjualan,
    required Map<String, int> keranjang,
    required Map<String, String> gula,
    required List<Menu> daftarMenu,
  }) async {
    final i = _penjualan.indexWhere((p) => p.id == idPenjualan);
    if (i < 0) return const HasilSimpan(false, 'Penjualan tidak ditemukan.');
    final lama = _penjualan[i];
    final alasan = alasanTidakBoleh(penjualan: lama, uidAktif: uidAktif, aksi: 'diubah');
    if (alasan != null) return HasilSimpan(false, alasan);

    final hasil = susunUbahPenjualan(
      lama: lama,
      keranjang: keranjang,
      gula: gula,
      daftarMenu: daftarMenu,
      daftarBahan: _bahan,
    );
    final rencana = hasil.rencana;
    if (rencana == null) return HasilSimpan(false, hasil.pesanGagal!);

    _terapkanStok(rencana.stokBaru);
    _penjualan[i] = rencana.penjualan;
    _beriTahu();
    return HasilSimpan(true, 'Perubahan tersimpan — Total ${formatRupiah(rencana.penjualan.total)}');
  }

  @override
  Future<HasilSimpan> hapusPenjualan({
    required String idPenjualan,
    required List<Menu> daftarMenu,
  }) async {
    final i = _penjualan.indexWhere((p) => p.id == idPenjualan);
    if (i < 0) return const HasilSimpan(false, 'Penjualan tidak ditemukan.');
    final lama = _penjualan[i];
    final alasan = alasanTidakBoleh(penjualan: lama, uidAktif: uidAktif, aksi: 'dihapus');
    if (alasan != null) return HasilSimpan(false, alasan);

    _terapkanStok(stokSetelahBatal(lama, daftarMenu, _bahan));
    _penjualan.removeAt(i);
    _beriTahu();
    return const HasilSimpan(true, 'Penjualan dihapus — stok bahan dikembalikan');
  }
}
