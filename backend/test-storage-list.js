const GATEWAY_KEY = 'AR_4c9b2435_929a80d916261b15c582db6fe3e41e52';
const BASE_URL = 'https://one.apprentice.cyou/v1';

async function testList() {
  try {
    const res = await fetch(`${BASE_URL}/storage/list?page=1&limit=10&provider=cloudinary`, {
      headers: { 'Authorization': `Bearer ${GATEWAY_KEY}` }
    });
    const data = await res.json();
    console.log('GET /storage/list Response status:', res.status);
    console.log('Response body:', JSON.stringify(data, null, 2));
  } catch (err) {
    console.error('List failed:', err);
  }
}

testList();
