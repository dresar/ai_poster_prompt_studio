const fs = require('fs');
const path = require('path');
require('dotenv').config();

const GATEWAY_KEY = process.env.STORAGE_GATEWAY_KEY || 'AR_4c9b2435_929a80d916261b15c582db6fe3e41e52';
const BASE_URL = process.env.STORAGE_GATEWAY_BASE_URL || 'https://one.apprentice.cyou/v1';

async function testStorageUploadWithRealImage() {
  console.log('🚀 Testing Storage CDN Upload using env API Key & Real Image (01_login.png)...');
  console.log('   Using API Key :', GATEWAY_KEY ? `${GATEWAY_KEY.slice(0, 10)}...` : 'NONE');
  console.log('   Base URL      :', BASE_URL);

  const imagePath = path.resolve(__dirname, '../assets/demo/01_login.png');
  if (!fs.existsSync(imagePath)) {
    console.error('❌ File not found at:', imagePath);
    return;
  }

  const imageBuffer = fs.readFileSync(imagePath);
  const base64Image = `data:image/png;base64,${imageBuffer.toString('base64')}`;

  console.log(`   Image loaded  : ${imagePath} (${imageBuffer.length} bytes)`);

  try {
    const uploadRes = await fetch(`${BASE_URL}/storage/upload`, {
      method: 'POST',
      headers: { 
        'Content-Type': 'application/json', 
        'Authorization': `Bearer ${GATEWAY_KEY}` 
      },
      body: JSON.stringify({ 
        file: base64Image, 
        file_name: '01_login.png', 
        auto_rotate: true, 
        provider: 'cloudinary' 
      })
    });

    const data = await uploadRes.json();
    if (uploadRes.ok && data.success) {
      console.log('\n✅ Storage CDN Upload Berhasil!');
      console.log('   Record ID        :', data.file.id);
      console.log('   Provider Terpakai:', data.file.provider);
      console.log('   File Name        :', data.file.file_name);
      console.log('   File Size        :', data.file.file_size, 'bytes');
      console.log('   Direct CDN URL   :', data.file.url);
    } else {
      console.error('\n❌ Upload Gagal:', data);
    }
  } catch (err) {
    console.error('\n❌ Error executing upload test:', err);
  }
}

testStorageUploadWithRealImage();
