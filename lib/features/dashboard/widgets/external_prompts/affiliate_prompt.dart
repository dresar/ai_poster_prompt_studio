import 'prompt_helpers.dart';

String buildAffiliatePrompt(Map<String, dynamic> formState) {
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

  final hookLine = hook.isNotEmpty ? hook : '(Buat hook masalah/solusi paling tajam AIDA/PAS)';
  final ctaLine = cta.isNotEmpty ? cta : '(Rekomendasikan CTA link di bio + promo diskon + ajakan follow)';

  return '''
Anda adalah AI Expert Affiliate Copywriter & High-Conversion Ad Designer berpengalaman.

INPUT USER:
- Jenis: IKLAN AFFILIATE / KONTEN PROMOSI PRODUK
- Produk/Layanan: $topic
- Manfaat/Solusi: $desc
- Detail Promo/Harga: $extra
- Hook/Masalah: $hookLine
- CTA/Link Bio: $ctaLine
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
  "systemInit": { "mission": "Misi affiliate: alur AIDA/PAS, problem-solution tajam, dorongan klik link di bio 2026" },
  "contentPayload": {
    "topic": "$topic",
    "targetAudience": "Profil calon pembeli: masalah nyata, keinginan belanja, pertimbangan harga",
    "painPoint": "Masalah utama audiens yang diselesaikan produk ini",
    "solutionAngle": "Sudut pandang solusi yang paling meyakinkan",
    "emotionalTrigger": "FOMO diskon / kemudahan hidup / penghematan / hasil instan 2026"
  },
  "designSystem": {
    "gridStructure": "Layout carousel promosi: hook > problem > sebelum-sesudah/fitur > penawaran > CTA",
    "whitespaceRatio": "Negatif space untuk menonjolkan foto produk dan teks harga promo",
    "colorPalette": "Palet konversi + warna aksen tombol promo (merah/oranye/kuning kontras)",
    "typographyHierarchy": "Headline masalah > poin benefit > harga diskon besar > CTA link bio",
    "slideNumberBadgeStyle": "Badge nomor slide kontras di pojok atas"
  },
  "visualBlueprint": {
    "coreVisualStyle": "Gaya visual yang menunjukkan produk secara nyata dan menarik",
    "compositionRules": "Fokus pada produk + testimoni/hasil + badge di pojok",
    "productShowcaseStyle": "3D render / foto lifestyle / sebelum-sesudah / pemakaian nyata",
    "promoBadgeStyle": "Badge diskon, garansi, cashback, terbatas"
  },
  "renderingBlueprint": {
    "renderStyle": "Clean commercial product photo / modern ad visual",
    "qualityParameters": "Detail tekstur produk tajam, pencahayaan komersial studio",
    "negativePrompt": "Terlihat jualan murahan, klaim palsu, foto produk buram"
  },
  "brandingEngine": {
    "logoPlacement": "${useManualLogo ? 'Buat badge lingkaran estetik di pojok frame dengan tulisan LOGO di tengah. Slot ini khusus tempat tempel logo di Canva.' : 'NO_LOGO'}",
    "watermarkFooter": "${watermark.isNotEmpty ? watermark : 'NO_WATERMARK'}"
  },
  "slidesContent": [
    {
      "slideNumber": 1,
      "headline": "Pertanyaan masalah audiens yang memicu rasa penasaran 'Pernah ngalamin ini?' (Hook Slide 1)",
      "description": "Ringkasan manfaat utama (40–70 kata / 250–500 karakter total). GAMBAR = POIN INTI & PRODUK 70% VISUAL, CAPTION = PENJELASAN PERSUASIF LENGKAP.",
      "subject": "Visual produk/ekspresi orang yang mewakili masalah",
      "sceneDescription": "Detail visual slide promosi + badge di pojok",
      "visualEmphasis": "Penekanan pada masalah atau hasil transformasi",
      "communicationGoal": "Audiens merasa 'Ini gue banget!'",
      "keyPoints": ["Poin masalah 1", "Poin solusi 2026"],
      "supportingFacts": ["Data riset kepuasan konsumen 2026 + kredit sumber"],
      "calloutSuggestions": ["Teks promo", "Link di bio", "Ajakan follow akun sosmed"],
      "storytellingSequence": "Alur PAS/AIDA: Slide 1 (Hook Masalah) > Problem > Solusi > Penawaran > Slide Terakhir (CTA Bio & Follow)"
    }
  ],
  "output": {
    "viralScore": 94,
    "analysisShortcomings": "Risiko keraguan pembeli (harga/kualitas) + strategi garansi/social proof",
    "hooks": ["Hook Problem 'Pernah ngalamin...'", "Hook Rahasia 'Gara-gara pakai ini...'", "Hook Diskoper 'Promo terbatas...'"],
    "logoExplanation": "Strategi penempatan promo dan identitas affiliate",
    "socialMediaCaption": "Caption persuasi AIDA + kode promo + ajakan klik link bio + ajakan follow + TEPAT 3 hashtag affiliate 2026"
  }
}''';
}
