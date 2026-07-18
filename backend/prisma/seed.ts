import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Seeding database (DROPDOWN + VISUAL STYLES only)...');

  // ══════════════════════════════════════════════════════════════════════════
  // 1. DROPDOWN OPTIONS — Semua fitur dengan helperText bantuan (❓) Bahasa Indonesia
  // ══════════════════════════════════════════════════════════════════════════

  await prisma.dropdownOption.deleteMany();

  const dropdownOptions = [
    // ─────────── POSTER (10 Gaya Desain) ───────────
    { groupKey: 'gaya_poster', label: '🎨 Neubrutalism Modern', value: 'neubrutalism', helperText: '❓ Gaya desain dengan border hitam tebal, warna kontras solid, bayangan tajam geometris. Cocok untuk konten yang ingin tampil bold, raw, dan anti-mainstream. Populer di kalangan Gen-Z dan startup kreatif.', sortOrder: 1 },
    { groupKey: 'gaya_poster', label: '⭐ Premium Product Shot', value: 'premium_product', helperText: '❓ Gaya studio bersih dengan pencahayaan elegan dan komposisi mewah. Ideal untuk poster produk high-end, brand luxury, atau konten yang butuh kesan profesional dan berkelas tinggi.', sortOrder: 2 },
    { groupKey: 'gaya_poster', label: '🧊 3D Clay Isometric', value: 'clay_3d', helperText: '❓ Gaya ilustrasi 3D dengan karakter imut membulat seperti tanah liat (clay). Tampilan isometric modern yang sering dipakai di aplikasi tech, infografis startup, dan konten edukatif yang ramah visual.', sortOrder: 3 },
    { groupKey: 'gaya_poster', label: '🍂 Minimalist Aesthetic', value: 'minimalist', helperText: '❓ Desain bersih dengan warna earth tone (coklat, krem, sage green), banyak ruang kosong (whitespace), dan font tipis elegan. Cocok untuk konten lifestyle, wellness, dan brand yang mengutamakan ketenangan visual.', sortOrder: 4 },
    { groupKey: 'gaya_poster', label: '👾 Retro Vaporwave', value: 'retro_vaporwave', helperText: '❓ Gaya visual dengan nuansa neon ungu/pink, efek glitch, grid perspektif, dan estetika lo-fi tahun 80-an. Cocok untuk konten musik, gaming, atau brand yang ingin tampil unik dan nostalgia futuristik.', sortOrder: 5 },
    { groupKey: 'gaya_poster', label: '🌸 Kawaii Pop Art', value: 'kawaii_pop', helperText: '❓ Gaya ilustrasi imut ala Jepang dengan warna pastel cerah, karakter chibi, elemen dekoratif seperti bintang dan hati. Ideal untuk konten anak-anak, K-beauty, fan merchandise, atau brand yang ceria dan playful.', sortOrder: 6 },
    { groupKey: 'gaya_poster', label: '🖼️ Cinematic Film Still', value: 'cinematic_film', helperText: '❓ Gaya visual sinematik seperti potongan adegan film — pencahayaan dramatis Rembrandt, color grading moody, depth of field yang kuat. Cocok untuk konten storytelling, event premium, atau brand yang ingin kesan emosional mendalam.', sortOrder: 7 },
    { groupKey: 'gaya_poster', label: '💫 Glassmorphism UI', value: 'glassmorphism', helperText: '❓ Desain modern dengan efek kaca buram transparan (frosted glass), blur background, dan border tipis bercahaya. Populer di UI/UX modern, konten teknologi, dan brand digital yang ingin tampil futuristik dan clean.', sortOrder: 8 },
    { groupKey: 'gaya_poster', label: '🎭 Art Deco Luxury', value: 'art_deco', helperText: '❓ Gaya seni dekoratif tahun 1920-an dengan pola geometris simetris, aksen emas/metalik, dan tipografi serif mewah. Cocok untuk undangan premium, event gala, hotel, restoran fine dining, dan brand luxury heritage.', sortOrder: 9 },
    { groupKey: 'gaya_poster', label: '📰 Editorial Magazine', value: 'editorial_magazine', helperText: '❓ Gaya layout majalah profesional dengan grid column yang rapi, tipografi editorial bold, dan komposisi foto berkualitas tinggi. Ideal untuk konten berita, profile bisnis, laporan tahunan, dan brand media.', sortOrder: 10 },

    // ─────────── POSTER: Tata Letak ───────────
    { groupKey: 'tata_letak_poster', label: '🎯 Auto Select', value: 'auto', helperText: '❓ AI akan secara otomatis memilih tata letak terbaik berdasarkan topik dan konten poster Anda. Biarkan AI memutuskan komposisi yang paling optimal.', sortOrder: 1 },
    { groupKey: 'tata_letak_poster', label: '🗂️ Split Layout (Kiri/Kanan)', value: 'split_left_right', helperText: '❓ Membagi poster menjadi dua kolom: satu sisi untuk gambar/visual, sisi lainnya untuk teks. Cocok untuk poster perbandingan, before-after, atau konten yang butuh keseimbangan visual dan teks.', sortOrder: 2 },
    { groupKey: 'tata_letak_poster', label: '🪜 Grid Top-to-Bottom', value: 'grid_top_bottom', helperText: '❓ Layout vertikal bertingkat dari atas ke bawah — header di atas, konten utama di tengah, CTA di bawah. Ideal untuk infografis, carousel feed, dan konten yang butuh urutan informasi jelas.', sortOrder: 3 },
    { groupKey: 'tata_letak_poster', label: '⭕ Focus Center', value: 'focus_center', helperText: '❓ Komposisi terpusat dengan subjek utama di tengah, dikelilingi elemen dekoratif. Cocok untuk poster dengan satu pesan utama, logo reveal, atau konten yang butuh perhatian langsung ke titik fokus.', sortOrder: 4 },

    // ─────────── POSTER: Rasio ───────────
    { groupKey: 'rasio_poster', label: '📱 9:16 (Reels/TikTok/Story)', value: '9:16', helperText: '❓ Format vertikal penuh untuk konten mobile-first. Ideal untuk Instagram Story, TikTok, YouTube Shorts, dan Reels. Ukuran piksel: 1080×1920.', sortOrder: 1 },
    { groupKey: 'rasio_poster', label: '🟦 1:1 (Square Feed)', value: '1:1', helperText: '❓ Format persegi untuk feed Instagram, Facebook, dan LinkedIn. Ukuran standar: 1080×1080. Cocok untuk konten yang butuh keseimbangan visual dan fleksibilitas platform.', sortOrder: 2 },
    { groupKey: 'rasio_poster', label: '📸 4:5 (Portrait Feed)', value: '4:5', helperText: '❓ Format potret untuk feed Instagram yang lebih tinggi dari square. Ukuran: 1080×1350. Memberikan ruang lebih untuk konten vertikal tanpa terlalu panjang.', sortOrder: 3 },
    { groupKey: 'rasio_poster', label: '🖥️ 16:9 (Landscape)', value: '16:9', helperText: '❓ Format landscape widescreen untuk YouTube thumbnail, presentasi, banner website, dan konten desktop. Ukuran: 1920×1080.', sortOrder: 4 },

    // ─────────── BANNER ───────────
    { groupKey: 'gaya_banner', label: '✨ Modern Tech Banner', value: 'modern_tech', helperText: '❓ Gaya teknologi bersih dengan aksen neon, grid digital, dan elemen futuristik. Cocok untuk startup tech, SaaS, event teknologi, atau webinar digital.', sortOrder: 1 },
    { groupKey: 'gaya_banner', label: '🔥 Bold Cyberpunk', value: 'bold_cyberpunk', helperText: '❓ Penuh warna neon kontras tinggi (magenta, cyan, kuning), glitch effect, dan high energy. Untuk brand gaming, esports, event malam, atau konten yang butuh perhatian maksimal.', sortOrder: 2 },
    { groupKey: 'gaya_banner', label: '💼 Corporate Clean', value: 'corporate_clean', helperText: '❓ Desain profesional minimalis dengan warna korporat rapi (biru tua, abu-abu, putih). Ideal untuk perusahaan, bank, konsultan, dan organisasi formal.', sortOrder: 3 },
    { groupKey: 'gaya_banner', label: '💥 Street Pop', value: 'street_pop', helperText: '❓ Tipografi berani, efek cat semprot (spray paint), tekstur grunge jalanan. Cocok untuk brand streetwear, event musik, festival seni, dan konten yang ingin kesan urban & edgy.', sortOrder: 4 },

    { groupKey: 'rasio_banner', label: '🖥️ 16:9 (Web Banner / YouTube Header)', value: '16:9', helperText: '❓ Format standar banner web dan YouTube channel art. Ukuran: 2560×1440 (YouTube) atau 1920×1080 (web banner).', sortOrder: 1 },
    { groupKey: 'rasio_banner', label: '📏 3:1 (Header Website / FB Cover)', value: '3:1', helperText: '❓ Format panoramik horizontal untuk header website dan Facebook Cover Photo. Ukuran: 1500×500 (Twitter header) atau 820×312 (FB).', sortOrder: 2 },
    { groupKey: 'rasio_banner', label: '🟦 1:1 (Square Banner)', value: '1:1', helperText: '❓ Banner persegi untuk platform yang mendukung format square. Cocok untuk iklan display, widget sidebar, dan konten multi-platform.', sortOrder: 3 },

    // ─────────── EDUKASI ───────────
    { groupKey: 'gaya_edukasi', label: '📊 Infographic Clean Grid', value: 'infographic_grid', helperText: '❓ Layout grid teratur dengan ikon-ikon rapi dan penunjuk visual. Ideal untuk data visualization, statistik, step-by-step tutorial, dan konten ilmiah populer.', sortOrder: 1 },
    { groupKey: 'gaya_edukasi', label: '🎨 Hand-drawn Doodle', value: 'doodle_sketch', helperText: '❓ Gaya gambar tangan seperti coretan di papan tulis kapur, sketch artistik dengan panah dan highlights. Cocok untuk konten yang ingin kesan personal, kreatif, dan mudah dipahami.', sortOrder: 2 },
    { groupKey: 'gaya_edukasi', label: '👾 Retro Pixel Art', value: 'pixel_art', helperText: '❓ Gaya visual 8-bit klasik seperti video game retro. Ikon piksel berwarna-warni yang mudah dibaca. Cocok untuk konten tech, gaming trivia, dan edukatif yang ingin tampil fun.', sortOrder: 3 },

    { groupKey: 'rasio_edukasi', label: '📱 9:16 (Infografis Vertikal)', value: '9:16', helperText: '❓ Format vertikal panjang untuk infografis yang bisa di-scroll atau carousel Instagram Story. Ideal untuk konten multi-point yang bertahap.', sortOrder: 1 },
    { groupKey: 'rasio_edukasi', label: '📸 4:5 (Carousel Portrait Feed)', value: '4:5', helperText: '❓ Format potret untuk carousel Instagram feed. Setiap slide berukuran 1080×1350 — memberikan ruang cukup untuk konten edukatif per halaman.', sortOrder: 2 },
    { groupKey: 'rasio_edukasi', label: '🟦 1:1 (Square)', value: '1:1', helperText: '❓ Format persegi standar untuk konten edukatif di semua platform sosial media.', sortOrder: 3 },

    // ─────────── IKLAN AFFILIATE ───────────
    { groupKey: 'gaya_affiliate', label: '🛍️ E-commerce Product Shot', value: 'ecommerce_product', helperText: '❓ Subjek produk di tengah dengan studio terang, label harga yang mencolok, dan elemen trust (rating bintang, badge). Ideal untuk review produk, unboxing highlight, dan konten jualan.', sortOrder: 1 },
    { groupKey: 'gaya_affiliate', label: '⚡ Urgent Flash Sale', value: 'flash_sale', helperText: '❓ Stiker diskon cerah, penuh urgensi visual (timer, "TERBATAS!"), kontras merah/kuning. Cocok untuk flash sale, promo terbatas, dan konten yang butuh FOMO (Fear of Missing Out).', sortOrder: 2 },
    { groupKey: 'gaya_affiliate', label: '⭐ UGC Review Style', value: 'ugc_style', helperText: '❓ Gaya foto review asli pembeli (User Generated Content) — natural, tanpa over-editing. Cocok untuk testimoni produk, before-after, dan konten yang ingin kesan otentik dari pengguna nyata.', sortOrder: 3 },

    { groupKey: 'cta_affiliate', label: '👉 Klik Link di Bio / Deskripsi', value: 'click_bio_link', helperText: '❓ Call-to-Action yang mengarahkan audiens ke link di bio profil atau deskripsi post. Paling umum dipakai di Instagram dan TikTok.', sortOrder: 1 },
    { groupKey: 'cta_affiliate', label: '🔥 Beli Sekarang (Diskon Terbatas!)', value: 'buy_now', helperText: '❓ CTA agresif dengan unsur urgensi — mendorong pembelian langsung dengan highlight diskon yang berlaku terbatas.', sortOrder: 2 },
    { groupKey: 'cta_affiliate', label: '📲 Ambil Promo Spesial Hari Ini', value: 'claim_promo', helperText: '❓ CTA yang menawarkan promo eksklusif hari ini saja. Cocok untuk campaign harian, voucher terbatas, atau early bird offer.', sortOrder: 3 },

    { groupKey: 'rasio_affiliate', label: '📱 9:16 (Story/TikTok)', value: '9:16', helperText: '❓ Format vertikal untuk iklan di Instagram Story dan TikTok. Paling efektif untuk konten video pendek dan swipe-up.', sortOrder: 1 },
    { groupKey: 'rasio_affiliate', label: '🟦 1:1 (Square Feed)', value: '1:1', helperText: '❓ Format persegi untuk feed marketplace dan sosial media. Cocok untuk iklan Shopee, Tokopedia, dan platform e-commerce.', sortOrder: 2 },

    // ─────────── PRODUK DIGITAL ───────────
    { groupKey: 'gaya_digital_product', label: '💻 Software/App Mockup', value: 'software_mockup', helperText: '❓ Mockup layar laptop/tablet/smartphone 3D yang menampilkan tampilan program/aplikasi. Cocok untuk landing page SaaS, demo produk digital, dan portfolio developer.', sortOrder: 1 },
    { groupKey: 'gaya_digital_product', label: '📚 Premium Ebook Cover', value: 'ebook_cover', helperText: '❓ Cover buku digital 3D realistis dengan bayangan elegan dan efek glossy. Ideal untuk promosi ebook, whitepaper, PDF premium, dan lead magnet.', sortOrder: 2 },
    { groupKey: 'gaya_digital_product', label: '🎫 Professional E-course Card', value: 'course_card', helperText: '❓ Kartu kursus online rapi dengan informasi materi lengkap, badge sertifikasi, dan elemen visual edukatif. Cocok untuk promosi kursus Udemy, Skillshare, atau platform e-learning.', sortOrder: 3 },

    { groupKey: 'rasio_digital_product', label: '🟦 1:1 (Square Mockup)', value: '1:1', helperText: '❓ Format persegi untuk mockup produk digital di sosial media dan marketplace kursus.', sortOrder: 1 },
    { groupKey: 'rasio_digital_product', label: '📸 4:5 (Portrait Product Card)', value: '4:5', helperText: '❓ Format potret untuk kartu produk digital yang lebih tinggi — memberikan ruang untuk detail fitur dan pricing.', sortOrder: 2 },

    // ─────────── SPANDUK BALIHO ───────────
    { groupKey: 'gaya_baliho', label: '🏢 High-Impact Billboard', value: 'billboard_modern', helperText: '❓ Desain billboard modern dengan teks raksasa kontras tinggi yang terbaca dari kejauhan. Cocok untuk iklan outdoor, highway billboard, dan branding area publik.', sortOrder: 1 },
    { groupKey: 'gaya_baliho', label: '🕌 Tabligh Akbar / Keagamaan', value: 'religious_event', helperText: '❓ Desain dengan motif ornamen islami, warna hijau/emas elegan, dan kaligrafi Arab. Cocok untuk acara tabligh akbar, pengajian, ramadan, dan event keagamaan lainnya.', sortOrder: 2 },
    { groupKey: 'gaya_baliho', label: '🎪 Event/Festival Megah', value: 'grand_festival', helperText: '❓ Pencahayaan panggung meriah, siluet keramaian, confetti, dan efek sparkle. Ideal untuk festival musik, konser, pameran, dan event besar yang butuh kesan megah dan spektakuler.', sortOrder: 3 },
    { groupKey: 'gaya_baliho', label: '🤝 Baliho Caleg / Politik', value: 'political_billboard', helperText: '❓ Format baliho politik dengan foto formal besar, warna bendera merah putih, nomor urut, dan tagline kampanye. Sesuai standar baliho pemilu Indonesia.', sortOrder: 4 },

    { groupKey: 'rasio_baliho', label: '📏 4:3 (Baliho Standar)', value: '4:3', helperText: '❓ Rasio standar baliho horizontal umum di Indonesia. Ukuran cetak: 3m×4m atau 4m×6m.', sortOrder: 1 },
    { groupKey: 'rasio_baliho', label: '📏 3:4 (Baliho Vertikal)', value: '3:4', helperText: '❓ Rasio baliho vertikal/portrait untuk penempatan di tiang dan struktur vertikal.', sortOrder: 2 },
    { groupKey: 'rasio_baliho', label: '🖥️ 16:9 (Landscape Billboard)', value: '16:9', helperText: '❓ Format landscape widescreen untuk billboard digital modern dan videotron.', sortOrder: 3 },

    // ─────────── LOGO ───────────
    { groupKey: 'gaya_logo', label: '💎 Minimalist Luxury Logo', value: 'minimalist_luxury', helperText: '❓ Logo satu garis tipis (monoline) atau geometris sederhana dengan warna emas/perak. Cocok untuk brand fashion, perhiasan, real estate, dan bisnis premium.', sortOrder: 1 },
    { groupKey: 'gaya_logo', label: '🐯 Mascot / Cartoon Brand', value: 'mascot_brand', helperText: '❓ Karakter maskot kartun 2D bergaris tebal dan ceria. Ideal untuk brand F&B, gaming, edukasi anak, dan bisnis yang ingin kesan fun dan memorable.', sortOrder: 2 },
    { groupKey: 'gaya_logo', label: '✏️ Hand-drawn Vintage Badge', value: 'vintage_badge', helperText: '❓ Gaya emblem klasik bertekstur kasar/retro, seperti stempel atau badge jadul. Cocok untuk brand kopi artisan, barbershop, brewery, dan bisnis dengan sentuhan heritage.', sortOrder: 3 },
    { groupKey: 'gaya_logo', label: '🔤 Modern Wordmark / Typographic', value: 'wordmark', helperText: '❓ Logo berbasis modifikasi huruf nama brand — fokus pada tipografi kreatif. Cocok untuk startup teknologi, media digital, dan brand yang namanya sudah kuat.', sortOrder: 4 },

    // ─────────── KATA MUTIARA (QUOTES) ───────────
    { groupKey: 'gaya_quotes', label: '🍂 Aesthetic Earth Tone Typography', value: 'aesthetic_quotes', helperText: '❓ Warna kalem earth tone (coklat, krem, sage), font serif cantik, layout minimalis. Untuk quotes inspiratif, motivasi harian, dan konten self-care.', sortOrder: 1 },
    { groupKey: 'gaya_quotes', label: '🕌 Islamic Gold Calligraphy', value: 'islamic_quotes', helperText: '❓ Kaligrafi indah dengan aksen emas, background islami gelap, dan ornamen arabesque. Cocok untuk quotes Quran, hadist, doa harian, dan konten dakwah.', sortOrder: 2 },
    { groupKey: 'gaya_quotes', label: '🌌 Deep Space / Philosophical', value: 'galaxy_quotes', helperText: '❓ Latar belakang galaksi/bintang/nebula, font sans-serif tipis, dan nuansa kosmik. Ideal untuk quotes filosofis, eksistensial, dan konten mendalam yang introspektif.', sortOrder: 3 },

    { groupKey: 'tema_quotes', label: '💪 Motivasi & Sukses', value: 'motivation', helperText: '❓ Tema seputar semangat, kerja keras, pencapaian, dan kesuksesan. Cocok untuk akun motivasi, entrepreneur, dan personal branding.', sortOrder: 1 },
    { groupKey: 'tema_quotes', label: '❤️ Cinta & Hubungan', value: 'love', helperText: '❓ Tema romantis, persahabatan, keluarga, dan kasih sayang. Ideal untuk akun quote romantis, wedding, dan konten relationship.', sortOrder: 2 },
    { groupKey: 'tema_quotes', label: '🌱 Kehidupan & Filsafat', value: 'life', helperText: '❓ Tema kebijaksanaan hidup, renungan mendalam, dan pandangan filosofis. Untuk akun quotes wisdom, self-reflection, dan personal growth.', sortOrder: 3 },
    { groupKey: 'tema_quotes', label: '🕌 Keagamaan & Spiritual', value: 'religious', helperText: '❓ Tema keagamaan, ketuhanan, ibadah, dan spiritualitas. Cocok untuk akun dakwah, reminder sholat, dan konten islami.', sortOrder: 4 },

    { groupKey: 'rasio_quotes', label: '📱 9:16 (Quotes Story/Reels)', value: '9:16', helperText: '❓ Format vertikal untuk quotes di Instagram Story dan Reels.', sortOrder: 1 },
    { groupKey: 'rasio_quotes', label: '🟦 1:1 (Quotes Square Feed)', value: '1:1', helperText: '❓ Format persegi untuk quotes di feed Instagram dan Twitter.', sortOrder: 2 },

    // ─────────── GLOBAL / GENERAL OPTIONS ───────────
    { groupKey: 'palet_warna', label: '🌈 Auto (AI Choice)', value: 'auto', helperText: '❓ AI akan secara otomatis memilih kombinasi warna terbaik berdasarkan topik, gaya, dan mood poster Anda. Pilihan paling fleksibel.', sortOrder: 1 },
    { groupKey: 'palet_warna', label: '🧁 Pastel Soft', value: 'pastel', helperText: '❓ Palet warna lembut seperti baby pink, lavender, mint green, dan cream. Kesan tenang, feminine, dan aesthetic. Cocok untuk konten beauty, lifestyle, dan anak-anak.', sortOrder: 2 },
    { groupKey: 'palet_warna', label: '🔥 Neon Vibrant', value: 'neon', helperText: '❓ Warna neon cerah dan mencolok — electric blue, hot pink, lime green, cyber yellow. Kesan energik, futuristik, dan attention-grabbing. Cocok untuk konten gaming, event, dan promo.', sortOrder: 3 },
    { groupKey: 'palet_warna', label: '🪨 Earth Tone', value: 'earth_tone', helperText: '❓ Warna natural dari alam — coklat tanah, sage green, terracotta, sand beige. Kesan hangat, organik, dan premium. Cocok untuk konten F&B, fashion, dan interior.', sortOrder: 4 },
    { groupKey: 'palet_warna', label: '🖤 Monochrome Dark', value: 'monochrome_dark', helperText: '❓ Palet hitam-putih-abu dengan aksen metalik. Kesan elegant, mysterious, dan luxury. Cocok untuk konten premium, fashion high-end, dan brand eksklusif.', sortOrder: 5 },

    { groupKey: 'nuansa_mood', label: '☀️ Siang / Ceria', value: 'bright_cheerful', helperText: '❓ Nuansa terang, optimis, dan energik. Background cerah, warna-warna warm, dan pencahayaan golden hour. Cocok untuk konten positif dan brand yang ramah.', sortOrder: 1 },
    { groupKey: 'nuansa_mood', label: '🌙 Gelap / Dramatis', value: 'dark_dramatic', helperText: '❓ Nuansa gelap dengan kontras tinggi, bayangan dalam, dan pencahayaan spotlight. Kesan misterius, kuat, dan premium. Cocok untuk konten luxury, horor, dan brand premium.', sortOrder: 2 },
    { groupKey: 'nuansa_mood', label: '✨ Elegan & Profesional', value: 'elegant_professional', helperText: '❓ Nuansa refined dengan warna netral, aksen emas/perak, dan komposisi simetris. Kesan terpercaya dan berkelas. Cocok untuk konten bisnis, korporat, dan brand mewah.', sortOrder: 3 },

    { groupKey: 'aturan_teks', label: '🔒 Strict (Presisi)', value: 'strict', helperText: '❓ AI akan sangat patuh pada teks yang Anda tulis — setiap kata, kalimat, dan placement dipertahankan persis. Cocok jika Anda sudah punya copywriting final yang tidak boleh diubah.', sortOrder: 1 },
    { groupKey: 'aturan_teks', label: '🔓 Flexible (Bebas)', value: 'flexible', helperText: '❓ AI bebas menyesuaikan, mempersingkat, atau mengembangkan teks Anda agar lebih cocok dengan desain visual. Cocok jika Anda ingin AI membantu menyusun kata-kata terbaik.', sortOrder: 2 },

    { groupKey: 'fokus_karakter', label: '🎲 Random / Kontekstual', value: 'random', helperText: '❓ AI akan memilih karakter/persona yang paling sesuai dengan topik poster secara otomatis — bisa manusia, hewan, maskot, atau objek.', sortOrder: 1 },
    { groupKey: 'fokus_karakter', label: '🛍️ Tanpa Karakter (Objek Saja)', value: 'product_only', helperText: '❓ Poster tanpa karakter/manusia — hanya fokus pada objek, produk, tipografi, dan elemen dekoratif. Cocok untuk poster produk dan konten text-heavy.', sortOrder: 2 },

    // ─────────── ENHANCE PHOTO ───────────
    { groupKey: 'enhance_style', label: '🇰🇷 K-pop / Korea Aesthetic', value: 'kpop_aesthetic', helperText: '❓ Transformasi foto dengan gaya Korea — glass skin halus, mata puppy, bibir gradient, blush natural, dan kulit porcelain bercahaya. Populer di kalangan Gen-Z dan beauty enthusiast.', sortOrder: 1 },
    { groupKey: 'enhance_style', label: '📸 Professional Headshot', value: 'professional_headshot', helperText: '❓ Retouching foto profil profesional — background netral, fokus tajam pada wajah, skin retouching halus, dan ekspresi percaya diri. Cocok untuk LinkedIn, CV, dan kartu nama.', sortOrder: 2 },
    { groupKey: 'enhance_style', label: '🎬 Cinematic Portrait', value: 'cinematic_portrait', helperText: '❓ Pencahayaan dramatis ala film — Rembrandt lighting, bayangan dalam, film grain, dan color grading moody. Untuk foto editorial, portfolio model, dan konten premium.', sortOrder: 3 },
    { groupKey: 'enhance_style', label: '🦾 Cyberpunk Mech', value: 'cyberpunk_mech', helperText: '❓ Overlay holografik neon, tatto sirkuit digital, implan mekanis, dan glow electric blue/magenta. Transformasi kreatif penuh untuk konten sci-fi dan gaming.', sortOrder: 4 },

    { groupKey: 'change_level', label: '🌱 Natural (Halus & Tetap Mirip)', value: 'natural', helperText: '❓ Perubahan sangat halus — identitas dan kemiripan wajah dipertahankan. Hanya perbaikan minor seperti skin smoothing, brightness, dan detail mata. Hasil tetap terlihat natural.', sortOrder: 1 },
    { groupKey: 'change_level', label: '⚡ Medium (Menambah Detail Visual)', value: 'medium', helperText: '❓ Peningkatan noticeable namun tetap realistis — perbaikan kulit, pencahayaan, background, dan detail pakaian. Wajah masih recognizable tapi lebih polished.', sortOrder: 2 },
    { groupKey: 'change_level', label: '🚀 High (Perubahan Kreatif Penuh)', value: 'high', helperText: '❓ Transformasi kreatif penuh — background bisa berubah total, gaya visual berubah drastis, elemen fantasi ditambahkan. Hasil bisa sangat berbeda dari foto asli.', sortOrder: 3 },
  ];

  for (const option of dropdownOptions) {
    await prisma.dropdownOption.create({ data: option });
  }
  console.log(`✅ Seeded ${dropdownOptions.length} dropdown options`);

  // ══════════════════════════════════════════════════════════════════════════
  // 2. VISUAL STYLES — 15 Gaya Visual dengan Prompt Template Super Detail
  // ══════════════════════════════════════════════════════════════════════════

  await prisma.visualStyle.deleteMany();
  await prisma.visualStyle.createMany({
    data: [
      {
        name: 'Studio Portrait',
        promptTemplate: `Photorealistic studio portrait photography with professional multi-point studio lighting setup. Key light: large octabox at 45-degree angle from camera-right creating a soft, diffused wraparound illumination on the subject's face. Fill light: silver reflector at camera-left reducing shadow density to a 2:1 ratio. Hair light: strip softbox positioned behind and above subject creating a subtle rim separation from the clean, seamless solid color background (choose between: pure white #FFFFFF, dove gray #B0B0B0, or matte charcoal #2C2C2C based on subject skin tone). Lens specification: 85mm prime lens at f/2.8 aperture creating a beautifully shallow depth of field that isolates the subject. The skin texture must be rendered with extreme photorealistic fidelity — visible pore detail, natural subsurface scattering, individual hair strands, and micro-highlights on the skin's surface. Color science: calibrated to Rec.709 with neutral white balance (5500K daylight), ensuring accurate skin reproduction across all ethnicities. Post-processing style: minimal retouching preserving natural beauty, slight eye sharpening, teeth whitening if visible, and subtle dodging/burning for three-dimensional facial contouring. Resolution target: 8K (7680×4320) with 16-bit color depth for maximum tonal range. Output must evoke the quality of a Peter Hurley or Annie Leibovitz corporate portrait session.`,
        previewImageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
        isActive: true,
      },
      {
        name: 'Neubrutalism Poster',
        promptTemplate: `Neubrutalism graphic design poster style — the defining aesthetic of modern anti-design movement. Visual characteristics: extremely thick black outlines (minimum 4-6px stroke) on every element creating a raw, unpolished digital collage feel. Color palette: limited to 4-5 maximum high-contrast stark colors — choose combinations like electric yellow (#FFE500) + hot coral (#FF6B6B) + cobalt blue (#0047AB) + pure white (#FFFFFF) on jet black (#000000). Typography: oversized display fonts occupying 30-40% of the canvas — use brutalist typefaces like Clash Display, Space Grotesk, or Archivo Black. All text should feel intentionally "too big" and uncomfortable. Layout rules: intentionally "broken" grid with overlapping elements, misaligned columns, and asymmetric spacing that creates visual tension. Shadow treatment: hard-edged drop shadows (offset: 6-8px right, 6-8px down) in solid black — absolutely NO soft gradients, NO gaussian blur, NO smooth transitions. Background textures: subtle paper grain or noise overlay at 5-10% opacity to add tactile quality. Decorative elements: geometric shapes (circles, rectangles, triangles) with thick outlines scattered as accent pieces, hand-drawn arrow doodles, asterisk marks (✦ ★ ※), and rubber stamp effects. The overall composition must feel like a digital punk zine — loud, intentional, unapologetically raw, and impossible to ignore. Every element must have a thick visible border. Anti-aesthetic is the aesthetic.`,
        previewImageUrl: 'https://images.unsplash.com/photo-1542744094-3a31f103e35f',
        isActive: true,
      },
      {
        name: '3D Isometric Render',
        promptTemplate: `Professional isometric 3D render scene with clay-style character models and environmental objects. Rendering engine aesthetic: Blender Cycles or Cinema 4D Octane — clean, noise-free global illumination with soft ambient occlusion shadows (AO radius: 0.5m, intensity: 30%). Material specification: smooth matte clay/plastic finish with subtle subsurface scattering on character skin, no harsh specular highlights — the overall feel should be friendly, approachable, and modern tech illustration. Camera setup: true isometric projection at precisely 30-degree elevation angle with orthographic lens (no perspective distortion). Color palette: vibrant yet harmonious pastel colors — baby blue (#A8D8EA), soft coral (#FFB7B2), mint green (#B5EAD7), lavender (#C7CEEA), warm peach (#FFDAC1) — with darker complementary tones for depth. Character design: rounded proportions (chibi-like 1:3 head-to-body ratio), simple geometric facial features (dot eyes, small triangle nose, curved smile line), smooth limbs without detailed fingers. Environmental objects: miniature world setup with tiny buildings, devices, plants, furniture — all with rounded edges (bevel: 2px minimum) and the same clay material. Lighting: single soft directional light at 60° elevation from upper-left, casting gentle shadows (shadow softness: 80%), with a subtle blue fill light from lower-right for depth. Scene composition: diorama on a floating platform or circular pedestal with subtle floating particles. Resolution: 4K minimum, anti-aliased, with transparent or gradient pastel background.`,
        previewImageUrl: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe',
        isActive: true,
      },
      {
        name: 'Flat Vector Illustration',
        promptTemplate: `Flat vector illustration style with perfectly clean, precise geometric shapes and zero three-dimensional depth cues. Design language: contemporary corporate tech illustration inspired by Slack, Notion, Dropbox brand illustrations. Line work: NO visible outlines on primary shapes — forms are defined purely by color contrast and adjacency. Color system: harmonious dual-tone or tri-tone palette with max 5 colors total — primary brand color (60%), secondary accent (25%), neutral (10%), highlight (5%). Suggested palettes: [Deep Indigo #3730A3 + Warm Amber #F59E0B + Soft Gray #F3F4F6] or [Forest Teal #0D9488 + Coral Pink #FB7185 + Cream #FEF3C7]. Character style: friendly, abstract human figures with simple oval heads, cylindrical limbs, and minimal facial features (single dot eyes, no nose, small arc smile). Proportions should be slightly elongated (6-7 head heights) for a sophisticated feel. Body language and poses must clearly communicate the intended message. Background: solid flat color or very subtle gradient (max 10% opacity shift). Composition: clean with generous whitespace, elements arranged on an invisible grid with consistent spacing units (8px baseline grid). Decorative elements: small geometric accents (circles, semicircles, wavy lines, dots) floating as supporting visual rhythm. NO textures, NO shadows, NO gradients deeper than 10%, NO photographic elements. The illustration must feel modern, inclusive, approachable, and scalable to any size without loss of quality — true vector aesthetic.`,
        previewImageUrl: 'https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5',
        isActive: true,
      },
      {
        name: 'Cinematic Film Look',
        promptTemplate: `Cinematic film still photography with Hollywood-grade production value and dramatic visual storytelling. Lighting: three-point cinematic lighting with a powerful key light creating chiaroscuro contrast (ratio 4:1 minimum), practical motivational lights in scene (neon signs, desk lamps, window light), and atmospheric volumetric haze/fog catching light beams. Lens: anamorphic 40mm equivalent with characteristic oval bokeh, horizontal lens flares, and subtle barrel distortion at frame edges. Color grading: teal-and-orange complementary color scheme (shadows pushed toward #1B4965 teal, highlights warmed to #F4845F amber) with crushed blacks (lift shadows to 5-10 IRE for that filmic look). Film emulation: Kodak Vision3 500T tungsten stock characteristics — visible but pleasing grain structure (ISO 800 equivalent), slight halation around bright highlights, and rich mid-tone color saturation. Depth of field: shallow (f/1.4-2.0 equivalent) with sharp focus on primary subject and smooth bokeh falloff. Composition: rule of thirds with leading lines, frame-within-frame techniques, and negative space used for tension. Aspect ratio: 2.39:1 CinemaScope letterbox. The frame must feel like a pause button on a Villeneuve, Fincher, or Deakins-shot film — every element placed with intentional narrative purpose. Post: slight vignetting at corners, subtle lens breathing simulation. 8K resolution with 10-bit color depth.`,
        previewImageUrl: 'https://images.unsplash.com/photo-1536440136628-849c177e76a1',
        isActive: true,
      },
      {
        name: 'Watercolor Painting',
        promptTemplate: `Traditional watercolor painting artwork with authentic wet-on-wet and wet-on-dry techniques beautifully reproduced in digital format. Brush characteristics: visible brush strokes with organic edge bleeding where pigment naturally diffuses into damp paper — hard edges where paint meets dry paper, soft feathered edges where wet areas merge. Color behavior: transparent color layering with visible paper texture showing through washes, granulation effects in heavier pigments (ultramarine blue, burnt sienna), and beautiful cauliflower/bloom effects where wet areas meet at different moisture levels. Paper simulation: cold-pressed watercolor paper texture (Arches 300gsm equivalent) with visible tooth/grain, slight cockling/warping at heavily saturated areas. Palette: limited harmonious palette of 5-7 pigments maximum — suggest combinations like Quinacridone Rose + Yellow Ochre + Ultramarine Blue + Burnt Sienna + Sap Green for naturalistic work, or Turquoise + Coral + Gold Ochre for contemporary feel. White areas: preserved paper white (no white paint) — planning and negative painting techniques to maintain highlights. Atmospheric perspective: distant elements rendered with increasingly dilute washes and cooler colors. Splash and spatter effects: controlled ink splatter and salt-crystal texture effects in select areas for visual interest. The final artwork must be indistinguishable from a genuine hand-painted watercolor by a skilled artist — no digital perfection, embrace the beautiful imperfections and happy accidents that define the medium.`,
        previewImageUrl: 'https://images.unsplash.com/photo-1513364776144-60967b0f800f',
        isActive: true,
      },
      {
        name: 'Retro 80s Synthwave',
        promptTemplate: `Retro 80s Synthwave/Retrowave aesthetic — the ultimate nostalgia-futurism visual experience. Background: infinite perspective grid stretching to the horizon on a flat neon-lit plane, converging to a vanishing point where a massive setting sun (gradient from hot magenta #FF006E at top through electric orange #FF6700 to golden yellow #FFD600 at base) sits on the horizon line. Sky: deep space backdrop in rich dark purples (#1A0533) and midnight blues (#0D1B2A) with scattered stars and distant nebula clouds in pink and cyan. Grid: glowing neon lines in cyan (#00FFFF) or hot pink (#FF1493) with slight bloom/glow effect — lines perfectly straight on the horizontal, converging on the vertical toward the vanishing point. Typography: chrome metallic 3D text with horizontal line scan effects, bright neon glow halos, and retro script fonts (Brush Script, Signatra, or custom chrome lettering). Decorative elements: palm tree silhouettes backlit by the sunset, DeLorean-style sports car, chrome geometric shapes (triangles, hexagons), VHS scan lines and chromatic aberration effects. Color temperature: exclusively neon palette — cyan (#00FFFF), magenta (#FF00FF), hot pink (#FF1493), electric purple (#BF00FF), sunset orange (#FF4500), chrome silver. Atmospheric effects: horizontal lens flares, light leak overlays in pink/orange, subtle CRT monitor scanline overlay. Music visualization: optional audio waveform or equalizer bars as decorative elements. The entire composition must evoke the feeling of driving a Lamborghini Countach through a digital sunset in 1987.`,
        previewImageUrl: 'https://images.unsplash.com/photo-1550745165-9bc0b252726f',
        isActive: true,
      },
      {
        name: 'Dark Moody Editorial',
        promptTemplate: `Dark moody editorial photography and design with luxury magazine production quality. Lighting philosophy: dramatic low-key lighting with a single concentrated light source — Rembrandt or split lighting creating deep, sculpted shadows that carve dimension into every surface. Key light: small, focused source (beauty dish or gridded strobe) positioned at steep angle (60-75° from camera axis) creating sharp shadow transitions. Fill: minimal to none — embrace deep shadows with shadow areas falling to near-black (5-10 IRE) while highlights remain controlled and never clipped. Background: solid deep black (#0A0A0A to #1A1A1A) or very dark moody gradient (dark charcoal to black). Color grading: desaturated palette with selective color emphasis — muted earth tones, aged gold (#B8860B), deep burgundy (#4A0E0E), forest green (#1B3A2D) as accent colors against predominantly monochromatic shadows. Skin rendering: detailed texture preservation with editorial retouching — visible skin pores, subtle shine on highlight areas, no plastic smoothing. Contrast: extremely high with controlled midtone separation — the histogram should show strong bimodal peaks at shadows and highlights with sparse midtones. Typography integration: elegant serif typefaces (Playfair Display, Cormorant, Didot) in thin weights, tracking-wide caps, positioned with generous negative space. Composition: asymmetric with intentional large dark areas as visual breathing room. Texture overlays: subtle film grain (Kodak Tri-X 400 equivalent), slight dust particle floaters in light beams. Resolution: 8K with deep shadow detail preserved. The aesthetic must feel like a Vogue Italia or Dazed Magazine editorial spread shot by Paolo Roversi.`,
        previewImageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d',
        isActive: true,
      },
      {
        name: 'Kawaii Chibi Cute',
        promptTemplate: `Kawaii Japanese chibi illustration style — maximum cuteness with rounded, deformed character proportions and expressive faces. Character design: chibi proportions with 1:1 or 1:2 head-to-body ratio, oversized round head (50%+ of total height), huge sparkling eyes with double-highlight catchlights (large white circle + small white dot), tiny dot nose or no nose, small rounded body, stubby limbs with mitten-like hands. Expression range: blushing cheeks (permanent pink circular blush marks), sparkle effects (✧) around excited characters, sweat drop for nervousness, steam puff for anger, heart eyes for love. Line work: clean, consistent weight outlines (2-3px) in dark color (not pure black — use dark brown #3D2B1F or dark navy #1B2838 for softer feel). Color palette: bright, saturated pastel colors — sakura pink (#FFB7C5), sky blue (#87CEEB), lemon yellow (#FFF44F), mint (#98FB98), lavender (#E6E6FA), peach (#FFDAB9). Shading: minimal cel-shading with one shadow layer at 10-15% darker than base color, no complex gradients. Background: solid pastel color or simple pattern (polka dots, stars, hearts, stripes) — never complex or photographic. Decorative elements: floating hearts, stars, sparkles, musical notes, small flowers, cloud shapes, rainbow arcs. Food and objects: also rendered in kawaii style with faces (smiling onigiri, blushing strawberry, winking coffee cup). The overall feeling must evoke Japanese stationery design, Sanrio characters, or Line Friends — irresistibly cute, clean, and instantly smile-inducing. Resolution: vector-crisp at any size.`,
        previewImageUrl: 'https://images.unsplash.com/photo-1509281373149-e957c6296406',
        isActive: true,
      },
      {
        name: 'Luxury Gold Foil',
        promptTemplate: `Ultra-premium luxury design with real gold foil stamping effects and high-end material textures. Primary material: authentic gold foil texture — not flat gold color, but genuine hot-stamped foil with visible micro-wrinkles, slight surface irregularities, and brilliant specular reflections that shift with viewing angle (simulate holographic foil behavior). Gold spectrum: offer variations from warm yellow gold (#FFD700, #DAA520), rose gold (#B76E79, #E8B4B8), to champagne gold (#F7E7CE) and white gold/platinum (#E5E4E2). Background substrates: deep matte black (#0D0D0D) for maximum gold contrast, navy blue (#0A1628), forest green (#0B3B2D), burgundy (#3C0919), or heavyweight cream cotton paper (#FFF8F0) with visible fiber texture. Typography: elegant high-contrast serif fonts (Didot, Bodoni, Playfair Display) with ultra-thin hairlines that showcase the foil effect — mix foil text with embossed/debossed blind stamp effects. Foil application: simulate different foil techniques — hot stamping (crisp metallic), cold foil (slightly softer edges), foil blocking on textured stock (foil conforming to paper grain). Supporting elements: thin gold foil geometric borders, ornamental corner pieces, delicate filigree patterns, laurel wreaths, monogram frames. Embossing simulation: raised blind emboss effects on non-foiled elements creating subtle shadow-only patterns visible through light angle changes. Edge treatment: gilt edges (thin gold line on card/page edges), beveled corners. Print finishing: spot UV gloss on select elements creating contrast between matte and glossy surfaces. The design must feel like holding a $500 wedding invitation or a Cartier product card — every detail screams exclusivity and craftsmanship. 8K resolution with HDR highlight rendering for foil reflections.`,
        previewImageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30',
        isActive: true,
      },
      {
        name: 'Comic Book Pop Art',
        promptTemplate: `Bold comic book Pop Art style inspired by Roy Lichtenstein, classic Marvel/DC Silver Age comics, and contemporary graphic novel aesthetics. Rendering technique: Ben-Day dots pattern (halftone dots at varying sizes for tonal simulation — small dots for light areas, large overlapping dots for shadows) visible at normal viewing distance as a signature Pop Art texture. Color palette: strictly limited CMYK comic print colors — primary red (#FF0000), primary blue (#0000FF), primary yellow (#FFFF00), black (#000000), and white — mixed through dot overlay to create secondary colors (orange, green, purple). Line work: bold black ink outlines with confident, variable stroke weight — thicker on outer contours (4-6px), thinner on interior details (1-2px), with dynamic brush-like quality suggesting hand-inking with a crow quill or brush pen. Speech bubbles: classic comic balloon shapes with bold text in ALL CAPS using comic book fonts (Comic Sans alternative: Bangers, Comic Neue, or Action Man). Sound effects: large onomatopoeia text (POW! ZAP! BOOM! CRASH!) rendered as explosive 3D block letters with speed lines and impact starbursts. Panel layout: comic book grid panels with thick black gutters, dynamic diagonal panel breaks for action sequences. Dramatic elements: speed lines radiating from action center, motion blur streaks, kirby dots/crackle energy effects, dramatic spotlighting with solid black shadow areas. Character rendering: heroic proportions, exaggerated expressions, dynamic action poses. Background: flat color fields or simple radiating line patterns. The artwork must feel like a premium limited-edition comic book cover or a Lichtenstein gallery piece — bold, graphic, and instantly iconic.`,
        previewImageUrl: 'https://images.unsplash.com/photo-1612036782180-6f0b6cd846fe',
        isActive: true,
      },
      {
        name: 'Botanical Illustration',
        promptTemplate: `Scientific botanical illustration style combining artistic beauty with naturalistic accuracy — inspired by the golden age of botanical art (Maria Sibylla Merian, Pierre-Joseph Redouté, Ernst Haeckel). Rendering technique: highly detailed hand-rendered illustration using layered transparent watercolor washes built up from light to dark, with fine detail work added in gouache, colored pencil, or ink for precision. Each leaf vein, petal texture, stamen hair, and bark pattern rendered with scientific accuracy. Color approach: naturalistic plant colors reproduced with botanical precision — chlorophyll greens (mixing sap green, hooker's green, yellow ochre for variety), petal colors in full chromatic range, stem and bark browns with subtle warm/cool temperature shifts. Background: clean white or off-white (parchment #FFF8DC) — traditional botanical illustration convention leaving subject floating on blank page for clarity of form. Composition: specimen-style arrangement showing the plant from multiple angles — whole plant habit, individual flower detail (cross-section if relevant), fruit/seed detail, root system. Labeling style: optional fine italic handwritten botanical nomenclature (Latin binomial name) in a classic serif font positioned discretely. Lighting: consistent soft directional light from upper-left (botanical convention) creating gentle shadows for three-dimensional form without harsh contrast. Additional details: dewdrops on leaves with refracted light, visiting pollinators (butterflies, bees) rendered with equal precision, seasonal progression if carousel format. Paper texture: subtle cold-pressed watercolor paper grain visible in wash areas. The illustration must meet the standard of a Kew Gardens or Smithsonian natural history collection botanical plate — simultaneously scientifically informative and breathtakingly beautiful as wall art.`,
        previewImageUrl: 'https://images.unsplash.com/photo-1490750967868-88aa4f44baee',
        isActive: true,
      },
      {
        name: 'Glassmorphism Modern',
        promptTemplate: `Glassmorphism UI design aesthetic — the premium frosted glass effect that defines modern digital interface design (Apple VisionOS, iOS, macOS). Glass panel properties: semi-transparent background (rgba(255,255,255,0.15) to rgba(255,255,255,0.25) for light mode, rgba(0,0,0,0.2) to rgba(0,0,0,0.4) for dark mode) with strong backdrop-filter blur (blur radius: 20-40px) creating a frosted glass diffusion effect that renders background colors and shapes as soft, dreamy bokeh. Border treatment: 1px semi-transparent border (rgba(255,255,255,0.3)) on glass edges creating a subtle light refraction line — critical for glass panel visibility. Shadow: soft multi-layered drop shadow (0 8px 32px rgba(0,0,0,0.12)) for floating elevation. Background requirement: vibrant gradient or abstract colorful background BEHIND the glass — mesh gradient using 3-4 colors (e.g., deep purple #7C3AED → ocean blue #2563EB → teal #14B8A6 → warm amber #F59E0B) creating the colorful substrate that the glass effect diffracts. Typography: clean sans-serif (SF Pro, Inter, or Outfit) in white or very light text on glass for readability, with subtle text-shadow for contrast. Hierarchy: multiple glass layers at different depths creating z-axis parallax — primary content on top glass, secondary on middle, decorative on back. Interactive elements: glass-style buttons with hover states that increase brightness/opacity, glass cards with subtle transform: scale(1.02) on hover. Icons: thin-line icons (Phosphor, Feather) in white/light with optional colorful gradient fills. Decorative: floating abstract 3D shapes (spheres, torus, blobs) with glossy material scattered in the background behind glass panels. The overall composition must feel like Apple's design language — premium, airy, spacious, and cutting-edge futuristic. Resolution: 4K+ for crisp glass edge rendering.`,
        previewImageUrl: 'https://images.unsplash.com/photo-1557672172-298e090bd0f1',
        isActive: true,
      },
      {
        name: 'Low-Poly Geometric',
        promptTemplate: `Low-poly geometric art style — the angular, faceted 3D aesthetic that transforms subjects into crystalline polygon sculptures. Mesh construction: triangulated polygon mesh with intentionally low polygon count (500-2000 faces for characters, 200-800 for objects) — each triangle face rendered as a flat-shaded plane with distinct color, creating the signature faceted diamond-like appearance. NO smooth shading, NO subdivision surface — every polygon face must be individually visible and flat. Color approach: each polygon face assigned a single flat color — adjacent faces differ by 5-15% brightness/hue creating a stained-glass mosaic effect. Color palette options: gradient spectrum across the mesh (cool blues/purples transitioning to warm oranges/pinks), monochromatic with value shifts, or nature-inspired (forest greens, ocean blues, sunset spectrums). Lighting model: simple directional light creating clear distinction between lit faces (brighter) and shadow faces (darker) — the light angle choice determines the entire mood of the piece. Edges: optionally show thin wireframe edges in slightly darker color for added geometric emphasis, or leave edges invisible for cleaner look. Background: complementary gradient or solid color — can include scattered geometric particles (floating triangles, diamonds, circles) as decorative elements. Composition: dramatic angles and perspectives that emphasize the geometric nature — three-quarter views, low angle hero shots. Material variation: can mix transparent/glass polygon sections with opaque sections for visual interest. Applications: character portraits where facial features are recognizable despite geometric abstraction, landscape panoramas with layered polygon mountains, animal figures with dynamic poses. Environment: optional floating platform, scattered polygon fragments as if the subject is assembling or disassembling. Resolution: crisp vector-like rendering where every polygon edge is razor-sharp. The result should feel like a premium video game concept art or modern gallery installation piece.`,
        previewImageUrl: 'https://images.unsplash.com/photo-1558618666-fcd25c85f82e',
        isActive: true,
      },
      {
        name: 'Grunge Street Art',
        promptTemplate: `Raw grunge street art aesthetic — the authentic visual language of urban culture, underground music, and guerrilla art movements. Surface texture: distressed concrete wall, weathered brick, peeling paint layers, rusted metal sheet, or wheat-pasted poster on rough urban surface — the substrate IS part of the art, showing through torn and worn areas. Technique mix: multi-medium layered approach combining spray paint stencil work (Banksy-style sharp stencil edges with overspray halo), freehand graffiti lettering, wheat-paste collage elements, screen-printed graphics, and hand-drawn marker/paint pen details. Color palette: limited but impactful — predominantly monochromatic (black, white, grays from the concrete) with 1-2 strategic accent colors in vivid spray paint (emergency red #FF0000, hazard yellow #FFD600, electric blue #0066FF, or toxic green #39FF14) for focal points. Typography: mixed chaotic type treatments — hand-painted brush lettering, stencil spray caps, marker scrawl, ripped magazine letter collage (ransom note style), vintage typewriter text. Distress effects: paint drips running down from text and images, scratch marks revealing layers underneath, faded/sun-bleached areas, splatter marks from thrown paint, tape residue, staple holes from posted flyers. Composition: anti-compositional — deliberately breaking grid rules, overlapping layers of different dates and artists (palimpsest effect), tags and throws partially covering older work. Imagery: stenciled icons (doves, rats, gas masks, fists, eyes), documentary-style photographs printed on newsprint, political symbols, underground music flyers. Aging: simulate natural weathering — rain streaks, bird droppings (subtle), UV fading, and edge peeling on pasted elements. The result must feel like an authentic photograph of a legendary street art wall in Berlin's Kreuzberg, London's Shoreditch, or NYC's Bushwick — raw, layered, subversive, and culturally charged.`,
        previewImageUrl: 'https://images.unsplash.com/photo-1499781350582-f3d20d tried6',
        isActive: true,
      },
    ],
  });

  console.log('✅ Seeded 15 visual styles with super-detailed prompt templates');

  // ══════════════════════════════════════════════════════════════════════════
  // 3. CHARACTERS
  // ══════════════════════════════════════════════════════════════════════════
  await prisma.character.deleteMany();
  await prisma.character.createMany({
    data: [
      {
        name: 'Cyber Ninja (Akira)',
        description: 'Ninja futuristik dengan katana neon dan armor cyberpunk.',
        imageUrl: 'https://images.unsplash.com/photo-1578358464971-8b2ea51d95e0?q=80&w=200&h=200&fit=crop',
        promptConsistency: 'Cyberpunk ninja wearing sleek black tactical armor, glowing neon blue accents on suit, holding a glowing katana, hyper-detailed mechanical visor covering the eyes, urban rainy neon reflection.',
        category: 'general',
        isActive: true,
      },
      {
        name: 'Cute Astronaut (Leo)',
        description: 'Astronot chibi yang lucu sedang menjelajahi luar angkasa.',
        imageUrl: 'https://images.unsplash.com/photo-1614730321146-b6fa6a46bcb4?q=80&w=200&h=200&fit=crop',
        promptConsistency: 'Cute chibi astronaut character with a large round helmet, starry reflection on the glass, wearing a bulky white space suit with colorful patches, floating in zero gravity, bright sparkling eyes.',
        category: 'general',
        isActive: true,
      }
    ]
  });
  console.log('✅ Seeded Characters successfully!');

  console.log('🎉 Seeding completed successfully!');
}

main()
  .catch((e) => {
    console.error('❌ Error during seeding database:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
