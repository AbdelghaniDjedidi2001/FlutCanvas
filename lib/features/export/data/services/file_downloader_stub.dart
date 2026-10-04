import 'dart:typed_data';

abstract class FileDownloader {
  static void downloadBytes({
    required Uint8List bytes,
    required String filename,
    required String mimeType,
  }) {
    throw UnsupportedError('Cannot download on this platform');
  }

  static void downloadString({
    required String content,
    required String filename,
    required String mimeType,
  }) {
    throw UnsupportedError('Cannot download on this platform');
  }
}
