# 📸 DOKUMENTASI RESMI: STORAGE CDN GATEWAY & ROTASI PROVIDER

Dokumentasi ini menjelaskan arsitektur, setelan kredensial, integrasi backend/frontend, serta spesifikasi API terpusat untuk **Storage CDN Gateway**.

---

## 🔑 1. Setelan Kredensial & Base Server

| Parameter | Nilai Konfigurasi |
| :--- | :--- |
| **Base URL API** | `https://one.apprentice.cyou/v1` |
| **Gateway API Key** | `AR_4c9b2435_929a80d916261b15c582db6fe3e41e52` |
| **Target Provider CDN** | `CLOUDINARY` (atau `imagekit`, `uploadcare`) |
| **Fitur Utama** | Multi-CDN Failover (ImageKit ➔ Cloudinary ➔ Uploadcare) & Auto EXIF Orientation Fix |

---

## 🛰️ 2. SPESIFIKASI ENDPOINT STORAGE GATEWAY SERVICE

### A. Upload Berkas CDN (Base64 atau Remote URL)
- **URL**: `POST https://one.apprentice.cyou/v1/storage/upload`
- **Headers**:
  - `Content-Type: application/json`
  - `Authorization: Bearer AR_4c9b2435_929a80d916261b15c582db6fe3e41e52`
- **Request Body (JSON)**:
  ```json
  {
    "file": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==",
    "file_name": "poster_demo.png",
    "auto_rotate": true,
    "provider": "cloudinary"
  }
  ```
- **Response Success (`201 Created`)**:
  ```json
  {
    "success": true,
    "file": {
      "id": "5e7da21a-5304-464f-a433-76068bcb9320",
      "provider": "cloudinary",
      "url": "https://res.cloudinary.com/dvyfkgnsn/image/upload/v1784635892/cbjwqvvwwmpefot02c9v.png",
      "file_id": "cbjwqvvwwmpefot02c9v",
      "file_name": "poster_demo.png",
      "file_size": 64078,
      "mime_type": "image/png",
      "width": 751,
      "height": 945,
      "auto_rotated": true,
      "created_at": "2026-07-21T12:11:33.101Z"
    }
  }
  ```

---

### B. List Berkas CDN Terunggah di Database
- **URL**: `GET https://one.apprentice.cyou/v1/storage/list?page=1&limit=30&provider=cloudinary&search=`
- **Headers**: `Authorization: Bearer AR_4c9b2435_929a80d916261b15c582db6fe3e41e52`
- **Query Parameters**:
  - `page`: Nomor halaman (default: `1`)
  - `limit`: Jumlah item per halaman (default: `30`)
  - `provider`: Target provider (`cloudinary`, `imagekit`, `uploadcare`, atau kosongkan untuk semua)
  - `search`: Pencarian nama berkas
- **Response Success (`200 OK`)**:
  ```json
  {
    "object": "list",
    "items": [
      {
        "id": "5e7da21a-5304-464f-a433-76068bcb9320",
        "provider": "cloudinary",
        "url": "https://res.cloudinary.com/dvyfkgnsn/image/upload/v1784635892/cbjwqvvwwmpefot02c9v.png",
        "file_name": "01_login.png",
        "file_size": 64078,
        "width": 751,
        "height": 945
      }
    ],
    "pagination": {
      "total": 10,
      "page": 1,
      "limit": 30,
      "total_pages": 1
    }
  }
  ```

---

### C. Detail Berkas CDN Berdasarkan ID
- **URL**: `GET https://one.apprentice.cyou/v1/storage/files/:id`
- **Headers**: `Authorization: Bearer AR_4c9b2435_929a80d916261b15c582db6fe3e41e52`

---

### D. Hapus Berkas CDN dari Database Persistent
- **URL**: `DELETE https://one.apprentice.cyou/v1/storage/files/:id`
- **Headers**: `Authorization: Bearer AR_4c9b2435_929a80d916261b15c582db6fe3e41e52`
- **Response Success (`200 OK`)**:
  ```json
  {
    "success": true,
    "message": "File ID 5e7da21a-5304-464f-a433-76068bcb9320 berhasil dihapus dari database CDN"
  }
  ```

---

## 💻 3. INTEGRASI BACKEND & ENV

Konfigurasi disimpan di `backend/.env`:
```env
STORAGE_GATEWAY_KEY="AR_4c9b2435_929a80d916261b15c582db6fe3e41e52"
STORAGE_GATEWAY_BASE_URL="https://one.apprentice.cyou/v1"
```

Dalam controller `backend/src/modules/poster/poster.controller.ts`, fungsi `uploadToCloudinary` akan mengirim payload gambar base64 ke Storage CDN Gateway dan mengembalikan URL CDN persisten yang kemudian disimpan ke database PostgreSQL.

---

## 🎨 4. INTEGRASI FRONTEND (MEDIA MANAGER & MODAL)

1. **Halaman Admin Media CDN (`/admin/media`)**:
   - Dapat diakses melalui navigasi **Media CDN** di Admin Console Panel.
   - Mendukung **Upload Massal (Bulk Upload)** berkas media.
   - Filter pencarian, provider, galeri grid neobrutalism.
   - Fitur **Salin Direct URL**, **Lihat Detail Metadata**, dan **Hapus Berkas Real-time**.

2. **Modal Quick-Access Header (`StorageCdnModal`)**:
   - Icon tombol **Media CDN** di header desktop dan mobile.
   - Memungkinkan admin mengunggah, memilih, atau menyalin URL media dari mana saja tanpa meninggalkan halaman kerja.
