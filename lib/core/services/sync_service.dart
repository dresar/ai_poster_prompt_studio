import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../network/dio_client.dart';
import 'local_db_service.dart';

class SyncResult {
  final bool hasUpdate;
  final String? remoteChecksum;
  final String? error;

  const SyncResult({
    required this.hasUpdate,
    this.remoteChecksum,
    this.error,
  });
}

/// SyncService handles all offline-first synchronization logic.
/// High-speed optimization: saves data to SQLite instantly (< 500ms),
/// then pre-caches images in the background asynchronously without blocking the UI.
class SyncService {
  SyncService._();
  static final SyncService instance = SyncService._();

  /// Quick check: compare local checksum vs remote.
  Future<SyncResult> checkForUpdates() async {
    try {
      final response = await dioClient.get(
        '/sync/checksum',
        options: Options(
          sendTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );

      if (response.data['success'] != true) {
        return const SyncResult(hasUpdate: false);
      }

      final remoteChecksum = response.data['checksum'] as String?;
      final localChecksum = await LocalDbService.instance.getChecksum();

      final hasUpdate = remoteChecksum != null && remoteChecksum != localChecksum;

      return SyncResult(
        hasUpdate: hasUpdate,
        remoteChecksum: remoteChecksum,
      );
    } catch (e) {
      debugPrint('[SyncService] checkForUpdates error: $e');
      return SyncResult(hasUpdate: false, error: e.toString());
    }
  }

  /// Ultra-fast Sync: saves dropdown options + visual styles to SQLite IMMEDIATELY,
  /// then triggers background image pre-caching non-blockingly.
  Future<bool> performSync({String? expectedChecksum}) async {
    try {
      // 1. Fetch dropdown options
      final dropdownRes = await dioClient.get('/dropdown-options');
      if (dropdownRes.data['success'] != true) {
        throw Exception('Dropdown fetch failed');
      }
      final List<dynamic> rawDropdowns = dropdownRes.data['data'] ?? [];
      final List<Map<String, dynamic>> dropdownsList = rawDropdowns.map((e) => Map<String, dynamic>.from(e as Map)).toList();

      // 2. Fetch visual styles
      final stylesRes = await dioClient.get('/poster/visual-styles');
      if (stylesRes.data['success'] != true) {
        throw Exception('Visual styles fetch failed');
      }
      final List<dynamic> rawStyles = stylesRes.data['data'] ?? [];
      final List<Map<String, dynamic>> stylesList = rawStyles.map((e) => Map<String, dynamic>.from(e as Map)).toList();

      // 3. Save to SQLite INSTANTLY (< 100ms)
      await LocalDbService.instance.saveDropdownOptions(dropdownsList);
      await LocalDbService.instance.saveVisualStyles(stylesList);

      // 4. Save new checksum
      final checksum = expectedChecksum ?? await _fetchChecksum();
      if (checksum != null) {
        await LocalDbService.instance.saveChecksum(checksum);
      }

      // 5. Trigger non-blocking background image pre-caching
      if (!kIsWeb) {
        _bgPrecacheImages(dropdownsList, stylesList);
      }

      debugPrint('[SyncService] Sync completed instantly. ${rawDropdowns.length} dropdowns, ${rawStyles.length} visual styles saved to DB.');
      return true;
    } catch (e) {
      debugPrint('[SyncService] performSync error: $e');
      return false;
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────

  void _bgPrecacheImages(List<Map<String, dynamic>> dropdowns, List<Map<String, dynamic>> styles) async {
    try {
      final cacheDir = await _getImageCacheDir();
      final urls = <String>{};

      for (final opt in dropdowns) {
        final url = opt['icon'] as String?;
        if (url != null && url.startsWith('http')) urls.add(url);
      }
      for (final style in styles) {
        final url = style['previewImageUrl'] as String?;
        if (url != null && url.startsWith('http')) urls.add(url);
      }

      // Download in batches of 5 with 3s timeout per image
      final list = urls.toList();
      for (var i = 0; i < list.length; i += 5) {
        final batch = list.sublist(i, (i + 5 > list.length) ? list.length : i + 5);
        await Future.wait(batch.map((url) => _downloadImageToCache(url, cacheDir).timeout(
          const Duration(seconds: 3),
          onTimeout: () => null,
        )));
      }
    } catch (e) {
      debugPrint('[SyncService] bgPrecache error: $e');
    }
  }

  Future<Directory> _getImageCacheDir() async {
    final cacheRoot = await getApplicationCacheDirectory();
    final imgDir = Directory(p.join(cacheRoot.path, 'visual_style_images'));
    if (!await imgDir.exists()) {
      await imgDir.create(recursive: true);
    }
    return imgDir;
  }

  Future<String?> _downloadImageToCache(String url, Directory cacheDir) async {
    final fileName = url.hashCode.abs().toString() + '_vs.jpg';
    final filePath = p.join(cacheDir.path, fileName);

    final file = File(filePath);
    if (await file.exists()) {
      return filePath;
    }

    try {
      await dioClient.download(
        url,
        filePath,
        options: Options(
          sendTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
        ),
      );
      return filePath;
    } catch (e) {
      debugPrint('[SyncService] Download error for $url: $e');
      return null;
    }
  }

  Future<String?> _fetchChecksum() async {
    try {
      final res = await dioClient.get('/sync/checksum');
      return res.data['checksum'] as String?;
    } catch (_) {
      return null;
    }
  }
}
