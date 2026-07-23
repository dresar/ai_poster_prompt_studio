import 'prompt_helpers.dart';

String buildEdukasiPrompt(Map<String, dynamic> formState) {
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
  final mood = formState['mood'] ?? 'auto';
  final textRule = formState['textRule'] ?? 'auto';

  final ss = styleBlock(style, charFocus);
  final bs = brandingBlock(useManualLogo, watermark);
  final outs = outputRulesBlock();
  final sr = slideStructureRules(slideCount);
  final cs = completionBlock(topic, slideCount);

  final hookLine = hook.isNotEmpty ? hook : '(Buat hook edukatif berbasis riset 2026)';
  final ctaLine = cta.isNotEmpty ? cta : '(Rekomendasikan CTA terbaik + ajakan follow sosmed)';

  return '''
Anda adalah AI Expert Education Content Designer & Infographic Specialist untuk konten EDUKASI viral berbasis data riset 2026 terpercaya.

INPUT USER:
- Jenis: INFOGRAFIS / CAROUSEL EDUKASI
- Topik: $topic
- Deskripsi Materi: $desc
- Detail Tambahan: $extra
- Hook Edukatif: $hookLine
- CTA: $ctaLine
- Jumlah Slide: $slideCount | Rasio: $ratio | Palet: $palette | Mood: $mood | Teks: $textRule

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
  "systemInit": { "mission": "Misi edukatif: pendekatan pedagogis, target literasi, strategi penyampaian mudah dicerna berbasis data aktual 2026" },
  "contentPayload": {
    "topic": "$topic",
    "educationLevel": "Level pengetahuan target + profil audiens spesifik",
    "learningObjective": "Tujuan pembelajaran konkret setelah membaca semua slide",
    "emotionalTrigger": "Pemicu: rasa ingin tahu, kekhawatiran, kebanggaan, empati",
    "knowledgeGap": "Kesenjangan pengetahuan yang dijembatani konten ini"
  },
  "designSystem": {
    "gridStructure": "Layout infografis yang mendukung keterbacaan dan hierarki informasi",
    "whitespaceRatio": "Rasio ruang kosong agar tidak overwhelming",
    "colorPalette": "Palet edukasi profesional + hex + makna psikologis tiap warna",
    "typographyHierarchy": "Hierarki: angka/stat besar, headline, subheading, body, caption sumber",
    "slideNumberBadgeStyle": "Badge desain nomor slide kontras di pojok atas"
  },
  "visualBlueprint": {
    "coreVisualStyle": "Gaya yang mendukung penyampaian informasi edukatif efektif",
    "compositionRules": "Aturan komposisi memandu mata + posisi badge nomor slide di pojok",
    "dataVisualizationStyle": "Tipe visualisasi data: chart/diagram/timeline/comparison table",
    "illustrationIconography": "Ikon/ilustrasi yang merepresentasikan konsep secara universal"
  },
  "renderingBlueprint": {
    "renderStyle": "Modern flat/semi-3D/minimalist clean",
    "qualityParameters": "Keterbacaan optimal di berbagai ukuran layar",
    "negativePrompt": "Elemen yang membuat konten terkesan tidak terpercaya"
  },
  "brandingEngine": {
    "logoPlacement": "${useManualLogo ? 'Buat badge lingkaran estetik di pojok frame dengan tulisan LOGO di tengah. Slot ini khusus tempat tempel logo di Canva.' : 'NO_LOGO'}",
    "watermarkFooter": "${watermark.isNotEmpty ? watermark : 'NO_WATERMARK'}"
  },
  "slidesContent": [
    {
      "slideNumber": 1,
      "headline": "Judul memikat & punchy (30–60 karakter)",
      "description": "Ringkasan poin utama (40–70 kata / 250–500 karakter total). GAMBAR = POIN INTI, CAPTION = PENJELASAN LENGKAP & MENDALAM.",
      "subject": "Ilustrasi visual utama yang sangat mendominasi artwork (70% area visual)",
      "sceneDescription": "Deskripsi latar dan detail artwork visual",
      "visualEmphasis": "Data atau ilustrasi kunci yang ditonjolkan",
      "communicationGoal": "Poin inti yang harus ditangkap pembaca saat swipe cepat di HP",
      "educationalObjective": "Tujuan pembelajaran spesifik slide ini",
      "keyPoints": ["Poin 1 singkat (20–50 karakter)", "Poin 2 singkat (20–50 karakter)", "Poin 3 singkat (20–50 karakter)"],
      "supportingFacts": ["Fakta/statistik ringkas (sumber: Kompas 2026)"],
      "calloutSuggestions": ["Pull-quote atau highlight paling impactful"],
      "storytellingSequence": "Alur: Slide 1 (Hook) > Konteks > Data 2026 > Solusi > Slide Terakhir (Follow Sosmed & CTA)"
    }
  ],
  "output": {
    "viralScore": 90,
    "analysisShortcomings": "Analisis risiko miskonsepsi + cara mitigasinya",
    "hooks": ["Hook statistik mengejutkan 2026", "Hook pertanyaan retoris", "Hook mitos vs fakta"],
    "logoExplanation": "Strategi penempatan identitas dan sumber data",
    "socialMediaCaption": "Caption: fakta mengejutkan + ajakan swipe + ajakan follow akun sosmed + TEPAT 3 hashtag edukasi 2026"
  }
}''';
}
