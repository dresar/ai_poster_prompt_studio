import 'prompt_helpers.dart';

String buildAdvancedVideoPrompt(Map<String, dynamic> formState) {
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
  final duration = formState['duration'] ?? 30;

  final ss = styleBlock(style, charFocus);
  final bs = brandingBlock(useManualLogo, watermark);
  final outs = outputRulesBlock();
  final sr = slideStructureRules(slideCount);
  final cs = completionBlock(topic, slideCount);

  final hookLine = hook.isNotEmpty ? hook : '(Buat visual storyboard sinematik kelas Hollywood)';
  final ctaLine = cta.isNotEmpty ? cta : '(Rekomendasikan CTA sinematik + ajakan follow sosmed)';

  return '''
Anda adalah AI Master Film Director & Multi-AI Video Storyboard Architect (Veo, Kling, Runway Gen-3, Luma Dream Machine, Sora) 2026.

INPUT USER:
- Jenis: ADVANCED CINEMATIC STORYBOARD VIDEO
- Judul/Konsep Film: $topic
- Alur Drama/Sinematik: $desc
- Pengarahan Kamera & Efek: $extra
- Hook Adegan Pembuka: $hookLine
- CTA/Penutup Film: $ctaLine
- Durasi Total: $duration detik | Jumlah Adegan: $slideCount adegan sinematik

$outs

============================================================
ATURAN SISTEM KONTEN (WAJIB DIPATUHI SEPENUHNYA)
============================================================
$ss

$bs

$sr

$cs

============================================================
FORMAT JSON OUTPUT (semua field wajib diisi, SEMUA adegan wajib ditulis PENUH)
============================================================
{
  "systemInit": { "mission": "Misi film sinematik: pengarahan kamera profesional 2026, pencahayaan dramatis, kontinuitas karakter & suasana" },
  "contentPayload": {
    "topic": "$topic",
    "targetAudience": "Penonton film/iklan sinematik kelas atas: standar kualitas 2026",
    "cinematicGenre": "Sci-Fi / Drama / Action / Commercial / Documentary / Cyberpunk / Fantasy",
    "dramaticArc": "Struktur 3 babak: Pembuka (Hook) > Konflik > Resolusi (CTA & Follow)",
    "colorGradingPhilosophy": "Filosofi grading warna sinematik (contoh: Teal & Orange, Bleach Bypass, Cyberpunk Neon)"
  },
  "designSystem": {
    "gridStructure": "Framing 16:9 widescreen atau 9:16 vertical cinema safe zone",
    "whitespaceRatio": "Komposisi sinematik: rule of thirds, headroom, lead room",
    "colorPalette": "Grading warna LUT profesional + hex kode warna",
    "typographyHierarchy": "Judul film sinematik + subtitle sinematik + badge adegan di pojok",
    "slideNumberBadgeStyle": "Badge nomor adegan di pojok atas frame"
  },
  "visualBlueprint": {
    "coreVisualStyle": "Hollywood 8K cinematic render / IMAX film stock texture",
    "compositionRules": "Kamera gerakan kontinu + posisi badge nomor adegan di pojok",
    "cameraLenses": "Pilihan lensa kamera: 35mm anamorphic, 85mm portrait, 24mm wide angle",
    "lightingDesign": "Desain cahaya: volumetric fog, rim light, Rembrandt lighting, practical lights"
  },
  "renderingBlueprint": {
    "renderStyle": "Optimized for Veo / Runway Gen-3 Alpha / Kling AI / Luma Dream Machine",
    "qualityParameters": "Photorealistic 8K, 60fps, ray-traced reflections, atmospheric depth",
    "negativePrompt": "Gerakan kamera patah-patah, pencahayaan rata tanpa kedalaman, distorsi anatomi"
  },
  "brandingEngine": {
    "logoPlacement": "${useManualLogo ? 'Buat badge lingkaran estetik di pojok frame dengan tulisan LOGO di tengah. Slot ini khusus tempat tempel logo di Canva.' : 'NO_LOGO'}",
    "watermarkFooter": "${watermark.isNotEmpty ? watermark : 'NO_WATERMARK'}"
  },
  "segmentsContent": [
    {
      "segmentNumber": 1,
      "timecode": "00:00 - 00:05",
      "headline": "Judul Adegan Pembuka (Hook Sinematik Adegan 1)",
      "description": "PENGARAHAN SUTRADARA LENGKAP minimal 100-150 kata: pergerakan kamera sinematik, lighting, aksi aktor/karakter, atmosfer suara, riset konteks 2026 dengan KREDIT SUMBER, dan dorongan emosional penonton.",
      "subject": "Aksi, busana, ekspresi emosi karakter utama secara mendetail",
      "sceneDescription": "Deskripsi lingkungan, cuaca, dan efek visual sinematik + badge di pojok",
      "visualEmphasis": "Penekanan fokus sinematik adegan ini",
      "cameraInstruction": "Prompt kamera presisi untuk Veo/Kling/Runway (contoh: 'Dolly zoom in 85mm anamorphic lens, shallow depth of field')",
      "voiceoverScript": "Dialog atau monolog suara sinematik",
      "soundEffects": "Desain suara lingkungan & foley (SFX)",
      "keyPoints": ["Fokus dramatis adegan ini"],
      "supportingFacts": ["Data/fakta riset pendukung 2026 + kredit sumber terpercaya"],
      "storytellingSequence": "Alur Sinematik: Adegan 1 (Hook Film) s/d Adegan Terakhir (Resolusi & Follow Sosmed)"
    }
  ],
  "output": {
    "viralScore": 97,
    "analysisShortcomings": "Evaluasi kontinuitas adegan + teknik menjaga konsistensi karakter antar adegan",
    "hooks": ["Visual Hook Pembuka", "Audio Hook Atmosfer", "Dramatic Hook Monolog"],
    "logoExplanation": "Penempatan kredit sutradara dan brand identity",
    "socialMediaCaption": "Caption peluncuran film/iklan sinematik + ajakan follow sosmed + TEPAT 3 hashtag sinematik 2026"
  }
}''';
}
