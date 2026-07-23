import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:flutter/foundation.dart';

/// CacheService handles image pre-caching for instant dropdown display.
/// Priority order for images:
///   1. Local file (downloaded by SyncService) → [FileImage]
///   2. Network URL → [NetworkImage] with in-memory Flutter cache
class CacheService {
  CacheService._();
  static final CacheService instance = CacheService._();

  bool _hasPreloaded = false;
  String? _cacheDirPath;

  /// Initialize and resolve visual_style_images cache directory in memory
  Future<void> init() async {
    if (kIsWeb) return;
    try {
      final cacheRoot = await getApplicationCacheDirectory();
      _cacheDirPath = p.join(cacheRoot.path, 'visual_style_images');
      final dir = Directory(_cacheDirPath!);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    } catch (e) {
      debugPrint('[CacheService] init error: $e');
    }
  }

  /// Check if local cached file exists for a given network URL
  String? getLocalCachePathFor(String url) {
    if (kIsWeb || _cacheDirPath == null) return null;
    final fileName = url.hashCode.abs().toString() + '_vs.jpg';
    final path = p.join(_cacheDirPath!, fileName);
    final file = File(path);
    if (file.existsSync()) {
      return path;
    }
    return null;
  }

  /// Returns the appropriate [ImageProvider] for an icon URL.
  /// Checks if a local file path is available (from SQLite cache),
  /// otherwise falls back to [NetworkImage].
  ImageProvider imageProviderFor({
    String? localPath,
    required String networkUrl,
  }) {
    if (!kIsWeb && localPath != null && localPath.isNotEmpty) {
      final cleanPath = localPath.replaceFirst('file://', '');
      final file = File(cleanPath);
      if (file.existsSync()) {
        return FileImage(file);
      }
    }
    
    // Dynamic cache check
    if (!kIsWeb) {
      final localCachedPath = getLocalCachePathFor(networkUrl);
      if (localCachedPath != null) {
        return FileImage(File(localCachedPath));
      }
    }
    
    return NetworkImage(networkUrl);
  }

  /// Precache all visual style preview images into Flutter's image cache.
  /// Supports both local files and network URLs for instant display.
  Future<void> precacheVisualStyleImages({
    required BuildContext context,
    required List<({String url, String? localPath})> images,
  }) async {
    if (kIsWeb) return;
    if (_hasPreloaded) return;
    _hasPreloaded = true;

    for (final img in images) {
      try {
        final provider = imageProviderFor(
          localPath: img.localPath,
          networkUrl: img.url,
        );
        await precacheImage(provider, context);
      } catch (_) {
        // Ignore failures — images are nice-to-have
      }
    }
  }

  /// Legacy method for backward compatibility — only uses network URLs.
  Future<void> precacheVisualStyleImagesFromUrls({
    required BuildContext context,
    required List<String> imageUrls,
  }) async {
    await precacheVisualStyleImages(
      context: context,
      images: imageUrls.map((url) => (url: url, localPath: null)).toList(),
    );
  }

  /// Simpan versi terakhir data (untuk invalidasi manual jika perlu)
  Future<void> setDataVersion(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_data_version', version);
  }

  Future<String?> getDataVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('app_data_version');
  }

  /// Reset preload flag (called after a sync to re-precache new images)
  void resetPreloadFlag() {
    _hasPreloaded = false;
  }

  /// Hapus seluruh cache lokal (untuk keperluan debug / force refresh)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) =>
      k.startsWith('dropdown_') ||
      k.startsWith('app_data_'));
    for (final key in keys) {
      await prefs.remove(key);
    }
    _hasPreloaded = false;
  }
}
