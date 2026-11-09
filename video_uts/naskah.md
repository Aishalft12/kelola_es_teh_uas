# Naskah Video UTS — Aplikasi Es Teh

Target durasi ±9 menit 20 detik (batas 10 menit). Suara TTS: Gadis (perempuan).
Bagian bertanda **[CEK]** adalah draf dari saya — mohon dikoreksi supaya sesuai kenyataan.

---

## 1. Pembuka (±0:30)

**Layar:** judul aplikasi, logo cangkir teh, identitas.

> Halo, selamat datang. Saya Aisha Lufita, NIM 23.01.55.0012, dari kelas A1, mata kuliah Mobile and Web Application Development. Pada video UTS ini saya mempresentasikan prototype aplikasi saya, yaitu Aplikasi Es Teh: aplikasi penjualan dan persediaan bahan baku untuk UMKM es teh. Temanya, dari ide ke prototype.

---

## 2. Masalah & pengguna (±1:30)

**Layar:** problem statement → target pengguna → kartu persona.

> Masalah apa yang diselesaikan aplikasi ini? Banyak penjual es teh skala kecil masih mencatat penjualan di buku tulis, atau tidak mencatat sama sekali. Akibatnya ada tiga masalah. Pertama, stok bahan seperti teh dan gula sering habis mendadak di tengah jualan, karena tidak ada yang memantau sisa stok. Kedua, penjual tidak tahu laba sebenarnya, karena biaya bahan per gelas tidak pernah dihitung. Ketiga, tidak ada data menu mana yang paling laris, sehingga sulit memutuskan apa yang perlu ditambah.
>
> Masalah ini penting karena bagi UMKM, kehabisan bahan berarti kehilangan penjualan, dan tidak tahu laba berarti tidak tahu apakah usahanya untung.
>
> Siapa pengguna utamanya? Target pengguna aplikasi ini adalah pemilik sekaligus penjual di usaha es teh kecil, seperti gerobak atau kedai di dekat kampus dan sekolah.
>
> **[CEK]** Persona pengguna utama saya adalah Bu Rina, tiga puluh delapan tahun, pemilik gerobak es teh di dekat kampus. Ia menjual sekitar delapan puluh gelas per hari dan melayani pembeli sendirian. Ia terbiasa memakai ponsel Android untuk WhatsApp, tetapi tidak sempat membuat pembukuan. Tujuannya: mencatat penjualan dengan cepat, tahu kapan harus belanja bahan, dan tahu untungnya setiap hari.

---

## 3. Kebutuhan & prioritas (±1:00)

**Layar:** 6 user story, lalu tabel Must / Should.

> Dari masalah tersebut, saya menyusun enam user story.
> Satu: sebagai penjual, saya ingin mencatat penjualan dengan memilih menu, jumlah, dan tingkat gula, agar total harga terhitung otomatis.
> Dua: sebagai pemilik, saya ingin stok bahan berkurang otomatis setiap ada penjualan, agar tidak perlu menghitung manual.
> Tiga: sebagai pemilik, saya ingin melihat status stok Aman, Menipis, atau Habis, agar tahu kapan harus belanja bahan.
> Empat: sebagai pemilik, saya ingin penjualan ditolak bila stok tidak cukup, agar data stok tidak minus.
> Lima: sebagai pemilik, saya ingin menambah menu baru beserta harganya, agar daftar menu sesuai jualan.
> Enam: sebagai pemilik, saya ingin melihat laporan penjualan, laba kotor, dan menu terlaris.
>
> Mengapa fitur ini yang diprioritaskan? Fitur Must adalah pencatatan penjualan, stok bahan, menu dan resep, serta laporan, karena keempatnya langsung menjawab tiga masalah tadi. Resep menjadi kunci: dari resep per gelas, aplikasi bisa mengurangi stok dan menghitung laba kotor secara otomatis. Login dan pencatatan pembelian bahan saya tempatkan sebagai Should, dan dikerjakan setelah Firebase terhubung.

---

## 4. Rancangan (±2:00)

**Layar:** diagram user flow → sitemap → wireframe Figma berdampingan dengan aplikasi.

> Berikut user flow utama. Pengguna membuka aplikasi dan login. Setelah masuk, pengguna tiba di halaman Menu dan Resep. Untuk mencatat penjualan, pengguna membuka halaman Penjualan, memilih menu, mengatur jumlah dan tingkat gula, lalu menekan Simpan. Aplikasi memeriksa kecukupan stok. Jika stok cukup, penjualan tersimpan, stok bahan berkurang sesuai resep, dan hasilnya langsung tampil di halaman Laporan. Jika tidak cukup, penjualan ditolak dengan pesan yang jelas. Catatan: langkah login sudah ada di rancangan, tetapi baru akan dibangun dengan Firebase Authentication di pertemuan sembilan.
>
> Sitemap aplikasi terdiri dari empat halaman utama yang terhubung lewat NavigationBar: Menu dan Resep, Penjualan, Stok Bahan, dan Laporan. Ada dua halaman turunan yang dibuka dengan Navigator push, yaitu Resep Menu dan Tambah Menu.
>
> Ini wireframe Figma saya, disandingkan dengan aplikasi yang sudah dibangun. Struktur halaman, urutan komponen, dan warnanya mengikuti style guide: cokelat teh sebagai warna primer, hijau untuk status aman, oranye untuk menipis, dan merah untuk galat. Tipografi memakai empat ukuran, dari dua puluh dua piksel untuk judul sampai dua belas piksel untuk keterangan.

---

## 5. Demo prototype (±3:30)

**Layar:** rekaman aplikasi yang berjalan, diperbesar di bagian penting.

> Sekarang demo aplikasi yang berjalan di Chrome. Ini halaman Menu dan Resep, berisi data simulasi: empat menu dengan kategori, harga, dan status ketersediaan. Lewat NavigationBar di bawah, saya bisa berpindah ke Penjualan, Stok, dan Laporan.
>
> Kembali ke Menu. Saat kartu Es Teh Manis diketuk, halaman Resep terbuka dengan Navigator push: satu gelas butuh lima gram teh, lima belas gram gula, dan satu gelas plastik. Tombol Kembali memanggil Navigator pop.
>
> Sekarang form Tambah Menu. Form ini punya empat kolom dari tiga jenis input: teks untuk nama dan harga, dropdown untuk kategori, dan switch untuk ketersediaan. Jika saya langsung menekan Simpan dalam keadaan kosong, setiap kolom menampilkan pesan kesalahan di bawahnya, dan muncul SnackBar merah.
>
> Saya coba input yang salah. Nama dua huruf ditolak: nama menu minimal tiga karakter. Harga berisi huruf ditolak: harga harus berupa angka. Harga lima ratus rupiah juga ditolak, karena minimalnya seribu rupiah. Dan nama yang sudah ada, misalnya Es Teh Manis, ditolak sebagai duplikat.
>
> Sekarang input yang benar: Es Teh Melon, kategori Es Teh Spesial, harga enam ribu, tersedia. Simpan. Muncul SnackBar hijau, dan menu baru langsung tampil di daftar.
>
> Berikutnya aturan bisnis di halaman Penjualan. Stok gula tinggal seratus sepuluh gram, dan satu gelas Es Teh Manis butuh lima belas gram. Kalau saya memesan delapan gelas, butuh seratus dua puluh gram, sehingga penjualan ditolak dengan pesan stok bahan tidak cukup. Tidak ada data yang berubah.
>
> Saya kurangi menjadi dua gelas, pilih tingkat gula, lalu simpan. Penjualan tersimpan dengan total sepuluh ribu rupiah. Di halaman Stok, gula otomatis berkurang tiga puluh gram dan statusnya Menipis. Di halaman Laporan, total penjualan, laba kotor yang dihitung dari resep, dan menu terlaris ikut diperbarui.
>
> Terakhir, keadaan kosong. Jika data belum ada, halaman menampilkan pesan yang jelas, bukan daftar kosong tanpa keterangan.

---

## 6. Rencana teknis & penutup (±1:20)

**Layar:** tech stack → skema Firestore → linimasa P9–P15 → kendala & pelajaran → penutup.

> Tech stack yang saya pakai adalah Flutter dan Dart dengan Material 3, supaya satu kode bisa berjalan di Android dan web. Untuk backend saya memakai Firebase paket Spark yang gratis: Firestore sebagai database, Authentication untuk login, dan Hosting untuk versi web.
>
> Bagaimana data akan disimpan? Di Firestore saya merancang enam collection, mengikuti model data yang sudah ada di prototype. Users untuk akun pemilik. Menu berisi nama, kategori, harga, dan ketersediaan. Bahan berisi nama, satuan, stok, stok minimum, dan harga beli. Resep menghubungkan menu dan bahan dengan jumlah per gelas. Penjualan berisi tanggal, total, laba kotor, dan daftar item. Pembelian mencatat bahan yang dibeli. Saat penjualan disimpan, pengurangan stok dan pencatatan penjualan ditulis dalam satu batch, supaya stok tidak pernah berkurang tanpa penjualan yang sah.
>
> Rencana pertemuan sembilan sampai lima belas: menghubungkan Firebase dan membuat login, memindahkan data menu dan bahan ke Firestore, menyimpan penjualan dengan batch write, membuat form Catat Pembelian, membangun laporan dari Firestore, lalu deploy ke Firebase Hosting dan pengujian akhir.
>
> **[CEK]** Kendala yang saya alami: awalnya stok di halaman Stok tidak ikut berubah setelah penjualan disimpan, karena halaman lain tidak tahu bahwa data berubah. Saya mengatasinya dengan ValueNotifier sebagai penanda versi data, yang nanti digantikan stream dari Firestore. Pelajaran yang saya dapat: merancang aturan bisnis dulu, seperti resep dan validasi stok, membuat kode jauh lebih mudah diuji. Bagian yang belum selesai adalah login, koneksi Firebase, dan form Catat Pembelian, dan semuanya sudah masuk rencana sebelum UAS.
>
> Sekian presentasi dari saya. Terima kasih.
