# 🏛️ Arsitektur Sistem & Database - AI Poster Prompt Studio

Dokumen ini merinci arsitektur perangkat lunak, desain database, dan alur integrasi AI dari proyek **AI Poster Prompt Studio**.

---

## 🌐 Arsitektur Ekosistem (System Architecture)

Sistem ini didesain menggunakan arsitektur **Three-Tier** modern yang memisahkan antara Presentation Layer, Application Layer, dan Data Layer:

```mermaid
graph TD
    subgraph Presentation Layer [📱 Presentation Layer]
        Flutter[📱 Flutter Client Mobile/Web <br>Riverpod + GoRouter]
        React[💻 React Admin Portal <br>TanStack Start + Tailwind v4]
    end

    subgraph Application Layer [🛡️ Application Layer]
        Express[Express.js Server <br>Node.js + TypeScript]
        Auth[JWT & Bcrypt Auth Middleware]
        PromptEngine[AI Prompt Engine]
        Logger[Winston Logger & Audit Logs]
    end

    subgraph Data & AI Services [💾 Data & AI Services]
        DB[(Neon PostgreSQL Database)]
        Drizzle[Drizzle ORM Mapping]
        Gemini[Google Gemini API Pool]
    end

    %% Hubungan antar layer
    Flutter -->|REST API Requests JSON| Express
    React -->|REST API Requests JSON| Express
    Express --> Auth
    Express --> PromptEngine
    Express --> Logger
    PromptEngine --> Drizzle
    Drizzle --> DB
    PromptEngine -->|Generative Text Request| Gemini
    
    %% Styling
    style Presentation Layer fill:#f9f9f9,stroke:#333,stroke-width:1px;
    style Application Layer fill:#f5f5f5,stroke:#333,stroke-width:1px;
    style Data & AI Services fill:#f0f0f0,stroke:#333,stroke-width:1px;
    style Flutter fill:#e1f5fe,stroke:#0288d1,stroke-width:2px;
    style React fill:#ede7f6,stroke:#5e35b1,stroke-width:2px;
    style Express fill:#e8f5e9,stroke:#2e7d32,stroke-width:2px;
    style DB fill:#fff3e0,stroke:#e65100,stroke-width:2px;
    style Gemini fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px;
```

---

## 💾 Skema & Relasi Database (Database Schema ERD)

Database menggunakan **PostgreSQL** yang diinangi di **Neon DB Serverless**. Struktur tabel dipetakan menggunakan **Drizzle ORM**. Berikut adalah representasi Entity-Relationship Diagram (ERD) dari database kita:

```mermaid
erDiagram
    User {
        text id PK
        text email UK
        text passwordHash
        text role "USER | ADMIN"
        text subscriptionStatus "FREE | VIP"
        timestamp subscriptionExpiresAt
        integer credits
        text imagekitPublicKey
        text imagekitPrivateKey
        text imagekitUrlEndpoint
        timestamp createdAt
    }
    LicenseKey {
        text id PK
        text key UK
        integer days
        integer credits
        boolean isUsed
        text usedBy FK
        timestamp usedAt
        timestamp createdAt
    }
    Prompt {
        text id PK
        text userId FK
        text mode
        text topic
        jsonb payloadJson
        text promptFinal
        text referenceImageUrl
        jsonb referenceImageUrls
        text category
        text_array hooks
        integer viralScore
        boolean isFavorite
        boolean isShared
        timestamp createdAt
    }
    Character {
        text id PK
        text name
        text description
        text imageUrl
        text promptConsistency
        jsonb characterBible
        text positivePrompt
        text negativePrompt
        text masterPrompt
        text category
        boolean isActive
        timestamp createdAt
    }
    VisualStyle {
        text id PK
        text name
        text promptTemplate
        text previewImageUrl
        boolean isActive
        timestamp createdAt
    }
    PromptTemplate {
        text id PK
        text category
        text template
        boolean isActive
        text previewImageUrl
        integer viralScore
        jsonb viralBreakdown
        jsonb payloadJson
        text_array hooks
        text analysis
    }
    DropdownOption {
        text id PK
        text groupKey
        text label
        text value
        text helperText
        text icon
        boolean isActive
        integer sortOrder
    }
    GeminiApiKey {
        text id PK
        text keyEncrypted
        boolean isEncrypted
        boolean isActive
        integer priority
        integer usageCount
        timestamp lastUsedAt
        text healthStatus "healthy | dead"
        text provider
    }
    Log {
        text id PK
        text userId FK
        text action
        jsonb detail
        timestamp createdAt
    }

    %% Hubungan Relasi
    User ||--o{ Prompt : "membuat"
    User ||--o{ LicenseKey : "mengklaim"
    User ||--o{ Log : "memicu"
```

---

## 🤖 Alur Rekayasa Prompt AI (AI Prompt Engineering Flow)

Mekanisme utama pembuatan prompt menggabungkan masukan variabel pengguna dengan aset visual dan arahan konsistensi dari database. Proses ini memastikan hasil akhir prompt memiliki kualitas tinggi dan struktur yang sesuai untuk generator gambar AI.

```mermaid
flowchart TD
    %% Mulai Proses
    Start([Mulai Generate Prompt]) --> UserInput[1. Pengguna memasukkan Topik & Pilihan Form di Flutter]
    
    %% Pengambilan Data Database
    UserInput --> FetchData[2. Backend mengambil data dari Database Neon]
    FetchData --> FetchChar[Karakter Bible & Konsistensi]
    FetchData --> FetchStyle[Visual Style Template]
    FetchData --> FetchPromptTemp[Prompt Formula Template]
    
    %% Penggabungan Prompt
    FetchChar --> Combine[3. Prompt Assembler Engine]
    FetchStyle --> Combine
    FetchPromptTemp --> Combine
    UserInput --> Combine
    
    %% Alur Gemini
    Combine --> APIKeyCheck{4. Cek Pool API Key Gemini}
    APIKeyCheck -->|Ada Key Sehat & Aktif| CallGemini[5. Eksekusi Prompt Builder via Gemini AI API]
    APIKeyCheck -->|Key Habis/Error| ThrowError[Kembalikan Error ke Klien]
    
    %% Response Gemini
    CallGemini --> ParseResponse[6. Parse Output JSON dari Gemini]
    ParseResponse --> SaveDB[7. Simpan Prompt Final, Hooks, & Skor Viralitas ke DB]
    SaveDB --> DeductCredit[8. Kurangi Kredit Pengguna & Tambah Log Audit]
    DeductCredit --> SendClient[9. Kirim Prompt Final ke Flutter Client]
    SendClient --> End([Selesai])

    style Start fill:#e8f5e9,stroke:#2e7d32,stroke-width:1px;
    style End fill:#ffebee,stroke:#c62828,stroke-width:1px;
    style APIKeyCheck fill:#fffde7,stroke:#fbc02d,stroke-width:2px;
```

---

## 🔑 Sistem Rotasi API Key Gemini (Gemini API Key Rotation Engine)

Untuk mencegah pemblokiran akibat pembatasan kuota (*rate limits*) dan menjaga keandalan sistem (*high availability*), backend mengimplementasikan **Gemini API Key Manager** dengan alur kerja berikut:

1.  **Enkripsi Kunci**: API Key disimpan di database dengan enkripsi dua arah berbasis `crypto` Node.js untuk menjaga keamanan kunci.
2.  **Pemilihan Kunci Dinamis**: Setiap ada request prompt generation, backend mencari semua API Key di tabel `GeminiApiKey` yang memiliki status `isActive = true` dan `healthStatus = 'healthy'`.
3.  **Prioritas Eksekusi**: Kolam kunci diurutkan berdasarkan `priority` tertinggi dan `usageCount` terendah.
4.  **Detektor Kerusakan (Circuit Breaker)**:
    *   Jika pemanggilan AI menggunakan kunci tertentu menghasilkan error autentikasi atau kuota habis (`RESOURCE_EXHAUSTED` / `API_KEY_INVALID`), backend secara otomatis menandai status kesehatan kunci tersebut sebagai `'dead'`.
    *   Sistem kemudian segera beralih mencoba kunci berikutnya di dalam kolam tanpa menghentikan request pengguna.
    *   Admin akan menerima notifikasi status kesehatan kunci ini melalui portal admin secara langsung.
