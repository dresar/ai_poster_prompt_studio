import 'prompt_helpers.dart';

String buildLogoPrompt(Map<String, dynamic> formState) {
  final topic = formState['topic'] ?? '';
  final desc = formState['description'] ?? '';
  final extra = formState['extraDetails'] ?? '';
  final hook = formState['hook'] ?? '';
  final cta = (formState['callToAction'] ?? '').toString();
  final watermark = (formState['watermark'] ?? '').toString().trim();
  final style = (formState['style'] ?? 'auto').toString();
  final charFocus = (formState['characterFocus'] ?? 'auto').toString();
  final useManualLogo = formState['useManualLogo'] == true;
  final slideCount = formState['slideCount'] ?? 3;
  final ratio = formState['aspectRatio'] ?? '1:1';
  final palette = formState['colorPalette'] ?? 'auto';

  final ss = styleBlock(style, charFocus);
  final bs = brandingBlock(useManualLogo, watermark);
  final outs = outputRulesBlock();
  final sr = slideStructureRules(slideCount);
  final cs = completionBlock(topic, slideCount);

  final hookLine = hook.isNotEmpty ? hook : '(Buat nama/slogan brand yang memikat)';
  final ctaLine = cta.isNotEmpty ? cta : '(Rekomendasikan strategi brand identity + ajakan follow)';

  return '''
Anda adalah AI Expert Brand Identity Designer & Master Logo Craftsman profesional 2026.

INPUT USER:
- Jenis: DESAIN LOGO / BRAND IDENTITY
- Nama Brand/Perusahaan: $topic
- Industri/Visi: $desc
- Detail Tambahan: $extra
- Slogan/Tagline: $hookLine
- CTA: $ctaLine
- Jumlah Konsep: $slideCount | Rasio: $ratio | Palet: $palette

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
  "systemInit": { "mission": "Misi branding: filosofi logo, daya ingat tinggi, skalabilitas di berbagai media, identitas visual 2026" },
  "contentPayload": {
    "topic": "$topic",
    "targetAudience": "Pasar sasaran: demografi, nilai-nilai yang dicari dalam sebuah brand",
    "brandArchetype": "Arketipe brand: Hero/Outlaw/Magician/Explorer/Sage/Innocent/Creator dll",
    "coreBrandValues": "3-5 nilai utama brand yang direpresentasikan oleh logo",
    "industryPositioning": "Posisi di industri dibanding kompetitor 2026"
  },
  "designSystem": {
    "gridStructure": "Golden ratio / konstruksi geometris logo",
    "whitespaceRatio": "Margin dan padding aman logo (clear space)",
    "colorPalette": "Warna utama, sekunder, aksen + kode hex + filosofi psikologis",
    "typographyHierarchy": "Custom logotype / pasangan font pendukung",
    "slideNumberBadgeStyle": "Badge nomor konsep di pojok atas"
  },
  "visualBlueprint": {
    "coreVisualStyle": "Minimalist/Monogram/Mascot/Abstract/Emblem/Wordmark",
    "compositionRules": "Keseimbangan bentuk geometri + posisi badge nomor konsep di pojok",
    "symbolicMeaning": "Makna tersembunyi di balik elemen visual logo",
    "versatilityRules": "Uji keterbacaan ukuran 16x16px (favicon) s/d papan baliho"
  },
  "renderingBlueprint": {
    "renderStyle": "Vector art clean / 3D mockup / embossed on texture",
    "qualityParameters": "Format SVG/EPS vector ready, 300 DPI, CMYK & RGB profiles",
    "negativePrompt": "Detail terlalu rumit tidak bisa diperkecil, gradien murah, font klise"
  },
  "brandingEngine": {
    "logoPlacement": "Tampilkan logo terpusat (centered) di kanvas",
    "watermarkFooter": "${watermark.isNotEmpty ? watermark : 'NO_WATERMARK'}"
  },
  "slidesContent": [
    {
      "slideNumber": 1,
      "headline": "Nama Brand + Konsep Logo Utama (Hook Slide 1)",
      "description": "Ringkasan filosofi logo (40–70 kata / 250–500 karakter total). Visual logo 70% dominan.",
      "subject": "Deskripsi bentuk simbol/logomark dan logotype secara presisi",
      "sceneDescription": "Latar belakang mockup visual logo + badge di pojok",
      "visualEmphasis": "Elemen paling ikonis dari desain logo",
      "communicationGoal": "Kesan pertama yang dirasakan calon konsumen",
      "keyPoints": ["Bentuk geometri utama", "Makna simbolik"],
      "supportingFacts": ["Data tren brand identity 2026 + kredit sumber"],
      "calloutSuggestions": ["Slogan brand", "Panduan warna hex", "Ajakan follow sosmed"],
      "storytellingSequence": "Posisi: Konsep 1 (Hook Visual) s/d Konsep Terakhir (Brand Guide & Follow)"
    }
  ],
  "output": {
    "viralScore": 93,
    "analysisShortcomings": "Evaluasi potensi kemiripan dengan logo lain + strategi pembeda utuh",
    "hooks": ["Konsep A - Minimalist Modern", "Konsep B - Symbolic Abstract", "Konsep C - Heritage Emblem"],
    "logoExplanation": "Buku panduan brand identity (brand guidelines ringkas)",
    "socialMediaCaption": "Caption peluncuran logo baru + filosofi brand + ajakan follow + TEPAT 3 hashtag branding 2026"
  }
}''';
}
