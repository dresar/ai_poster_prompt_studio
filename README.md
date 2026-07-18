# 🎨 AI Poster Prompt Studio 🚀
[![Flutter](https://img.shields.io/badge/Flutter-v3.12.2-blue?logo=flutter&logoColor=white&style=for-the-badge)](https://flutter.dev)
[![React](https://img.shields.io/badge/React-v19.0-blue?logo=react&logoColor=white&style=for-the-badge)](https://react.dev)
[![Express](https://img.shields.io/badge/Express-v4.19.2-lightgrey?logo=express&logoColor=white&style=for-the-badge)](https://expressjs.com)
[![Drizzle ORM](https://img.shields.io/badge/Drizzle_ORM-v0.35.2-orange?logo=drizzle&logoColor=white&style=for-the-badge)](https://orm.drizzle.team)
[![Gemini AI](https://img.shields.io/badge/Gemini_AI-v1.5-purple?logo=google-gemini&logoColor=white&style=for-the-badge)](https://deepmind.google/technologies/gemini/)

> **AI Poster Prompt Studio** adalah platform *full-stack* modern yang dirancang untuk menghasilkan prompt poster yang sangat teroptimasi, konsisten, dan memiliki daya tarik viral tinggi (misalnya untuk Bing Image Creator, Midjourney, Stable Diffusion, atau DALL-E 3). Platform ini menggunakan integrasi AI Gemini melalui rotasi API key, sistem konsistensi karakter (Character Bible), template prompt dinamis, dan sistem manajemen admin yang komprehensif.

---

## 📸 Demo & Tampilan Antarmuka (Aplikasi Klien)

Berikut adalah alur tampilan antarmuka utama pada aplikasi klien (**Flutter App**):

### 🔑 1. Halaman Masuk (Login Screen)
![Login Screen](assets/demo/01_login.png)
*Halaman masuk untuk otentikasi akun pengguna.*

### 📱 2. Dashboard Utama (Dashboard Screen)
![Dashboard Screen](assets/demo/02_dashboard.png)
*Menu utama untuk memilih kategori studio konten AI.*

### 📝 3. Formulir Pembuatan Poster (Poster Form)
![Poster Form](assets/demo/03_poster_form.png)
*Formulir input topik poster utama serta fitur opsional untuk mengunggah gambar referensi.*

### ⚙️ 4. Parameter Visual Tambahan (Visual Parameters)
![Visual Parameters](assets/demo/04_poster_parameters.png)
*Konfigurasi lanjutan untuk gaya desain, tata letak, ukuran rasio, dan palet warna poster.*

### 📜 5. Riwayat Eksekusi (Execution History)
![Execution History](assets/demo/05_history.png)
*Daftar riwayat pembuatan prompt AI lengkap dengan skor viralitas dan kategori konten.*

### 📂 6. Katalog Templat (Templates Library)
![Templates Library](assets/demo/06_templates.png)
*Halaman pemilihan templat prompt poster pemasaran visual yang siap dipakai.*

### 👤 7. Profil Pengguna & Token (User Profile)
![User Profile](assets/demo/07_profile.png)
*Informasi profil akun, sisa token/kredit, dan pengaturan kunci ImageKit pribadi.*

### 🛠️ 8. Pengaturan Aplikasi & Bahasa (App Settings)
![App Settings](assets/demo/08_settings.png)
*Halaman preferensi bahasa sistem (Indonesia/Inggris) dan fitur pembersih memori cache.*

---

## 🗺️ Struktur Dokumentasi Proyek

Untuk mempermudah pemahaman dan instalasi proyek ini, kami membagi dokumentasi menjadi beberapa sub-dokumen terperinci:

*   📖 **[Dokumentasi Arsitektur & Skema Database (docs/ARCHITECTURE.md)](docs/ARCHITECTURE.md)**
    *   Detail arsitektur full-stack sistem, diagram relasi database menggunakan Drizzle ORM, alur eksekusi Gemini AI, dan workflow sistem.
*   ⚙️ **[Panduan Instalasi & Konfigurasi (docs/INSTALLATION.md)](docs/INSTALLATION.md)**
    *   Cara menginstal, mengonfigurasi variabel lingkungan (`.env`), menjalankan server backend (Node.js), portal admin (React), dan aplikasi klien (Flutter).
*   ⭐ **[Panduan Fitur Utama (docs/FEATURES.md)](docs/FEATURES.md)**
    *   Penjelasan mendalam tentang *Character Bible & Consistency*, *AI Prompt Engine*, *Gemini API Key Rotation*, dan *License Voucher System*.
*   🤝 **[Panduan Kontribusi & Standar Kode (docs/CONTRIBUTING.md)](docs/CONTRIBUTING.md)**
    *   Panduan bagi pengembang yang ingin melakukan kontribusi, konvensi kode, struktur direktori repositori secara penuh, dan pengelolaan migrasi database.

---

## ⚙️ Ringkasan Alur Kerja Sistem (End-to-End Workflow)

Berikut adalah diagram alur bagaimana pengguna (melalui aplikasi Flutter) meminta pembuatan poster, dan bagaimana Backend memprosesnya menggunakan template, profil karakter dari **Character Bible**, dan rotasi API Key Gemini untuk mengembalikan prompt final yang siap pakai:

```mermaid
graph TD
    %% Definisi Aktor & Entitas
    User[📱 Flutter Client User]
    Admin[💻 Admin Portal Interface]
    API[🛡️ Express API Backend]
    DB[(💾 Neon PostgreSQL DB)]
    Gemini[🤖 Gemini Generative AI]

    %% Alur Input Pengguna
    User -->|1. Pilih Karakter & Isi Form Input| API
    API -->|2. Ambil Profil Karakter, Template & Dropdown| DB
    DB -.->|Kirim Karakter Bible & Template| API
    
    %% Alur Seleksi & Rotasi Kunci API Gemini
    API -->|3. Pilih Gemini API Key Aktif & Sehat| DB
    DB -.->|Gunakan Key Prioritas Tertinggi| API
    
    %% Alur Pengolahan AI
    API -->|4. Gabungkan Input + Character Bible + Template| Gemini
    Gemini -->|5. Hasilkan Prompt Final & Skor Viralitas| API
    
    %% Penyimpanan & Output
    API -->|6. Simpan Prompt Hasil & Update Kuota User| DB
    API -->|7. Tampilkan Prompt Final & Gambar Pratinjau| User

    %% Hubungan Admin
    Admin -->|Kelola Karakter, Template, Dropdown & API Keys| DB
    
    %% Penataan Gaya Diagram
    style User fill:#e1f5fe,stroke:#039be5,stroke-width:2px;
    style Admin fill:#ede7f6,stroke:#5e35b1,stroke-width:2px;
    style API fill:#e8f5e9,stroke:#2e7d32,stroke-width:2px;
    style DB fill:#fff3e0,stroke:#ef6c00,stroke-width:2px;
    style Gemini fill:#f3e5f5,stroke:#8e24aa,stroke-width:2px;
```

---

## ⚡ Fitur Utama

1.  **Character Bible (Konsistensi Karakter)**: Menyimpan detail deskripsi visual karakter (pakaian, rambut, wajah) agar ketika AI men-generate prompt gambar berkali-kali, karakter yang dihasilkan tetap sama (konsisten).
2.  **Rotasi API Key Otomatis**: Backend secara cerdas merotasi API Key Gemini dari kolam kunci yang aktif berdasarkan tingkat penggunaan dan status kesehatan kunci tersebut, menghindari *Rate Limit* atau kegagalan pemanggilan.
3.  **Dynamic Form Renderer**: Struktur form di aplikasi Flutter dimotori secara dinamis oleh konfigurasi dari database yang dikontrol sepenuhnya melalui Admin Panel.
4.  **Sistem Voucher Lisensi**: Mengisi kredit atau masa berlaku paket subscription pengguna menggunakan kode voucher lisensi yang dihasilkan oleh admin.
5.  **Drizzle ORM & Postgres (Neon DB)**: Integrasi database modern berkecepatan tinggi dengan tipe data aman menggunakan TypeScript.

---

## 🚀 Memulai Cepat (Quick Start)

Untuk menjalankan seluruh ekosistem ini secara lokal di komputer Anda, Anda dapat menggunakan script launcher otomatis `run_all.bat` yang sudah disediakan:

```bash
# Jalankan launcher
.\run_all.bat
```

Script ini akan otomatis melakukan:
1.  Menjalankan backend API server pada port `3000`.
2.  Menjalankan aplikasi Flutter Web di browser Chrome.

*Catatan: Kredensial default untuk Admin Portal:*
*   **Email**: `admin@promptstudio.com`
*   **Password**: `admin123`

---

## 🛡️ Lisensi & Hak Cipta

Proyek ini dibuat untuk portofolio dan penggunaan internal. Hak cipta dilindungi oleh pengembang repositori [dresar/ai_poster_prompt_studio](https://github.com/dresar/ai_poster_prompt_studio).
