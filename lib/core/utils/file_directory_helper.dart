import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'download_helper.dart';

class FileSaveResult {
  final bool isSuccess;
  final String fileName;
  final String filePath;
  final String displayLocation;
  final String? errorMessage;

  FileSaveResult({
    required this.isSuccess,
    required this.fileName,
    required this.filePath,
    required this.displayLocation,
    this.errorMessage,
  });
}

class FileDirectoryHelper {
  /// Mendapatkan folder penyimpanan publik yang dapat diakses pengguna di File Manager HP (Folder Download > AIPosterStudio)
  static Future<Directory> getPublicDirectory() async {
    if (kIsWeb) {
      final dir = await getApplicationDocumentsDirectory();
      return dir;
    }

    if (Platform.isAndroid) {
      // Prioritaskan folder Download publik HP di /storage/emulated/0/Download/AIPosterStudio
      final candidates = [
        Directory('/storage/emulated/0/Download/AIPosterStudio'),
        Directory('/sdcard/Download/AIPosterStudio'),
        Directory('/storage/emulated/0/Documents/AIPosterStudio'),
      ];

      for (final candidate in candidates) {
        try {
          if (!await candidate.exists()) {
            await candidate.create(recursive: true);
          }
          return candidate;
        } catch (_) {
          // Lanjut ke kandidat berikutnya jika gagal karena ijin
        }
      }
    }

    // Fallback untuk iOS / Desktop / Android fallback
    final baseDir = await getApplicationDocumentsDirectory();
    final appDir = Directory('${baseDir.path}/AIPosterStudio');
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }
    return appDir;
  }

  /// Menyimpan file ke folder Download publik HP atau mendownload via browser di Web
  static Future<FileSaveResult> saveFile({
    required String fileName,
    required String content,
  }) async {
    try {
      if (kIsWeb) {
        downloadFileWeb(content, fileName);
        return FileSaveResult(
          isSuccess: true,
          fileName: fileName,
          filePath: fileName,
          displayLocation: 'Folder Downloads Browser',
        );
      }

      final dir = await getPublicDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsString(content);

      String displayLoc = dir.path;
      if (dir.path.contains('/Download/')) {
        displayLoc = 'Penyimpanan Internal > Download > AIPosterStudio';
      } else if (dir.path.contains('/Documents/')) {
        displayLoc = 'Penyimpanan Internal > Documents > AIPosterStudio';
      }

      return FileSaveResult(
        isSuccess: true,
        fileName: fileName,
        filePath: file.path,
        displayLocation: displayLoc,
      );
    } catch (e) {
      return FileSaveResult(
        isSuccess: false,
        fileName: fileName,
        filePath: '',
        displayLocation: '',
        errorMessage: e.toString(),
      );
    }
  }
}
