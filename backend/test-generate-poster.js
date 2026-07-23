const GATEWAY_KEY = 'AR_7651fb06_0f19ac85a3a409b4fe568b2afb7a1512';
const BASE_URL = 'https://one.apprentice.cyou/v1';

async function testFullPosterPromptNewModels() {
  console.log('🚀 Testing FULL Poster Prompt Generation with High-Quota Models (gemini-3.1-flash-lite & gemini-3.5-flash)...');

  const promptText = `Kamu adalah Art Director & Master AI Prompt Generator profesional.
Tugasmu: Buat poster edukasi tentang "Pentingnya Belajar Coding sejak Dini".
Gaya Visual: 3D Pixar Disney Style.
Rasio: 3:4.

Return ONLY raw JSON with keys:
{
  "title": "Judul Utama Poster",
  "masterPositivePrompt": "master positive prompt in English for Midjourney/Flux",
  "masterNegativePrompt": "negative prompt in English",
  "visualStyle": "3D Pixar Disney Style",
  "colorPalette": "Vibrant Neon Blue and Yellow"
}`;

  const models = ['gemini-3.1-flash-lite', 'gemini-3.5-flash', 'gemini-2.5-flash'];

  for (const model of models) {
    console.log(`\n📡 Trying poster generation with model: ${model}...`);
    try {
      const startTime = Date.now();
      const res = await fetch(`${BASE_URL}/chat/completions`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${GATEWAY_KEY}`,
        },
        body: JSON.stringify({
          model,
          messages: [
            { role: 'system', content: 'Kamu adalah asisten AI yang cerdas.' },
            { role: 'user', content: promptText }
          ],
          temperature: 0.7,
        }),
      });

      const elapsed = Date.now() - startTime;
      const rawText = await res.text();

      if (res.ok) {
        const data = JSON.parse(rawText);
        console.log(`✅ ${model} GENERASI POSTER SUKSES! (200 OK - ${elapsed}ms)`);
        console.log('==================================================');
        console.log(data.choices?.[0]?.message?.content?.trim());
        console.log('==================================================');
        return;
      } else {
        console.error(`❌ ${model} GAGAL Status ${res.status}:`, rawText.substring(0, 150));
      }
    } catch (err) {
      console.error(`❌ ${model} Error:`, err);
    }
  }
}

testFullPosterPromptNewModels();
