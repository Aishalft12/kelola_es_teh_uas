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
    _penjualan.add(rencana.penjualan);
    _beriTahu();
    return HasilSimpan(true, 'Penjualan tersimpan — Total ${formatRupiah(rencana.penjualan.total)}');
  }
}
