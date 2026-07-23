import 'prompt_helpers.dart';

String buildQuotesPrompt(Map<String, dynamic> formState) {
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
  final mood = formState['mood'] ?? 'auto';

  final ss = styleBlock(style, charFocus);
  final bs = brandingBlock(useManualLogo, watermark);
  final outs = outputRulesBlock();
  final sr = slideStructureRules(slideCount);
  final cs = completionBlock(topic, slideCount);

  final hookLine = hook.isNotEmpty ? hook : '(Buat kalimat mutiara mendalam & puitis)';
  final ctaLine = cta.isNotEmpty ? cta : '(Rekomendasikan CTA reflektif + ajakan follow)';

  return '''
Anda adalah AI Expert Visual Storyteller & Typography Artist khusus QUOTES, WISDOM CARDS, dan KATA MUTIARA viral.

INPUT USER:
- Jenis: QUOTES / KATA MUTIARA / WISDOM CARD
- Tema/Kutipan: $topic
- Konteks/Makna: $desc
- Detail Tambahan: $extra
- Kutipan Utama: $hookLine
- CTA: $ctaLine
- Jumlah Slide: $slideCount | Rasio: $ratio | Palet: $palette | Mood: $mood

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
  "systemInit": { "mission": "Misi quotes: resonance emosional mendalam, shareability tinggi, nilai estetika tipografi premium 2026" },
  "contentPayload": {
    "topic": "$topic",
    "targetAudience": "Profil audiens pencari inspirasi: kebutuhan emosional, nilai hidup",
    "emotionalResonance": "Emosi utama yang disentuh: ketenangan/keberanian/harapan/renungan",
    "quoteAuthorSource": "Tokoh/sumber kutipan asli atau kreasi original berkualitas",
    "viralShareability": "Alasan mengapa quotes ini mendorong orang membagikan di Story/Feed"
  },
  "designSystem": {
    "gridStructure": "Tata letak quotes: simetris/asimetris, centering, margin pemisah",
    "whitespaceRatio": "Negatif space luas untuk menciptakan kedalaman dan ketenangan",
    "colorPalette": "Palet emosional + kode hex + mood psikologis",
    "typographyHierarchy": "Serif/sans puitis, quotation marks estetik, hierarki nama pengarang",
    "slideNumberBadgeStyle": "Badge nomor variasi estetik di pojok atas"
  },
  "visualBlueprint": {
    "coreVisualStyle": "Gaya visual pendukung suasana puitis/inspiratif",
    "compositionRules": "Keseimbangan visual + posisi badge nomor variasi di pojok",
    "backgroundTexture": "Tekstur/gambar latar yang melengkapi emosi kutipan",
    "decorativeElements": "Ornamen tipografi: quotation marks, garis halus, simbol estetik"
  },
  "renderingBlueprint": {
    "renderStyle": "Cinematic atmosphere / moody lighting / minimalist elegance",
    "qualityParameters": "Kejelasan teks, kontras dengan latar belakang",
    "negativePrompt": "Warna mencolok tidak ramah mata, font sulit dibaca, ornamen berlebihan"
  },
  "brandingEngine": {
    "logoPlacement": "${useManualLogo ? 'Buat badge lingkaran estetik di pojok frame dengan tulisan LOGO di tengah. Slot ini khusus tempat tempel logo di Canva.' : 'NO_LOGO'}",
    "watermarkFooter": "${watermark.isNotEmpty ? watermark : 'NO_WATERMARK'}"
  },
  "slidesContent": [
    {
      "slideNumber": 1,
      "headline": "Kutipan/Quotes utama yang sangat puitis dan impactful (Hook Slide 1)",
      "description": "Kutipan / kata mutiara singkat & estetis (20–50 kata). Visual 70% pendukung suasana emosional, Teks 30% ringkas.",
      "subject": "Elemen visual/simbolis yang merepresentasikan makna kutipan",
      "sceneDescription": "Suasana latar visual dan pencahayaan puitis + badge di pojok",
      "visualEmphasis": "Penekanan pada kata kunci dalam kutipan",
      "communicationGoal": "Resonansi emosional yang dirasakan pembaca",
      "keyPoints": ["Poin perenungan 1", "Poin perenungan 2"],
      "supportingFacts": ["Data psikologi emosi/referensi karya 2026 + kredit sumber"],
      "calloutSuggestions": ["Refleksi singkat", "Pertanyaan retoris", "Ajakan follow akun sosmed"],
      "storytellingSequence": "Posisi: Variasi 1 (Hook Emosional) s/d Variasi Terakhir (Refleksi & Follow)"
    }
  ],
  "output": {
    "viralScore": 91,
    "analysisShortcomings": "Risiko klise/terlalu umum + cara membuatnya unik dan otentik",
    "hooks": ["Kutipan versi A - pendek & tajam", "Kutipan versi B - puitis mendalam", "Kutipan versi C - inspiratif modern"],
    "logoExplanation": "Penempatan identitas penulis dan watermark estetik",
    "socialMediaCaption": "Caption renungan mendalam + pertanyaan untuk diskusi + ajakan follow + TEPAT 3 hashtag quotes 2026"
  }
}''';
}
