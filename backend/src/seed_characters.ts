import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';
import { characters } from './db/schema';
import 'dotenv/config';

async function seed() {
  console.log('Seeding characters...');
  const client = postgres(process.env.DATABASE_URL!);
  const db = drizzle(client);

  const newCharacters = [
    {
      id: 'char-1',
      name: 'Si Piko',
      description: 'Kucing oranye gendut yang suka ngemil',
      imageUrl: 'https://ui-avatars.com/api/?name=Piko&background=F59E0B&color=fff',
      promptConsistency: 'a fat orange tabby cat, cute, cartoon style, big eyes',
      category: 'animal',
    },
    {
      id: 'char-2',
      name: 'Bubu si Beruang',
      description: 'Beruang cokelat kecil yang selalu membawa madu',
      imageUrl: 'https://ui-avatars.com/api/?name=Bubu&background=78350F&color=fff',
      promptConsistency: 'a small brown bear holding a honey jar, cute, 3d render',
      category: 'animal',
    },
    {
      id: 'char-3',
      name: 'Nino si Ninja',
      description: 'Ninja cilik yang kikuk tapi bersemangat',
      imageUrl: 'https://ui-avatars.com/api/?name=Nino&background=111827&color=fff',
      promptConsistency: 'a clumsy chibi ninja boy, wearing black mask and headband, anime style',
      category: 'humanoid',
    },
    {
      id: 'char-4',
      name: 'Astro-Bot',
      description: 'Robot astronot mini yang selalu penasaran',
      imageUrl: 'https://ui-avatars.com/api/?name=Astro&background=3B82F6&color=fff',
      promptConsistency: 'a cute tiny astronaut robot, glowing blue eyes, sci-fi style',
      category: 'robot',
    },
    {
      id: 'char-5',
      name: 'Profesor Hoot',
      description: 'Burung hantu berkacamata tebal yang jenius',
      imageUrl: 'https://ui-avatars.com/api/?name=Hoot&background=4B5563&color=fff',
      promptConsistency: 'a wise old owl wearing thick round glasses, holding a book, vector illustration',
      category: 'animal',
    },
    {
      id: 'char-6',
      name: 'Mochi',
      description: 'Kelinci putih selembut mochi',
      imageUrl: 'https://ui-avatars.com/api/?name=Mochi&background=EC4899&color=fff',
      promptConsistency: 'a fluffy white bunny, round like a mochi, kawaii style, pastel colors',
      category: 'animal',
    },
    {
      id: 'char-7',
      name: 'Kapten Dino',
      description: 'T-rex kecil dengan topi pelaut',
      imageUrl: 'https://ui-avatars.com/api/?name=Dino&background=10B981&color=fff',
      promptConsistency: 'a cute baby t-rex wearing a sailor hat, bright green skin, 3d animation style',
      category: 'animal',
    },
    {
      id: 'char-8',
      name: 'Lala si Peri',
      description: 'Peri hutan mungil dengan sayap berkilau',
      imageUrl: 'https://ui-avatars.com/api/?name=Lala&background=A855F7&color=fff',
      promptConsistency: 'a tiny beautiful forest fairy with glowing wings, magical vibe, digital painting',
      category: 'fantasy',
    },
    {
      id: 'char-9',
      name: 'Chef Mumu',
      description: 'Sapi perah gemuk yang suka memasak',
      imageUrl: 'https://ui-avatars.com/api/?name=Mumu&background=000000&color=fff',
      promptConsistency: 'a fat cow wearing a chef hat and apron, smiling, cartoon mascot',
      category: 'animal',
    },
    {
      id: 'char-10',
      name: 'Gigi',
      description: 'Anjing corgi dengan pantat berbentuk hati',
      imageUrl: 'https://ui-avatars.com/api/?name=Gigi&background=F59E0B&color=fff',
      promptConsistency: 'a cute corgi dog from behind showing a heart shaped butt, vector style',
      category: 'animal',
    },
    {
      id: 'char-11',
      name: 'Slimey',
      description: 'Slime hijau yang bisa berubah bentuk',
      imageUrl: 'https://ui-avatars.com/api/?name=Slimey&background=10B981&color=fff',
      promptConsistency: 'a cute green slime monster with big cute eyes, shiny texture, 3d render',
      category: 'fantasy',
    },
    {
      id: 'char-12',
      name: 'Panda-san',
      description: 'Panda malas yang suka makan bambu',
      imageUrl: 'https://ui-avatars.com/api/?name=Panda&background=4B5563&color=fff',
      promptConsistency: 'a lazy panda eating bamboo, sitting comfortably, cartoon style',
      category: 'animal',
    },
    {
      id: 'char-13',
      name: 'Ksatria Kucing',
      description: 'Kucing abu-abu berzirah lengkap dengan pedang',
      imageUrl: 'https://ui-avatars.com/api/?name=Ksatria&background=6B7280&color=fff',
      promptConsistency: 'a serious gray cat wearing medieval knight armor holding a small sword, detailed illustration',
      category: 'animal',
    },
    {
      id: 'char-14',
      name: 'Alien Zorb',
      description: 'Alien mata tiga dari planet mars',
      imageUrl: 'https://ui-avatars.com/api/?name=Zorb&background=14B8A6&color=fff',
      promptConsistency: 'a cute friendly three eyed green alien, retro sci fi style',
      category: 'sci-fi',
    },
    {
      id: 'char-15',
      name: 'Koki Bebek',
      description: 'Bebek kuning yang selalu panik di dapur',
      imageUrl: 'https://ui-avatars.com/api/?name=Bebek&background=FBBF24&color=fff',
      promptConsistency: 'a panicking yellow duck wearing a chef hat, kitchen background, funny cartoon',
      category: 'animal',
    }
  ];

  try {
    for (const char of newCharacters) {
      await db.insert(characters).values(char).onConflictDoNothing();
    }
    console.log('Successfully seeded 15 dummy characters!');
  } catch (error) {
    console.error('Error seeding:', error);
  } finally {
    await client.end();
  }
}
seed();
