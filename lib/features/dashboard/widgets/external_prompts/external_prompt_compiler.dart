import 'poster_prompt.dart';
import 'edukasi_prompt.dart';
import 'banner_prompt.dart';
import 'baliho_prompt.dart';
import 'quotes_prompt.dart';
import 'logo_prompt.dart';
import 'affiliate_prompt.dart';
import 'digital_product_prompt.dart';
import 'video_prompt.dart';
import 'advanced_video_prompt.dart';
import 'berita_prompt.dart';
import 'karakter_prompt.dart';
import 'gaya_visual_prompt.dart';

class ExternalPromptParts {
  final String fullPrompt;
  final String part1;
  final String part2;
  final String part3;
  final String part4;

  const ExternalPromptParts({
    required this.fullPrompt,
    required this.part1,
    required this.part2,
    required this.part3,
    required this.part4,
  });
}

/// Central dispatcher function that routes prompt compilation
/// to the feature-specific prompt builders.
String compileExternalPrompt(Map<String, dynamic> formState) {
  final feature = (formState['feature'] ?? 'poster').toString();

  switch (feature) {
    case 'karakter':
      return buildKarakterPrompt(formState);
    case 'gaya_visual':
      return buildGayaVisualPrompt(formState);
    case 'berita':
      return buildBeritaPrompt(formState);
    case 'edukasi':
      return buildEdukasiPrompt(formState);
    case 'banner':
      return buildBannerPrompt(formState);
    case 'baliho':
      return buildBalihoPrompt(formState);
    case 'quotes':
      return buildQuotesPrompt(formState);
    case 'logo':
      return buildLogoPrompt(formState);
    case 'affiliate':
      return buildAffiliatePrompt(formState);
    case 'digital_product':
      return buildDigitalProductPrompt(formState);
    case 'video':
      return buildVideoPrompt(formState);
    case 'advanced_video':
      return buildAdvancedVideoPrompt(formState);
    case 'poster':
    default:
      return buildPosterPrompt(formState);
  }
}

/// Helper that splits compiled prompt into 4 clean parts for Android multi-part copying with super complete instructions.
ExternalPromptParts compileExternalPromptParts(Map<String, dynamic> formState) {
  final fullText = compileExternalPrompt(formState);
  final topic = (formState['topic'] ?? 'Konten Visual').toString();
  final feature = (formState['feature'] ?? 'poster').toString().toUpperCase();
  final slideCount = formState['slideCount'] ?? 5;

  final part1Header = '''
========================================
📋 PETUNJUK PROTOKOL 4-PART UNTUK AI (CHATGPT / CLAUDE / GEMINI)
========================================
⚠️ SANGAT WAJIB DIPATUHI OLEH AI (MODE CANVAS / TEKS SALIN):
Pengguna mengirimkan instruksi ini dalam 4 BAGIAN TERPISAH (Part 1, Part 2, Part 3, Part 4).
JANGAN BUAT FILE UNDUH (.json) TERLEBIH DAHULU SAAT MEMPROSES MULTI-PART!
Tampilkan balasan KODE JSON per bagian dalam format KODE CANVAS / CODE BLOCK (```json ... ```) yang SIAP DISALIN langsung di jendela chat.

Anda WAJIB memproses instruksi ini dan membalas dengan KODE JSON SECARA BERTAHAP per bagian:
1️⃣ Balasan Part 1 JSON: Buat objek JSON ("systemInit", "contentPayload", "brandingEngine") dalam kode block canvas siap salin.
2️⃣ Balasan Part 2 JSON: Buat objek JSON ("designSystem", "visualBlueprint", "renderingBlueprint") dalam kode block canvas siap salin.
3️⃣ Balasan Part 3 JSON: Buat objek JSON ("slidesContent" / "segmentsContent") LENGKAP Slide 1 s/d $slideCount (1 per 1 per slide, badge 1/$slideCount di pojok, riset 2026 + kredit sumber, Slide 1 Hook, Slide Terakhir Follow CTA) dalam kode block canvas siap salin.
4️⃣ Balasan Part 4 JSON: Buat objek JSON ("output") berisi viral score, hooks array, dan caption sosial media + TEPAT 3 HASHTAG TRENDING 2026. Nanti jika pengguna mengumpulkan seluruh instruksi atau meminta file akhir, barulah buatkan FILE UNDUH (.json).

👉 SAAT SAYA MENGIRIM PART 1 INI: Silakan baca informasi awal di bawah ini, lalu JAWAB DENGAN BALASAN KODE JSON PART 1 SAJA DALAM KODE BLOCK CANVAS TERLEBIH DAHULU dan beri tahu bahwa Anda siap menerima Part 2!

----------------------------------------
[BAGIAN 1 / 4: INISIALISASI STRATEGI & TARGET AUDIENS]
Jenis Konten: $feature | Topik Utama: "$topic" | Total Slide: $slideCount
----------------------------------------
''';

  final part2Header = '''
========================================
[BAGIAN 2 / 4: ATURAN DESAIN, GRID & VISUAL BLUEPRINT]
========================================
⚠️ PETUNJUK UNTUK AI:
Ini adalah LANJUTAN BAGIAN 2. Buatlah balasan KODE JSON PART 2 yang memuat field ("designSystem", "visualBlueprint", dan "renderingBlueprint") secara detail, profesional, dan tanpa singkatan.

----------------------------------------
''';

  final countInt = int.tryParse(slideCount.toString()) ?? 5;
  final isSingleSlide = countInt == 1;
  final isMultiSlide = countInt >= 4;

  final badgeInstructionText = isSingleSlide
      ? '- DILARANG BADGE NOMOR SLIDE (1 SLIDE): Karena ini poster tunggal (1 slide), DILARANG KERAS mencantumkan badge/indikator nomor slide ("1/1", "1/10", dst). Hapus total elemen ini.'
      : '- ATURAN BADGE NOMOR SLIDE CAROUSEL:\n'
          '  • SLIDE 1 (HOOK): DILARANG ADA BADGE NOMOR — Slide 1 murni tanpa nomor apapun ("1/$slideCount" dll).\n'
          '  • SLIDE 2 S/D $slideCount: WAJIB ADA BADGE NOMOR di pojok atas (contoh: "2/$slideCount", "3/$slideCount", ..., "$slideCount/$slideCount"). Desain badge kontras dan konsisten.';

  final part3Header = '''
========================================
[BAGIAN 3 / 4: DETAIL ALUR SLIDE (1 S/D $slideCount) & RISET DATA 2026]
========================================
⚠️ PETUNJUK UNTUK AI:
Ini adalah LANJUTAN BAGIAN 3. Buatlah balasan KODE JSON PART 3 ("slidesContent" / "segmentsContent") untuk SEMUA $slideCount SLIDE/SEGMEN TERPISAH 1 PER 1.
Aturan Keras Part 3:
- GAYA BAHASA SUPER NON-FORMAL & SANTAI: Gunakan gaya bahasa SUPER SANTAI, CASUAL, AKRAB, GAUL, DAN ENAK DIBACA. DILARANG KERAS menggunakan bahasa kaku/akademis/korporat.
${isSingleSlide ? '- POSTER TUNGGAL (1 SLIDE): WAJIB menggunakan rasio PORTRAIT (Vertikal 4:5 / 9:16) dan narasi teks WAJIB SANGAT KOMPLEKS, PADAT, DAN MENDALAM (150-250 kata + riset 2026).\n' : ''}${isMultiSlide ? '- CAROUSEL BANYAK SLIDE ($slideCount SLIDE): Karena slide cukup banyak ($slideCount slide), narasi teks per slide WAJIB SINGKAT, RINGKAS, TO THE POINT, DAN PUNCHY (sekitar 40-70 kata per slide). DILARANG KERAS membuat teks terlalu tebal/penuh di setiap slide agar audiens nyaman membaca.\n' : ''}$badgeInstructionText
- RISET DATA REAL 2026: Riset berita/data 2026 + sertakan kredit sumber terpercaya (contoh: "Sumber: Kompas 2026", "Data: BPS 2025/2026").
- SLIDE 1 HOOK: Slide 1 WAJIB berupa Hook memancing rasa ingin tahu tinggi.
- SLIDE TERAKHIR ($slideCount): Slide Terakhir WAJIB berupa Call-To-Action (CTA) & ajakan Follow media sosial.

----------------------------------------
''';

  final part4Header = '''
========================================
[BAGIAN 4 / 4: SKEMA VIRAL SCORE, HOOKS & CAPTION SOSMED 2026]
========================================
⚠️ PETUNJUK UNTUK AI:
Ini adalah BAGIAN TERAKHIR (Part 4). Buatlah balasan KODE JSON PART 4 ("output") memuat viral score, analisis kelemahan, array hooks, serta caption sosial media + TEPAT 3 HASHTAG TRENDING 2026.

----------------------------------------
''';

  final lines = fullText.split('\n');
  final List<String> p1Lines = [];
  final List<String> p2Lines = [];
  final List<String> p3Lines = [];
  final List<String> p4Lines = [];

  int section = 1;

  for (var line in lines) {
    if (line.contains('ATURAN SISTEM')) {
      section = 2;
    } else if (line.contains('FORMAT JSON OUTPUT') || line.contains('"slidesContent"') || line.contains('"segmentsContent"')) {
      section = 3;
    } else if (line.contains('"output":')) {
      section = 4;
    }

    if (section == 1) {
      p1Lines.add(line);
    } else if (section == 2) {
      p2Lines.add(line);
    } else if (section == 3) {
      p3Lines.add(line);
    } else {
      p4Lines.add(line);
    }
  }

  if (p2Lines.isEmpty || p3Lines.isEmpty || p4Lines.isEmpty) {
    final chunkSize = (fullText.length / 4).ceil();
    final p1 = fullText.isNotEmpty ? fullText.substring(0, fullText.length < chunkSize ? fullText.length : chunkSize) : '';
    final p2 = fullText.length > chunkSize ? fullText.substring(chunkSize, fullText.length < chunkSize * 2 ? fullText.length : chunkSize * 2) : '';
    final p3 = fullText.length > chunkSize * 2 ? fullText.substring(chunkSize * 2, fullText.length < chunkSize * 3 ? fullText.length : chunkSize * 3) : '';
    final p4 = fullText.length > chunkSize * 3 ? fullText.substring(chunkSize * 3) : '';

    return ExternalPromptParts(
      fullPrompt: fullText,
      part1: '$part1Header$p1',
      part2: '$part2Header$p2',
      part3: '$part3Header$p3',
      part4: '$part4Header$p4',
    );
  }

  return ExternalPromptParts(
    fullPrompt: fullText,
    part1: '$part1Header${p1Lines.join('\n')}',
    part2: '$part2Header${p2Lines.join('\n')}',
    part3: '$part3Header${p3Lines.join('\n')}',
    part4: '$part4Header${p4Lines.join('\n')}',
  );
}
