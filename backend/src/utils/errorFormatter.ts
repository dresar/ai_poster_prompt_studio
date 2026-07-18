export function formatGeminiError(rawError: string): string {
  return formatAiError(rawError, 'gemini');
}

export function formatAiError(rawError: string, provider: string = 'gemini'): string {
  const lowercase = rawError.toLowerCase();
  
  if (
    lowercase.includes('api key not valid') || 
    lowercase.includes('api_key_invalid') || 
    lowercase.includes('invalid api key')
  ) {
    return 'Terjadi kendala otentikasi pada server. Silakan hubungi admin.';
  }
  
  if (
    lowercase.includes('quota') || 
    lowercase.includes('429') || 
    lowercase.includes('rate limit') ||
    lowercase.includes('resource_exhausted') ||
    lowercase.includes('limit exceeded')
  ) {
    return 'Layanan sedang sibuk karena tingginya permintaan. Silakan coba beberapa saat lagi.';
  }
  
  if (
    lowercase.includes('geo-blocked') || 
    lowercase.includes('location not supported') || 
    lowercase.includes('user location is not supported') ||
    lowercase.includes('not supported in your country')
  ) {
    return 'Layanan tidak dapat diakses dari lokasi Anda saat ini.';
  }
  
  if (
    lowercase.includes('503') || 
    lowercase.includes('service unavailable') || 
    lowercase.includes('overloaded') ||
    lowercase.includes('experiencing high demand')
  ) {
    return 'Layanan sedang sibuk atau mengalami kendala kapasitas sementara. Silakan coba beberapa saat lagi.';
  }
  
  if (
    lowercase.includes('404') || 
    lowercase.includes('model not found') ||
    lowercase.includes('no longer available')
  ) {
    return 'Sistem mengalami kendala pada pemrosesan. Silakan hubungi admin.';
  }
  
  return `Terjadi kendala pada server. Silakan hubungi admin atau coba beberapa saat lagi. [Detail: ${rawError}]`;
}
