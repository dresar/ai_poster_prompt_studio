import 'prompt_helpers.dart';

/// Builds a super-detailed Visual Style Design System prompt for AI image generation.
String buildGayaVisualPrompt(Map<String, dynamic> formState) {
  final namaGaya = formState['namaGaya'] ?? 'Gaya Visual kustom';
  final kategori = formState['kategori'] ?? 'Modern Minimalis';
  final mood = formState['mood'] ?? 'Elegan & Profesional';
  final dominasiWarna = formState['dominasiWarna'] ?? 'Dark Mode & Neon Accent';
  final mediumSeni = formState['mediumSeni'] ?? '3D Studio Render';
  final pencahayaan = formState['pencahayaan'] ?? 'Cinematic Studio Light';
  final tekstur = formState['tekstur'] ?? 'Smooth Glassmorphism & Matte';
  final deskripsi = formState['deskripsi'] ?? '';
  final extra = formState['extraDetails'] ?? '';
  final watermark = (formState['watermark'] ?? '').toString().trim();

  final outs = outputRulesBlock();

  final deskripsiLine = deskripsi.isNotEmpty ? deskripsi : '(AI rancang gaya visual unik yang mewah, estetik, dan trendset 2026)';
  final extraLine = extra.isNotEmpty ? 'Detail Tambahan: $extra' : '';
  final watermarkLine = watermark.isNotEmpty ? 'Watermark/Branding: $watermark' : 'Watermark: NO_WATERMARK';

  return '''
Anda adalah AI Lead Visual Art Director & Master Design System Architect profesional kelas dunia. Tugas Anda adalah membuat DESIGN SYSTEM & VISUAL STYLE BLUEPRINT ultra-detail untuk gaya visual "$namaGaya" agar dapat diterapkan secara KONSISTEN di berbagai media visual (Poster, Banner, UI/UX, 3D Render, Branding, Ads) menggunakan AI (Midjourney, DALL-E 3, Stable Diffusion, Adobe Firefly, dll).

INPUT USER:
- Nama Gaya Visual: $namaGaya
- Kategori Gaya: $kategori
- Atmosphere / Mood: $mood
- Dominasi Warna: $dominasiWarna
- Medium Seni: $mediumSeni
- Pencahayaan: $pencahayaan
- Tekstur & Material: $tekstur
- Deskripsi: $deskripsiLine
$extraLine
- $watermarkLine

$outs

============================================================
ATURAN VISUAL STYLE BLUEPRINT (WAJIB DIPATUHI SEPENUHNYA)
============================================================
1. STYLE CONSISTENCY: Rancang aturan visual yang begitu rinci sehingga siapapun yang menggunakan prompt ini dapat membuat aset visual dengan gaya yang 100% identik dan harmonis.
2. PALET WARNA PRESHI: Berikan kode HEX pasti, rasio penggunaan warna (60-30-10 rule), serta aspek psikologi warnanya.
3. KELENGKAPAN TIPOGRAFI: Berikan rekomendasi font pairing, skala hirarki, letter spacing, dan layout grid structure.
4. ASPEK RASIO & FORMAT: WAJIB MENGGUNAKAN RASIO LANSKAP (LANDSCAPE WIDESCREEN 16:9 - FORMAT YOUTUBE). DILARANG KERAS FORMAT POTRET/VERTIKAL.
5. JUMLAH SLIDE: CUKUP 1 SLIDE BLUEPRINT FRAME. DILARANG MEMBUAT MULTI-SLIDE CAROUSEL.
6. MASTER PROMPT ALL-AI: Sertakan master prompt bahasa Inggris (--ar 16:9) yang langsung siap di-copy ke Midjourney v6.1, DALL-E 3, dan Stable Diffusion XL.
7. MULTI-USE COMPATIBILITY: Berikan panduan lengkap adaptasi ke Poster Edukasi, Logo Brand, Banner Iklan, Video Shorts, E-Commerce, dan YouTube Widescreen.

============================================================
FORMAT JSON OUTPUT (semua field wajib diisi PENUH)
============================================================
{
  "styleOverview": {
    "name": "$namaGaya",
    "category": "$kategori",
    "moodAtmosphere": "$mood",
    "artMedium": "$mediumSeni",
    "designPhilosophy": "Filosofi di balik gaya visual ini dalam 2 kalimat singkat.",
    "idealUseCases": ["Poster Edukasi", "Logo & Identitas Brand", "Banner Promosi", "Video Shorts & YouTube Widescreen 16:9", "E-Commerce Mockup"],
    "targetEmotion": "Perasaan yang ingin ditimbulkan saat audiens melihat karya dengan gaya ini"
  },
  "colorEngine": {
    "dominantColor": {"name": "Warna Dominan (60%)", "hex": "#XXXXXX", "role": "Latar belakang / bidang utama"},
    "secondaryColor": {"name": "Warna Sekunder (30%)", "hex": "#XXXXXX", "role": "Struktur kontainer / kartu"},
    "accentColor": {"name": "Warna Aksen (10%)", "hex": "#XXXXXX", "role": "Highlight / CTA / Focal Point"},
    "neutralColor": {"name": "Warna Netral Teks", "hex": "#XXXXXX", "role": "Teks utama & pembatas"},
    "gradientSpec": "Spesifikasi gradasi warna jika ada (angle, stop color, hex opacity)"
  },
  "typographySystem": {
    "primaryFontFamily": "Rekomendasi jenis font utama (mis: Inter, Outfit, Syne, Cabinet Grotesk)",
    "fontPairing": "Kombinasi font heading + body yang serasi",
    "hierarchyScale": "Ukuran rasio font (Title 32pt, Subtitle 20pt, Body 14pt)",
    "textPlacementRules": "Aturan penataan posisi teks agar tidak mengganggu keindahan visual"
  },
  "compositionAndLighting": {
    "compositionRule": "Aturan tata letak (mis: Rule of thirds, Golden ratio, Center focus, Asymmetric grid)",
    "negativeSpaceRatio": "Persentase ruang kosong (mis: 35-40% whitespace untuk kesan mahal)",
    "lightingStyle": "$pencahayaan",
    "shadowAndDepth": "Ketebalan bayangan, blur radius, dan efek depth-of-field",
    "cameraAngle": "Sudut pandang kamera ideal (mis: Eye-level, Low-angle 45 deg, Isometric 3D)"
  },
  "materialAndTexture": {
    "surfaceTexture": "$tekstur",
    "roughnessAndReflectivity": "Tingkat kekasaran permukaan dan kejelasan pantulan cahaya",
    "particleEffects": "Efek partikel opsional (mis: Dust particles, Light bokeh, Grain 5%)"
  },
  "aiPrompts": {
    "masterPositivePrompt": "FULL ENGLISH PROMPT — highly descriptive art style, lighting, render engine, materials, color refs, resolution: '$namaGaya style, [mediumSeni], [pencahayaan], [tekstur], color palette [hex codes], 8k resolution, widescreen 16:9, highly detailed'",
    "masterNegativePrompt": "FULL ENGLISH NEGATIVE PROMPT — low quality, blurry, noisy, distorted, amateur, oversaturated, ugly typography, bad composition, vertical, portrait",
    "midjourney": "/imagine prompt: [full style description] --style raw --v 6.1 --ar 16:9",
    "dalleOptimized": "DALL-E 3 optimized prompt format",
    "stableDiffusionTags": "SDXL prompt tags separated by commas"
  },
  "dosAndDonts": {
    "dos": ["Hal yang WAJIB ada di gaya ini 1", "Hal yang WAJIB ada di gaya ini 2"],
    "donts": ["Hal yang DILARANG di gaya ini 1", "Hal yang DILARANG di gaya ini 2"]
  },
  "output": {
    "styleAestheticScore": 95,
    "trendfit2026": "Analisis seberapa relevan gaya ini dengan tren visual tahun 2026.",
    "verdict": "Kesimpulan super singkat dalam 2 kalimat."
  }
}''';
}
