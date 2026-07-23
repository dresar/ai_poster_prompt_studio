library;

/// Helper functions for building external prompt instructions cleanly.

String outputRulesBlock() {
  return '''
============================================================
ATURAN OUTPUT & PENGIRIMAN HASIL (WAJIB DIBACA PERTAMA)
============================================================
1. JIKA PROMPT DIKIRIM SEKALIGUS (FULL MASTER PROMPT): WAJIB buat hasil akhir sebagai FILE UNDUH (.json) menggunakan fitur Artifacts/Canvas/Code Interpreter di Claude/ChatGPT/Gemini agar pengguna bisa mengunduh file 1-klik.
2. JIKA PROMPT DIKIRIM BERTAHAP (PART 1, PART 2, PART 3, PART 4): JANGAN buat file unduh terlebih dahulu! Tampilkan balasan JSON per part dalam format KODE CANVAS / CODE BLOCK (```json ... ```) yang SIAP DISALIN langsung di chat balasan, lalu beri tahu bahwa Anda siap menerima Part selanjutnya.
3. Setelah seluruh bagian atau file dibuat, konfirmasi balasan di chat dengan singkat + tautan/tombol unduh (jika mode file).
4. FALLBACK — jika platform AI murni teks tanpa fitur pembuat file atau canvas:
   a. Beri tahu secara eksplisit bahwa platform ini tidak mendukung pembuatan file.
   b. Pecah output menjadi beberapa pesan balasan terpisah (1 slide per satu balasan) agar tetap bisa disalin utuh tanpa terpotong di HP.
5. Jangan pernah mengorbankan kelengkapan isi (jumlah kata per slide, riset data 2026, dsb) demi mempersingkat cara pengiriman — aturan di atas hanya soal CARA MENGIRIM, bukan alasan untuk memotong konten.''';
}

String styleBlock(String style, String characterFocus) {
  final isStyleAuto = style == 'auto' || style == 'random' || style.isEmpty;
  final isCharAuto = characterFocus == 'auto' ||
      characterFocus == 'random' ||
      characterFocus == 'product_only' ||
      characterFocus.isEmpty;

  final sRule = isStyleAuto
      ? 'GAYA VISUAL (AI BEBAS MERANCANG): Pengguna memilih otomatis. Anda WAJIB merancang '
          'gaya visual yang SEDERHANA, ELEGAN, TIDAK MENCOLOK BERLEBIHAN, TIDAK NORAK, '
          'namun SANGAT PROFESIONAL DAN BERKELAS (mis: Swiss minimal design, clean modern typography grid, '
          'subtle 3D illustration, elegant dark mode). Teks wajib 100% sempurna, presisi, dan mudah dibaca.'
      : 'GAYA VISUAL (SUDAH DIPILIH MANUAL = "$style"): JANGAN rancang gaya visual baru. '
          'KOSONGKAN field "designSystem" dan "visualBlueprint" dengan: '
          '{"note":"SYSTEM_INJECTED - gaya dari backend: $style"}. '
          'Backend kami mengisi otomatis dari database.';

  final cRule = isCharAuto
      ? 'KARAKTER/SUBJEK (AI BEBAS): Rancang karakter/subjek visual yang konsisten dan menarik.'
      : 'KARAKTER/SUBJEK (MANUAL="$characterFocus"): JANGAN tulis deskripsi karakter baru. '
          'Isi "character":"SYSTEM_INJECTED".';

  return '$sRule\n$cRule';
}

String brandingBlock(bool useManualLogo, String watermark) {
  final lr = useManualLogo
      ? 'LOGO PLACEHOLDER (EDIT MANUAL CANVA): Pengguna mengaktifkan opsi tempat logo. AI WAJIB merancang badge lingkaran estetik di pojok frame dengan tulisan "LOGO" di bagian tengahnya. Tempat ini dibuat khusus sebagai slot agar pengguna bisa menempelkan logo asli di Canva.'
      : 'LOGO: DILARANG menggambar logo atau tempat logo. Isi "logoPlacement":"NO_LOGO".';
  final wr = watermark.isNotEmpty
      ? 'WATERMARK: Gunakan teks ini persis: "$watermark"'
      : 'WATERMARK: DILARANG membuat watermark. Isi "watermarkFooter":"NO_WATERMARK".';
  return '$lr\n$wr';
}

String slideStructureRules(dynamic slideCount) {
  final countInt = int.tryParse(slideCount.toString()) ?? 5;
  final isSingleSlide = countInt == 1;

  final badgeRuleText = isSingleSlide
      ? '2. DILARANG SERTAKAN BADGE NOMOR SLIDE (KHUSUS 1 SLIDE): Karena ini adalah poster tunggal (1 slide), DILARANG KERAS mencantumkan badge/indikator nomor slide ("1/1", "1/10", dst). Hapus atau jangan adakan badge nomor slide!'
      : '2. ATURAN BADGE/INDIKATOR NOMOR SLIDE (CAROUSEL >1 SLIDE):\n'
          '   a. SLIDE PERTAMA (HOOK) — DILARANG ADA BADGE NOMOR: Slide 1 TIDAK BOLEH memiliki badge atau indikator nomor slide apapun ("1/$slideCount", "1/10", dsb). Slide pertama adalah Hook murni tanpa nomor slide.\n'
          '   b. SLIDE KEDUA S/D TERAKHIR — WAJIB ADA BADGE NOMOR: Mulai Slide 2, sertakan badge nomor slide yang estetik di pojok atas frame (contoh: "2/$slideCount", "3/$slideCount", ..., "${slideCount}/$slideCount"). Badge harus kontras, bersih, dan konsisten di semua slide.';

  final slideDensityText = '5. KEPADATAN TEKS UNTUK CAROUSEL EDUKASI ($slideCount SLIDE):\n'
      '   a. GAMBAR = POIN INTI & VISUAL ARTWORK DOMINAN (70% Visual Art, 30% Teks Ringkas).\n'
      '   b. CAPTION = PENJELASAN LENGKAP & MENDALAM.\n'
      '   c. BATAS KARAKTER TEKS GAMBAR: Total teks per 1 slide WAJIB 350–700 karakter (~40–70 kata per slide agar nyaman dibaca di layar HP). Headline: 30–60 karakter, Subheadline: 40–80 karakter, Bullet points: 3–5 poin (20–50 karakter per bullet point). DILARANG KERAS menjejalkan naskah tebal di dalam gambar carousel!';

  final singleRuleText = isSingleSlide
      ? '\n8. ATURAN KHUSUS 1 SLIDE (POSTER TUNGGAL WAJIB PORTRAIT & SUPER KOMPLEKS):\n'
          '   a. WAJIB Menggunakan Rasio PORTRAIT (Vertikal 4:5 atau 9:16).\n'
          '   b. WAJIB Sangat KOMPLEKS, PADAT, DAN MENDALAM isi teksnya (narasi minimal 150-250 kata, analisis isu mendalam, poin riset 2026 komprehensif lengkap dengan kredit sumber berita).\n'
          '   c. DILARANG KERAS menampilkan badge/indikator nomor slide seperti 1/1, 1/10, dst di mana pun di dalam kanvas.'
      : '';

  return 'ATURAN KETAT STRUKTUR SLIDE (SLIDE/SEGMEN TERPISAH SEPENUHNYA):\n'
      '1. PEMISAHAN SLIDE (1/1): Setiap slide WAJIB dibuat sebagai 1 objek terpisah secara berurutan '
      'dalam array "slidesContent" (atau "segmentsContent"/"scenes"). '
      'DILARANG KERAS menggabungkan beberapa slide sekaligus atau hanya membuat 1 slide ringkasan.\n'
      '$badgeRuleText\n'
      '3. SLIDE PERTAMA (HOOK MEMANCING RASA INGIN TAHU): Slide 1 WAJIB berupa Hook utama yang sangat memancing penasaran, '
      'mengejutkan, dan memiliki stopping power tinggi. TIDAK ADA badge nomor di slide ini.\n'
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

  return 'RISET DATA REAL & AKTUAL (UPDATE 2026):\n'
      '- GAYA BAHASA: Gunakan bahasa SUPER NON-FORMAL, SANTAI, AKRAB, DAN ENAK DIBACA oleh audiens.\n'
      '- Anda WAJIB melakukan riset data/berita/statistik terbaru hingga tahun 2026 dari sumber terpercaya '
      '(seperti Kompas, Detik, Tempo, BPS, WHO, Reuters, Bloomberg, Forbes, dll) yang sangat relevan dengan topik "$topic".\n'
      '- Setiap data/fakta WAJIB menyertakan KREDIT SUMBER & TAHUN di dalam teks (contoh: "Sumber: Kompas 2026", "Data: BPS 2025/2026"). '
      'Jika ada materi/sub-poin yang tidak relevan atau outdated, WAJIB diganti dengan data paling aktual 2026.\n'
      '- KELENGKAPAN KRITIS: Tuliskan SEMUA $slideCount slide PENUH secara utuh. '
      'Field "description" berukuran $wordCount. '
      'DILARANG KERAS menggunakan singkatan, "...", atau placeholder. Target output 4000-8000+ karakter total.';
}
