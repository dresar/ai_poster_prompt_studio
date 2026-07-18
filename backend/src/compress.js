const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

async function compress() {
  try {
    const logoPath = path.resolve(__dirname, '../../assets/logo.png');
    const logoOut = path.resolve(__dirname, '../../assets/logo_c.png');
    await sharp(logoPath).resize({ width: 600 }).png({ quality: 70, compressionLevel: 9 }).toFile(logoOut);
    fs.renameSync(logoOut, logoPath);
    console.log('logo.png compressed');
    
    const onePath = path.resolve(__dirname, '../../assets/1.png');
    const oneOut = path.resolve(__dirname, '../../assets/1_c.png');
    await sharp(onePath).resize({ width: 600 }).png({ quality: 70, compressionLevel: 9 }).toFile(oneOut);
    fs.renameSync(oneOut, onePath);
    console.log('1.png compressed');
  } catch (e) {
    console.error(e);
  }
}
compress();
