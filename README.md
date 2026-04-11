# Noctoriagoras Cosrent App

Aplikasi mobile penyewaan kostum cosplay (Cosrent) yang dibangun menggunakan *framework* Flutter. Aplikasi ini terhubung dengan Backend API (Laravel) untuk mengelola data katalog kostum, transaksi penyewaan (QRIS), notifikasi, event, dan manajemen profil pengguna.

---

## 🛠 Persyaratan Sistem (Prerequisites)

Sebelum menjalankan aplikasi, pastikan komputer Anda sudah terinstal:
* **Flutter SDK** (Versi 3.10.x atau yang lebih baru)
* **Dart SDK**
* **Android Studio** (beserta Android SDK & Emulator) atau **VS Code**
* Pastikan Backend Laravel API sudah berjalan di komputer Anda (biasanya di `http://127.0.0.1:8000`).

---

## 🚀 Instalasi & Setup Awal

1. Buka terminal/CMD dan arahkan ke dalam direktori proyek ini (`noctoriagoras_rent_app`).
2. Jalankan perintah berikut untuk mengunduh semua *library* dan *dependencies* yang dibutuhkan:
   ```bash
   flutter pub get
   ```

---

## 🌐 Konfigurasi URL API (SANGAT PENTING!)

Karena aplikasi terhubung ke *Localhost Backend* komputer Anda, Anda **harus menyesuaikan Alamat IP** di dalam kode Flutter agar aplikasi bisa menembak API dengan benar.

Buka file konfigurasi jaringan di:
👉 **`lib/core/network/api_client.dart`**

Cari variabel `localIp` di dalam fungsi `_baseUrl` dan ubah nilainya berdasarkan skenario testing Anda:

### Skenario 1: Testing menggunakan Emulator Android
Emulator Android tidak mengenali `127.0.0.1` sebagai komputer Anda (ia menganggap 127.0.0.1 adalah emulator itu sendiri). Anda harus menggunakan IP Alias khusus emulator.
* Ubah nilai `localIp` menjadi: `"10.0.2.2"`

### Skenario 2: Testing menggunakan Device HP Asli (Physical Device)
Jika Anda me-run aplikasi (lewat kabel USB atau Wireless Debugging) ke HP asli, HP tersebut tidak akan bisa mengakses `127.0.0.1`. Anda **WAJIB** menggunakan IP jaringan WiFi dari komputer Anda.

**Cara mengecek IP Komputer Anda:**
1. Pastikan HP dan Komputer terhubung pada **jaringan WiFi/Hotspot yang sama**.
2. **Windows**: Buka CMD, ketik `ipconfig`. Cari baris **IPv4 Address** (Contoh: `192.168.1.15`).
3. **Mac / Linux**: Buka Terminal, ketik `ifconfig` atau `ip a`. Cari IP address (inet) dari koneksi WiFi.

**Terapkan IP tersebut ke dalam kode `api_client.dart`:**
```dart
// Ganti dengan IP hasil ipconfig komputer Anda
const String localIp = "192.168.1.15"; 
```

*(Catatan: Jika koneksi API gagal, matikan Firewall sementara di komputer Anda karena Firewall sering memblokir HP yang mencoba mengakses port 8000).*

---

## ▶️ Menjalankan Aplikasi (Debug Mode)

Pastikan Emulator sudah menyala atau HP asli sudah terhubung dan terdeteksi (ketik `flutter devices` untuk mengecek).

Jalankan perintah:
```bash
flutter run
```
Atau tekan **F5** jika Anda menggunakan VS Code.

---

## 📦 Mem-Build APK (Release Version)

Jika aplikasi sudah selesai di-develop dan Anda ingin mengekspor/membuat file `.apk` mentah untuk di-install ke HP orang lain, Anda harus mem-build versi **Release**.

Buka terminal di root proyek, lalu jalankan perintah:
```bash
flutter build apk --release
```

Tunggu proses kompilasi selesai (memakan waktu beberapa menit). Jika berhasil, file APK Anda akan tersimpan secara otomatis di dalam folder:
👉 **`build/app/outputs/flutter-apk/app-release.apk`**

Anda dapat membagikan file `app-release.apk` ini ke pengguna Android lainnya.

---

## 📁 Struktur Folder Utama

* `lib/models/` : Berisi struktur data (User, Costum, Order, Event, Notification).
* `lib/viewmodels/` : Berisi *business logic* (Provider) yang menangani pemanggilan ke API (AuthViewModel, CostumViewModel, dll).
* `lib/views/` : Berisi semua UI / Tampilan halaman aplikasi (Beranda, Detail, Profil, Autentikasi).
* `lib/core/` : Konfigurasi utama sistem seperti Theme warna dan pengaturan *Network* (Dio Client).