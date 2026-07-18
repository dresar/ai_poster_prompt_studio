import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import '../../core/services/local_db_service.dart';
import '../../shared/widgets/neo_dropdown_field.dart';

class DropdownState {
  final Map<String, List<NeoDropdownOption>> groups;
  final bool isLoading;
  final String? errorMessage;
  final bool hasUpdate;

  DropdownState({
    required this.groups,
    this.isLoading = false,
    this.errorMessage,
    this.hasUpdate = false,
  });

  DropdownState copyWith({
    Map<String, List<NeoDropdownOption>>? groups,
    bool? isLoading,
    String? errorMessage,
    bool? hasUpdate,
  }) {
    return DropdownState(
      groups: groups ?? this.groups,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      hasUpdate: hasUpdate ?? this.hasUpdate,
    );
  }
}

class DropdownNotifier extends StateNotifier<DropdownState> {
  DropdownNotifier() : super(DropdownState(groups: {}, isLoading: true)) {
    loadDropdownOptions();
  }

  // Fallback offline dropdown data (used only if SQLite is also empty)
  // Each feature has its own unique groupKey for independent dropdown management
  static final Map<String, List<NeoDropdownOption>> offlineFallbacks = {
    // ═══ POSTER ═══
    'gaya_poster': [
      NeoDropdownOption(id: 'auto_gp', label: '🤖 AI Pilihkan (Auto)', value: 'auto', helperText: 'Biarkan AI merekomendasikan gaya terbaik'),
      NeoDropdownOption(id: 'p1', label: '🎨 Neubrutalism Modern', value: 'neubrutalism', helperText: 'Border hitam tebal, warna kontras solid, bayangan tajam.'),
      NeoDropdownOption(id: 'p2', label: '⭐ Premium Product Shot', value: 'premium_product', helperText: 'Studio bersih, pencahayaan elegan, mewah.'),
      NeoDropdownOption(id: 'p3', label: '🧊 3D Clay Isometric', value: 'clay_3d', helperText: 'Karakter 3D imut, membulat, gaya animasi modern.'),
      NeoDropdownOption(id: 'p4', label: '🍂 Minimalist Aesthetic', value: 'minimalist', helperText: 'Warna earth tone, tata letak luas, font tipis elegan.'),
      NeoDropdownOption(id: 'p5', label: '👾 Retro Vaporwave', value: 'retro_vaporwave', helperText: 'Warna neon ungu/pink, glitch effect, gaya lofi 80-an.'),
    ],
    'tata_letak_poster': [
      NeoDropdownOption(id: 'auto_tlp', label: '🤖 AI Pilihkan (Auto)', value: 'auto'),
      NeoDropdownOption(id: 'tl1', label: '🗂️ Split Layout (Kiri/Kanan)', value: 'split_left_right'),
      NeoDropdownOption(id: 'tl2', label: '🪜 Grid Top-to-Bottom', value: 'grid_top_bottom'),
      NeoDropdownOption(id: 'tl3', label: '⭕ Focus Center', value: 'focus_center'),
    ],
    'rasio_poster': [
      NeoDropdownOption(id: 'auto_rp', label: '🤖 AI Pilihkan (Auto)', value: 'auto'),
      NeoDropdownOption(id: 'r1', label: '📱 9:16 (Reels/TikTok/Story)', value: '9:16'),
      NeoDropdownOption(id: 'r2', label: '🟦 1:1 (Square Feed)', value: '1:1'),
      NeoDropdownOption(id: 'r3', label: '📸 4:5 (Portrait Feed)', value: '4:5'),
      NeoDropdownOption(id: 'r4', label: '🖥️ 16:9 (Landscape)', value: '16:9'),
    ],
    'palet_warna_poster': [
      NeoDropdownOption(id: 'auto_cwp', label: '🤖 AI Pilihkan (Auto)', value: 'auto'),
      NeoDropdownOption(id: 'c1p', label: '🧁 Pastel Soft', value: 'pastel'),
      NeoDropdownOption(id: 'c2p', label: '🔥 Neon Vibrant', value: 'neon'),
      NeoDropdownOption(id: 'c3p', label: '🪨 Earth Tone', value: 'earth_tone'),
    ],
    'mood_poster': [
      NeoDropdownOption(id: 'auto_mp', label: '🤖 AI Pilihkan (Auto)', value: 'auto'),
      NeoDropdownOption(id: 'm1p', label: '☀️ Siang / Ceria', value: 'bright_cheerful'),
      NeoDropdownOption(id: 'm2p', label: '🌙 Gelap / Dramatis', value: 'dark_dramatic'),
      NeoDropdownOption(id: 'm3p', label: '✨ Elegan & Profesional', value: 'elegant_professional'),
    ],
    'aturan_teks_poster': [
      NeoDropdownOption(id: 'auto_atp', label: '🤖 AI Pilihkan (Auto)', value: 'auto'),
      NeoDropdownOption(id: 'tr1p', label: '🔒 Strict (Presisi)', value: 'strict'),
      NeoDropdownOption(id: 'tr2p', label: '🔓 Flexible (Bebas)', value: 'flexible'),
    ],
    'fokus_karakter_poster': [
      NeoDropdownOption(id: 'auto_fkp', label: '🤖 AI Pilihkan (Auto)', value: 'auto', icon: 'assets/ai_pilihan_auto.png'),
      NeoDropdownOption(id: 'cf1p', label: '🎲 Random / Kontekstual', value: 'random', icon: 'assets/random_choice.png'),
      NeoDropdownOption(id: 'cf2p', label: '🛍️ Tanpa Karakter (Objek Saja)', value: 'product_only', icon: 'assets/without_character.png'),
    ],
    // ═══ BANNER ═══
    'gaya_banner': [
      NeoDropdownOption(id: 'auto_gb', label: '🤖 AI Pilihkan (Auto)', value: 'auto'),
      NeoDropdownOption(id: 'b1', label: '✨ Modern Tech Banner', value: 'modern_tech', helperText: 'Gaya teknologi bersih, aksen neon grid.'),
      NeoDropdownOption(id: 'b2', label: '🔥 Bold Cyberpunk', value: 'bold_cyberpunk', helperText: 'Penuh warna neon kontras tinggi, high energy.'),
      NeoDropdownOption(id: 'b3', label: '💼 Corporate Clean', value: 'corporate_clean', helperText: 'Desain profesional, minimalis, warna korporat rapi.'),
      NeoDropdownOption(id: 'b4', label: '💥 Street Pop', value: 'street_pop', helperText: 'Tipografi berani, efek cat semprot, grunge.'),
    ],
    'rasio_banner': [
      NeoDropdownOption(id: 'auto_rb', label: '🤖 AI Pilihkan (Auto)', value: 'auto'),
      NeoDropdownOption(id: 'rb1', label: '🖥️ 16:9 (Web Banner / YouTube Header)', value: '16:9'),
      NeoDropdownOption(id: 'rb2', label: '📏 3:1 (Header Website / FB Cover)', value: '3:1'),
      NeoDropdownOption(id: 'rb3', label: '🟦 1:1 (Square Banner)', value: '1:1'),
    ],
    'palet_warna_banner': [
      NeoDropdownOption(id: 'auto_cwb', label: '🤖 AI Pilihkan (Auto)', value: 'auto'),
      NeoDropdownOption(id: 'c1b', label: '🧁 Pastel Soft', value: 'pastel'),
      NeoDropdownOption(id: 'c2b', label: '🔥 Neon Vibrant', value: 'neon'),
      NeoDropdownOption(id: 'c3b', label: '🪨 Earth Tone', value: 'earth_tone'),
    ],
    'aturan_teks_banner': [
      NeoDropdownOption(id: 'auto_atb', label: '🤖 AI Pilihkan (Auto)', value: 'auto'),
      NeoDropdownOption(id: 'tr1b', label: '🔒 Strict (Presisi)', value: 'strict'),
      NeoDropdownOption(id: 'tr2b', label: '🔓 Flexible (Bebas)', value: 'flexible'),
    ],
    // ═══ EDUKASI ═══
    'gaya_edukasi': [
      NeoDropdownOption(id: 'auto_ge', label: '🤖 AI Pilihkan (Auto)', value: 'auto'),
      NeoDropdownOption(id: 'e1', label: '📊 Infographic Clean Grid', value: 'infographic_grid', helperText: 'Kotak-kotak teratur, penunjuk ikon rapi.'),
      NeoDropdownOption(id: 'e2', label: '🎨 Hand-drawn Doodle', value: 'doodle_sketch', helperText: 'Gaya gambar tangan, papan tulis kapur artistik.'),
      NeoDropdownOption(id: 'e3', label: '👾 Retro Pixel Art', value: 'pixel_art', helperText: 'Gaya visual 8-bit klasik, mudah dibaca.'),
    ],
    'tata_letak_edukasi': [
      NeoDropdownOption(id: 'auto_tle', label: '🤖 AI Pilihkan (Auto)', value: 'auto'),
      NeoDropdownOption(id: 'tle1', label: '🗂️ Split Layout', value: 'split_left_right'),
      NeoDropdownOption(id: 'tle2', label: '🪜 Grid Top-to-Bottom', value: 'grid_top_bottom'),
      NeoDropdownOption(id: 'tle3', label: '⭕ Focus Center', value: 'focus_center'),
    ],
    'rasio_edukasi': [
      NeoDropdownOption(id: 'auto_re', label: '🤖 AI Pilihkan (Auto)', value: 'auto'),
      NeoDropdownOption(id: 're1', label: '📱 9:16 (Infografis Vertikal)', value: '9:16'),
      NeoDropdownOption(id: 're2', label: '📸 4:5 (Carousel Portrait)', value: '4:5'),
      NeoDropdownOption(id: 're3', label: '🟦 1:1 (Square)', value: '1:1'),
    ],
    'palet_warna_edukasi': [
      NeoDropdownOption(id: 'auto_cwe', label: '🤖 AI Pilihkan (Auto)', value: 'auto'),
      NeoDropdownOption(id: 'c1e', label: '🧁 Pastel Soft', value: 'pastel'),
      NeoDropdownOption(id: 'c2e', label: '🔥 Neon Vibrant', value: 'neon'),
      NeoDropdownOption(id: 'c3e', label: '🪨 Earth Tone', value: 'earth_tone'),
    ],
    // ═══ AFFILIATE ═══
    'gaya_affiliate': [
      NeoDropdownOption(id: 'auto_gaf', label: '🤖 AI Pilihkan (Auto)', value: 'auto'),
      NeoDropdownOption(id: 'af1', label: '🛍️ E-commerce Product Shot', value: 'ecommerce_product', helperText: 'Subjek produk di tengah, studio terang, label harga.'),
      NeoDropdownOption(id: 'af2', label: '⚡ Urgent Flash Sale', value: 'flash_sale', helperText: 'Stiker diskon cerah, penuh urgensi, kontras merah/kuning.'),
      NeoDropdownOption(id: 'af3', label: '⭐ UGC Review Style', value: 'ugc_style', helperText: 'Mirip foto review asli pembeli, natural.'),
    ],
    'cta_affiliate': [
      NeoDropdownOption(id: 'auto_cta', label: '🤖 AI Pilihkan (Auto)', value: 'auto'),
      NeoDropdownOption(id: 'cta1', label: '👉 Klik Link di Bio', value: 'click_bio_link'),
      NeoDropdownOption(id: 'cta2', label: '🔥 Beli Sekarang', value: 'buy_now'),
      NeoDropdownOption(id: 'cta3', label: '📲 Ambil Promo Spesial', value: 'claim_promo'),
    ],
    'rasio_affiliate': [
      NeoDropdownOption(id: 'auto_raf', label: '🤖 AI Pilihkan (Auto)', value: 'auto'),
      NeoDropdownOption(id: 'raf1', label: '📱 9:16 (Story/TikTok)', value: '9:16'),
      NeoDropdownOption(id: 'raf2', label: '🟦 1:1 (Square Feed)', value: '1:1'),
    ],
    'palet_warna_affiliate': [
      NeoDropdownOption(id: 'auto_cwaf', label: '🤖 AI Pilihkan (Auto)', value: 'auto'),
      NeoDropdownOption(id: 'c1af', label: '🧁 Pastel Soft', value: 'pastel'),
      NeoDropdownOption(id: 'c2af', label: '🔥 Neon Vibrant', value: 'neon'),
      NeoDropdownOption(id: 'c3af', label: '🪨 Earth Tone', value: 'earth_tone'),
    ],
    // ═══ DIGITAL PRODUCT ═══
    'gaya_digital_product': [
      NeoDropdownOption(id: 'auto_gdp', label: '🤖 AI Pilihkan (Auto)', value: 'auto'),
      NeoDropdownOption(id: 'dp1', label: '💻 Software/App Mockup', value: 'software_mockup', helperText: 'Layar laptop/tablet canggih 3D.'),
      NeoDropdownOption(id: 'dp2', label: '📚 Premium Ebook Cover', value: 'ebook_cover', helperText: 'Cover buku 3D realistis.'),
      NeoDropdownOption(id: 'dp3', label: '🎫 Professional E-course Card', value: 'course_card', helperText: 'Kartu kursus rapi.'),
    ],
    'rasio_digital_product': [
      NeoDropdownOption(id: 'auto_rdp', label: '🤖 AI Pilihkan (Auto)', value: 'auto'),
      NeoDropdownOption(id: 'rdp1', label: '🟦 1:1 (Square Mockup)', value: '1:1'),
      NeoDropdownOption(id: 'rdp2', label: '📸 4:5 (Portrait Card)', value: '4:5'),
    ],
    'palet_warna_digital': [
      NeoDropdownOption(id: 'auto_cwd', label: '🤖 AI Pilihkan (Auto)', value: 'auto'),
      NeoDropdownOption(id: 'c1d', label: '🧁 Pastel Soft', value: 'pastel'),
      NeoDropdownOption(id: 'c2d', label: '🔥 Neon Vibrant', value: 'neon'),
      NeoDropdownOption(id: 'c3d', label: '🪨 Earth Tone', value: 'earth_tone'),
    ],
    // ═══ BALIHO ═══
    'gaya_baliho': [
      NeoDropdownOption(id: 'auto_gba', label: '🤖 AI Pilihkan (Auto)', value: 'auto'),
      NeoDropdownOption(id: 'ba1', label: '🏢 High-Impact Billboard', value: 'billboard_modern', helperText: 'Text raksasa kontras tinggi.'),
      NeoDropdownOption(id: 'ba2', label: '🕌 Tabligh Akbar', value: 'religious_event', helperText: 'Motif ornamen islami.'),
      NeoDropdownOption(id: 'ba3', label: '🎪 Event/Festival Megah', value: 'grand_festival', helperText: 'Pencahayaan panggung meriah.'),
      NeoDropdownOption(id: 'ba4', label: '🤝 Baliho Caleg / Politik', value: 'political_billboard', helperText: 'Foto formal besar.'),
    ],
    'tata_letak_baliho': [
      NeoDropdownOption(id: 'auto_tlba', label: '🤖 AI Pilihkan (Auto)', value: 'auto'),
      NeoDropdownOption(id: 'tlba1', label: '🗂️ Split Layout', value: 'split_left_right'),
      NeoDropdownOption(id: 'tlba2', label: '🪜 Grid Top-to-Bottom', value: 'grid_top_bottom'),
      NeoDropdownOption(id: 'tlba3', label: '⭕ Focus Center', value: 'focus_center'),
    ],
    'rasio_baliho': [
      NeoDropdownOption(id: 'auto_rba', label: '🤖 AI Pilihkan (Auto)', value: 'auto'),
      NeoDropdownOption(id: 'rba1', label: '📏 4:3 (Baliho Standar)', value: '4:3'),
      NeoDropdownOption(id: 'rba2', label: '📏 3:4 (Baliho Vertikal)', value: '3:4'),
      NeoDropdownOption(id: 'rba3', label: '🖥️ 16:9 (Landscape)', value: '16:9'),
    ],
    'palet_warna_baliho': [
      NeoDropdownOption(id: 'auto_cwba', label: '🤖 AI Pilihkan (Auto)', value: 'auto'),
      NeoDropdownOption(id: 'c1ba', label: '🧁 Pastel Soft', value: 'pastel'),
      NeoDropdownOption(id: 'c2ba', label: '🔥 Neon Vibrant', value: 'neon'),
      NeoDropdownOption(id: 'c3ba', label: '🪨 Earth Tone', value: 'earth_tone'),
    ],
    // ═══ LOGO ═══
    'gaya_logo': [
      NeoDropdownOption(id: 'auto_gl', label: '🤖 AI Pilihkan (Auto)', value: 'auto'),
      NeoDropdownOption(id: 'l1', label: '💎 Minimalist Luxury', value: 'minimalist_luxury', helperText: 'Monoline, geometris, emas/perak.'),
      NeoDropdownOption(id: 'l2', label: '🐯 Mascot / Cartoon', value: 'mascot_brand', helperText: 'Maskot kartun 2D.'),
      NeoDropdownOption(id: 'l3', label: '✏️ Vintage Badge', value: 'vintage_badge', helperText: 'Emblem klasik retro.'),
      NeoDropdownOption(id: 'l4', label: '🔤 Modern Wordmark', value: 'wordmark', helperText: 'Tipografi modifikasi.'),
    ],
    'palet_warna_logo': [
      NeoDropdownOption(id: 'auto_cwl', label: '🤖 AI Pilihkan (Auto)', value: 'auto'),
      NeoDropdownOption(id: 'c1l', label: '🧁 Pastel Soft', value: 'pastel'),
      NeoDropdownOption(id: 'c2l', label: '🔥 Neon Vibrant', value: 'neon'),
      NeoDropdownOption(id: 'c3l', label: '🪨 Earth Tone', value: 'earth_tone'),
    ],
    'aturan_teks_logo': [
      NeoDropdownOption(id: 'auto_atl', label: '🤖 AI Pilihkan (Auto)', value: 'auto'),
      NeoDropdownOption(id: 'tr1l', label: '🔒 Strict (Presisi)', value: 'strict'),
      NeoDropdownOption(id: 'tr2l', label: '🔓 Flexible (Bebas)', value: 'flexible'),
    ],
    // ═══ QUOTES ═══
    'gaya_quotes': [
      NeoDropdownOption(id: 'auto_gq', label: '🤖 AI Pilihkan (Auto)', value: 'auto'),
      NeoDropdownOption(id: 'q1', label: '🍂 Aesthetic Earth Tone', value: 'aesthetic_quotes', helperText: 'Font serif cantik, minimalis.'),
      NeoDropdownOption(id: 'q2', label: '🕌 Islamic Gold Calligraphy', value: 'islamic_quotes', helperText: 'Kaligrafi emas islami.'),
      NeoDropdownOption(id: 'q3', label: '🌌 Deep Space', value: 'galaxy_quotes', helperText: 'Bintang/galaksi, font tipis.'),
    ],
    'tema_quotes': [
      NeoDropdownOption(id: 'auto_tq', label: '🤖 AI Pilihkan (Auto)', value: 'auto'),
      NeoDropdownOption(id: 'tq1', label: '💪 Motivasi & Sukses', value: 'motivation'),
      NeoDropdownOption(id: 'tq2', label: '❤️ Cinta & Hubungan', value: 'love'),
      NeoDropdownOption(id: 'tq3', label: '🌱 Kehidupan & Filsafat', value: 'life'),
      NeoDropdownOption(id: 'tq4', label: '🕌 Keagamaan & Spiritual', value: 'religious'),
    ],
    'rasio_quotes': [
      NeoDropdownOption(id: 'auto_rq', label: '🤖 AI Pilihkan (Auto)', value: 'auto'),
      NeoDropdownOption(id: 'rq1', label: '📱 9:16 (Story/Reels)', value: '9:16'),
      NeoDropdownOption(id: 'rq2', label: '🟦 1:1 (Square Feed)', value: '1:1'),
    ],
    'palet_warna_quotes': [
      NeoDropdownOption(id: 'auto_cwq', label: '🤖 AI Pilihkan (Auto)', value: 'auto'),
      NeoDropdownOption(id: 'c1q', label: '🧁 Pastel Soft', value: 'pastel'),
      NeoDropdownOption(id: 'c2q', label: '🔥 Neon Vibrant', value: 'neon'),
      NeoDropdownOption(id: 'c3q', label: '🪨 Earth Tone', value: 'earth_tone'),
    ],
    // ═══ PERCANTIK FOTO ═══
    'enhance_style': [
      NeoDropdownOption(id: 'auto_es', label: '🤖 AI Pilihkan (Auto)', value: 'auto'),
      NeoDropdownOption(id: 'es1', label: '🇰🇷 K-pop / Korea Aesthetic', value: 'kpop_aesthetic'),
      NeoDropdownOption(id: 'es2', label: '📸 Professional Headshot', value: 'professional_headshot'),
      NeoDropdownOption(id: 'es3', label: '🎬 Cinematic Portrait', value: 'cinematic_portrait'),
      NeoDropdownOption(id: 'es4', label: '🦾 Cyberpunk Mech', value: 'cyberpunk_mech'),
    ],
    'change_level': [
      NeoDropdownOption(id: 'auto_cl', label: '🤖 AI Pilihkan (Auto)', value: 'auto'),
      NeoDropdownOption(id: 'cl1', label: '🌱 Natural (Halus)', value: 'natural'),
      NeoDropdownOption(id: 'cl2', label: '⚡ Medium (Detail Tambahan)', value: 'medium'),
    ],
    'gaya_video': [
      NeoDropdownOption(id: 'auto_gv', label: '🤖 AI Pilihkan (Auto)', value: 'auto', helperText: 'Biarkan AI merekomendasikan gaya video terbaik'),
      NeoDropdownOption(id: 'gv1', label: '🎬 Cinematic Portrait', value: 'cinematic_portrait', helperText: 'Pencahayaan dramatis, kedalaman ruang (bokeh), gaya film bioskop'),
      NeoDropdownOption(id: 'gv2', label: '🧊 3D Pixar Animation', value: 'pixar_3d', helperText: 'Gaya animasi karakter 3D imut, membulat, cerah khas film Pixar'),
      NeoDropdownOption(id: 'gv3', label: '🎨 Japanese Anime', value: 'japanese_anime', helperText: 'Gaya gambar tangan animasi anime Jepang klasik'),
      NeoDropdownOption(id: 'gv4', label: '📈 Minimalist Motion Graphic', value: 'motion_graphic', helperText: 'Grafis gerak minimalis, bentuk vektor datar bersih'),
      NeoDropdownOption(id: 'gv5', label: '👾 Cyberpunk / Sci-Fi', value: 'cyberpunk', helperText: 'Penuh lampu neon, elemen teknologi futuristik'),
      NeoDropdownOption(id: 'gv6', label: '📱 Daily Life Vlog', value: 'vlog', helperText: 'Gaya kamera handheld alami, suasana vlog kehidupan nyata'),
    ],
    'gerakan_kamera_video': [
      NeoDropdownOption(id: 'auto_gkm', label: '🤖 AI Pilihkan (Auto)', value: 'auto', helperText: 'AI akan menentukan gerakan kamera yang paling dramatis'),
      NeoDropdownOption(id: 'gkm1', label: '↔️ Slow Panning (Kiri ke Kanan)', value: 'slow_pan', helperText: 'Kamera bergeser horizontal perlahan untuk mengekspos pemandangan'),
      NeoDropdownOption(id: 'gkm2', label: '🔍 Steady Zoom In / Out', value: 'zoom', helperText: 'Perubahan fokus perlahan mendekat/menjauh untuk penekanan dramatis'),
      NeoDropdownOption(id: 'gkm3', label: '🏃‍♂️ Dynamic Subject Tracking', value: 'subject_tracking', helperText: 'Kamera aktif mengikuti pergerakan subjek utama'),
      NeoDropdownOption(id: 'gkm4', label: '🚁 Drone Flyover / Aerial', value: 'drone_aerial', helperText: 'Sudut pandang luas dari atas ke bawah khas drone'),
      NeoDropdownOption(id: 'gkm5', label: '❓ First-Person Handheld', value: 'handheld_shake', helperText: 'Gaya kamera digenggam tangan dengan getaran alami'),
      NeoDropdownOption(id: 'gkm6', label: '🎥 Fixed Tripod (Statis)', value: 'static_shot', helperText: 'Kamera diam di tempat, fokus murni pada aksi subjek'),
    ],
    'rasio_video': [
      NeoDropdownOption(id: 'auto_rv', label: '🤖 AI Pilihkan (Auto)', value: 'auto', helperText: 'Biarkan AI menyesuaikan rasio visual terbaik'),
      NeoDropdownOption(id: 'rv1', label: '📱 9:16 (TikTok / Reels / Shorts)', value: '9:16', helperText: 'Rasio vertikal penuh untuk layar smartphone'),
      NeoDropdownOption(id: 'rv2', label: '🖥️ 16:9 (YouTube Widescreen)', value: '16:9', helperText: 'Rasio horizontal lebar cocok untuk monitor & TV'),
      NeoDropdownOption(id: 'rv3', label: '🟦 1:1 (Square Feed)', value: '1:1', helperText: 'Format persegi klasik cocok untuk media sosial feed'),
    ],
    'palet_warna_video': [
      NeoDropdownOption(id: 'auto_cwv', label: '🤖 AI Pilihkan (Auto)', value: 'auto', helperText: 'Biarkan AI menentukan harmoni warna yang cocok'),
      NeoDropdownOption(id: 'c1v', label: '🧁 Pastel Soft', value: 'pastel', helperText: 'Warna-warna lembut, menenangkan dan estetik'),
      NeoDropdownOption(id: 'c2v', label: '🔥 Neon Vibrant', value: 'neon', helperText: 'Warna kontras tinggi yang menyala terang'),
      NeoDropdownOption(id: 'c3v', label: '🪨 Earth Tone', value: 'earth_tone', helperText: 'Warna-warna alami seperti cokelat kayu, hijau daun, dsb.'),
      NeoDropdownOption(id: 'c4v', label: '🎬 Teal & Orange', value: 'teal_orange', helperText: 'Skema warna populer perfilman Hollywood untuk sinematik instan'),
    ],
    'fokus_karakter_video': [
      NeoDropdownOption(id: 'auto_fkv', label: '🤖 AI Pilihkan (Auto)', value: 'auto', icon: 'assets/ai_pilihan_auto.png'),
      NeoDropdownOption(id: 'cf1v', label: '🎲 Random / Kontekstual', value: 'random', icon: 'assets/random_choice.png'),
      NeoDropdownOption(id: 'cf2v', label: '🛍️ Tanpa Karakter (Objek Saja)', value: 'product_only', icon: 'assets/without_character.png'),
    ],
    'jenis_cerita_video': [
      NeoDropdownOption(id: 'auto_jcv', label: '🤖 AI Pilihkan (Auto)', value: 'auto', helperText: 'AI menentukan jenis cerita paling efektif'),
      NeoDropdownOption(id: 'jcv1', label: '🎭 Narrative / Film Pendek', value: 'narrative', helperText: 'Cerita berurutan dengan karakter dan plot yang jelas'),
      NeoDropdownOption(id: 'jcv2', label: '📚 Edukasi / Tutorial', value: 'edukasi', helperText: 'Menyampaikan informasi dengan cara menarik'),
      NeoDropdownOption(id: 'jcv3', label: '🛍️ Commercial / Iklan', value: 'commercial', helperText: 'Promosi produk atau layanan dengan CTA kuat'),
      NeoDropdownOption(id: 'jcv4', label: '🔥 Viral Hook / Micro Content', value: 'viral_hook', helperText: 'Konten pendek 15-30 detik yang dirancang untuk viral'),
      NeoDropdownOption(id: 'jcv5', label: '🎵 Music Video / Mood Video', value: 'music_video', helperText: 'Visual artistik sinkron dengan musik atau beat'),
      NeoDropdownOption(id: 'jcv6', label: '📖 Documentary Style', value: 'documentary', helperText: 'Pendekatan bertutur seperti film dokumenter'),
    ],
    'lokasi_video': [
      NeoDropdownOption(id: 'auto_lv', label: '🤖 AI Pilihkan (Auto)', value: 'auto', helperText: 'AI memilih setting lokasi paling cocok'),
      NeoDropdownOption(id: 'lv1', label: '🏙️ Urban / Kota Modern', value: 'urban_city', helperText: 'Jalanan kota, gedung tinggi, kehidupan metropolitan'),
      NeoDropdownOption(id: 'lv2', label: '🌿 Alam / Outdoor', value: 'nature_outdoor', helperText: 'Hutan, pantai, pegunungan, landscape alami'),
      NeoDropdownOption(id: 'lv3', label: '🏠 Indoor / Studio', value: 'indoor_studio', helperText: 'Ruangan dalam, studio foto/video, interior modern'),
      NeoDropdownOption(id: 'lv4', label: '🚀 Futuristik / Sci-Fi', value: 'futuristic_scifi', helperText: 'Lab hologram, ruang angkasa, dunia masa depan'),
      NeoDropdownOption(id: 'lv5', label: '🏰 Historical / Period', value: 'historical', helperText: 'Setting era masa lalu, kastil, kota kuno'),
    ],
    'transisi_video': [
      NeoDropdownOption(id: 'auto_tv', label: '🤖 AI Pilihkan (Auto)', value: 'auto', helperText: 'AI memilih transisi terbaik per scene'),
      NeoDropdownOption(id: 'tv1', label: '✂️ Hard Cut', value: 'hard_cut', helperText: 'Potongan langsung, dinamis dan tegas'),
      NeoDropdownOption(id: 'tv2', label: '🌫️ Dissolve / Fade', value: 'dissolve', helperText: 'Transisi halus memudar, cocok untuk emosi lembut'),
      NeoDropdownOption(id: 'tv3', label: '⬛ Fade to Black', value: 'fade_black', helperText: 'Memudar ke hitam, tanda pergantian waktu/adegan besar'),
      NeoDropdownOption(id: 'tv4', label: '💨 Whip Pan / Swipe', value: 'whip_pan', helperText: 'Gerakan cepat kamera kiri-kanan untuk energi tinggi'),
      NeoDropdownOption(id: 'tv5', label: '🔲 Match Cut', value: 'match_cut', helperText: 'Potongan visual yang cocok antara dua adegan berbeda'),
    ],
    'mood_audio_video': [
      NeoDropdownOption(id: 'auto_mav', label: '🤖 AI Pilihkan (Auto)', value: 'auto', helperText: 'AI merekomendasikan suasana musik yang tepat'),
      NeoDropdownOption(id: 'mav1', label: '🎸 Epic / Dramatic', value: 'epic_dramatic', helperText: 'Orkestra megah, penuh tekanan dan dramatis'),
      NeoDropdownOption(id: 'mav2', label: '😎 Chill / Lofi', value: 'chill_lofi', helperText: 'Beat santai, relaks, cocok untuk vlog kasual'),
      NeoDropdownOption(id: 'mav3', label: '⚡ Energetic / Upbeat', value: 'energetic_upbeat', helperText: 'Tempo cepat, semangat tinggi, cocok untuk action/sport'),
      NeoDropdownOption(id: 'mav4', label: '😢 Emotional / Melancholic', value: 'emotional', helperText: 'Piano lembut, sedih, menyentuh hati'),
      NeoDropdownOption(id: 'mav5', label: '🎉 Fun / Playful', value: 'fun_playful', helperText: 'Ceria, ringan, cocok untuk konten anak atau hiburan'),
      NeoDropdownOption(id: 'mav6', label: '🌌 Ambient / Cinematic', value: 'ambient_cinematic', helperText: 'Atmosferik tenang, lebar, mengesankan'),
    ],
  };


  // ─────────────────────────────────────────────────────────
  // Load: SQLite-first (instant), then background revalidate via SyncService
  // ─────────────────────────────────────────────────────────
  Future<void> loadDropdownOptions() async {
    try {
      final localDb = LocalDbService.instance;

      // 1. Serve from SQLite immediately (zero network, instant load)
      final cachedRows = await localDb.getDropdownOptions();
      if (cachedRows.isNotEmpty) {
        final parsed = _parseRawRows(cachedRows);
        if (mounted) {
          state = DropdownState(groups: parsed, isLoading: false);
        }
        return; // Done — SyncService will handle background revalidation
      }

      // 2. No cache yet — fetch from API (first-time install)
      final response = await dioClient.get('/dropdown-options');
      if (response.data['success'] == true) {
        final rawData = response.data['data'] as List;
        final rows = rawData.map((e) => Map<String, dynamic>.from(e as Map)).toList();

        // Save to SQLite for next launch
        await localDb.saveDropdownOptions(rows);

        final parsedGroups = _parseRawRows(rows);
        if (mounted) {
          state = DropdownState(groups: parsedGroups, isLoading: false);
        }
      } else {
        _useFallbackIfEmpty('API returned error');
      }
    } catch (e) {
      _useFallbackIfEmpty(e.toString());
    }
  }

  /// Called by dashboard when SyncService detects new data.
  /// Updates the in-memory state from fresh SQLite data (no network call).
  Future<void> reloadFromLocalDb() async {
    try {
      final cachedRows = await LocalDbService.instance.getDropdownOptions();
      if (cachedRows.isNotEmpty && mounted) {
        final parsed = _parseRawRows(cachedRows);
        state = state.copyWith(groups: parsed, hasUpdate: false);
      }
    } catch (e) {
      debugPrint('[DropdownProvider] reloadFromLocalDb error: $e');
    }
  }

  /// Force refresh: fetch from API, save to SQLite, reload state
  Future<void> forceRefresh() async {
    if (!mounted) return;
    try {
      state = state.copyWith(isLoading: true);
      final response = await dioClient.get('/dropdown-options');
      if (response.data['success'] == true) {
        final rawData = response.data['data'] as List;
        final rows = rawData.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        await LocalDbService.instance.saveDropdownOptions(rows);
        final parsedGroups = _parseRawRows(rows);
        if (mounted) {
          state = DropdownState(groups: parsedGroups, isLoading: false, hasUpdate: false);
        }
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  void _useFallbackIfEmpty(String err) {
    if (state.groups.isEmpty) {
      state = DropdownState(
        groups: offlineFallbacks,
        isLoading: false,
        errorMessage: 'Mode offline. Data lokal digunakan.',
      );
    }
  }

  Map<String, List<NeoDropdownOption>> _parseRawRows(List<Map<String, dynamic>> rawList) {
    final Map<String, List<NeoDropdownOption>> map = {};
    for (final item in rawList) {
      final String group = (item['groupKey'] as String?) ?? '';
      if (group.isEmpty) continue;

      String? icon = item['icon'] as String?;
      if (group == 'fokus_karakter_poster' || group == 'fokus_karakter_video') {
        final val = item['value'] as String? ?? '';
        if (val == 'auto') {
          icon = 'assets/ai_pilihan_auto.png';
        } else if (val == 'random') {
          icon = 'assets/random_choice.png';
        } else if (val == 'product_only') {
          icon = 'assets/without_character.png';
        }
      }

      final option = NeoDropdownOption(
        id: item['id'] as String? ?? '',
        label: item['label'] as String? ?? '',
        value: item['value'] as String? ?? '',
        helperText: item['helperText'] as String?,
        icon: icon,
      );

      if (!map.containsKey(group)) {
        map[group] = [];
      }
      map[group]!.add(option);
    }
    return map;
  }
}

final dropdownProvider = StateNotifierProvider<DropdownNotifier, DropdownState>((ref) {
  return DropdownNotifier();
});
