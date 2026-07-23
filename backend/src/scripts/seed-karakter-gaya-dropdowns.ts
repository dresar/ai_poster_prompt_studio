import * as dotenv from 'dotenv';
import path from 'path';
dotenv.config({ path: path.join(__dirname, '../../.env') });

import { db } from '../config/db';
import { dropdownOptions } from '../db/schema';
import crypto from 'crypto';

const newDropdownOptions = [
  // karakter_jenis
  { groupKey: 'karakter_jenis', label: '🐱 Hewan (Animal Mascot)', value: 'Hewan', helperText: 'Mascot hewan seperti penguin, rubah, kucing, dll', sortOrder: 1 },
  { groupKey: 'karakter_jenis', label: '👤 Manusia (Human Character)', value: 'Manusia', helperText: 'Karakter sosok manusia dengan gaya spesifik', sortOrder: 2 },
  { groupKey: 'karakter_jenis', label: '🐉 Makhluk Fantasi (Fantasy Creature)', value: 'Makhluk Fantasi', helperText: 'Naga, monster imut, atau mahluk mitologi', sortOrder: 3 },
  { groupKey: 'karakter_jenis', label: '🤖 Robot / Android', value: 'Robot', helperText: 'Robot futuristik atau robot imut pembantu', sortOrder: 4 },

  // karakter_kategori
  { groupKey: 'karakter_kategori', label: '🏆 Maskot Brand', value: 'Maskot Brand', helperText: 'Identitas utama perusahaan atau produk', sortOrder: 1 },
  { groupKey: 'karakter_kategori', label: '📚 Karakter Edukasi', value: 'Karakter Edukasi', helperText: 'Menjelaskan konten tips & fakta ilmiah', sortOrder: 2 },
  { groupKey: 'karakter_kategori', label: '📖 Tokoh Cerita / Komik', value: 'Tokoh Cerita', helperText: 'Karakter utama dalam alur narasi komik/buku', sortOrder: 3 },
  { groupKey: 'karakter_kategori', label: '🎮 Karakter Game / Avatar', value: 'Karakter Game', helperText: 'Avatar pemain atau NPC game', sortOrder: 4 },
  { groupKey: 'karakter_kategori', label: '🌐 Influencer Virtual', value: 'Influencer Virtual', helperText: 'Karakter konten creator VTuber / virtual host', sortOrder: 5 },

  // karakter_gaya_ilustrasi
  { groupKey: 'karakter_gaya_ilustrasi', label: '🧸 3D Pixar / Disney Style', value: '3D Pixar Disney Style', helperText: 'Karakter 3D imut khas film animasi Pixar/Disney', sortOrder: 1 },
  { groupKey: 'karakter_gaya_ilustrasi', label: '🎨 3D Cute Isometric Render', value: '3D Cute Isometric', helperText: 'Tampilan 3D bersih dengan sudut isometrik', sortOrder: 2 },
  { groupKey: 'karakter_gaya_ilustrasi', label: '✏️ 2D Flat Vector Modern', value: '2D Flat Vector', helperText: 'Desain vektor datar bersih kontemporer', sortOrder: 3 },
  { groupKey: 'karakter_gaya_ilustrasi', label: '🎌 Anime / Manga Chibi', value: 'Anime Chibi Style', helperText: 'Gaya animasi Jepang berkepala besar imut', sortOrder: 4 },
  { groupKey: 'karakter_gaya_ilustrasi', label: '🖌️ Claymation 3D', value: 'Claymation 3D', helperText: 'Tekstur tanah liat animasi stop-motion', sortOrder: 5 },

  // gaya_kategori
  { groupKey: 'gaya_kategori', label: '🏢 Modern Minimalis & Clean', value: 'Modern Minimalis', helperText: 'Desain bersih dengan negative space luas', sortOrder: 1 },
  { groupKey: 'gaya_kategori', label: '🌌 Cyberpunk & Futuristic Neon', value: 'Cyberpunk Neon', helperText: 'Cahaya neon menyala dengan latar gelap', sortOrder: 2 },
  { groupKey: 'gaya_kategori', label: '🎨 Retro & Vintage 90s', value: 'Retro Vintage', helperText: 'Sentuhan nostalgia dengan warna hangat 90an', sortOrder: 3 },
  { groupKey: 'gaya_kategori', label: '🌿 Organic & Nature Minimalist', value: 'Organic Nature', helperText: 'Elemen alam, daun, dan warna alami', sortOrder: 4 },
  { groupKey: 'gaya_kategori', label: '✨ Luxury & Elegant Gold', value: 'Luxury Gold', helperText: 'Aksen emas mewah dan nuansa premium', sortOrder: 5 },

  // gaya_medium
  { groupKey: 'gaya_medium', label: '🔮 3D Studio Render (Octane / Cinema4D)', value: '3D Studio Render', helperText: 'Hasil render 3D studio pencahayaan murni', sortOrder: 1 },
  { groupKey: 'gaya_medium', label: '📐 2D Swiss Vector Grid', value: '2D Swiss Vector Grid', helperText: 'Tipografi presisi Swiss grid kontemporer', sortOrder: 2 },
  { groupKey: 'gaya_medium', label: '📸 Hyperrealistic Photography', value: 'Hyperrealistic Photography', helperText: 'Gaya foto nyata dengan lensa kamera pro', sortOrder: 3 },
  { groupKey: 'gaya_medium', label: '🎨 Oil Painting & Fine Art', value: 'Oil Painting Fine Art', helperText: 'Tekstur lukisan cat minyak klasik', sortOrder: 4 },
];

async function seed() {
  console.log('Seeding Karakter & Gaya Visual dropdown options...');
  try {
    for (const opt of newDropdownOptions) {
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
    console.log('Karakter & Gaya Visual dropdown options seeded successfully.');
    process.exit(0);
  } catch (err) {
    console.error('Failed to seed dropdown options:', err);
    process.exit(1);
  }
}

seed();
