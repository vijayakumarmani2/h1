import 'package:flutter/services.dart';

class LinuxWiFiManager {
  static const MethodChannel _channel = MethodChannel('wifi_manager');

  static Future<List<String>> getAvailableNetworks() async {
    final List<dynamic> networks = await _channel.invokeMethod('getAvailableNetworks');
    return networks.cast<String>();
  }

  static Future<String?> getActiveNetwork() async {
    final String? activeNetwork = await _channel.invokeMethod('getActiveNetwork');
    return activeNetwork;
  }

  static Future<bool> connectToNetwork(String ssid, String password) async {
    final bool result = await _channel.invokeMethod(
      'connectToNetwork',
      {'ssid': ssid, 'password': password},
    );
    return result;
  }
}
