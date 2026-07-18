import * as dotenv from 'dotenv';
import path from 'path';
dotenv.config({ path: path.join(__dirname, '../../.env') });

import { db } from '../config/db';
import { dropdownOptions } from '../db/schema';
import crypto from 'crypto';

const videoDropdownOptions = [
  // gaya_video
  { groupKey: 'gaya_video', label: '🤖 AI Pilihkan (Auto)', value: 'auto', helperText: 'Biarkan AI merekomendasikan gaya video terbaik', sortOrder: 0 },
  { groupKey: 'gaya_video', label: '🎬 Cinematic Portrait', value: 'cinematic_portrait', helperText: 'Pencahayaan dramatis, kedalaman ruang (bokeh), gaya film bioskop', sortOrder: 1 },
  { groupKey: 'gaya_video', label: '🧊 3D Pixar Animation', value: 'pixar_3d', helperText: 'Gaya animasi karakter 3D imut, membulat, cerah khas film Pixar', sortOrder: 2 },
  { groupKey: 'gaya_video', label: '🎨 Japanese Anime', value: 'japanese_anime', helperText: 'Gaya gambar tangan animasi anime Jepang klasik', sortOrder: 3 },
  { groupKey: 'gaya_video', label: '📈 Minimalist Motion Graphic', value: 'motion_graphic', helperText: 'Grafis gerak minimalis, bentuk vektor datar bersih', sortOrder: 4 },
  { groupKey: 'gaya_video', label: '👾 Cyberpunk / Sci-Fi', value: 'cyberpunk', helperText: 'Penuh lampu neon, elemen teknologi futuristik', sortOrder: 5 },
  { groupKey: 'gaya_video', label: '📱 Daily Life Vlog', value: 'vlog', helperText: 'Gaya kamera handheld alami, suasana vlog kehidupan nyata', sortOrder: 6 },

  // gerakan_kamera_video
  { groupKey: 'gerakan_kamera_video', label: '🤖 AI Pilihkan (Auto)', value: 'auto', helperText: 'AI akan menentukan gerakan kamera yang paling dramatis', sortOrder: 0 },
  { groupKey: 'gerakan_kamera_video', label: '↔️ Slow Panning (Kiri ke Kanan)', value: 'slow_pan', helperText: 'Kamera bergeser horizontal perlahan untuk mengekspos pemandangan', sortOrder: 1 },
  { groupKey: 'gerakan_kamera_video', label: '🔍 Steady Zoom In / Out', value: 'zoom', helperText: 'Perubahan fokus perlahan mendekat/menjauh untuk penekanan dramatis', sortOrder: 2 },
  { groupKey: 'gerakan_kamera_video', label: '🏃‍♂️ Dynamic Subject Tracking', value: 'subject_tracking', helperText: 'Kamera aktif mengikuti pergerakan subjek utama', sortOrder: 3 },
  { groupKey: 'gerakan_kamera_video', label: '🚁 Drone Flyover / Aerial', value: 'drone_aerial', helperText: 'Sudut pandang luas dari atas ke bawah khas drone', sortOrder: 4 },
  { groupKey: 'gerakan_kamera_video', label: '❓ First-Person Handheld', value: 'handheld_shake', helperText: 'Gaya kamera digenggam tangan dengan getaran alami', sortOrder: 5 },
  { groupKey: 'gerakan_kamera_video', label: '🎥 Fixed Tripod (Statis)', value: 'static_shot', helperText: 'Kamera diam di tempat, fokus murni pada aksi subjek', sortOrder: 6 },

  // rasio_video
  { groupKey: 'rasio_video', label: '🤖 AI Pilihkan (Auto)', value: 'auto', helperText: 'Biarkan AI menyesuaikan rasio visual terbaik', sortOrder: 0 },
  { groupKey: 'rasio_video', label: '📱 9:16 (TikTok / Reels / Shorts)', value: '9:16', helperText: 'Rasio vertikal penuh untuk layar smartphone', sortOrder: 1 },
  { groupKey: 'rasio_video', label: '🖥️ 16:9 (YouTube Widescreen)', value: '16:9', helperText: 'Rasio horizontal lebar cocok untuk monitor & TV', sortOrder: 2 },
  { groupKey: 'rasio_video', label: '🟦 1:1 (Square Feed)', value: '1:1', helperText: 'Format persegi klasik cocok untuk media sosial feed', sortOrder: 3 },

  // palet_warna_video
  { groupKey: 'palet_warna_video', label: '🤖 AI Pilihkan (Auto)', value: 'auto', helperText: 'Biarkan AI menentukan harmoni warna yang cocok', sortOrder: 0 },
  { groupKey: 'palet_warna_video', label: '🧁 Pastel Soft', value: 'pastel', helperText: 'Warna-warna lembut, menenangkan dan estetik', sortOrder: 1 },
  { groupKey: 'palet_warna_video', label: '🔥 Neon Vibrant', value: 'neon', helperText: 'Warna kontras tinggi yang menyala terang', sortOrder: 2 },
  { groupKey: 'palet_warna_video', label: '🪨 Earth Tone', value: 'earth_tone', helperText: 'Warna-warna alami seperti cokelat kayu, hijau daun, dsb.', sortOrder: 3 },
  { groupKey: 'palet_warna_video', label: '🎬 Teal & Orange', value: 'teal_orange', helperText: 'Skema warna populer perfilman Hollywood untuk sinematik instan', sortOrder: 4 },

  // jenis_cerita_video
  { groupKey: 'jenis_cerita_video', label: '🤖 AI Pilihkan (Auto)', value: 'auto', helperText: 'AI menentukan jenis cerita paling efektif', sortOrder: 0 },
  { groupKey: 'jenis_cerita_video', label: '🎭 Narrative / Film Pendek', value: 'narrative', helperText: 'Cerita berurutan dengan karakter dan plot yang jelas', sortOrder: 1 },
  { groupKey: 'jenis_cerita_video', label: '📚 Edukasi / Tutorial', value: 'edukasi', helperText: 'Menyampaikan informasi dengan cara menarik', sortOrder: 2 },
  { groupKey: 'jenis_cerita_video', label: '🛍️ Promosi Produk / Iklan', value: 'promosi', helperText: 'Fokus pada kelebihan produk dan Call to Action', sortOrder: 3 },

  // lokasi_video
  { groupKey: 'lokasi_video', label: '🤖 AI Pilihkan (Auto)', value: 'auto', helperText: 'Biarkan AI memilih lokasi terbaik', sortOrder: 0 },
  { groupKey: 'lokasi_video', label: '🏢 Indoor Studio', value: 'studio', helperText: 'Studio tertutup bersih profesional', sortOrder: 1 },
  { groupKey: 'lokasi_video', label: '🏙️ Outdoor Perkotaan', value: 'urban', helperText: 'Jalanan kota modern, gedung tinggi', sortOrder: 2 },
  { groupKey: 'lokasi_video', label: '🌲 Hutan / Alam Liar', value: 'nature', helperText: 'Hutan lebat, pegunungan alami', sortOrder: 3 },

  // transisi_video
  { groupKey: 'transisi_video', label: '🤖 AI Pilihkan (Auto)', value: 'auto', helperText: 'Biarkan AI memilih transisi scene terbaik', sortOrder: 0 },
  { groupKey: 'transisi_video', label: '✂️ Cut (Tanpa Efek)', value: 'cut', helperText: 'Potongan langsung antar scene', sortOrder: 1 },
  { groupKey: 'transisi_video', label: '🔍 Zoom / Push Transition', value: 'zoom_transition', helperText: 'Transisi kamera zoom cepat', sortOrder: 2 },
  { groupKey: 'transisi_video', label: '🌊 Fade Out/In', value: 'fade', helperText: 'Transisi memudar ke hitam/putih', sortOrder: 3 },

  // mood_audio_video
  { groupKey: 'mood_audio_video', label: '🤖 AI Pilihkan (Auto)', value: 'auto', helperText: 'Biarkan AI menyesuaikan mood musik', sortOrder: 0 },
  { groupKey: 'mood_audio_video', label: '⚡ Energik / Upbeat', value: 'energetic', helperText: 'Musik penuh semangat dan cepat', sortOrder: 1 },
  { groupKey: 'mood_audio_video', label: '🎭 Emosional / Sedih', value: 'emotional', helperText: 'Musik menyentuh hati dan lambat', sortOrder: 2 },
  { groupKey: 'mood_audio_video', label: '🧘 Tenang / Relaks', value: 'calm', helperText: 'Musik damai, santai latar belakang', sortOrder: 3 },
];

async function seed() {
  console.log('Seeding video dropdown options...');
  try {
    for (const opt of videoDropdownOptions) {
      await db.insert(dropdownOptions).values({
        id: crypto.randomUUID(),
        groupKey: opt.groupKey,
        label: opt.label,
        value: opt.value,
        helperText: opt.helperText,
        isActive: true,
        sortOrder: opt.sortOrder,
      });
      console.log(`Seeded: [${opt.groupKey}] ${opt.label}`);
    }
    console.log('Video dropdown options seeded successfully.');
    process.exit(0);
  } catch (err) {
    console.error('Failed to seed video dropdown options:', err);
    process.exit(1);
  }
}

seed();
