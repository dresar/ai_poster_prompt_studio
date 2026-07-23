import 'prompt_helpers.dart';

/// Builds a comprehensive 15-Section Professional Character Bible prompt for AI image generation.
String buildKarakterPrompt(Map<String, dynamic> formState) {
  final namaKarakter = formState['namaKarakter'] ?? 'Karakter Tanpa Nama';
  final jenisKarakter = formState['jenisKarakter'] ?? 'Hewan';
  final kategori = formState['kategori'] ?? 'Maskot Brand';
  final spesies = formState['spesies'] ?? '';
  final usiaVisual = formState['usiaVisual'] ?? 'Dewasa';
  final kepribadian = formState['kepribadian'] ?? 'Ceria, Ramah';
  final warnaUtama = formState['warnaUtama'] ?? 'auto';
  final gayaIlustrasi = formState['gayaIlustrasi'] ?? '3D Cartoon';
  final platform = formState['platform'] ?? 'Poster & Media Sosial';
  final deskripsi = formState['deskripsi'] ?? '';
  final extra = formState['extraDetails'] ?? '';
  final watermark = (formState['watermark'] ?? '').toString().trim();

  final outs = outputRulesBlock();

  final spesiesLine = spesies.isNotEmpty ? spesies : '(AI tentukan spesies paling menarik & unik)';
  final deskripsiLine = deskripsi.isNotEmpty ? deskripsi : '(AI tentukan pakaian & aksesori khas yang menarik)';
  final extraLine = extra.isNotEmpty ? 'Detail Tambahan: $extra' : '';
  final watermarkLine = watermark.isNotEmpty ? 'Watermark/Branding: $watermark' : 'Watermark: NO_WATERMARK';

  return '''
ROLE
Kamu adalah Senior Character Designer Disney/Pixar + Brand Mascot Specialist + Art Director profesional kelas dunia.

MISSION
Buat Character Bible & Visual Design Blueprint super lengkap dalam satu format master prompt untuk karakter "$namaKarakter".

INPUT USER:
- Nama Karakter: $namaKarakter
- Jenis: $jenisKarakter
- Kategori Penggunaan: $kategori
- Spesies/Ras: $spesiesLine
- Usia Visual: $usiaVisual
- Kepribadian: $kepribadian
- Warna Utama: $warnaUtama
- Gaya Ilustrasi: $gayaIlustrasi
- Platform Target: $platform
- Pakaian & Aksesori: $deskripsiLine
$extraLine
- $watermarkLine

$outs

============================================================
STRUKTUR CHARACTER BIBLE (WAJIB ADA & LENGKAP):
============================================================
1. HERO CHARACTER
- Full body pose heroik
- Background tema yang bersih
- Nama karakter
- Deskripsi visual utama

2. CHARACTER INFORMATION
- Nama: $namaKarakter
- Umur visual: $usiaVisual
- Kepribadian: $kepribadian
- Filosofi & Nilai karakter
- Cerita latar belakang singkat

3. POSE LIBRARY (12-20 Pose Berbeda)
- idle, berjalan, melompat, duduk, membaca, makan, selfie, melambai, tidur, berpikir, berlari, menunjuk, dll.

4. EXPRESSION LIBRARY (20 Ekspresi)
- senang, sedih, marah, malu, terkejut, bingung, berpikir, tertawa, menangis, fokus, cemas, bangga, dll.

5. TURNAROUND SHEET
- Front view, 3/4 Front, Side view, 3/4 Back, Back view.

6. ACCESSORIES
- Breakdown semua aksesori & pakaian dipisah rapi.

7. MATERIAL CLOSE-UP
- Zoom tekstur detail: bulu/kulit, bahan pakaian, mata, aksesori.

8. COLOR PALETTE
- Primary, Secondary, Accent, Neutral lengkap dengan Kode Hex Warna (#HEX).

9. SILHOUETTE
- Bentuk siluet karakter yang ikonik.

10. BRAND VALUE & PHILOSOPHY

11. DESIGN RULES & GUIDELINES

12. STYLE GUIDE & VISUAL IDENTITY ($gayaIlustrasi)

13. TYPOGRAPHY & HEADER RECOMMENDATIONS

14. ICON SYSTEM & SYMBOLS

15. LAYOUT & PRESENTATION
- Professional Character Bible, Game Studio Style, Pixar Style, White Background, Rounded Panel UI, Premium Editorial Layout.

QUALITY & RESOLUTION RULES:
- Ultra detailed 8K, Professional Character Sheet, AAA Game Studio quality, Disney Pixar aesthetic, No watermark, No blur, --ar 3:4.

============================================================
FORMAT JSON OUTPUT (semua field wajib diisi PENUH)
============================================================
{
  "characterOverview": {
    "name": "$namaKarakter",
    "type": "$jenisKarakter",
    "category": "$kategori",
    "species": "$spesiesLine",
    "visualAge": "$usiaVisual",
    "personality": "$kepribadian",
    "philosophy": "Filosofi & nilai utama karakter",
    "backstory": "Cerita latar belakang singkat yang inspiratif",
    "catchphrase": "Kalimat khas karakter"
  },
  "visualDesign": {
    "bodyProportions": "Deskripsi ringkas proporsi tubuh karakter",
    "headAndFace": {
      "eyes": "Bentuk, warna mata HEX, sorot mata",
      "uniqueFeatures": "Fitur unik wajah"
    },
    "clothingAndAccessories": {
      "mainOutfit": "$deskripsiLine",
      "mandatoryAccessories": ["Aksesori 1", "Aksesori 2"]
    }
  },
  "poseLibrary": [
    "1. Idle standard pose",
    "2. Berjalan santai",
    "3. Melompat gembira",
    "4. Duduk membaca",
    "5. Makan snack",
    "6. Selfie gaya seru",
    "7. Melambai ramah",
    "8. Tidur nyenyak",
    "9. Berpikir keras",
    "10. Berlari cepat",
    "11. Menunjuk papan",
    "12. Tertawa terbahak"
  ],
  "expressionLibrary": [
    "1. Senang gembira",
    "2. Sedih terharu",
    "3. Marah tegas",
    "4. Malu tersipu",
    "5. Terkejut kagum",
    "6. Bingung garuk kepala",
    "7. Berpikir fokus",
    "8. Tertawa lebar",
    "9. Menangis terharu",
    "10. Fokus konsentrasi"
  ],
  "turnaroundSheet": {
    "front": "Tampilan depan penuh",
    "threeQuarterFront": "Tampilan 3/4 depan",
    "side": "Tampilan samping",
    "threeQuarterBack": "Tampilan 3/4 belakang",
    "back": "Tampilan belakang"
  },
  "colorPalette": {
    "primary": {"name": "Warna utama", "hex": "#XXXXXX"},
    "secondary": {"name": "Warna sekunder", "hex": "#XXXXXX"},
    "accent": {"name": "Warna aksen", "hex": "#XXXXXX"},
    "neutral": {"name": "Warna netral", "hex": "#XXXXXX"}
  },
  "aiPrompts": {
    "masterPositivePrompt": "ROLE: Senior Character Designer Disney Pixar. MISSION: Professional Character Bible Layout for $namaKarakter, $spesiesLine, $gayaIlustrasi style. HERO CHARACTER: Full body portrait of $namaKarakter wearing $deskripsiLine, vibrant color palette, expressively detailed face. INCLUDES: 1. Hero Character, 2. Character Info, 3. Pose Library (12-20 poses), 4. Expression Library (20 expressions), 5. Turnaround Sheet (front, side, back), 6. Accessories breakdown, 7. Material Close-Up texture, 8. Color Palette Hex, 9. Silhouette, 10. Brand Value. STYLE: Professional Character Sheet, AAA Game Studio Style, Pixar Style, White Background, Rounded Panel UI, Editorial Layout, Ultra detailed 8K, --ar 3:4",
    "masterNegativePrompt": "deformed, blurry, bad anatomy, extra limbs, missing fingers, ugly, low quality, text, watermark, signature, landscape aspect ratio",
    "midjourney": "/imagine prompt: A complete professional Character Bible sheet for $namaKarakter, $gayaIlustrasi style, full body hero pose, turnaround view, expression library, color palette hex codes, game studio layout, clean white background, ultra detailed 8k --ar 3:4 --v 6.1",
    "dalleOptimized": "Professional Character Sheet of $namaKarakter, Disney Pixar style, full body with expression variations and color palette, clean editorial layout",
    "stableDiffusionTags": "$namaKarakter, character sheet, character bible, $gayaIlustrasi style, full body, turnaround, 8k"
  },
  "usageGuidelines": {
    "platform": "$platform",
    "recommendedUseCases": ["Poster Edukasi", "Brand Mascot", "Banner Promo", "Video Shorts"]
  },
${imageGenerationRulesJson()}
}''';
}
