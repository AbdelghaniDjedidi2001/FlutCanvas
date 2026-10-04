import 'dart:convert';
import 'dart:ui' as ui;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class ImageService {
  static final Map<String, ui.Image> _imageCache = {};

  /// Prompts the user to pick an image file and returns base64 encoded string + aspect ratio
  static Future<({String base64, double width, double height})?> pickImage() async {
    try {
      final result = await FilePickerPlatform.instance.pickFiles(
        type: FileType.image,
      );

      if (result.isNotEmpty) {
        final file = result.first;
        final bytes = await file.readAsBytes();
        final base64Str = base64Encode(bytes);

        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        final img = frame.image;
        _imageCache[base64Str] = img;

        return (
          base64: base64Str,
          width: img.width.toDouble(),
          height: img.height.toDouble(),
        );
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
    return null;
  }

  /// Retrieves or lazily loads a ui.Image from base64 string
  static ui.Image? getImage(String base64Str) {
    if (_imageCache.containsKey(base64Str)) {
      return _imageCache[base64Str];
    }

    // Lazily trigger async load
    try {
      final bytes = base64Decode(base64Str);
      ui.instantiateImageCodec(bytes).then((codec) {
        codec.getNextFrame().then((frame) {
          _imageCache[base64Str] = frame.image;
        });
      });
    } catch (_) {}
    return null;
  }
}
