import 'prompt_helpers.dart';

String buildBannerPrompt(Map<String, dynamic> formState) {
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
  final palette = formState['colorPalette'] ?? 'auto';

  final ss = styleBlock(style, charFocus);
  final bs = brandingBlock(useManualLogo, watermark);
  final outs = outputRulesBlock();
  final sr = slideStructureRules(slideCount);
  final cs = completionBlock(topic, slideCount);

  final hookLine = hook.isNotEmpty ? hook : '(Buat tagline paling persuasif berbasis riset 2026)';
  final ctaLine = cta.isNotEmpty ? cta : '(Rekomendasikan teks CTA button + ajakan follow)';

  return '''
Anda adalah AI Expert Digital Marketing Designer & Conversion Rate Optimizer khusus BANNER DIGITAL berkinerja tinggi.

INPUT USER:
- Jenis: BANNER DIGITAL / IKLAN VISUAL
- Brand/Produk: $topic
- Deskripsi: $desc
- USP/Detail: $extra
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
  "systemInit": { "mission": "Misi banner: tujuan konversi, psikologi persuasi 2026, visual hierarchy mengarahkan mata ke CTA" },
  "contentPayload": {
    "topic": "$topic",
    "targetAudience": "Profil target iklan: demografi, psikografi, perilaku pembelian 2026, pain points",
    "conversionGoal": "Tujuan konversi spesifik: klik/pembelian/pendaftaran/awareness",
    "emotionalTrigger": "Psikologi persuasi: urgency, scarcity, social proof, authority",
    "competitorDifferentiator": "Keunikan kompetitif yang dikomunikasikan secara visual"
  },
  "designSystem": {
    "gridStructure": "Zona: visual utama 60%, headline zone, CTA zone dominan, logo zone",
    "whitespaceRatio": "White space yang mengarahkan fokus ke CTA",
    "colorPalette": "Brand colors + hex + psikologi untuk konversi",
    "typographyHierarchy": "Headline impact > subheadline benefit > CTA kontras tinggi > fine print",
    "slideNumberBadgeStyle": "Badge nomor variasi kontras di pojok atas"
  },
  "visualBlueprint": {
    "coreVisualStyle": "Gaya dengan stopping power sesuai brand positioning",
    "compositionRules": "F-pattern atau Z-pattern eye tracking + badge nomor variasi di pojok",
    "heroImageConcept": "Konsep gambar hero yang paling persuasif dan aspirasional",
    "ctaDesign": "CTA button: ukuran, warna kontras, teks, posisi optimal"
  },
  "renderingBlueprint": {
    "renderStyle": "Sesuai platform target (web/mobile/print/digital signage)",
    "qualityParameters": "File size optimal + tajam di retina display",
    "negativePrompt": "Elemen yang membuat banner terlihat spammy atau tidak terpercaya"
  },
  "brandingEngine": {
    "logoPlacement": "${useManualLogo ? 'Buat badge lingkaran estetik di pojok frame dengan tulisan LOGO di tengah. Slot ini khusus tempat tempel logo di Canva.' : 'NO_LOGO'}",
    "watermarkFooter": "${watermark.isNotEmpty ? watermark : 'NO_WATERMARK'}"
  },
  "slidesContent": [
    {
      "slideNumber": 1,
      "headline": "Headline dengan stopping power maksimal (Hook Slide 1)",
      "description": "Ringkasan promo/penawaran (40–70 kata / 250–500 karakter total). Visual 70% dominan, Teks 30% ringkas.",
      "subject": "Visual utama: produk/model/ilustrasi dengan detail pose, ekspresi, posisi",
      "sceneDescription": "Latar dan suasana visual banner + badge nomor variasi di pojok atas",
      "visualEmphasis": "Focal point dan strategi visual hierarchy",
      "communicationGoal": "Action yang diharapkan dari viewer",
      "keyPoints": ["Benefit utama 2026", "USP yang dikomunikasikan visual"],
      "supportingFacts": ["Data riset consumer behavior kategori produk 2026 + kredit sumber"],
      "calloutSuggestions": ["Teks CTA button optimal", "Tagline pendukung", "Ajakan follow akun sosmed"],
      "storytellingSequence": "Posisi: Variasi 1 (Hook) s/d Variasi Terakhir (Conversion & Follow)"
    }
  ],
  "output": {
    "viralScore": 88,
    "analysisShortcomings": "Analisis kelemahan banner dan rekomendasi optimasi A/B testing",
    "hooks": ["Variasi headline A", "Variasi headline B", "Variasi headline C"],
    "logoExplanation": "Rekomendasi penempatan logo/brand identity",
    "socialMediaCaption": "Ad copy siap: primary text + headline + ajakan follow sosmed + TEPAT 3 hashtag Ads 2026"
  }
}''';
}
