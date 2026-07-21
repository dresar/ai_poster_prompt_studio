# 🎨 AI Poster Prompt Studio - Frontend Console

Aplikasi Web Admin Console & Media Manager modern berkinerja tinggi untuk **AI Poster Prompt Studio**, dibangun dengan **React 19**, **TanStack Start (Vite + Nitro)**, **TailwindCSS**, dan **Storage CDN Gateway Service**.

---

## 🌟 Fitur Utama

### 1. 📸 Storage CDN Gateway Manager (Terpusat)
- **Multi-CDN Failover**: Mengunggah media langsung ke Storage CDN Gateway (`https://one.apprentice.cyou/v1/storage/upload`) dengan otomatisasi ImageKit ➔ Cloudinary ➔ Uploadcare.
- **Auto EXIF Orientation Fix**: Koreksi rotasi foto otomatis pada saat proses pengunggahan.
- **Upload Massal & Pratinjau**: Pengunggahan banyak gambar sekaligus dengan indikator status *real-time*.
- **Manajemen Berkas CDN**: Pratinjau detail media via **Responsive Popup Modal**, salin Direct CDN URL instan, dan hapus berkas persisten dari database.

### 2. 👤 Responsive Admin Layout & Profile Avatar
- **User Avatar Profile Dropdown**: Pengelolaan profil admin dengan menu popup melayang (Profil, Pengaturan Studio, Kelola User, dan Keluar Console).
- **Desain Neobrutalism Modern**: Antarmuka visual yang berani, kontras tinggi, dan responsif sempurna untuk desktop maupun mobile.

### 3. 🔔 Web Browser Native Notification API
- **Alert Real-Time**: Integrasi langsung dengan Notification API bawaan browser untuk memberikan pemberitahuan desktop saat aktivitas upload/penghapusan selesai.
- **Pusat Notifikasi Persisten**: Popover lonceng notifikasi interaktif dilengkapi pengatur izin browser, opsi "Tandai Dibaca", dan "Hapus Semua".

### 4. 🤖 AI Completion Gateway (Gemini 2.5 Flash)
- Terhubung dengan AI Chat & Completion Gateway (`https://one.apprentice.cyou/v1/chat/completions`) untuk pembuatan prompt poster otomatis.

---

## 🛠️ Teknologi Yang Digunakan

| Kategori | Teknologi |
| :--- | :--- |
| **Core UI** | React 19, TypeScript |
| **Framework & Build** | Vite 8, TanStack Start, TanStack Router, Nitro Engine |
| **Styling** | TailwindCSS v4, Neobrutalism Design System |
| **Komponen UI** | Radix UI Primitives, Lucide Icons, Sonner Toast |
| **Storage API** | Storage CDN Gateway Service (REST Client) |

---

## 🔑 Setelan Kredensial Gateway API

Aplikasi ini menggunakan kredensial Gateway terpusat untuk operasi penyimpanan media dan completion AI:

- **Base URL Storage CDN**: `https://one.apprentice.cyou/v1`
- **Gateway API Key**: `AR_4c9b2435_929a80d916261b15c582db6fe3e41e52`
- **Target Provider Storage**: `CLOUDINARY`

---

## 🚀 Panduan Memulai (Local Setup)

### 1. Prasyarat Sistem
- **Node.js**: versi `v18.0.0` atau yang lebih baru
- **npm** / **bun** / **pnpm**

### 2. Instalasi Dependensi
Jalankan perintah berikut di dalam direktori `promtingfrontend`:

```bash
npm install
```

### 3. Menjalankan Development Server
```bash
npm run dev
```
Aplikasi frontend akan berjalan di `http://localhost:8080` (atau port yang ditentukan Vite).

### 4. Melakukan Production Build
```bash
npm run build
```
Hasil build static dan serverless function akan dibuat di folder `.output/`.

---

## 🌐 Panduan Deployment (Vercel)

Aplikasi ini sudah dilengkapi dengan berkas konfigurasi `vercel.json` bawaan:

```json
{
  "buildCommand": "npm run build",
  "outputDirectory": ".output/public",
  "rewrites": [
    {
      "source": "/(.*)",
      "destination": "/index.html"
    }
  ]
}
```

### Langkah Deploy ke Vercel:
1. Hubungkan repository GitHub Anda ke **Vercel Dashboard**.
2. Di bagian **Project Settings -> General**:
   - **Root Directory**: `promtingfrontend`
   - **Build Command**: `npm run build`
   - **Output Directory**: `.output/public`
3. Simpan dan jalankan **Redeploy**.

---

## 📁 Struktur Direktori

```text
promtingfrontend/
├── public/                 # Aset statis & favicon
├── src/
│   ├── components/        # Komponen UI & StorageCdnModal
│   │   └── ui/            # Radix UI + Neobrutalism Primitives
│   ├── hooks/             # Custom React Hooks
│   ├── lib/               # Utility API, browserNotifications, & Helper
│   ├── routes/            # TanStack Router File-Based Routes
│   │   ├── _admin.media.tsx # Halaman Manajemen Media CDN
│   │   ├── _admin.tsx     # Admin Console Layout & Header
│   │   └── index.tsx      # Dashboard Utama
│   ├── router.tsx         # Konfigurasi TanStack Router
│   └── styles.css         # Styling TailwindCSS Utama
├── vercel.json            # Konfigurasi Deployment Vercel
├── vite.config.ts         # Konfigurasi Vite & TanStack Start
└── package.json           # Dependensi & Script Project
```

---

## 📄 Lisensi

Hak Cipta © 2026 **AI Poster Prompt Studio**. Seluruh hak dilindungi undang-undang.
