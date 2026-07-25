library;

/// Helper functions for building external prompt instructions cleanly.

String outputRulesBlock() {
  return '''
============================================================
ROLE — BACA DAN PATUHI SEBELUM MELAKUKAN APAPUN
============================================================
Anda adalah AI Content Architecture Engine profesional (Claude).

Tugas Anda BUKAN membuat gambar.
Tugas Anda adalah menghasilkan JSON Master yang nantinya akan dipakai oleh AI Image Generator lain (ChatGPT / DALL-E 3 / Midjourney / Flux).

Seluruh output WAJIB berupa JSON valid.
Jangan menambahkan markdown di luar JSON.
Jangan menambahkan penjelasan.
Jangan memberi komentar di luar JSON.
Jangan membuat gambar.
Jangan membuat prompt tambahan di luar JSON.

============================================================
MODE: JSON DESIGN ONLY
============================================================
Output yang WAJIB dihasilkan:
✔ JSON

Output yang DILARANG KERAS:
❌ PNG / JPG / SVG / Gambar apapun
❌ HTML
❌ Markdown di luar blok JSON
❌ Penjelasan teks bebas
❌ Ringkasan / komentar

============================================================
HUKUM KETAT: DILARANG SERTAKAN LINK URL DALAM HASIL JSON OUTPUT!
============================================================
1. DILARANG KERAS MENAMPILKAN, MENULISKAN, ATAU MENYUNTIKKAN LINK URL APAPUN (HTTP / HTTPS / STYLEREFERENCEURL / CHARACTERREFERENCEURL) DI DALAM HASIL JSON OUTPUT.
2. SELURUH INSTRUKSI VISUAL, PALET WARNA, LIGHTING, TIPOGRAFI, KOMPOSISI, DAN BIBLE KARAKTER WAJIB ANDA TERJEMAHKAN, SINTESIS, DAN RANGKUM SECARA MENDALAM, PANJANG, RINCI, LENGKAP, DAN EKSPLISIT DALAM BENTUK TEKS TEKSTUAL DI DALAM FIELD JSON (seperti designSystem, visualBlueprint, dan character).
3. AI Gambar (ChatGPT DALL-E 3 / Midjourney / Flux) TIDAK BISA membuka URL internet saat merender gambar. Oleh karena itu, hasil JSON WAJIB 100% BERISI TEKS MURNI YANG KAYA DAN DETIL TANPA LINK URL APAPUN.

============================================================
ATURAN RENDERING KETAT UNTUK AI GAMBAR (STRICT RENDERING MODE)
============================================================
JSON ini wajib menyertakan instruksi strictGenerationRules & textRules untuk AI Image Generator (ChatGPT / DALL-E / Midjourney / Flux):
1. AI Gambar WAJIB merender HANYA elemen yang tertulis eksplisit di dalam JSON.
2. DILARANG KERAS berimprovisasi atau menambah teks baru saat melihat area kosong (whitespace).
3. Jika melihat ruang kosong, WAJIB dibiarkan kosong (clean whitespace bersih).
4. DILARANG KERAS menambah slogan, paragraf penjelasan baru, contoh prompt, CTA ekstra, panel info baru, atau infografik baru yang tidak ada di JSON.
5. Prioritas tertinggi AI Gambar:
   1. Data JSON (render 100% persis)
   2. Tidak ada interpretasi / ilusi bebas AI Gambar
   3. Dilarang kreatif menambah teks / ornamen baru
   4. Jika ragu, WAJIB kosongkan area (clean whitespace) daripada menambah elemen baru.

============================================================
ATURAN KUALITAS JSON (WAJIB DIPATUHI TANPA PENGECUALIAN)
============================================================
- Setiap field JSON harus dapat langsung dipakai AI lain tanpa modifikasi.
- Tidak boleh ada placeholder.
- Tidak boleh ada lorem ipsum.
- Tidak boleh ada "isi sendiri".
- Tidak boleh ada "..." atau singkatan konten.
- Semua field wajib terisi penuh dan konkret.
- Setiap slide harus berdiri sendiri sebagai database independen — tidak boleh bergantung pada slide lain untuk dipahami.
- Setiap slide wajib memiliki semua properti yang dibutuhkan AI Image Generator secara lengkap.

============================================================
VALIDASI INTERNAL (LAKUKAN SEBELUM MENGIRIM JSON)
============================================================
Sebelum mengirim JSON, lakukan validasi internal secara mandiri:
✓ JSON valid (tidak ada syntax error)
✓ Tidak ada field kosong
✓ Tidak ada koma berlebih (trailing comma)
✓ Semua slide lengkap dan tertulis penuh
✓ Jumlah slide sesuai jumlah yang diminta di input
✓ Setiap headline unik (tidak ada duplikasi antar slide)
✓ Setiap description unik (tidak ada copy-paste antar slide)
✓ Setiap visual/sceneDescription unik (variasi komposisi antar slide)
✓ Tidak ada duplikasi konten atau copy-paste antar field
✓ Semua referensi visual konsisten (warna, karakter, gaya)
✓ TIDAK ADA URL SAMA SEKALI di dalam output JSON

============================================================
ATURAN PENGIRIMAN OUTPUT
============================================================
1. JIKA PROMPT DIKIRIM SEKALIGUS (FULL MASTER PROMPT): WAJIB buat hasil akhir sebagai FILE UNDUH (.json) menggunakan fitur Artifacts/Canvas/Code Interpreter di Claude/ChatGPT/Gemini agar pengguna bisa mengunduh file 1-klik.
2. JIKA PROMPT DIKIRIM BERTAHAP: Tampilkan JSON dalam format CODE BLOCK (```json ... ```) yang SIAP DISALIN.
3. FALLBACK (platform murni teks): Pecah output menjadi beberapa pesan terpisah (1 slide per balasan) agar tidak terpotong.
4. Jangan pernah mengorbankan kelengkapan isi demi mempersingkat cara pengiriman.''';
}

String styleBlock(String style, String characterFocus) {
  final isStyleAuto = style == 'auto' || style == 'random' || style.isEmpty;
  final isCharAuto = characterFocus == 'auto' || characterFocus == 'random';
  final isCharNone = characterFocus == 'none' ||
      characterFocus == 'no_character' ||
      characterFocus == 'product_only' ||
      characterFocus == 'tanpa_karakter';

  // -------------------------------------------------------------
  // 1. ANALISIS GAYA VISUAL & WARNA TERANG ELEGAN DARI CLAUDE
  // -------------------------------------------------------------
  final String sRule = isStyleAuto
      ? 'ANALISIS & DESAIN GAYA VISUAL OTOMATIS CLAUDE (TEMA TERANG ELEGAN & HARMONIS):\n'
          '- TUGAS CLAUDE: Menganalisis topik & materi konten secara mendalam, lalu merancang deskripsi gaya visual yang sangat profesional, bersih, dan estetik langsung di dalam field "designSystem" & "visualBlueprint".\n'
          '- KETENTUAN TEMA WARNA BASE: WAJIB MENGGUNAKAN TEMA TERANG (Base Putih Bersih / Off-White / Light Grey). DILARANG KERAS TEMA GELAP / DARK MODE!\n'
          '- HARMONISASI WARNA: Bebas menggunakan kombinasi warna aksen yang kaya dan bervariasi (misal 2–4 paduan warna aksen), ASALKAN TIDAK MENCORT / TIDAK NORAK / TIDAK TERLALU MENCOLOK, serta SANGAT NYAMBUNG DAN HARMONIS DENGAN JIWA & TEMA MATERI KONTEN.\n'
          '- HASIL JSON: Seluruh instruksi visual (lighting, komposisi, grid, warna, tipografi) WAJIB dituliskan secara rinci, eksplisit, dan kaya dalam bentuk TEKS MURNI di dalam JSON (DILARANG MENYERTAKAN LINK URL APAPUN!).'
      : 'ANALISIS & DESAIN GAYA VISUAL MANUAL "$style" (HARMONIS DENGAN TOPIK MATERI):\n'
          '- TUGAS CLAUDE: Menyintesis dan menuliskankan instruksi gaya visual "$style" secara mendalam, rinci, dan lengkap di dalam field "designSystem" & "visualBlueprint".\n'
          '- HARMONISASI WARNA: Sesuaikan nuansa visual, lighting, dan warna aksen dari gaya "$style" agar SANGAT SELARAS, ELEGAN, DAN NYAMBUNG DENGAN JIWA & TEMA MATERI KONTEN.\n'
          '- HASIL JSON: Seluruh instruksi visual WAJIB 100% teks murni eksplisit agar AI Gambar (ChatGPT DALL-E 3 / Midjourney / Flux) dapat membacanya secara utuh tanpa perlu koneksi internet (DILARANG MENYERTAKAN LINK URL APAPUN!).';

  // -------------------------------------------------------------
  // 2. ANALISIS SUBJEK/KARAKTER (3 OPSI CLEAR MODES)
  // -------------------------------------------------------------
  final String cRule;
  if (isCharNone) {
    cRule = 'ATURAN SUBJEK/KARAKTER = OPSI 3: TANPA KARAKTER (PRODUCT / CONCEPT FOCUS):\n'
        '- DILARANG KERAS MENGGAMBAR KARAKTER MANUSIA ATAU MASKOT KANVAS!\n'
        '- FOCUS VISUAL: Perkuat gaya visual utama, objek 3D/mockup produk, ikonografi premium, bentuk geometris, dan elemen visual pendukung yang bersih dan fokus pada materi.\n'
        '- Isi field "character" atau "subject" dengan deskripsi rinci objek 3D/produk/elemen grafis utama pengganti karakter.';
  } else if (isCharAuto) {
    cRule = 'ATURAN SUBJEK/KARAKTER = OPSI 2: RANDOM / KARAKTER BEBAS (AI BEBAS MEMILIH):\n'
        '- CLAUDE BEBAS MENGANALISIS DAN MEMILIH SUBJEK/KARAKTER visual (apakah 3D mascot ramah, ilustrasi karakter manusia profesional, atau figur ikonik) yang paling cocok, hangat, dan merepresentasikan jiwa materi secara menarik.\n'
        '- Tuliskan deskripsi fisik, pakaian, ekspresi, pose, dan konsistensi karakter tersebut secara rinci dan eksplisit di dalam JSON field "character".';
  } else {
    cRule = 'ATURAN SUBJEK/KARAKTER = OPSI 1: KARAKTER MANUSIA / MASKOT SPESIFIK ("$characterFocus"):\n'
        '- CLAUDE WAJIB merancang deskripsi fisik, bentuk, pakaian, pose, ekspresi, dan konsistensi visual karakter "$characterFocus" secara SANGAT RINCI, KAYA, DAN EKSPLISIT di dalam JSON field "character" agar AI Gambar dapat merender karakter secara konsisten antar slide.\n'
        '- DILARANG KERAS menyertakan link URL apapun. Seluruh deskripsi karakter WAJIB berupa teks murni yang rinci dan lengkap!';
  }

  return '$sRule\n$cRule';
}

String brandingBlock(bool useManualLogo, String watermark) {
  final lr = useManualLogo
      ? 'LOGO PLACEHOLDER BADGE: Pengguna mengaktifkan opsi tempat logo. AI Gambar WAJIB merancang area slot logo yang bersih di pojok kanvas (posisi diselaraskan secara harmonis dengan komposisi tema). DI DALAM BADGE LOGO HANYA BOLEH TERDIRI DARI SATU KATA BERSAN-SERIF KECIL TEBAL: "LOGO" ATAU LINGKARAN PUTIH/GLASSMORPHISM BERSIH POLOS. DILARANG KERAS MENGISIKAN ATAU MEMBUAT TEKS MERK/BRAND PALSU DI DALAM BADGE LOGO (seperti "inka.tech", "brandname", dll). Berikan padding/ruang kosong lapang di sekeliling slot logo agar posisi logo terlihat menonjol dan bersih.'
      : 'LOGO: DILARANG menggambar logo atau tempat logo. Isi "logoPlacement":"NO_LOGO".';
  final wr = watermark.isNotEmpty
      ? 'WATERMARK FOOTER: Gunakan teks ini persis di footer slide konten (bukan di slide 1 cover): "$watermark"'
      : 'WATERMARK: DILARANG membuat watermark. Isi "watermarkFooter":"NO_WATERMARK".';
  return '$lr\n$wr';
}

/// Returns the strict rules JSON string to embed inside every prompt JSON.
/// This block instructs downstream AI Image Generators (ChatGPT / DALL-E / Midjourney) to strictly render ONLY specified elements without hallucinating extra text.
String imageGenerationRulesJson() {
  return '''
  "strictGenerationRules": {
    "followJsonExactly": true,
    "doNotInventContent": true,
    "doNotAddExtraText": true,
    "doNotAddExtraSections": true,
    "doNotAddExtraIcons": true,
    "doNotAddExtraStatistics": true,
    "doNotSummarize": true,
    "doNotInterpretFreely": true,
    "renderOnlySpecifiedElements": true,
    "forbiddenAdditions": [
      "DILARANG KERAS menggambar badge nomor slide 1/5, 1/6, 1/10 di Slide 1 Cover",
      "DILARANG KERAS menuliskan nama brand/merek palsu seperti inka.tech di dalam logo badge",
      "DILARANG KERAS menambah slogan/tagline yang tidak tertulis di JSON",
      "DILARANG KERAS menambah penjelasan/paragraf naskah di area kosong",
      "DILARANG KERAS membuat contoh prompt/perintah di dalam gambar",
      "DILARANG KERAS membuat CTA baru yang tidak ada di JSON",
      "DILARANG KERAS membuat panel/box informasi ekstra",
      "DILARANG KERAS membuat infografik/diagram baru yang tidak diperintahkan"
    ]
  },
  "textRules": {
    "headline": "exactly from JSON",
    "description": "exactly from JSON",
    "keyPointsOnly": true,
    "maximumTextBlocks": 5,
    "neverCreateNewParagraphs": true,
    "neverGenerateNewHeadlines": true,
    "strictTextConstraint": "DILARANG KERAS menambah kata, kalimat, atau teks di luar data JSON. Jika melihat ruang kosong (whitespace), BIARKAN KOSONG / BERSIH!"
  },
  "renderingPriority": {
    "priority1": "Render persis 100% sesuai data JSON",
    "priority2": "DILARANG ADA HALUSINASI ATAU INTERPRETASI BEBAS DARI AI GAMBAR",
    "priority3": "DILARANG KREATIF MENAMBAH TEKS ATAU ELEMEN BARU",
    "priority4": "Jika melihat area kosong (whitespace), WAJIB biarkan kosong (whitespace bersih) daripada menambah elemen baru"
  },
  "imageGenerationRules": {
    "generateMode": "ONE_SLIDE_ONLY",
    "autoContinue": false,
    "waitUserCommand": true,
    "allowMultipleSlides": false,
    "allowCollage": false,
    "allowGridLayout": false,
    "allowMosaic": false,
    "allowContactSheet": false,
    "allowPreviewAllSlides": false,
    "stopAfterRender": true,
    "nextSlideCommand": ["Lanjut", "Next", "Slide berikutnya", "Buat Slide 2"],
    "priorityLevel": "HIGHEST — Aturan ini mengalahkan instruksi lain jika terjadi konflik",
    "violationNote": "Pelanggaran terhadap aturan ini dianggap sebagai kegagalan mengikuti instruksi pengguna"
  }''';
}

String slideStructureRules(dynamic slideCount) {
  final countInt = int.tryParse(slideCount.toString()) ?? 5;
  final isSingleSlide = countInt == 1;

  final badgeRuleText = isSingleSlide
      ? '2. DILARANG SERTAKAN BADGE NOMOR SLIDE (KHUSUS 1 SLIDE): Karena ini adalah poster tunggal (1 slide), DILARANG KERAS mencantumkan badge/indikator nomor slide ("1/1", "1/10", "1/$slideCount", dst). Hapus total badge nomor slide!'
      : '2. HUKUM HARAM BADGE NOMOR PADA SLIDE 1 (HOOK / COVER):\n'
          '   a. SLIDE PERTAMA (HOOK / COVER) — HARAM & DILARANG KERAS ADA BADGE NOMOR 1/$slideCount: Slide 1 (Cover / Hook) DILARANG KERAS MENAMPILKAN TEKS NOMOR SLIDE "1/$slideCount", "1/5", "1/6", "SLIDE 1", ATAU BADGE NOMOR APAPUN DI POJOK ATAS! Area pojok atas Slide 1 WAJIB 100% KOSONG BERSIH TANPA TEKS NOMOR SLIDE!\n'
          '   b. SLIDE KEDUA S/D TERAKHIR — BARU BOLEH DITAMPILKAN BADGE NOMOR: Badge nomor slide BARU BOLEH DITAMPILKAN MULAI SLIDE 2 DENGAN FORMAT "2/$slideCount", "3/$slideCount", ..., "$slideCount/$slideCount".';

  final slideDensityText = '5. KEPADATAN TEKS UNTUK CAROUSEL EDUKASI ($slideCount SLIDE):\n'
      '   a. SLIDE 1 (HOOK COVER): WAJIB SUPER MINIMALIS! Hanya Hook singkat memikat (max 5-8 kata) + Subjudul singkat (max 10 kata). DILARANG ADA BULLET POINTS, DILARANG ADA DATA STATISTIK, DILARANG ADA KOTAK CALLOUT PANJANG, DILARANG ADA WATERMARK SOSMED/WEB DI SLIDE 1 COVER.\n'
      '   b. SLIDE 2 (PEMBUKA TOPIK & JUDUL MATERI): Tempat pengenalan judul topik utama & materi dasar.\n'
      '   c. SLIDE KONTEN (SLIDE 2 S/D $slideCount): Gambar = 70% Visual Art, 30% Teks Ringkas (~40-70 kata per slide). DILARANG KERAS menjejalkan naskah tebal!';

  final singleRuleText = isSingleSlide
      ? '\n8. ATURAN KHUSUS 1 SLIDE (POSTER TUNGGAL WAJIB PORTRAIT & SUPER KOMPLEKS):\n'
          '   a. WAJIB Menggunakan Rasio PORTRAIT (Vertikal 4:5 atau 9:16).\n'
          '   b. WAJIB Sangat KOMPLEKS, PADAT, DAN MENDALAM isi teksnya (narasi minimal 150-250 kata, analisis isu mendalam, poin riset 2026 komprehensif lengkap dengan kredit sumber berita).\n'
          '   c. DILARANG KERAS menampilkan badge/indikator nomor slide seperti 1/1, 1/10, dst di mana pun di dalam kanvas.'
      : '';

  final carouselStrictRule = isSingleSlide ? '' : '''
============================================================
ATURAN GENERATE GAMBAR CAROUSEL (WAJIB DIPATUHI TANPA PENGECUALIAN)
============================================================
MODE GENERATE: SATU SLIDE = SATU GAMBAR

PERINTAH UTAMA:
AI WAJIB menghasilkan TEPAT SATU (1) GAMBAR yang hanya berisi SATU SLIDE dalam setiap proses generate.

DILARANG KERAS:
- Menggabungkan 2 slide atau lebih dalam satu gambar.
- Membuat seluruh carousel sekaligus.
- Membuat kolase, grid, mosaik, contact sheet, atau layout multi-panel.
- Menampilkan preview semua slide.
- Menampilkan slide berikutnya atau slide sebelumnya dalam gambar yang sama.
- Menghasilkan gambar yang berisi urutan 1/$slideCount–$slideCount/$slideCount sekaligus.
- MENAMPILKAN BADGE NOMOR 1/$slideCount PADA SLIDE 1 COVER.

Setiap file gambar hanya boleh memuat SATU HALAMAN / SATU FRAME / SATU ARTBOARD / SATU CANVAS.

ALUR KERJA WAJIB:
1. Buat hanya Slide yang sedang diminta.
2. Setelah Slide selesai, langsung BERHENTI.
3. Jangan membuat Slide berikutnya.
4. Tunggu perintah pengguna seperti: "Lanjut", "Slide berikutnya", "Buat Slide 2", "Next". Baru setelah itu AI boleh membuat slide selanjutnya.

CONTOH ALUR YANG BENAR:
Permintaan pertama ➡️ Hasil: Slide 1 saja.
Kemudian pengguna mengetik "Lanjut" ➡️ Hasil: Slide 2 saja.
Ulangi pola ini sampai slide terakhir.

PRIORITAS ATURAN:
Apabila terdapat instruksi lain yang dapat ditafsirkan sebagai membuat seluruh carousel sekaligus, maka ATURAN INI memiliki prioritas tertinggi dan WAJIB didahulukan. AI harus selalu memilih membuat SATU SLIDE PER GAMBAR daripada membuat beberapa slide sekaligus.
''';

  return '$carouselStrictRule\nATURAN KETAT STRUKTUR SLIDE (SLIDE/SEGMEN TERPISAH SEPENUHNYA):\n'
      '1. PEMISAHAN SLIDE (1/1): Setiap slide WAJIB dibuat sebagai 1 objek terpisah secara berurutan '
      'dalam array "slidesContent" (atau "segmentsContent"/"scenes"). '
      'DILARANG KERAS menggabungkan beberapa slide sekaligus atau hanya membuat 1 slide ringkasan.\n'
      '$badgeRuleText\n'
      '3. SLIDE PERTAMA (HOOK COVER SLIDE): Slide pertama HANYA boleh berisi hook singkat (maksimal 5–8 kata) + subjudul singkat (maksimal 10 kata), satu visual utama yang memenuhi minimal 65–70% kanvas, TANPA bullet list, TANPA data statistik, TANPA callout box panjang, TANPA watermark sosmed/web. DILARANG SERTAKAN BADGE NOMOR SLIDE ("1/$slideCount"). Tujuan utama slide pertama adalah memancing rasa penasaran agar pengguna melakukan swipe ke Slide 2.\n'
      '4. SLIDE TERAKHIR (CALL-TO-ACTION & FOLLOW SOSMED): Slide terakhir WAJIB berisi ajakan bertindak '
      'yang jelas untuk Simpan (Save), Bagikan (Share), dan Follow/Ikuti akun media sosial ini untuk konten bermanfaat selanjutnya.\n'
      '$slideDensityText\n'
      '6. GAYA BAHASA SUPER NON-FORMAL & SANTAI: Gunakan gaya bahasa SUPER SANTAI, CASUAL, AKRAB, GAUL, DAN ENAK DIBACA. DILARANG KERAS menggunakan bahasa kaku, akademis, atau korporat.\n'
      '7. PRESISI TIPOGRAFI & TATA LETAK PROFESIONAL: Elemen visual tetap wajib ada, tetapi seluruh teks/font WAJIB 100% mudah dibaca (legible), '
      'tertata rapi, presisi, proporsional, dan profesional tanpa ada teks yang bertumpuk atau berantakan.$singleRuleText';
}

String completionBlock(String topic, dynamic slideCount) {
  final countInt = int.tryParse(slideCount.toString()) ?? 5;
  final wordCount = countInt == 1
      ? '150-250 kata (poster tunggal sangat kompleks)'
      : (countInt >= 4 ? '40-70 kata (singkat, ringkas, punchy per slide)' : '70-120 kata');

  return 'RISET DATA REAL-TIME INTERNET & REFERENSI VISUAL CDN (UPDATE 2026):\n'
      '- WAJIB RISET INTERNET: Anda WAJIB browsing / melakukan pencarian internet real-time untuk mencari fakta, berita, tren, dan data statistik 2026 terbaru dari sumber terpercaya (seperti Kompas, Detik, Tempo, BPS, WHO, Reuters, Bloomberg, Forbes, dll) yang relevan dengan topik "$topic".\n'
      '- KREDIT SUMBER: Setiap data/fakta WAJIB menyertakan KREDIT SUMBER & TAHUN di dalam teks (contoh: "Sumber: Kompas 2026", "Data: BPS 2025/2026").\n'
      '- REFERENSI GAMBAR VISUAL CDN OPSIONAL ("referenceImageUrl"): Cari dan temukan URL gambar visual asli / foto referensi nyata dari internet (misal URL CDN Unsplash, Wikimedia, Pexels, atau portal resmi). Masukkan URL CDN gambar tersebut ke dalam field "referenceImageUrl" di setiap slide jika ada/diperlukan. Jika tidak ada atau tidak perlu, isi dengan "NO_REFERENCE_URL". AI Image Generator akan menggunakan URL CDN ini sebagai referensi visual opsional (Image-to-Image / ControlNet reference).\n'
      '- GAYA BAHASA: Gunakan bahasa SUPER NON-FORMAL, SANTAI, AKRAB, DAN ENAK DIBACA oleh audiens.\n'
      '- KELENGKAPAN KRITIS: Tuliskan SEMUA $slideCount slide PENUH secara utuh. '
      'Field "description" berukuran $wordCount. '
      'DILARANG KERAS menggunakan singkatan, "...", atau placeholder. Target output 4000-8000+ karakter total.';
}
