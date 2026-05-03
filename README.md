# 🗄️ Website Gudang Pusat Polban (Sistem Informasi Manajemen Gudang)

Selamat datang di repositori Aplikasi Mobile InventIF. Ini adalah aplikasi mobile berarsitektur Offline-First yang dibangun menggunakan Flutter, Hive, dan Firestore untuk mengelola inventaris, aset, dan alur peminjaman di lingkungan Jurusan Teknik Komputer dan Informatika Polban.
Mohon baca dan patuhi panduan ini untuk menjaga alur kerja tim kelompok A4 tetap rapi dan efisien.
---
# 🏗️ Struktur Folder

Struktur ini adalah proyek Flutter dengan penerapan Clean Architecture, di mana folder lib/ adalah akar dari aplikasi kita.
```
├── android/            # Konfigurasi native Android
├── build/              # Hasil build aplikasi (jangan di-commit)
├── ios/                # Konfigurasi native iOS
├── lib/                # --- Folder Utama FLUTTER ---
│   ├── controllers/    # Logic aplikasi & State Management (cth: auth_controller.dart)
│   ├── models/         # Blueprint/Schema data (cth: facility_model.dart)
│   ├── services/       # Koneksi eksternal API & Local Storage (cth: hive_service.dart)
│   ├── views/          # Halaman UI dan Screen (Dilarang menaruh logic DB di sini)
│   │   ├── auth/       # Layar Login/Register
│   │   ├── catalog/    # Layar Katalog Barang & Ruangan
│   │   └── transaction/# Layar Pengajuan Peminjaman
│   ├── utils/          # Konstanta, Warna Theme, dan fungsi bantuan
│   └── main.dart       # Titik masuk utama aplikasi (Entry Point)
├── test/               # Unit test dan Widget test
├── pubspec.yaml        # Manajemen dependensi (Package Flutter/Dart)
└── README.md           # Dokumentasi proyek
```
---
# 🌿 Struktur Branch

## Branch Utama
- `main` → Versi rilis (produksi) stabil. (DILARANG PUSH LANGSUNG)
- `develop` → Gabungan dari semua fitur yang sudah selesai dan siap untuk diuji coba. Ini adalah target PR utama.
## Branch Fitur
Gunakan format: 
```
<tipe>/<nama-fitur-singkat>
```
Contoh:

`fitur/auth-login-rbac`

`fitur/offline-draft-peminjaman`

`bug/fix-sync-mongodb`

---
# 🚀 Project Setup (Lokal)

Pastikan Anda memiliki Composer (PHP) dan NPM (Node.js) terinstal.
## 1. Clone Repositori
```
git clone https://github.com/Ditt21-Lang/A4-Proyek4-InventIF.git
```
```
cd A4-Proyek4-InventIF
```
## 2. Install Dependensi (Packages)
Unduh semua dependensi yang tercatat di pubspec.yaml:
```
flutter pub get
```
## 3. Setup Environment Variables
Jika menggunakan API Key atau URL khusus, salin file .env (pastikan package flutter_dotenv sudah terkonfigurasi):
```
cp .env.example .env
```
## 4. Setup Firebase (Wajib untuk Semua Anggota Tim)

Karena aplikasi InventIF kini menggunakan Cloud Firestore sebagai *database* terpusat, setiap anggota tim **wajib** melakukan konfigurasi Firebase CLI di laptop masing-masing agar bisa menjalankan aplikasi secara lokal.

Pastikan posisi terminal Anda berada di dalam folder proyek `A4-Proyek4-InventIF`.

**Langkah 1: Install Firebase Tools (via Node.js)**
```bash
npm install -g firebase-tools
```
**Langkah 2: Login ke Firebase**
```bash
firebase login
```
(Ketik Y jika ditanya, lalu browser akan terbuka. Silakan login menggunakan akun Google yang sudah diberi akses/diundang ke proyek Firebase InventIF).
**Langkah 3: Install FlutterFire CLI**
```bash
dart pub global activate flutterfire_cli
```
**Langkah 4: Sinkronisasi Proyek & Generate File Konfigurasi**
Jalankan perintah ini untuk mengunduh konfigurasi database ke lokal Anda.
(Catatan: Perintah set NODE_OPTIONS digunakan untuk membungkam peringatan bawaan Node.js yang seringkali membuat proses konfigurasi FlutterFire menjadi error / FormatException).

Untuk Windows (Command Prompt / VS Code Terminal):
```bash
set NODE_OPTIONS="--no-warnings"
flutterfire configure --project=inventif-c98ab
```
Untuk Mac/Linux:
```bash
export NODE_OPTIONS="--no-warnings"
flutterfire configure --project=inventif-c98ab
```
(Tekan Enter untuk menyetujui platform default yang dipilihkan, biasanya Android, iOS, macOS, Web. Tunggu hingga file lib/firebase_options.dart berhasil dibuat).
---
# 💻 Menjalankan di Mode Development

Pastikan emulator sudah berjalan atau perangkat fisik sudah terhubung melalui debugging mode.
- Jalankan aplikasi dengan fitur Hot Reload:
```
flutter run
```
---
# 📦 Build untuk Production

Build APK (Untuk testing internal):
```
flutter build apk --release
```
---
# 🔁 Alur Kerja GitHub

## 1. Selalu mulai dari develop
```
git checkout develop
```
```
git pull origin develop
```
## 2. Buat branch fitur baru
```
git checkout -b fitur/offline-draft-peminjaman
```
## 3. Kerjakan fitur (Coding...)
## 4. Commit perubahan Anda
```
git add .
```
```
git commit -m "feat: implementasi form pengajuan offline"
```
## 5. Push branch Anda ke GitHub
```
git push origin fitur/offline-draft-peminjaman
```
## 6. Buat Pull Request (PR)
- Buka repositori di GitHub.
- Buat Pull Request dari fitur/offline-draft-peminjaman ke develop.
- Minta 1-2 rekan setim untuk me-review kode Anda.
---
# ✅ Format Commit Message

Gunakan format konvensional: 
```
<tipe>: <deskripsi singkat>
```
Tipe umum:
- feat: fitur baru
- fix: perbaikan bug
- docs: dokumentasi
- style: perubahan visual tanpa logic
- refactor: perbaikan kode internal
- test: pengujian
- chore: pembaruan kecil (update package di pubspec.yaml, dll)
Contoh:
```
feat: tambahkan validasi timestamp untuk mekanisme sinkronisasi
fix: perbaiki list katalog yang tidak muncul saat mode offline
refactor: pisahkan logika Hive dari file UI utama
```
---
# 🧼 Tips Tambahan

- Pastikan aplikasi tetap berfungsi mulus saat mode offline/tanpa internet diuji coba.
- Jalankan dart format . dan flutter analyze sebelum push.
- Pisahkan logika pengolahan data (Controller/Service) dari desain tampilan (View).
- Jika ragu saat terjadi merge conflict, tanyakan ke rekan setim sebelum di-merge.
---
Semangat berkontribusi! 💪
