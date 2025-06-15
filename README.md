# Aplikasi Kas Desa - Flutter

Sebuah aplikasi mobile sederhana yang fungsional untuk mengelola data kas masuk dan keluar di lingkungan desa atau organisasi kecil. Aplikasi ini dibangun sepenuhnya menggunakan Flutter dan Dart, dengan fokus pada fungsionalitas CRUD yang lengkap dan pengalaman pengguna yang bersih.

## ✨ Fitur Utama

Aplikasi ini memiliki semua fitur yang dibutuhkan untuk pengelolaan kas dasar:

* **📊 Laporan Saldo Dinamis:** Saldo kas akan otomatis terhitung ulang setiap kali ada transaksi baru, edit, atau hapus.
* **➕ Tambah Transaksi:** Mencatat transaksi baru (Pemasukan atau Pengeluaran) dengan deskripsi dan jumlah.
* **✏️ Edit Transaksi:** Mengubah detail transaksi yang sudah ada. Halaman form secara cerdas beradaptasi untuk mode tambah atau edit.
* **🗑️ Hapus Transaksi:** Menghapus transaksi dengan gestur "geser-untuk-hapus" (*swipe-to-delete*) yang intuitif, lengkap dengan dialog konfirmasi untuk mencegah kesalahan.
* **⚖️ Validasi Saldo:** Sistem secara otomatis mencegah pengguna memasukkan pengeluaran yang melebihi saldo kas yang tersedia.
* **🔎 Filter Data:** Pengguna dapat dengan mudah memfilter riwayat transaksi untuk menampilkan "Semua", "Hanya Pemasukan", atau "Hanya Pengeluaran".
* **💾 Penyimpanan Permanen:** Semua data transaksi disimpan secara lokal di dalam perangkat menggunakan database SQLite, sehingga data tidak akan hilang saat aplikasi ditutup.


## 🛠️ Teknologi & Stack

* **Framework:** Flutter
* **Bahasa:** Dart
* **Database Lokal:** `sqflite`
* **State Management:** `setState` (StatefulWidget)
* **Formatting:** `intl` (untuk format mata uang dan tanggal)
* **Branding:** `flutter_native_splash` & `flutter_launcher_icons`


## 🚀 Memulai Proyek Secara Lokal

Untuk menjalankan proyek ini di komputer Anda, ikuti langkah-langkah berikut:

1.  **Prasyarat:** Pastikan Anda sudah menginstal [Flutter SDK](https://flutter.dev/docs/get-started/install).

2.  **Clone repositori ini:**
    ```bash
    git clone [https://github.com/mragenks/aplikasi-kas-desa.git](https://github.com/mragenks/aplikasi-kas-desa.git)
    ```

3.  **Masuk ke direktori proyek:**
    ```bash
    cd aplikasi-kas-desa
    ```

4.  **Instal semua dependencies:**
    ```bash
    flutter pub get
    ```

5.  **Jalankan aplikasi:**
    ```bash
    flutter run
    ```

---

Dibuat dengan ❤️ by Ageng.
