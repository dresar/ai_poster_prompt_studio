import 'prompt_helpers.dart';

String buildVideoPrompt(Map<String, dynamic> formState) {
  final topic = formState['topic'] ?? '';
  final desc = formState['description'] ?? '';
  final extra = formState['extraDetails'] ?? '';
  final hook = formState['hook'] ?? '';
  final cta = (formState['callToAction'] ?? '').toString();
  final watermark = (formState['watermark'] ?? '').toString().trim();
  final style = (formState['style'] ?? 'auto').toString();
  final charFocus = (formState['characterFocus'] ?? 'auto').toString();
  final useManualLogo = formState['useManualLogo'] == true;
  final slideCount = formState['slideCount'] ?? 5; // video segments
  final duration = formState['duration'] ?? 30;

  final ss = styleBlock(style, charFocus);
  final bs = brandingBlock(useManualLogo, watermark);
  final outs = outputRulesBlock();
  final sr = slideStructureRules(slideCount);
  final cs = completionBlock(topic, slideCount);

  final hookLine = hook.isNotEmpty ? hook : '(Buat visual hook 3 detik pertama paling dramatis)';
  final ctaLine = cta.isNotEmpty ? cta : '(Rekomendasikan CTA video viral + ajakan follow sosmed)';

  return '''
Anda adalah AI Expert Video Director & Viral Short-Form Video Producer (TikTok / Reels / YouTube Shorts) 2026.

INPUT USER:
- Jenis: SHORT-FORM VIRAL VIDEO (TikTok / Shorts / Reels)
- Topik Video: $topic
- Alur Cerita: $desc
- Detail Sinematik: $extra
- Hook 3 Detik: $hookLine
- CTA Akhir: $ctaLine
- Durasi: $duration detik | Jumlah Segmen: $slideCount segmen video

$outs

============================================================
ATURAN SISTEM KONTEN (WAJIB DIPATUHI SEPENUHNYA)
============================================================
$ss

$bs

$sr

$cs

============================================================
FORMAT JSON OUTPUT (semua field wajib diisi, SEMUA segmen wajib ditulis PENUH)
============================================================
{
  "systemInit": { "mission": "Misi video: retensi penonton tinggi, 3-second hook dramatis, alur dinamis, viral pacing 2026" },
  "contentPayload": {
    "topic": "$topic",
    "targetAudience": "Profil penonton video pendek: rentang perhatian 3 detik, tren emosi 2026",
    "videoGoal": "Tujuan video: edukasi / hiburan / jualan / kesadaran isu",
    "pacingStrategy": "Strategi ritme pemotongan adegan per 2-3 detik",
    "audioAtmosphere": "Gaya audio/soundtrack/suara latar penunjang emosi"
  },
  "designSystem": {
    "gridStructure": "Framing 9:16 vertical video safe zone",
    "whitespaceRatio": "Area aman teks subtitle agar tidak tertutup UI TikTok/Reels",
    "colorPalette": "Grading warna sinematik + hex mood",
    "typographyHierarchy": "Teks subtitle animasi melayang (kinetic typography) + badge segmen di pojok",
    "slideNumberBadgeStyle": "Badge nomor segmen di pojok atas video"
  },
  "visualBlueprint": {
    "coreVisualStyle": "Cinematic realism / hyper-dynamic motion / 3D animation",
    "compositionRules": "Rule of thirds gerak + posisi badge nomor segmen di pojok",
    "cameraMovement": "Gerakan kamera: push-in, orbit, tracking shot, pan cepat",
    "lightingMood": "Lighting sinematik sesuai mood cerita"
  },
  "renderingBlueprint": {
    "renderStyle": "Sesuai AI Video Generator: Veo / Runway Gen-3 / Sora / Kling AI",
    "qualityParameters": "60fps, 4K resolution, dynamic motion blur",
    "negativePrompt": "Gerakan kaku, artefak visual video, teks subtitle terpotong UI"
  },
  "brandingEngine": {
    "logoPlacement": "${useManualLogo ? 'Buat badge lingkaran estetik di pojok frame dengan tulisan LOGO di tengah. Slot ini khusus tempat tempel logo di Canva.' : 'NO_LOGO'}",
    "watermarkFooter": "${watermark.isNotEmpty ? watermark : 'NO_WATERMARK'}"
  },
  "segmentsContent": [
    {
      "segmentNumber": 1,
      "timecode": "00:00 - 00:03",
      "headline": "Teks Hook Melayang di Layar 3 Detik Pertama (Hook Segmen 1)",
      "description": "SKENARIO DAN SUTRADARA MENDALAM minimal 100 kata: detail aksi karakter, sudut kamera, transisi, audio/voiceover lengkap, data riset 2026 dengan KREDIT SUMBER, dan strategi retensi penonton.",
      "subject": "Aksi dan ekspresi subjek utama dalam gerak kamera",
      "sceneDescription": "Detail visual adegan video sinematik + badge nomor segmen di pojok",
      "visualEmphasis": "Gerakan atau efek visual yang menghentikan scroll penonton",
      "cameraInstruction": "Instruksi kamera spesifik untuk generator video AI (Veo/Kling/Runway)",
      "voiceoverScript": "Teks narasi suara (voiceover) yang diucapkan pada segmen ini",
      "soundEffects": "Efek suara (SFX) yang memperkuat efek visual",
      "keyPoints": ["Insight utama adegan ini"],
      "supportingFacts": ["Fakta/statistik terkini 2026 + kredit sumber terpercaya"],
      "storytellingSequence": "Posisi: Segmen 1 (Hook 3 Detik) s/d Segmen Terakhir (CTA & Follow Sosmed)"
    }
  ],
  "output": {
    "viralScore": 96,
    "analysisShortcomings": "Analisis risiko drop-off penonton di detik tertentu + solusi ritme",
    "hooks": ["Visual Hook A", "Audio Hook B", "Text Hook C"],
    "logoExplanation": "Penempatan identitas pembuat video",
    "socialMediaCaption": "Script caption video viral + CTA ajakan follow sosmed + TEPAT 3 hashtag trending video 2026"
  }
}''';
}
