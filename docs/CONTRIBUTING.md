# 🤝 Panduan Kontribusi - AI Poster Prompt Studio

Terima kasih telah tertarik untuk berkontribusi pada pengembangan **AI Poster Prompt Studio**! Panduan ini dirancang untuk membantu Anda memahami struktur proyek, standar pengkodean, dan alur kontribusi.

---

## 📂 Struktur Direktori Repositori (Repository Directory Structure)

Repositori ini diorganisasikan dengan struktur monorepo terpisah untuk memisahkan frontend, backend, dan aplikasi Flutter:

```
ai_poster_prompt_studio/
├── android/ & ios/ & web/ ...     # Folder target platform Flutter
├── assets/                         # Folder aset global (Logo, Gambar Referensi)
│   └── demo/                       # Cuplikan layar demo aplikasi untuk dokumentasi
├── backend/                        # Server Backend (Express.js + TypeScript)
│   ├── src/
│   │   ├── config/                 # Konfigurasi sistem (Auth, encryption)
│   │   ├── db/                     # Konfigurasi Database & Schema Drizzle
│   │   │   └── schema.ts           # Skema tabel database (drizzle-orm)
│   │   ├── middlewares/            # Middleware Express (Auth, logger)
│   │   ├── modules/                # Modul bisnis logika (User, Prompt, Key, dll.)
│   │   ├── utils/                  # Fungsi utilitas (Kriptografi, validator)
│   │   ├── seed_characters.ts      # Skrip seed untuk data karakter awal
│   │   └── server.ts               # Titik entri utama backend (Dev)
│   ├── app.js                      # Output build produksi (Bundled esbuild)
│   ├── package.json
│   └── tsconfig.json
├── docs/                           # Dokumentasi proyek lengkap (.md)
│   ├── ARCHITECTURE.md
│   ├── CONTRIBUTING.md
│   ├── FEATURES.md
│   └── INSTALLATION.md
├── lib/                            # Aplikasi Klien Flutter (Feature-First)
│   ├── core/                       # Inti aplikasi (Network client, routing, theme)
│   ├── shared/                     # Komponen UI & Widget yang dapat digunakan kembali
│   ├── features/                   # Fitur bisnis (auth, chat, templates, dll.)
│   │   ├── templates/              # Halaman formulir & katalog template
│   │   └── subscription/           # Halaman klaim voucher lisensi
│   └── main.dart                   # Titik masuk aplikasi Flutter
├── promtingfrontend/               # Portal Admin (React + TanStack Start)
│   ├── src/
│   │   ├── components/             # Komponen UI (Shadcn + Radix)
│   │   ├── hooks/                  # Custom React Hooks
│   │   ├── routes/                 # Halaman & Rute TanStack (File-Based Router)
│   │   │   ├── _admin.tsx          # Layout Sidebar Admin
│   │   │   └── _admin.dashboard.tsx# Dashboard Statistik
│   │   └── router.tsx              # Konfigurasi router React
│   ├── package.json
│   └── tsconfig.json
├── run_all.bat                     # Script launcher ekosistem lokal
├── pubspec.yaml                    # Dependensi aplikasi Flutter
└── README.md                       # Dokumentasi utama repositori
```

---

## 🎨 Standar Pengkodean (Coding Conventions)

### 📱 1. Flutter Client
*   **Arsitektur**: Feature-First. Simpan widget, provider, dan model di bawah folder fiturnya masing-masing.
*   **State Management**: Gunakan **Riverpod** dengan generator `@riverpod` untuk semua status aplikasi.
*   **Komunikasi API**: Gunakan instansi `DioClient` di `lib/core/network/` untuk semua HTTP request. Jangan menginstal client HTTP lain.
*   **Desain**: Gunakan Material Design 3 dengan palet warna yang telah ditentukan di tema sistem.

### 🛡️ 2. Backend (Express + TypeScript)
*   **Validasi**: Gunakan **Zod** untuk memvalidasi setiap payload body dan parameter query pada router level.
*   **Database Query**: Selalu gunakan **Drizzle ORM** untuk query database. Hindari penulisan SQL mentah kecuali sangat mendesak.
*   **Error Handling**: Semua route handler wajib menggunakan wrapper error untuk menangkap exception dan mencatat log melalui `winston` logger.

### 💻 3. Admin Portal (React)
*   **Routing**: Rute bersifat file-based menggunakan **TanStack Router**. Nama file di dalam `src/routes/` menentukan jalur URL halaman.
*   **Styling**: Gunakan kelas utilitas **Tailwind CSS v4** untuk menjaga konsistensi tampilan UI yang responsif dan premium.
*   **Komponen**: Gunakan pustaka komponen berbasis Radix UI (Shadcn) untuk mempercepat pembangunan antarmuka.

---

## 🔄 Prosedur Perubahan Database (Database Migrations)

Jika Anda perlu menambahkan tabel baru atau mengubah kolom tabel yang sudah ada:

1.  Buka file [backend/src/db/schema.ts](file:///c:/Users/NCN0C/Documents/ai_poster_prompt_studio/backend/src/db/schema.ts) dan lakukan modifikasi skema tabel menggunakan Drizzle.
2.  Lakukan singkronisasi ke database lokal pengembangan:
    ```bash
    cd backend
    npx drizzle-kit push
    ```
3.  (Opsional) Jika memerlukan file migrasi SQL formal untuk dideploy ke staging/produksi:
    ```bash
    npx drizzle-kit generate
    ```
    Skrip di atas akan menghasilkan file migrasi SQL baru di direktori `backend/drizzle/`.

---

## 🚦 Alur Git & Kontribusi (Git Workflow)

1.  **Fork** repositori ini ke akun Anda.
2.  Buat branch baru untuk fitur Anda:
    ```bash
    git checkout -b fitur/fitur-baru-anda
    ```
3.  Lakukan perubahan kode dan pastikan program dapat berjalan/dibangun dengan sukses tanpa linting error.
4.  Lakukan commit dengan pesan commit yang jelas:
    ```bash
    git commit -m "feat: menambah fitur pencarian template dinamis"
    ```
5.  Push branch Anda ke repositori fork:
    ```bash
    git push origin fitur/fitur-baru-anda
    ```
6.  Buka **Pull Request** ke repositori utama [dresar/ai_poster_prompt_studio](https://github.com/dresar/ai_poster_prompt_studio) dengan deskripsi perubahan yang jelas.
