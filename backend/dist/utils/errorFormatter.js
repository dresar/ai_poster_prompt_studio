"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.formatGeminiError = formatGeminiError;
function formatGeminiError(rawError) {
    const lowercase = rawError.toLowerCase();
    if (lowercase.includes('api key not valid') ||
        lowercase.includes('api_key_invalid') ||
        lowercase.includes('invalid api key')) {
        return 'Kunci API tidak valid, telah terhapus, atau tidak aktif di Google AI Studio.';
    }
    if (lowercase.includes('quota') ||
        lowercase.includes('429') ||
        lowercase.includes('rate limit') ||
        lowercase.includes('resource_exhausted')) {
        return 'Batas kuota Kunci API terlampaui (Rate Limit / Quota Exceeded).';
    }
    if (lowercase.includes('geo-blocked') ||
        lowercase.includes('location not supported') ||
        lowercase.includes('user location is not supported') ||
        lowercase.includes('not supported in your country')) {
        return 'Kunci API tidak dapat digunakan di wilayah geografis Anda (Geo-Blocked).';
    }
    if (lowercase.includes('503') ||
        lowercase.includes('service unavailable') ||
        lowercase.includes('overloaded') ||
        lowercase.includes('experiencing high demand')) {
        return 'Layanan Gemini sedang sibuk atau mengalami kendala kapasitas sementara (503 Service Unavailable).';
    }
    if (lowercase.includes('404') ||
        lowercase.includes('model not found') ||
        lowercase.includes('no longer available')) {
        return 'Model Gemini yang diminta tidak ditemukan atau sudah tidak lagi didukung oleh Google.';
    }
    return 'Terjadi kendala koneksi dengan layanan Gemini. Silakan coba beberapa saat lagi.';
}
