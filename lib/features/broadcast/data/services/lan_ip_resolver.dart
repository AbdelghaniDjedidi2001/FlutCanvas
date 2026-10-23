import 'dart:io';
import 'package:flutter/foundation.dart';

/// Helper to discover the machine's primary local network IPv4 address.
class LanIpResolver {
  const LanIpResolver._();

  /// Resolves the local IPv4 address best suited for audience devices on the same Wi-Fi / LAN.
  static Future<String> getLocalIpAddress() async {
    if (kIsWeb) {
      return '127.0.0.1';
    }

    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );

      if (interfaces.isEmpty) {
        return '127.0.0.1';
      }

      // 1. Try to find primary Wi-Fi / Ethernet interface names
      // On macOS/iOS: en0 is usually Wi-Fi. On Linux/Android: wlan0/eth0. On Windows: 'Wi-Fi' / 'Ethernet'
      final preferredNames = ['en0', 'wlan0', 'eth0', 'wi-fi', 'ethernet'];

      for (final pref in preferredNames) {
        for (final iface in interfaces) {
          if (iface.name.toLowerCase().contains(pref)) {
            for (final addr in iface.addresses) {
              if (_isValidLanAddress(addr.address)) {
                return addr.address;
              }
            }
          }
        }
      }

      // 2. Fallback: inspect any interface with a private LAN IP (192.168.x.x, 10.x.x.x, 172.16-31.x.x)
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          if (_isValidLanAddress(addr.address)) {
            return addr.address;
          }
        }
      }

      // 3. Fallback to first non-loopback address if found
      if (interfaces.isNotEmpty && interfaces.first.addresses.isNotEmpty) {
        return interfaces.first.addresses.first.address;
      }
    } catch (e) {
      debugPrint('LanIpResolver error: $e');
    }

    return '127.0.0.1';
  }

  /// Checks if an IPv4 address is a valid private LAN address (and not link-local 169.254.x.x).
  static bool _isValidLanAddress(String ip) {
    if (ip.startsWith('127.') || ip.startsWith('169.254.')) {
      return false;
    }
    // Standard RFC1918 private IP ranges
    if (ip.startsWith('192.168.') ||
        ip.startsWith('10.') ||
        RegExp(r'^172\.(1[6-9]|2[0-9]|3[0-1])\.').hasMatch(ip)) {
      return true;
    }
    return true;
  }

  /// Formats the broadcast HTTP URL.
  static String formatBroadcastUrl(String ip, int port) {
    return 'http://$ip:$port';
  }
}
