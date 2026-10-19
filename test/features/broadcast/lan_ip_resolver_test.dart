import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutcanvas/features/broadcast/data/services/lan_ip_resolver.dart';

void main() {
  group('LanIpResolver', () {
    test('formats broadcast URL with IP and port', () {
      final url = LanIpResolver.formatBroadcastUrl('192.168.1.42', 4040);
      expect(url, 'http://192.168.1.42:4040');
    });

    test('formats broadcast URL with loopback IP and custom port', () {
      final url = LanIpResolver.formatBroadcastUrl('127.0.0.1', 8080);
      expect(url, 'http://127.0.0.1:8080');
    });

    test('resolves a valid non-empty IPv4 address on the host machine', () async {
      final ip = await LanIpResolver.getLocalIpAddress();
      expect(ip, isNotEmpty);
      final parsed = InternetAddress.tryParse(ip);
      expect(parsed, isNotNull);
      expect(parsed!.type, InternetAddressType.IPv4);
    });
  });
}
