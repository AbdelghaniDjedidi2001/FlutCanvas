// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:typed_data';

class FileDownloader {
  static void downloadBytes({
    required Uint8List bytes,
    required String filename,
    required String mimeType,
  }) {
    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..style.display = 'none';
    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);

    // Revoke object URL with delay so the browser can finish transferring bytes
    Future.delayed(const Duration(seconds: 10), () {
      html.Url.revokeObjectUrl(url);
    });
  }

  static void downloadString({
    required String content,
    required String filename,
    required String mimeType,
  }) {
    final blob = html.Blob([content], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..style.display = 'none';
    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);

    // Revoke object URL with delay so the browser can finish transferring bytes
    Future.delayed(const Duration(seconds: 10), () {
      html.Url.revokeObjectUrl(url);
    });
  }
}
