// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:html' as html;

class ClipboardPasteService {
  static StreamSubscription? _pasteSubscription;

  static void initWebPasteListener(void Function(String base64Image) onImagePasted) {
    _pasteSubscription?.cancel();
    _pasteSubscription = html.document.onPaste.listen((html.ClipboardEvent e) {
      // Ignore paste events triggered while user is actively typing inside an input/textarea
      final target = e.target;
      if (target is html.InputElement || target is html.TextAreaElement) {
        return;
      }

      final items = e.clipboardData?.items;
      if (items == null) return;
      final count = items.length ?? 0;

      for (var i = 0; i < count; i++) {
        final item = items[i];
        if (item.type != null && item.type!.startsWith('image/')) {
          final file = item.getAsFile();
          if (file != null) {
            final reader = html.FileReader();
            reader.onLoadEnd.listen((_) {
              final result = reader.result;
              if (result is String) {
                final base64Str = result.contains(',')
                    ? result.substring(result.indexOf(',') + 1)
                    : result;
                onImagePasted(base64Str);
              }
            });
            reader.readAsDataUrl(file);
          }
          break;
        }
      }
    });
  }

  static void dispose() {
    _pasteSubscription?.cancel();
    _pasteSubscription = null;
  }
}
