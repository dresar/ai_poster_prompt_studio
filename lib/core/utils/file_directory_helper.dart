import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileDirectoryHelper {
  static Future<Directory> getPublicDirectory() async {
    Directory? appDir;
    if (Platform.isAndroid) {
      // Create folder in public Documents directory for easy access
      appDir = Directory('/storage/emulated/0/Documents/AIPosterStudio');
    } else {
      // Fallback for iOS/Web/Desktop
      final dir = await getApplicationDocumentsDirectory();
      appDir = Directory('${dir.path}/AIPosterStudio');
    }
    
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }
    
    return appDir;
  }
}
