import 'package:flutter/foundation.dart';

class AppConstants {
  // ---------------------------------------------------------------------------
  // IMPORTANT: For physical devices, replace '10.0.2.2' with your computer's local IP address.
  // Example: static const String _localIp = '192.168.1.5';
  // You can find this by running 'ipconfig' (Windows) or 'ifconfig' (Mac/Linux)
  // ---------------------------------------------------------------------------
  static const String _localIp = '10.122.188.108'; // Detect IP from ipconfig
  
  static const String _port = '8001';

  static String get apiBaseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:$_port';
    } else {
      // For Android Emulator, 10.0.2.2 maps to host localhost.
      // For physical devices, you must change _localIp to your machine's LAN IP or use a tunnel (ngrok).
      return 'http://$_localIp:$_port';
    }
  }

  static String get predictionEndpoint => '$apiBaseUrl/predict';
}
