import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/dio_client.dart';

class AppUpdateInfo {
  final bool hasUpdate;
  final String latestVersion;
  final String currentVersion;
  final String apkUrl;
  final String title;
  final String description;
  final List<String> changelog;
  final String fileSizeMb;
  final bool isMandatory;

  AppUpdateInfo({
    required this.hasUpdate,
    required this.latestVersion,
    required this.currentVersion,
    required this.apkUrl,
    required this.title,
    required this.description,
    required this.changelog,
    required this.fileSizeMb,
    required this.isMandatory,
  });
}

class UpdateService {
  static const String currentVersion = '1.0.0';
  static const int currentBuildNumber = 1;

  static final UpdateService _instance = UpdateService._internal();
  static UpdateService get instance => _instance;
  UpdateService._internal();

  /// Check for app updates from cPanel version.json or backend route /api/update/check
  Future<AppUpdateInfo?> checkForUpdates({String? customCpanelUrl}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCustomUrl = prefs.getString('custom_update_url');

      final String targetUrl = customCpanelUrl ??
          (savedCustomUrl != null && savedCustomUrl.isNotEmpty
              ? savedCustomUrl
              : '/update/check?version=$currentVersion');

      dynamic responseData;

      if (targetUrl.startsWith('http://') || targetUrl.startsWith('https://')) {
        final standaloneDio = Dio();
        final res = await standaloneDio.get(targetUrl);
        responseData = res.data;
      } else {
        final res = await dioClient.get(targetUrl);
        responseData = res.data;
      }

      if (responseData == null) return null;

      final data = responseData['data'] ?? responseData;
      final latestVer = (data['latestVersion'] ?? '1.0.0').toString();
      final apkUrl = (data['apkUrl'] ?? '').toString();
      final title = (data['title'] ?? 'Pembaruan Aplikasi').toString();
      final description = (data['description'] ?? 'Versi baru telah tersedia.').toString();
      final fileSize = (data['fileSizeMb'] ?? '67.7 MB').toString();
      final isMandatory = data['isMandatory'] == true;

      final List<String> changelogList = data['changelog'] != null
          ? List<String>.from(data['changelog'].map((e) => e.toString()))
          : [
              '✨ Fitur Karakter & Maskot Bible Generator 16:9',
              '🎨 Fitur Gaya Visual Design System Blueprint',
              '🎯 Perbaikan Tempat Logo Canva (Badge Lingkaran LOGO)',
              '📱 Layout Form 1 Baris Ke Bawah (Rapi & Responsif)',
              '⚡ Saran AI Otomatis di Semua Field Form',
            ];

      final bool hasUpdate = responseData['hasUpdate'] == true ||
          isVersionGreater(latestVer, currentVersion);

      return AppUpdateInfo(
        hasUpdate: hasUpdate,
        latestVersion: latestVer,
        currentVersion: currentVersion,
        apkUrl: apkUrl,
        title: title,
        description: description,
        changelog: changelogList,
        fileSizeMb: fileSize,
        isMandatory: isMandatory,
      );
    } catch (e) {
      debugPrint('UpdateService check error: $e');
      return null;
    }
  }

  /// Compares two semver strings (e.g., '1.1.0' vs '1.0.0')
  static bool isVersionGreater(String v1, String v2) {
    final p1 = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final p2 = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    for (int i = 0; i < p1.length || i < p2.length; i++) {
      final num1 = i < p1.length ? p1[i] : 0;
      final num2 = i < p2.length ? p2[i] : 0;
      if (num1 > num2) return true;
      if (num1 < num2) return false;
    }
    return false;
  }

  /// Download and trigger APK installation
  Future<bool> downloadAndInstallApk(
    String apkUrl, {
    required Function(double progress, String status) onProgress,
  }) async {
    try {
      if (apkUrl.isEmpty) return false;

      // 1. If web or fallback, launch direct URL to APK in browser/downloader
      final Uri uri = Uri.parse(apkUrl);

      if (kIsWeb) {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return true;
        }
        return false;
      }

      // 2. Mobile Native Download via Dio
      onProgress(0.05, 'Menyiapkan ruang penyimpanan...');
      final dir = await getTemporaryDirectory();
      final savePath = '${dir.path}/app-update.apk';

      final file = File(savePath);
      if (await file.exists()) {
        await file.delete();
      }

      final dio = Dio();
      onProgress(0.10, 'Mulai mengunduh file APK...');

      await dio.download(
        apkUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total);
            onProgress(progress, 'Mengunduh APK: ${(progress * 100).toStringAsFixed(0)}%');
          }
        },
      );

      onProgress(1.0, 'Mengunduh selesai! Membuka installer...');

      // Launch file URI to trigger package installer on Android
      final Uri fileUri = Uri.file(savePath);
      if (await canLaunchUrl(fileUri)) {
        await launchUrl(fileUri, mode: LaunchMode.externalApplication);
        return true;
      } else if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('Error downloading/installing APK: $e');
      // Fallback: try launching direct URL
      try {
        final Uri uri = Uri.parse(apkUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return true;
        }
      } catch (_) {}
      return false;
    }
  }
}
