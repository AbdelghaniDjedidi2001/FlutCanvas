import 'dart:io';
import 'dart:typed_data';

class FileDownloader {
  static void downloadBytes({
    required Uint8List bytes,
    required String filename,
    required String mimeType,
  }) {
    // For desktop/mobile, writes to the current download directory or temporary path
    try {
      final dir = Directory.current;
      final file = File('${dir.path}/$filename');
      file.writeAsBytesSync(bytes);
    } catch (_) {
      // Fallback
    }
  }

  static void downloadString({
    required String content,
    required String filename,
    required String mimeType,
  }) {
    try {
      final dir = Directory.current;
      final file = File('${dir.path}/$filename');
      file.writeAsStringSync(content);
    } catch (_) {
      // Fallback
    }
  }
}
