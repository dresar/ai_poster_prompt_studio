import 'prompt_helpers.dart';

String buildDigitalProductPrompt(Map<String, dynamic> formState) {
  final topic = formState['topic'] ?? '';
  final desc = formState['description'] ?? '';
  final extra = formState['extraDetails'] ?? '';
  final hook = formState['hook'] ?? '';
  final cta = (formState['callToAction'] ?? '').toString();
  final watermark = (formState['watermark'] ?? '').toString().trim();
  final style = (formState['style'] ?? 'auto').toString();
  final charFocus = (formState['characterFocus'] ?? 'auto').toString();
  final useManualLogo = formState['useManualLogo'] == true;
  final slideCount = formState['slideCount'] ?? 5;
  final ratio = formState['aspectRatio'] ?? 'auto';
  final palette = formState['colorPalette'] ?? 'auto';

  final ss = styleBlock(style, charFocus);
  final bs = brandingBlock(useManualLogo, watermark);
  final outs = outputRulesBlock();
  final sr = slideStructureRules(slideCount);
  final cs = completionBlock(topic, slideCount);

  final hookLine = hook.isNotEmpty ? hook : '(Buat headline 3D mockup produk digital paling menarik 2026)';
  final ctaLine = cta.isNotEmpty ? cta : '(Rekomendasikan CTA download/akses instan + ajakan follow)';

  return '''
Anda adalah AI Expert Digital Product Showcase & 3D Mockup Designer profesional 2026.

INPUT USER:
- Jenis: PRODUK DIGITAL / E-BOOK / KURSUS / TEMPLATE / SOFTWARE
- Nama Produk: $topic
- Fitur & Isi: $desc
- Bonus/Detail: $extra
- Tagline: $hookLine
- CTA: $ctaLine
- Jumlah Slide: $slideCount | Rasio: $ratio | Palet: $palette

$outs

============================================================
ATURAN SISTEM KONTEN (WAJIB DIPATUHI SEPENUHNYA)
============================================================
$ss

$bs

$sr

$cs

============================================================
FORMAT JSON OUTPUT (semua field wajib diisi, SEMUA slide wajib ditulis PENUH)
============================================================
{
  "systemInit": { "mission": "Misi produk digital: visualisasi 3D bernilai tinggi, persepsi harga mahal, pameran isi/template 2026" },
  "contentPayload": {
    "topic": "$topic",
    "targetAudience": "Profil pembeli digital: kreator, profesional, bisnis, pelajar 2026",
    "productType": "E-Book / Course / Template UI-UX / Source Code / Presets / SaaS",
    "valueProposition": "Transformasi utama yang didapatkan pengguna setelah menggunakan produk ini",
    "perceivedValue": "Mengapa produk ini terlihat bernilai jutaan rupiah"
  },
  "designSystem": {
    "gridStructure": "Layout pameran produk digital 3D + mockup floating",
    "whitespaceRatio": "Negatif space luas untuk kesan eksklusif dan bersih",
    "colorPalette": "Palet futuristik/modern + hex + efek neon/glassmorphism",
    "typographyHierarchy": "Title impact > feature list > price tag > CTA button",
    "slideNumberBadgeStyle": "Badge nomor slide di pojok atas"
  },
  "visualBlueprint": {
    "coreVisualStyle": "3D isometric floating device / glassmorphism mockup / studio dark mode",
    "compositionRules": "Mockup 3D pusat perhatian + badge di pojok",
    "mockupStyle": "Laptop, tablet, smartphone, 3D book boxset, floating cards",
    "uiInterfacePreview": "Tampilan layar antarmuka produk digital yang realistis"
  },
  "renderingBlueprint": {
    "renderStyle": "Octane Render / Cinema4D 3D style / ultra high-end tech showcase",
    "qualityParameters": "Bayangan halus 3D, pantulan kaca realistis, 4K crispness",
    "negativePrompt": "Mockup 2D murah, tampilan layar tidak realistis, teks kecil buram"
  },
  "brandingEngine": {
    "logoPlacement": "${useManualLogo ? 'Buat badge lingkaran estetik di pojok frame dengan tulisan LOGO di tengah. Slot ini khusus tempat tempel logo di Canva.' : 'NO_LOGO'}",
    "watermarkFooter": "${watermark.isNotEmpty ? watermark : 'NO_WATERMARK'}"
  },
  "slidesContent": [
    {
      "slideNumber": 1,
      "headline": "Judul Produk Digital + Mockup 3D Memukau (Hook Slide 1)",
      "description": "Ringkasan nilai produk digital (40–70 kata / 250–500 karakter total). Visual 70% dominan, Teks 30% ringkas.",
      "subject": "Deskripsi susunan mockup 3D (laptop + tablet + phone + boxset)",
      "sceneDescription": "Latar belakang 3D studio dan pencahayaan futuristik + badge di pojok",
      "visualEmphasis": "Tampilan mockup 3D yang paling bernilai tinggi",
      "communicationGoal": "Audiens terpukau oleh tampilan visual 3D produk",
      "keyPoints": ["Fitur utama 1", "Modul/Isi 2026"],
      "supportingFacts": ["Data kebutuhan skill/tools digital 2026 + kredit sumber"],
      "calloutSuggestions": ["Beli sekali akses selamanya", "Download instan", "Ajakan follow sosmed"],
      "storytellingSequence": "Posisi: Slide 1 (Hook 3D Showcase) s/d Slide Terakhir (Penawaran & Follow)"
    }
  ],
  "output": {
    "viralScore": 95,
    "analysisShortcomings": "Risiko ragu mencoba produk digital + strategi jaminan uang kembali / lisensi",
    "hooks": ["Headline 3D Showcase", "Headline Hemat Waktu 10x", "Headline Template Siap Pakai"],
    "logoExplanation": "Strategi branding produk digital",
    "socialMediaCaption": "Caption peluncuran produk digital + daftar bonus + link akses + ajakan follow + TEPAT 3 hashtag digital product 2026"
  },
${imageGenerationRulesJson()}
}''';
}
