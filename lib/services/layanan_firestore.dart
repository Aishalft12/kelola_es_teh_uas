import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/data_simulasi.dart';
import 'layanan_es_teh.dart';

/// Implementasi asli: data disimpan di Cloud Firestore.
///
/// Collection:
/// - users/{uid}        profil pengguna
/// - menu/{idMenu}      menu + resep (denormalisasi nama_bahan)
/// - bahan/{idBahan}    stok bahan baku
/// - penjualan/{auto}   transaksi milik satu pengguna (id_pengguna)
class LayananFirestore implements LayananEsTeh {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  LayananFirestore({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _users => _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _menu => _db.collection('menu');
  CollectionReference<Map<String, dynamic>> get _bahan => _db.collection('bahan');
  CollectionReference<Map<String, dynamic>> get _penjualan => _db.collection('penjualan');

  /// Timestamp dari server; null selama tulisan masih menunggu konfirmasi
  /// (dianggap "baru saja").
  DateTime _waktu(Object? nilai) =>
      nilai is Timestamp ? nilai.toDate() : DateTime.now();

  // ===== READ (real-time) =====

  @override
  Stream<Pengguna?> streamPenggunaSaya() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);
    return _users.doc(user.uid).snapshots().map((snap) {
      final data = snap.data();
      return data == null ? null : Pengguna.fromMap(snap.id, data);
    });
  }

  @override
  Stream<List<Menu>> streamMenu() {
    return _menu.snapshots().map((snap) {
      final daftar = snap.docs
          .map((d) => Menu.fromMap(d.id, d.data(), dibuatPada: _waktu(d.data()['dibuat_pada'])))
          .toList();
      // Terbaru di atas; data awal (waktu sama) diurutkan menurut ID.
      daftar.sort((a, b) {
        final w = b.dibuatPada!.compareTo(a.dibuatPada!);
        return w != 0 ? w : a.id.compareTo(b.id);
      });
      return daftar;
    });
  }

  @override
  Stream<List<Bahan>> streamBahan() {
    return _bahan.snapshots().map((snap) {
      final daftar = snap.docs.map((d) => Bahan.fromMap(d.id, d.data())).toList()
        ..sort((a, b) => a.id.compareTo(b.id));
      return daftar;
    });
  }

  /// Hanya satu where() di Firestore; pengurutan dilakukan di Dart agar
  /// tidak memerlukan composite index.
  @override
  Stream<List<Penjualan>> streamPenjualanSaya() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(const []);
    return _penjualan.where('id_pengguna', isEqualTo: user.uid).snapshots().map((snap) {
      final daftar = snap.docs
          .map((d) => Penjualan.fromMap(d.id, d.data(), tanggal: _waktu(d.data()['tanggal'])))
          .toList()
        ..sort((a, b) => b.tanggal.compareTo(a.tanggal));
      return daftar;
    });
  }

  // ===== CREATE =====

  @override
  Future<void> simpanPenggunaSaatLogin({
    required String uid,
    required String email,
    String? namaLengkap,
  }) async {
    final ref = _users.doc(uid);
    final nama = (namaLengkap ?? '').trim();

    if (nama.isNotEmpty) {
      // Mode Daftar: simpan nama lengkap dari form (menimpa nama bawaan).
      await ref.set({
        'id_pengguna': uid,
        'nama_lengkap': nama,
        'email': email,
        'peran': 'pemilik',
        'dibuat_pada': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return;
    }

    // Mode Masuk: buat dokumen hanya bila belum ada (mis. akun Minggu 9).
    // Transaction mencegah menimpa nama yang baru saja disimpan mode Daftar.
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (snap.exists) return;
      tx.set(ref, {
        'id_pengguna': uid,
        'nama_lengkap': email.split('@').first,
        'email': email,
        'peran': 'pemilik',
        'dibuat_pada': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> isiDataAwalJikaKosong() async {
    final cekMenu = await _menu.limit(1).get();
    final cekBahan = await _bahan.limit(1).get();
    if (cekMenu.docs.isNotEmpty && cekBahan.docs.isNotEmpty) return;

    // WriteBatch: semua dokumen awal ditulis sekaligus dalam satu operasi.
    final batch = _db.batch();
    if (cekMenu.docs.isEmpty) {
      for (final m in menuAwal) {
        batch.set(_menu.doc(m.id), {...m.toMap(), 'dibuat_pada': FieldValue.serverTimestamp()});
      }
    }
    if (cekBahan.docs.isEmpty) {
      for (final b in bahanAwal) {
        batch.set(_bahan.doc(b.id), b.toMap());
      }
    }
    await batch.commit();
  }

  @override
  Future<void> siapkanSesi() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await simpanPenggunaSaatLogin(uid: user.uid, email: user.email ?? '');
    await isiDataAwalJikaKosong();
  }

  @override
  Future<void> tambahMenu({
    required String nama,
    required String kategori,
    required int harga,
    required bool ketersediaan,
  }) async {
    // Cek duplikat di server, bukan hanya di layar
    final semua = await _menu.get();
    final daftar = semua.docs.map((d) => Menu.fromMap(d.id, d.data())).toList();
    final pesan = validasiNamaMenu(nama, daftar);
    if (pesan != null) throw NamaMenuDuplikatException(pesan);

    final ref = _menu.doc(); // auto-ID
    await ref.set({
      ...Menu(
        id: ref.id,
        nama: nama.trim(),
        kategori: kategori,
        harga: harga,
        ketersediaan: ketersediaan,
      ).toMap(),
      'dibuat_pada': FieldValue.serverTimestamp(),
    });
  }

  /// Transaction: stok dibaca ulang dari server, divalidasi (B3), lalu
  /// pengurangan stok (B1) dan dokumen penjualan (B2) ditulis bersamaan.
  /// Jika stok tidak cukup, tidak ada satu dokumen pun yang berubah.
  @override
  Future<HasilSimpan> simpanPenjualan({
    required Map<String, int> keranjang,
    required Map<String, String> gula,
    required List<Menu> daftarMenu,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return const HasilSimpan(false, 'Sesi berakhir. Silakan masuk kembali.');

    final idBahan = kebutuhanBahanKeranjang(keranjang, daftarMenu).keys.toList();
    final ref = _penjualan.doc();

    try {
      return await _db.runTransaction<HasilSimpan>((tx) async {
        final bahanTerbaru = <Bahan>[];
        for (final id in idBahan) {
          final snap = await tx.get(_bahan.doc(id));
          final data = snap.data();
          if (data != null) bahanTerbaru.add(Bahan.fromMap(snap.id, data));
        }

        final hasil = susunPenjualan(
          keranjang: keranjang,
          gula: gula,
          daftarMenu: daftarMenu,
          daftarBahan: bahanTerbaru,
          idPengguna: user.uid,
        );
        final rencana = hasil.rencana;
        if (rencana == null) return HasilSimpan(false, hasil.pesanGagal!);

        rencana.stokBaru.forEach((id, stok) {
          tx.update(_bahan.doc(id), {'stok': stok});
        });
        tx.set(ref, {
          ...rencana.penjualan.toMap(),
          'id_penjualan': ref.id,
          'tanggal': FieldValue.serverTimestamp(),
        });
        return HasilSimpan(
          true,
          'Penjualan tersimpan — Total ${formatRupiah(rencana.penjualan.total)}',
        );
      });
    } on FirebaseException catch (e) {
      return HasilSimpan(false, pesanGagalFirestore(e.code));
    }
  }
}

/// Pesan ramah untuk kode error Firestore.
String pesanGagalFirestore(String kode) {
  switch (kode) {
    case 'permission-denied':
      return 'Akses ditolak. Silakan masuk kembali.';
    case 'unavailable':
      return 'Tidak dapat terhubung ke server. Periksa koneksi internet.';
    default:
      return 'Gagal menyimpan ($kode). Silakan coba lagi.';
  }
}
