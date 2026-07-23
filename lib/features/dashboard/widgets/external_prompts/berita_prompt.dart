import 'prompt_helpers.dart';

/// Builds a simplified visual-focused Berita (News) prompt.
/// Emphasizes 70% visual artwork dominance and 30% clean, minimal text overlay (no wall-of-text).
String buildBeritaPrompt(Map<String, dynamic> formState) {
  final topic = formState['topic'] ?? '';
  final desc = formState['description'] ?? '';
  final extra = formState['extraDetails'] ?? '';
  final location = formState['location'] ?? '';
  final incidentStyleExtra = formState['incidentStyleExtra'] ?? '';
  final hook = formState['hook'] ?? '';
  final cta = (formState['callToAction'] ?? '').toString();
  final watermark = (formState['watermark'] ?? '').toString().trim();
  final style = (formState['style'] ?? 'auto').toString();
  final charFocus = (formState['characterFocus'] ?? 'auto').toString();
  final useManualLogo = formState['useManualLogo'] == true;
  final rawSlideCount = formState['slideCount'] ?? 5;
  final countInt = int.tryParse(rawSlideCount.toString()) ?? 5;
  final slideCount = countInt > 5 ? 5 : countInt;
  final ratio = formState['aspectRatio'] ?? 'auto';
  final palette = formState['colorPalette'] ?? 'auto';
  final mood = formState['mood'] ?? 'auto';
  final textRule = formState['textRule'] ?? 'auto';

  final ss = styleBlock(style, charFocus);
  final bs = brandingBlock(useManualLogo, watermark);
  final outs = outputRulesBlock();
  final sr = slideStructureRules(slideCount);
  final cs = completionBlock(topic, slideCount);

  final hookLine = hook.isNotEmpty ? hook : '(Headline berita singkat & memikat)';
  final ctaLine = cta.isNotEmpty ? cta : '(CTA berita singkat + ajakan follow)';

  final isStyleAuto = style == 'auto' || style == 'random' || style.isEmpty;
  final newsStyleRule = isStyleAuto
      ? 'GAYA VISUAL BERITA: Ilustrasi jurnalistik 3D/editorial dramatis yang menonjolkan visual adegan (70% visual artwork, 30% teks minimalis). '
          'Sertakan detail suasana adegan ${incidentStyleExtra.isNotEmpty ? "($incidentStyleExtra)" : ""} ke "designSystem" dan "visualBlueprint".'
      : 'GAYA VISUAL (SUDAH DIPILIH MANUAL = "$style"): KOSONGKAN field "designSystem" dan "visualBlueprint" dengan: '
          '{"note":"SYSTEM_INJECTED - gaya dari backend: $style"}.';

  return '''
Anda adalah AI Press Photojournalist & Visual Infographic Architect profesional. Tugas Anda adalah merancang poster/carousel berita yang SANGAT MENONJOLKAN VISUAL ILUSTRASI ARTWORK DRAMATIS (70% area visual, 30% area teks bersih & minimalis).

INPUT USER:
- Topik Berita: $topic
- Lokasi Kejadian: ${location.isNotEmpty ? location : '(Lokasi terkait)'}
- Rincian Kronologi: $desc
- Gaya Ilustrasi Kejadian: ${incidentStyleExtra.isNotEmpty ? incidentStyleExtra : 'Visual jurnalistik 3D dramatis'}
- Detail Lain: $extra
- Headline Hook: $hookLine
- CTA: $ctaLine
- Jumlah Slide: $slideCount | Rasio: $ratio | Palet: $palette | Mood: $mood | Teks: $textRule

$outs

============================================================
ATURAN VISUAL KONTEN BERITA (FOKUS BANYAKIN VISUAL):
============================================================
1. FOKUS KEPADA VISUAL DAHULUKAN: 70% area gambar adalah karya seni visual / ilustrasi adegan kejadian yang dramatis, indah, dan berkualitas tinggi.
2. TEKS MINIMALIS & RINGKAS: DILARANG KERAS membuat paragraf panjang atau teks menumpuk berlebihan! Gunakan HANYA 1 headline singkat (max 8 kata) dan 1-2 kalimat ringkasan fakta pendek.
3. KETERBACAAN MAKSIMAL: Teks diletakkan pada kontras bersih di bagian atas/bawah frame tanpa menghalangi visual utama.
4. KREDIT SUMBER SINGKAT: Sertakan kredit sumber berita resmi secara singkat di bagian footer (contoh: "Sumber: Kompas/CNN 2026").
5. JUMLAH SLIDE: Maksimal $slideCount slide.

$newsStyleRule

$ss

$bs

$sr

$cs

============================================================
FORMAT JSON OUTPUT (semua field wajib diisi PENUH)
============================================================
{
  "systemInit": { "mission": "Misi berita: visual artwork dramatis 70%, teks berita singkat minimalis 30%, fakta akurat 2026" },
  "contentPayload": {
    "topic": "$topic",
    "newsCategory": "Berita Utama / Insiden / Teknologi / Viral",
    "locationDate": "Lokasi & Waktu Kejadian Berita 2026",
    "primarySources": "Sumber Berita Resmi 2026",
    "publicImpact": "Dampak singkat bagi publik"
  },
  "designSystem": {
    "gridStructure": "70% visual artwork adegan dramatis, 30% overlay teks berita bersih minimalis",
    "whitespaceRatio": "Ruang negatif bersih untuk estetika profesional",
    "colorPalette": "Palet berita profesional kontras tinggi + hex",
    "typographyHierarchy": "Headline bold singkat > 1 kalimat ringkasan > sumber kredit",
    "slideNumberBadgeStyle": "Badge nomor slide mini di pojok atas"
  },
  "visualBlueprint": {
    "coreVisualStyle": "DRAMATIC 3D EDITORIAL INCIDENT ILLUSTRATION",
    "compositionRules": "Visual hero utama mendominasi layar 70%",
    "incidentSceneDetails": "Deskripsi visual adegan utama secara kaya dan detail",
    "illustrationIconography": "Simbol pendukung minimalis"
  },
  "renderingBlueprint": {
    "renderStyle": "Dramatic 3D editorial realism / press graphic artwork",
    "qualityParameters": "Detail adegan presisi, lighting dramatis, visual menonjol",
    "negativePrompt": "Teks panjang menumpuk, wall of text, paragraf berlebih, warna norak"
  },
  "brandingEngine": {
    "logoPlacement": "${useManualLogo ? 'Badge bulat kecil LOGO di pojok atas' : 'NO_LOGO'}",
    "watermarkFooter": "${watermark.isNotEmpty ? watermark : 'NO_WATERMARK'}"
  },
  "slidesContent": [
    {
      "slideNumber": 1,
      "headline": "Headline Berita Singkat & Memikat Max 8 Kata (Hook Slide 1)",
      "description": "RINGKASAN FAKTA BERITA SINGKAT 1-2 KALIMAT SAJA. DILARANG PARAGRAF PANJANG. Tuliskan 1 fakta utama + Kredit Sumber Resmi 2026.",
      "subject": "Deskripsi visual artwork adegan insiden utama",
      "sceneDescription": "Detail komposisi visual karya seni 70% frame + overlay teks minimalis 30%",
      "visualEmphasis": "Momen visual utama yang ditonjolkan",
      "communicationGoal": "Fakta utama berita yang langsung dipahami pembaca",
      "educationalObjective": "Edukasi/imbauan publik singkat",
      "keyPoints": ["Fakta 1 singkat", "Fakta 2 + Sumber 2026"],
      "supportingFacts": ["Data resmi 1-line"],
      "calloutSuggestions": ["Kutipan 1 kalimat"],
      "storytellingSequence": "Alur Berita Visual Ringkas"
    }
  ],
  "output": {
    "viralScore": 95,
    "analysisShortcomings": "Evaluasi daya tarik visual berita",
    "hooks": ["Headline Singkat 1", "Headline Singkat 2"],
    "logoExplanation": "Penempatan identitas media berita",
    "socialMediaCaption": "Caption berita singkat 5W+1H + hashtag berita 2026"
  },
${imageGenerationRulesJson()}
}''';
}
