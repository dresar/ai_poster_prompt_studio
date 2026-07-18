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
/// 
/// On startup: silently checks if remote data changed (via checksum).
/// If changed → caller shows a banner. User taps "Sync" → performSync().
/// 
/// Images are downloaded once to local storage and served from there,
/// so the app never re-downloads preview images unnecessarily.
class SyncService {
  SyncService._();
  static final SyncService instance = SyncService._();

  /// Quick check: compare local checksum vs remote.
  /// Returns [SyncResult.hasUpdate = true] if data changed.
  Future<SyncResult> checkForUpdates() async {
    try {
      final response = await dioClient.get(
        '/sync/checksum',
        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
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
      // Network error — do not show update banner, just stay offline
      debugPrint('[SyncService] checkForUpdates error: $e');
      return SyncResult(hasUpdate: false, error: e.toString());
    }
  }

  /// Full sync: downloads fresh dropdown options + visual styles, 
  /// caches them in SQLite, and downloads all preview images to local storage.
  Future<bool> performSync({String? expectedChecksum}) async {
    try {
      // 1. Fetch dropdown options
      final dropdownRes = await dioClient.get('/dropdown-options');
      if (dropdownRes.data['success'] != true) {
        throw Exception('Dropdown fetch failed');
      }
      final List<dynamic> rawDropdowns = dropdownRes.data['data'] ?? [];
      final List<Map<String, dynamic>> dropdownsList = rawDropdowns.map((e) => Map<String, dynamic>.from(e as Map)).toList();

      if (!kIsWeb) {
        final cacheDir = await _getImageCacheDir();

        // Download and cache icons (characters) inside dropdown options
        for (final opt in dropdownsList) {
          final url = opt['icon'] as String?;
          if (url != null && url.startsWith('http')) {
            try {
              final localPath = await _downloadImageToCache(url, cacheDir);
              if (localPath != null) {
                opt['icon'] = 'file://' + localPath;
              }
            } catch (e) {
              debugPrint('[SyncService] Dropdown Icon download failed for $url: $e');
            }
          }
        }
      }
      await LocalDbService.instance.saveDropdownOptions(dropdownsList);

      // 2. Fetch visual styles
      final stylesRes = await dioClient.get('/poster/visual-styles');
      if (stylesRes.data['success'] != true) {
        throw Exception('Visual styles fetch failed');
      }
      final List<dynamic> rawStyles = stylesRes.data['data'] ?? [];

      // 3. Download preview images for visual styles
      final stylesList = rawStyles.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      
      if (!kIsWeb) {
        final cacheDir = await _getImageCacheDir();

        for (final style in stylesList) {
          final url = style['previewImageUrl'] as String?;
          if (url != null && url.startsWith('http')) {
            try {
              final localPath = await _downloadImageToCache(url, cacheDir);
              if (localPath != null) {
                style['localImagePath'] = 'file://' + localPath;
              }
            } catch (e) {
              debugPrint('[SyncService] Image download failed for $url: $e');
            }
          }
        }
      }

      await LocalDbService.instance.saveVisualStyles(stylesList);

      // 4. Save the new checksum
      final checksum = expectedChecksum ?? await _fetchChecksum();
      if (checksum != null) {
        await LocalDbService.instance.saveChecksum(checksum);
      }

      debugPrint('[SyncService] Sync completed. ${rawDropdowns.length} dropdowns, ${rawStyles.length} visual styles.');
      return true;
    } catch (e) {
      debugPrint('[SyncService] performSync error: $e');
      return false;
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────

  Future<Directory> _getImageCacheDir() async {
    final cacheRoot = await getApplicationCacheDirectory();
    final imgDir = Directory(p.join(cacheRoot.path, 'visual_style_images'));
    if (!await imgDir.exists()) {
      await imgDir.create(recursive: true);
    }
    return imgDir;
  }

  Future<String?> _downloadImageToCache(String url, Directory cacheDir) async {
    // Use URL hash as filename to avoid duplicates and re-downloads
    final fileName = url.hashCode.abs().toString() + '_vs.jpg';
    final filePath = p.join(cacheDir.path, fileName);

    final file = File(filePath);
    if (await file.exists()) {
      // Already cached — skip download
      return filePath;
    }

    try {
      // Use pre-configured dioClient to download, ensuring SSL and Base URL interceptors are preserved
      await dioClient.download(url, filePath);
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
