# 🚀 AI Poster Prompt Studio

Aplikasi full-stack pembuat prompt & poster AI interaktif berbasis **NestJS Backend**, **TanStack Start Frontend**, **Prisma PostgreSQL**, dan **Storage CDN Gateway Service**.

---

## 📌 Struktur Repositori

```text
ai_poster_prompt_studio/
├── backend/            # REST API Service (NestJS, Prisma, JWT Auth, Gateway API)
├── promtingfrontend/   # Admin Console & User Web App (React 19, Vite, TanStack Start)
├── docs/               # Dokumentasi Resmi API & Storage Gateway
├── assets/             # Demo Aset & Screenshots
├── run_all.bat         # Batch Script untuk Menjalankan Backend & Frontend Serentak
└── vercel.json         # Konfigurasi Build & Deployment Vercel
```

---

## 🌟 Fitur Utama

- **📸 Storage CDN Gateway Integration**: Pengunggahan media terpusat dengan fitur *multi-CDN failover*, *EXIF auto-orientation fix*, dan manajemen berkas CDN persisten.
- **🤖 Gemini 2.5 Flash AI Completions**: Generate prompt poster pintar secara otomatis via Gateway Service (`/v1/chat/completions`).
- **🎨 Neobrutalism Design System**: Antarmuka web modern dengan TailwindCSS v4, Lucide Icons, dan animasi mikro yang responsif.
- **👤 User & Admin Console**: Fitur otentikasi JWT, role-based access control (ADMIN/USER), dan User Avatar Profile Dropdown Menu.
- **🔔 Web Browser Native Notification API**: Notifikasi desktop bawaan browser untuk memantau proses unggah dan aktivitas sistem secara real-time.

---

## ⚡ Cara Menjalankan Project (Local Development)

### 1. Menjalankan Backend & Frontend Serentak (Windows)
Cukup eksekusi file batch launcher:

```bash
.\run_all.bat
```

Script akan otomatis:
- Menjalankan **Backend NestJS** di `http://localhost:3000`
- Menjalankan **Frontend Console** di `http://localhost:8080`

### 2. Menjalankan Manual per Folder

#### Backend:
```bash
cd backend
npm install
npm run start:dev
```

#### Frontend:
```bash
cd promtingfrontend
npm install
npm run dev
```

---

## 📖 Dokumentasi Resmi

- **[Storage CDN Gateway Specs](file:///c:/Users/NCN0C/Documents/ai_poster_prompt_studio/docs/STORAGE_CDN_GATEWAY.md)**: Dokumentasi teknis endpoint REST API `/v1/storage/upload`, `/v1/storage/list`, dan `/v1/storage/files/:id`.
- **[Frontend README](file:///c:/Users/NCN0C/Documents/ai_poster_prompt_studio/promtingfrontend/README.md)**: Dokumentasi arsitektur frontend TanStack Start & Vercel deployment setup.

---

## 📄 Lisensi

Hak Cipta © 2026 **AI Poster Prompt Studio Team**. All rights reserved.
