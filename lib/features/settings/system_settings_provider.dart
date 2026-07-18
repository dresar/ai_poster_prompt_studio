import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/dio_client.dart';

class PricingPackage {
  final String id;
  final String name;
  final String priceText;
  final String billingCycle;
  final int credits;
  final String checkoutUrl;

  PricingPackage({
    required this.id,
    required this.name,
    required this.priceText,
    required this.billingCycle,
    required this.credits,
    required this.checkoutUrl,
  });

  factory PricingPackage.fromJson(Map<String, dynamic> json) {
    return PricingPackage(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      priceText: json['priceText'] ?? '',
      billingCycle: json['billingCycle'] ?? 'bulan',
      credits: json['credits'] ?? 0,
      checkoutUrl: json['checkoutUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'priceText': priceText,
        'billingCycle': billingCycle,
        'credits': credits,
        'checkoutUrl': checkoutUrl,
      };
}

class SystemSettings {
  final String appName;
  final int maxQuotaPerDay;
  final String footerText;
  final String bannerPosterInfo;
  final String bannerEnhanceInfo;
  final List<PricingPackage> packages;

  SystemSettings({
    required this.appName,
    required this.maxQuotaPerDay,
    required this.footerText,
    required this.bannerPosterInfo,
    required this.bannerEnhanceInfo,
    required this.packages,
  });

  factory SystemSettings.fromJson(Map<String, dynamic> json) {
    final rawPackages = json['packages'] as List<dynamic>? ?? [];
    final packagesList = rawPackages.map((e) => PricingPackage.fromJson(e as Map<String, dynamic>)).toList();

    return SystemSettings(
      appName: json['appName'] ?? 'PROMTING STUDIO',
      maxQuotaPerDay: json['maxQuotaPerDay'] ?? json['quotaDailyLimit'] ?? 10,
      footerText: json['footerText'] ?? 'PROMTING STUDIO · 1 lisensi = 1 perangkat aktif',
      bannerPosterInfo: json['bannerPosterInfo'] ?? '✨ Ditenagai AI. Isi form, klik GENERATE, lalu tempel hasilnya ke Gemini / AI image generator favoritmu.',
      bannerEnhanceInfo: json['bannerEnhanceInfo'] ?? '✨ Upload fotomu, pilih gaya, klik GENERATE. Salin prompt lalu tempel + upload foto yang sama ke Gemini / ChatGPT.',
      packages: packagesList,
    );
  }

  Map<String, dynamic> toJson() => {
        'appName': appName,
        'maxQuotaPerDay': maxQuotaPerDay,
        'footerText': footerText,
        'bannerPosterInfo': bannerPosterInfo,
        'bannerEnhanceInfo': bannerEnhanceInfo,
        'packages': packages.map((e) => e.toJson()).toList(),
      };
}

class SystemSettingsNotifier extends StateNotifier<SystemSettings> {
  SystemSettingsNotifier()
      : super(SystemSettings(
          appName: 'PROMTING STUDIO',
          maxQuotaPerDay: 50,
          footerText: 'PROMTING STUDIO · 1 lisensi = 1 perangkat aktif',
          bannerPosterInfo: '✨ Ditenagai AI. Isi form, klik GENERATE, lalu tempel hasilnya ke Gemini / AI image generator favoritmu.',
          bannerEnhanceInfo: '✨ Upload fotomu, pilih gaya, klik GENERATE. Salin prompt lalu tempel + upload foto yang sama ke Gemini / ChatGPT.',
          packages: [
            PricingPackage(id: 'starter', name: 'Starter Pack', priceText: 'Rp 15.000', billingCycle: 'bulan', credits: 300, checkoutUrl: 'https://checkout.placeholder.com/starter'),
            PricingPackage(id: 'standard', name: 'Standard Pack', priceText: 'Rp 25.000', billingCycle: 'bulan', credits: 500, checkoutUrl: 'https://checkout.placeholder.com/standard'),
            PricingPackage(id: 'professional', name: 'Professional Pack', priceText: 'Rp 45.000', billingCycle: 'bulan', credits: 1000, checkoutUrl: 'https://checkout.placeholder.com/professional'),
          ],
        )) {
    loadCachedSettings().then((_) => fetchSettings());
  }

  Future<void> loadCachedSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedStr = prefs.getString('sys_settings_cache');
      if (cachedStr != null) {
        state = SystemSettings.fromJson(jsonDecode(cachedStr));
      }
    } catch (e) {
      // Ignore cache load error
    }
  }

  Future<void> fetchSettings() async {
    try {
      final response = await dioClient.get('/admin/settings');
      if (response.data['success'] == true) {
        final data = response.data['data'];
        final settings = SystemSettings.fromJson(data);
        state = settings;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('sys_settings_cache', jsonEncode(settings.toJson()));
      }
    } catch (e) {
      // Keep using current state (cache or default) on connection error
    }
  }
}

final systemSettingsProvider = StateNotifierProvider<SystemSettingsNotifier, SystemSettings>((ref) {
  return SystemSettingsNotifier();
});
