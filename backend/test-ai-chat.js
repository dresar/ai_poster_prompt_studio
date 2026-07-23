const GATEWAY_KEY = 'AR_7651fb06_0f19ac85a3a409b4fe568b2afb7a1512';
const BASE_URL = 'https://one.apprentice.cyou/v1';

async function testNewModels() {
  console.log('🚀 Testing High-Quota Models: gemini-3.1-flash-lite & gemini-3.5-flash...');

  const models = ['gemini-3.1-flash-lite', 'gemini-3.5-flash', 'gemini-2.5-flash'];

  for (const model of models) {
    console.log(`\n🧪 Testing model: ${model}...`);
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
          messages: [{ role: 'user', content: 'Halo! Jawab singkat 1 kalimat bahwa kamu terhubung.' }],
          temperature: 0.7,
        }),
      });

      const elapsed = Date.now() - startTime;
      const rawText = await res.text();

      if (res.ok) {
        const data = JSON.parse(rawText);
        console.log(`  ✅ ${model} SUKSES! (200 OK - ${elapsed}ms)`);
        console.log(`  📌 Balasan: ${data.choices?.[0]?.message?.content?.trim()}`);
      } else {
        console.log(`  ❌ ${model} GAGAL Status ${res.status}: ${rawText.substring(0, 150)}`);
      }
    } catch (err) {
      console.error(`  ❌ ${model} Error:`, err);
    }
  }
}

testNewModels();
