import 'prompt_helpers.dart';

String buildPosterPrompt(Map<String, dynamic> formState) {
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
  final layout = formState['layout'] ?? 'auto';
  final mood = formState['mood'] ?? 'auto';
  final textRule = formState['textRule'] ?? 'auto';

  final ss = styleBlock(style, charFocus);
  final bs = brandingBlock(useManualLogo, watermark);
  final outs = outputRulesBlock();
  final sr = slideStructureRules(slideCount);
  final cs = completionBlock(topic, slideCount);

  final hookLine = hook.isNotEmpty ? hook : '(Buat yang paling efektif berdasarkan riset 2026)';
  final ctaLine = cta.isNotEmpty ? cta : '(Rekomendasikan yang terbaik + ajakan follow)';

  return '''
Anda adalah AI Expert Visual Content Strategist & Copywriter profesional khusus POSTER dan CAROUSEL viral media sosial.

INPUT USER:
- Jenis: POSTER / CAROUSEL MEDIA SOSIAL
- Topik: $topic
- Deskripsi: $desc
- Detail Tambahan: $extra
- Hook: $hookLine
- CTA: $ctaLine
- Jumlah Slide: $slideCount | Rasio: $ratio | Layout: $layout | Palet: $palette | Mood: $mood | Teks: $textRule

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
  "systemInit": { "mission": "Misi lengkap: tujuan komunikasi, strategi viral, dan emotional target audiens" },
  "contentPayload": {
    "topic": "$topic",
    "targetAudience": "Profil audiens spesifik: usia, profesi, minat, perilaku digital",
    "emotionalTrigger": "FOMO / inspirasi / kebanggaan / curiosity — jelaskan mengapa dipilih",
    "contentPillar": "Pilar konten: Edukasi/Entertainment/Inspirasi/Promosi",
    "viralMechanism": "Mekanisme viral: shareability, relatable, atau informational gap"
  },
  "designSystem": {
    "gridStructure": "Deskripsi detail struktur grid dan komposisi layout",
    "whitespaceRatio": "Rasio negative space untuk kesan premium",
    "colorPalette": "Palet warna + kode hex + filosofi psikologis",
    "typographyHierarchy": "Skala tipografi: heading/subheading/body + font yang disarankan",
    "slideNumberBadgeStyle": "ATURAN KETAT BADGE NOMOR: SLIDE 1 (COVER/HOOK) HARAM MEMILIKI BADGE NOMOR 1/$slideCount! AREA ATAS SLIDE 1 WAJIB KOSONG BERSIH. BADGE NOMOR HANYA BOLEH DAN WAJIB MULAI DITAMPILKAN PADA SLIDE 2 DENGAN FORMAT '2/$slideCount', '3/$slideCount', DST."
  },
  "visualBlueprint": {
    "coreVisualStyle": "Gaya visual utama + alasan pemilihan",
    "compositionRules": "Aturan komposisi visual (SLIDE 1: DILARANG ADA BADGE NOMOR 1/$slideCount. SLIDE 2+: Posisi badge nomor slide di pojok atas)",
    "illustrationIconography": "Jenis ilustrasi/ikonografi yang digunakan konsisten",
    "lightingMood": "Mood pencahayaan"
  },
  "renderingBlueprint": {
    "renderStyle": "Gaya rendering: 3D studio/flat premium/cinematic",
    "qualityParameters": "Resolusi, anti-aliasing, color depth",
    "negativePrompt": "watermark, blur, 1/$slideCount on slide 1, slide 1 number badge, 1/6 cover badge, 1/5 cover badge, teks berantakan, kualitas buruk, anatomi aneh"
  },
  "brandingEngine": {
    "logoPlacement": "${useManualLogo ? 'Buat badge lingkaran estetik di pojok frame dengan tulisan LOGO di tengah. Slot ini khusus tempat tempel logo di Canva.' : 'NO_LOGO'}",
    "watermarkFooter": "${watermark.isNotEmpty ? watermark : 'NO_WATERMARK'}"
  },
  "slidesContent": [
    {
      "slideNumber": 1,
      "headline": "Headline kuat dan memancing rasa ingin tahu (Hook Slide 1)",
      "description": "Narasi poin utama poster (40–80 kata / 350–700 karakter total). GAMBAR = POIN INTI & VISUAL ARTWORK DOMINAN, CAPTION = PENJELASAN LENGKAP.",
      "subject": "Deskripsi subjek/karakter visual utama",
      "sceneDescription": "Deskripsi latar, suasana, aksi, dan detail visual memikat (ATURAN KETAT SLIDE 1 COVER: DILARANG KERAS MENAMPILKAN BADGE NOMOR SLIDE 1/$slideCount DI POJOK ATAS, AREA ATAS SLIDE 1 WAJIB KOSONG BERSIH TANPA NOMOR SLIDE)",
      "visualEmphasis": "Focal point dan cara penekanan visual",
      "communicationGoal": "Tujuan komunikasi spesifik slide ini",
      "educationalObjective": "Nilai edukasi atau insight yang disampaikan",
      "keyPoints": ["Poin A dari riset 2026", "Poin B dari riset 2026"],
      "supportingFacts": ["Fakta/statistik nyata + nama sumber + tahun 2026"],
      "calloutSuggestions": ["Teks callout/highlight yang paling menarik perhatian"],
      "referenceImageUrl": "URL CDN / gambar referensi asli dari riset internet opsional (misal https://... atau NO_REFERENCE_URL)",
      "storytellingSequence": "Posisi dalam alur: Slide 1 (Hook Memancing Penasaran - TANPA NOMOR SLIDE 1/$slideCount) s/d Slide Terakhir (Follow Sosmed & CTA)"
    }
  ],
  "output": {
    "viralScore": 92,
    "analysisShortcomings": "Analisis mendalam kelemahan konten dan strategi mitigasi",
    "hooks": ["Hook provokatif", "Hook emosional", "Hook informatif"],
    "logoExplanation": "Strategi branding dan identitas visual",
    "socialMediaCaption": "Caption lengkap + emoji relevan + ajakan follow sosmed + TEPAT 3 hashtag trending 2026"
  },
${imageGenerationRulesJson()}
}''';
}
