# Aplikasi Es Teh

Aplikasi Penjualan dan Persediaan Bahan Baku UMKM Es Teh
Mata Kuliah: Mobile and Web Application Development

## Identitas

- **Nama:** Aisha Lufita
- **NIM:** 23.01.55.0012
- **Kelas:** A1
- **Semester:** 7 (Ganjil 2026/2027)
- **Wireframe Figma:** [Wireframe Aplikasi Es Teh](https://www.figma.com/design/OIUH6K8uZkULTgP4ne7uVc/Wireframe-Aplikasi-Es-Teh-%E2%80%94-sesuai-referensi?node-id=0-1&t=BqVC1PR9g8v6TiHa-1)
- **Video presentasi UTS:** https://youtu.be/pa9LfBGsTgs

## Deskripsi

Aplikasi ini membantu UMKM es teh untuk:
- Mencatat penjualan (pilih menu, atur jumlah & tingkat gula)
- Melihat stok bahan baku dengan status Aman/Menipis/Habis
- Melihat laporan penjualan, laba kotor, dan menu terlaris
- Mengelola menu dan resep (bahan per gelas)
- Menambah menu baru melalui form dengan validasi input
- Masuk, daftar, dan keluar dengan Firebase Authentication (Minggu 9)

## Screenshot Aplikasi

Seluruh screenshot diambil langsung dari aplikasi yang berjalan (Flutter Web, viewport
420×900), bukan mockup. Data yang tampil adalah data simulasi aplikasi.

### Halaman Utama (Minggu 6)

#### Halaman Menu dan Resep

Daftar menu beserta kategori, harga, dan status ketersediaan. Setiap kartu dapat diketuk
untuk membuka halaman resep.

![Halaman Menu dan Resep](screenshots/menu-dan-resep.png)

#### Halaman Penjualan

Pemilihan menu dengan pengatur jumlah, pilihan tingkat gula (Normal/Less/Extra), dan total
yang dihitung otomatis. Contoh: 2 Es Teh Manis + 1 Es Teh Susu = Rp 17.000.

![Halaman Penjualan](screenshots/penjualan.png)

#### Halaman Stok Bahan

Stok setiap bahan dengan batas minimum dan badge status: **Aman** (hijau) dan
**Menipis** (oranye). Gula berstatus Menipis karena stok 80 gram di bawah minimum 200 gram.

![Halaman Stok Bahan](screenshots/stok-bahan.png)

#### Halaman Laporan

Ringkasan total penjualan, laba kotor, jumlah gelas terjual, menu terlaris, dan rincian
penjualan per tanggal yang bisa dibuka.

![Halaman Laporan](screenshots/laporan.png)

#### Navigasi Push: Halaman Turunan Resep

Halaman turunan yang dibuka dengan `Navigator.push` saat kartu menu diketuk. Tombol
**Kembali** memanggil `Navigator.pop` untuk kembali ke daftar menu.

![Halaman Resep Menu](screenshots/resep-menu.png)

#### Keadaan Kosong

Saat data simulasi dikosongkan, setiap halaman menampilkan pesan keadaan kosong yang jelas
alih-alih daftar kosong tanpa keterangan.

![Keadaan Kosong Menu](screenshots/keadaan-kosong-menu.png)

![Keadaan Kosong Stok Bahan](screenshots/keadaan-kosong-stok.png)

### Form dan Validasi (Minggu 7)

#### 1. Form Tambah Menu

Halaman form dengan empat kolom input: Nama Menu, Kategori (dropdown),
Harga, dan Ketersediaan (switch).

![Form Tambah Menu](screenshots/form-tambah-menu.png)

#### 2. Validasi Input

Ketika tombol **Simpan Menu** ditekan dalam keadaan kosong, setiap kolom
menampilkan pesan kesalahan dan SnackBar merah "Periksa kembali data yang dimasukkan" muncul.

![Validasi Form](screenshots/validasi-form.png)

#### 3. Berhasil Menambah Menu

Setelah data valid disimpan, muncul SnackBar hijau
"Menu "Es Teh Melon" berhasil ditambahkan" dan menu baru langsung masuk ke daftar.

![Berhasil Menambah Menu](screenshots/berhasil-tambah-menu.png)

#### 4. Daftar Menu Setelah Menambah Data

Halaman daftar menu setelah penyimpanan. Menu **Es Teh Melon** (kategori Es Teh Spesial,
Rp 6.000, Tersedia) tampil bersama menu simulasi lainnya.

![Daftar Menu](screenshots/daftar-menu.png)

## Halaman Utama (Must)

| Halaman | File | Fungsi |
|---------|------|--------|
| Menu dan Resep | `lib/pages/menu_resep_page.dart` | Daftar menu, tombol Resep, tombol Tambah Menu |
| Penjualan | `lib/pages/penjualan_page.dart` | Pilih menu, atur jumlah & gula, total, Simpan |
| Stok Bahan | `lib/pages/stok_bahan_page.dart` | Daftar bahan, status stok, tombol Catat Pembelian |
| Laporan | `lib/pages/laporan_page.dart` | Periode, total penjualan, laba kotor, menu terlaris |

### Halaman Turunan

| Halaman | File | Cara Buka | Cara Kembali |
|---------|------|-----------|-------------|
| Resep Menu | `lib/pages/resep_page.dart` | `Navigator.push` dari Menu | `Navigator.pop` / tombol Kembali |
| Tambah Menu | `lib/pages/menu_form_page.dart` | `Navigator.push` dari Menu | `Navigator.pop` / tombol Batal |

## Form dan Validasi (Minggu 7)

Halaman **Tambah Menu** (`menu_form_page.dart`) mengimplementasikan:

- `Form` + `GlobalKey<FormState>` untuk validasi seluruh form
- 4 kolom input (3+ sesuai syarat):
  1. **Nama Menu** — `TextFormField` (validator: tidak kosong, min 3 karakter, tidak duplikat)
  2. **Kategori** — `DropdownButtonFormField` (validator: tidak boleh kosong)
  3. **Harga** — `TextFormField` dengan keyboard angka (validator: tidak kosong, angka valid, min Rp 1.000, maks Rp 1.000.000)
  4. **Ketersediaan** — `SwitchListTile` (tersedia/habis)
- `AutovalidateMode.onUserInteraction` — validasi muncul saat user mengetik
- `TextEditingController` dengan `dispose()` untuk mencegah memory leak
- Tombol **Simpan** memvalidasi form → SnackBar sukses (hijau) atau error (merah)
- Data valid disimpan ke `List<Menu> daftarMenu` di memori
- Daftar menu di-refresh via `await Navigator.push` + `setState()`

## Navigasi

- **Mobile (< 600px):** `NavigationBar` 4 item di bawah layar
- **Web (>= 600px):** `NavigationRail` di sisi kiri (sidebar)
- **Halaman turunan:** `Navigator.push` + `Navigator.pop`

## Firebase dan Login (Minggu 9)

Aplikasi terhubung ke project Firebase **es-teh-23010550012** (paket Spark, tanpa billing)
dengan penyedia **Email/Password**. Target platform: Chrome.

### Alur

```
main() → Firebase.initializeApp() → runApp
            ↓
     CekStatusLogin (authStateChanges + StreamBuilder)
       ├── menunggu      → indikator proses
       ├── belum masuk   → MasukPage (mode Masuk / Daftar)
       └── sudah masuk   → HalamanUtama (terlindungi, ada tombol Keluar)
```

- Satu halaman, dua mode: **Masuk** (email + password) dan **Daftar** (+ ulangi password).
- Validasi form: email wajib & format benar, password minimal 6 karakter, ulangi password harus sama.
- Tombol dinonaktifkan selama menunggu jawaban Firebase (`async/await` + `try/catch`).
- Setelah berhasil tidak ada `Navigator`: `CekStatusLogin` mengganti halaman otomatis.
- Sesi login disimpan Firebase sehingga **tetap masuk setelah refresh**, sampai menekan **Keluar**.
- Data penjualan/stok masih di memori (hilang saat refresh) — dipindah ke Firestore pada Minggu 10.

### Pesan Kesalahan

| Kode Firebase | Keadaan | Pesan |
|---|---|---|
| `invalid-credential` | Email tak terdaftar / password salah | Email atau password salah |
| `email-already-in-use` | Daftar dengan email terpakai | Email sudah terdaftar. Silakan masuk. |
| `weak-password` | Password terlalu pendek | Password terlalu lemah, minimal 6 karakter |
| `network-request-failed` | Koneksi gagal | Tidak dapat terhubung. Periksa koneksi internet. |
| `operation-not-allowed` | Penyedia belum aktif | Login email/password belum diaktifkan |

Email tak terdaftar dan password salah sengaja diberi pesan yang sama agar orang lain tidak dapat menebak email mana yang terdaftar.

### Tabel Uji Login

Diuji di Chrome dengan project Firebase asli memakai akun simulasi (bukan password asli).

| # | Kasus uji | Hasil yang diharapkan | Hasil nyata |
|---|---|---|---|
| 1 | Kolom kosong, tekan Masuk | Kedua kolom menampilkan pesan | Sesuai |
| 2 | Email tidak valid (`aisha@`) | Format email belum benar | Sesuai |
| 3 | Daftar akun baru `pemilik@esteh.id` | Langsung masuk ke Halaman Utama | Sesuai |
| 4 | Refresh (F5) setelah masuk | Tetap di Halaman Utama | Sesuai |
| 5 | Tekan Keluar | Kembali ke halaman Masuk | Sesuai |
| 6 | Password salah | Email atau password salah | Sesuai |
| 7 | Daftar dengan email terpakai | Email sudah terdaftar. Silakan masuk. | Sesuai |
| 8 | Login benar | Halaman Utama tampil | Sesuai |

### Bukti: Authentication > Users

![Firebase Console Authentication Users](screenshots/console-users.png)

## Struktur Folder

```
lib/
├── main.dart                      # Entry point: Firebase.initializeApp + MaterialApp
├── firebase_options.dart          # Konfigurasi project Firebase (web)
├── auth/
│   └── aturan_login.dart          # Validasi login + terjemahan kode error (Minggu 9)
├── data/
│   └── data_simulasi.dart         # Data menu, bahan, resep, penjualan (mutable)
├── theme/
│   ├── app_colors.dart            # Warna dari style guide Figma
│   └── app_theme.dart             # ThemeData (Material 3)
├── pages/
│   ├── cek_status_login.dart      # authStateChanges → Masuk / Halaman Utama (Minggu 9)
│   ├── masuk_page.dart            # Halaman Masuk & Daftar (Minggu 9)
│   ├── halaman_utama.dart         # Shell: NavigationBar / NavigationRail
│   ├── menu_resep_page.dart       # Halaman 1: Menu dan Resep (StatefulWidget)
│   ├── menu_form_page.dart        # Form Tambah Menu (Minggu 7)
│   ├── penjualan_page.dart        # Halaman 2: Penjualan
│   ├── stok_bahan_page.dart       # Halaman 3: Stok Bahan
│   ├── laporan_page.dart          # Halaman 4: Laporan
│   └── resep_page.dart            # Halaman turunan: Resep per menu
└── widgets/
    ├── keadaan_kosong.dart         # Widget keadaan kosong (ikon + pesan)
    ├── tombol_keluar.dart          # Tombol Keluar di AppBar (Minggu 9)
    └── status_badge.dart           # Badge Aman/Menipis/Habis

screenshots/                        # Screenshot aplikasi yang berjalan
├── menu-dan-resep.png
├── penjualan.png
├── stok-bahan.png
├── laporan.png
├── resep-menu.png
├── keadaan-kosong-menu.png
├── keadaan-kosong-stok.png
├── form-tambah-menu.png
├── validasi-form.png
├── berhasil-tambah-menu.png
├── daftar-menu.png
└── console-users.png             # Bukti akun di Firebase Authentication
```

## Pengujian

File: `test/widget_test.dart` — 11 kasus pengujian:

### Tes Form (Minggu 7)
1. Form kosong — semua validator menolak, SnackBar error tampil
2. Nama kurang dari 3 karakter — validasi menolak
3. Harga bukan angka — validasi menolak
4. Harga di bawah minimum (Rp 1.000) — validasi menolak
5. Harga di atas maksimum (Rp 1.000.000) — validasi menolak
6. Semua data valid — menu berhasil disimpan dan tampil di daftar
7. Nama duplikat — validasi menolak

### Tes Navigasi (Minggu 6)
8. Aplikasi menampilkan halaman Menu dan Resep
9. NavigationBar memiliki 4 tujuan utama
10. Tombol Tambah Menu tampil di halaman Menu
11. Klik menu membuka halaman Resep dengan tombol Kembali

Widget test memakai `EsTehApp(halamanAwal: HalamanUtama())` agar tidak memanggil Firebase.

File: `test/logika_penjualan_test.dart` — 7 kasus logika stok, resep, dan laba kotor.

### Tes Login (Minggu 9)
File: `test/login_test.dart` — 8 kasus:
1. Email kosong dan format salah ditolak
2. Password minimal 6 karakter
3. Ulangi password harus sama
4. Email tak terdaftar dan password salah diberi pesan yang sama
5. Kode error lain diterjemahkan ke pesan yang dipahami pengguna
6. Halaman Masuk: kolom kosong — kedua kolom menampilkan pesan
7. Halaman Masuk: email tidak valid dan password pendek ditolak
8. Mode Daftar: ulangi password harus sama

Total: **26 tes lulus** (`flutter test`).

## Style Guide

| Unsur | Warna | Kode |
|-------|-------|------|
| Primer | Cokelat teh | `#6D4C41` |
| Latar | Netral | `#FAFAFA` |
| Aman | Hijau | `#2E7D32` |
| Menipis | Oranye | `#B45309` |
| Galat | Merah | `#C62828` |

Tipografi: 22px (judul), 16px (subjudul), 14px (isi), 12px (keterangan)

## Cara Menjalankan

```bash
# Install dependencies
flutter pub get

# Jalankan di Chrome
flutter run -d chrome

# Analisis kode
flutter analyze

# Pengujian
flutter test
```

## Teknologi

- Flutter 3.47.7 (Channel stable)
- Dart 3.13.5
- Material 3
- firebase_core 5.1.0, firebase_auth 7.0.1
- Firebase (paket Spark): Authentication Email/Password

## Catatan

- Minggu 6: Widget, Layout, Halaman, dan Navigasi (data simulasi)
- Minggu 7: Form, Validasi Input, dan State Sederhana
  - Form Tambah Menu dengan `GlobalKey<FormState>`
  - 4 input: TextFormField, DropdownButtonFormField, Switch
  - Validator per kolom + `AutovalidateMode.onUserInteraction`
  - State data di memori (`List<Menu>` mutable)
  - Refresh daftar via `await Navigator.push` + `setState()`
- Minggu 9: Firebase dan Login
  - Project Firebase Spark + penyedia Email/Password
  - Halaman Masuk/Daftar, cek status login, tombol Keluar
  - Pesan kesalahan dari `FirebaseAuthException.code`
  - Sesi bertahan setelah refresh
- Minggu 10: data dipindah ke Cloud Firestore
