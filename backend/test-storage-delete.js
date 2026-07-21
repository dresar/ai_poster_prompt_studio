const GATEWAY_KEY = 'AR_4c9b2435_929a80d916261b15c582db6fe3e41e52';
const BASE_URL = 'https://one.apprentice.cyou/v1';

async function testDelete(fileId) {
  try {
    const res = await fetch(`${BASE_URL}/storage/files/${fileId}`, {
      method: 'DELETE',
      headers: { 'Authorization': `Bearer ${GATEWAY_KEY}` }
    });
    const data = await res.json();
    console.log('DELETE /storage/files/:id status:', res.status);
    console.log('Response body:', JSON.stringify(data, null, 2));
  } catch (err) {
    console.error('Delete failed:', err);
  }
}

testDelete('a3653d47-b27c-4a50-b017-0955c2431f03');
