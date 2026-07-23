import 'prompt_helpers.dart';

String buildBalihoPrompt(Map<String, dynamic> formState) {
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
  final ratio = formState['aspectRatio'] ?? 'auto';
  final layout = formState['layout'] ?? 'auto';
  final palette = formState['colorPalette'] ?? 'auto';

  final ss = styleBlock(style, charFocus);
  final bs = brandingBlock(useManualLogo, watermark);
  final outs = outputRulesBlock();
  final sr = slideStructureRules(slideCount);
  final cs = completionBlock(topic, slideCount);

  final hookLine = hook.isNotEmpty ? hook : '(Buat pesan baliho maks 7 kata memancing penasaran)';
  final ctaLine = cta.isNotEmpty ? cta : '(Rekomendasikan CTA outdoor + info sosmed)';

  return '''
Anda adalah AI Expert Outdoor Advertising Designer & Large Format Print Specialist khusus BALIHO dan media luar ruang.
PRINSIP WAJIB: 3-second rule — pesan terbaca dan dimengerti dalam 3 detik dari jarak 50-100m.

INPUT USER:
- Jenis: BALIHO / MEDIA LUAR RUANG
- Brand/Acara/Pesan: $topic
- Deskripsi: $desc
- Detail Tambahan: $extra
- Pesan Utama (maks 7 kata): $hookLine
- CTA: $ctaLine
- Jumlah Slide: $slideCount | Rasio: $ratio | Layout: $layout | Palet: $palette

$outs

============================================================
ATURAN SISTEM KONTEN (WAJIB DIPATUHI SEPENUHNYA)
============================================================
$ss

$bs

$sr

$cs
OUTDOOR RULES: Kontras 7:1+, HANYA font Bold/Black, max 7 kata headline, 40%+ white space.

============================================================
FORMAT JSON OUTPUT (semua field wajib diisi, SEMUA slide wajib ditulis PENUH)
============================================================
{
  "systemInit": { "mission": "Prinsip 3-second rule, keterbacaan 50-100m, satu pesan dominan dalam max 7 kata" },
  "contentPayload": {
    "topic": "$topic",
    "targetAudience": "Profil pengendara/pejalan kaki: lokasi, demografi, kecepatan exposure",
    "corePrimaryMessage": "SATU pesan utama max 7 kata yang tersampaikan dalam 3 detik",
    "emotionalTrigger": "Lokal pride / urgency / brand familiarity / curiosity",
    "locationContext": "Konteks lokasi pemasangan yang mempengaruhi desain"
  },
  "designSystem": {
    "gridStructure": "Safe zone 10%, headline dominan 1/6 tinggi baliho, clear space semua elemen",
    "whitespaceRatio": "MINIMAL 40% untuk keterbacaan jarak jauh",
    "colorPalette": "High-contrast outdoor + hex + pertimbangan cuaca/cahaya/malam hari",
    "typographyHierarchy": "Font Bold/Black minimum, headline min 30cm di media nyata untuk jarak 50m",
    "slideNumberBadgeStyle": "Badge nomor variasi kontras di pojok atas"
  },
  "visualBlueprint": {
    "coreVisualStyle": "Stopping power maksimal, SATU focal point sangat dominan",
    "compositionRules": "Visual 60% + Teks 40%, hierarki tunggal, NO CLUTTER + badge nomor variasi di pojok",
    "outdoorReadabilityRules": "Kontras 7:1+, Bold/Black only, no thin fonts, no small text",
    "heroVisual": "Visual hero terbaca dalam 2-3 detik dari kecepatan 60 km/jam"
  },
  "renderingBlueprint": {
    "renderStyle": "300 DPI minimum, CMYK color mode untuk cetak akurat",
    "qualityParameters": "Bleed 5mm, safe zone 10mm, color profile ISO Coated v2",
    "negativePrompt": "Font tipis, terlalu banyak teks (>10 kata), warna pastel, detail kecil tidak terbaca"
  },
  "brandingEngine": {
    "logoPlacement": "${useManualLogo ? 'Buat badge lingkaran estetik di pojok frame dengan tulisan LOGO di tengah. Slot ini khusus tempat tempel logo di Canva.' : 'NO_LOGO'}",
    "watermarkFooter": "${watermark.isNotEmpty ? watermark : 'NO_WATERMARK'}"
  },
  "slidesContent": [
    {
      "slideNumber": 1,
      "headline": "Teks baliho MAX 7 KATA, font Bold, ukuran sangat besar (Hook Slide 1)",
      "description": "KONSEP BALIHO MENDALAM minimal 100 kata: filosofi desain, hierarki visual, pilihan tipografi/warna, riset outdoor 2026 dengan kredit sumber, rekomendasi material cetak terbaik.",
      "subject": "Subjek visual: model/produk/ilustrasi + deskripsi pose dan ukuran relatif",
      "sceneDescription": "Latar visual dan suasana keseluruhan baliho + badge di pojok",
      "visualEmphasis": "Focal point utama terlihat pertama dari 100m",
      "communicationGoal": "Pesan tertanam di benak dalam 3 detik",
      "keyPoints": ["Pesan utama yang tersampaikan", "Info kontak/sosmed"],
      "supportingFacts": ["Data efektivitas outdoor advertising 2026 + kredit sumber"],
      "calloutSuggestions": ["CTA singkat dan actionable", "Follow akun sosmed / website"],
      "storytellingSequence": "Struktur: Slide 1 (Hook 3 Detik) s/d Variasi Terakhir (Brand & Follow)"
    }
  ],
  "output": {
    "viralScore": 85,
    "analysisShortcomings": "Tantangan outdoor: cuaca, kompetisi lingkungan, vandalisme + mitigasinya",
    "hooks": ["Headline A - paling direct", "Headline B - paling emosional", "Headline C - paling memorable"],
    "logoExplanation": "Rekomendasi ukuran dan posisi logo untuk brand recall optimal",
    "socialMediaCaption": "Caption posting foto baliho di sosmed + tag akun + TEPAT 3 hashtag outdoor 2026"
  }
}''';
}
