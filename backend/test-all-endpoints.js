require('dotenv').config();

const { TopicAnalyzerService } = require('./src/modules/ai-gateway/features/topic-analyzer.service');
const { ChatAssistantService } = require('./src/modules/ai-gateway/features/chat-assistant.service');
const { GeminiClient } = require('./src/modules/ai-gateway/core/gemini-client');
const { GroqClient } = require('./src/modules/ai-gateway/core/groq-client');

async function testAllAIEndpoints() {
  console.log('🧪 Testing AI Gateway Services Speed & Reliability...\n');
  
  const geminiClient = new GeminiClient();
  const groqClient = new GroqClient();
  const topicAnalyzer = new TopicAnalyzerService(geminiClient, groqClient);
  const chatAssistant = new ChatAssistantService(geminiClient, groqClient);

  // Test 1: Analyze Topic (Ide Topik & Analisis Materi)
  console.log('1️⃣ Testing Topic Analyzer (Ide Topik & Analisis Materi)...');
  const t1 = Date.now();
  try {
    const res1 = await topicAnalyzer.analyzeTopic('Tips Hemat Listrik 2026', 'Edukasi', 'gemini');
    const elapsed1 = Date.now() - t1;
    console.log(`  ✅ Topic Analyzer SUCCESS (${elapsed1}ms):`);
    console.log(`     Description (${res1.description?.length} chars): "${res1.description?.substring(0, 100)}..."`);
    console.log(`     Key points count: ${res1.keyPoints?.length}`);
    console.log(`     Hook: "${res1.hook}"`);
  } catch (err) {
    console.error(`  ❌ Topic Analyzer FAILED (${Date.now() - t1}ms):`, err?.message || err);
  }

  // Test 2: AI Chat Assistant
  console.log('\n2️⃣ Testing Chat Assistant...');
  const t2 = Date.now();
  try {
    const res2 = await chatAssistant.chat('Halo AI, sebutkan 3 warna terbaik untuk poster edukasi.', [], 'gemini');
    const elapsed2 = Date.now() - t2;
    console.log(`  ✅ Chat Assistant SUCCESS (${elapsed2}ms):`);
    console.log(`     Response: "${res2.substring(0, 120)}..."`);
  } catch (err) {
    console.error(`  ❌ Chat Assistant FAILED (${Date.now() - t2}ms):`, err?.message || err);
  }

  console.log('\n🎉 ALL ENDPOINTS TEST COMPLETED!');
  process.exit(0);
}

testAllAIEndpoints().catch(err => {
  console.error('Fatal error in test script:', err);
  process.exit(1);
});
