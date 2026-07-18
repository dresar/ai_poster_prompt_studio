# ⚙️ Panduan Instalasi & Konfigurasi - AI Poster Prompt Studio

Ikuti panduan langkah demi langkah ini untuk mengatur dan menjalankan seluruh ekosistem **AI Poster Prompt Studio** di komputer lokal Anda.

---

## 📋 Prasyarat Sistem

Sebelum memulai, pastikan perangkat Anda sudah terinstal:
- **Flutter SDK** (versi `^3.12.2`)
- **Node.js** (versi `v18` atau `v20`)
- **Bun** (opsional, direkomendasikan untuk Admin Portal)
- **Git**
- Akun **Neon.tech** (atau database PostgreSQL kosong lainnya)

---

## 🛠️ 1. Pengaturan Backend Server

Masuk ke direktori `backend/` untuk menyiapkan server Express.

```bash
cd backend
```

### Langkah A: Instal Dependensi
```bash
npm install
```

### Langkah B: Konfigurasi Variabel Lingkungan (`.env`)
Buat file bernama `.env` di dalam direktori `backend/` dan sesuaikan nilainya:

```env
PORT=3000
DATABASE_URL="postgresql://username:password@hostname/dbname?sslmode=require"
JWT_SECRET="masukkan_random_string_panjang_untuk_jwt_secret"
JWT_REFRESH_SECRET="masukkan_random_string_panjang_untuk_jwt_refresh"
PRISMA_CLIENT_ENGINE_TYPE="binary"
ENCRYPTION_KEY="kunci_enkripsi_32_bytes_dalam_format_base64"
USE_STRICT_PAYLOAD_SCHEMA="true"
```

> [!TIP]
> `ENCRYPTION_KEY` digunakan untuk mengenkripsi API Key Gemini saat disimpan di PostgreSQL. Anda dapat menghasilkan kunci 32-byte acak melalui Node.js CLI:
> `node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"`

### Langkah C: Migrasi Skema Database
Untuk memigrasikan tabel skema ke database PostgreSQL Anda:
```bash
# Push skema Drizzle langsung ke database
npx drizzle-kit push
```

### Langkah D: Seed Data Karakter Awal
Jika database sudah siap, isi karakter default menggunakan skrip seed:
```bash
npx ts-node src/seed_characters.ts
```

### Langkah E: Jalankan Server
*   **Mode Pengembangan (Auto-reload)**:
    ```bash
    npm run dev
    ```
*   **Mode Produksi (Bundled)**:
    ```bash
    npm run build
    npm start
    ```

---

## 💻 2. Pengaturan Portal Admin (React)

Portal Admin terletak di folder `promtingfrontend/` dan digunakan oleh administrator untuk mengelola sistem.

```bash
cd promtingfrontend
```

### Langkah A: Instal Dependensi
Anda dapat menggunakan **Bun** (disarankan) atau **NPM**:
```bash
# Menggunakan Bun
bun install

# Atau menggunakan NPM
npm install
```

### Langkah B: Konfigurasi Endpoint API (`.env`)
Buat file `.env` di dalam folder `promtingfrontend/` untuk mengarahkan frontend ke backend lokal Anda:

```env
# Untuk pengembangan lokal
VITE_API_BASE_URL=http://localhost:3000/api

# Untuk produksi
# VITE_API_BASE_URL=https://domain-anda.com/api
```

### Langkah C: Jalankan Admin Portal
*   **Mode Pengembangan**:
    ```bash
    bun dev    # atau npm run dev
    ```
*   **Mode Produksi**:
    ```bash
    bun build  # atau npm run build
    bun preview
    ```

Akses portal melalui browser di alamat yang tertera (biasanya `http://localhost:5173` atau `http://localhost:3000` tergantung adapter).

---

## 📱 3. Pengaturan Flutter Client App

Flutter Client merupakan aplikasi utama yang digunakan oleh pengguna akhir. Terletak di direktori root proyek.

### Langkah A: Unduh Dependensi Flutter
Kembali ke root direktori proyek, lalu unduh paket dependensi Flutter:
```bash
cd ..
flutter pub get
```

### Langkah B: Pengaturan Alamat API Server
Alamat backend diatur di file [lib/core/network/dio_client.dart](file:///c:/Users/NCN0C/Documents/ai_poster_prompt_studio/lib/core/network/dio_client.dart):
*   Secara default, kode menggunakan `http://localhost:3000/api` untuk Web dan `http://10.0.2.2:3000/api` untuk Android Emulator.
*   Jika Anda merilis aplikasi ke server produksi, pastikan konstanta `_productionBaseUrl` sudah disesuaikan dan dialihkan ke mode production.

### Langkah C: Jalankan Aplikasi
Jalankan aplikasi klien pada Google Chrome atau emulator pilihan Anda:
```bash
# Menjalankan di Chrome
flutter run -d chrome

# Menjalankan di perangkat mobile default
flutter run
```

---

## ⚡ Launcher Otomatis (`run_all.bat`)

Untuk kemudahan proses *development* harian, Anda dapat menyalakan server Backend dan Flutter Web secara bersamaan dengan sekali klik melalui launcher batch:

```bash
.\run_all.bat
```

**Kredensial Default Admin Portal:**
- **Email**: `admin@promptstudio.com`
- **Password**: `admin123`
