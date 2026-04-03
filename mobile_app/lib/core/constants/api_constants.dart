import 'package:flutter/foundation.dart';

class ApiConstants {
  // Set the current Wi-Fi IP Address of the Windows PC here.
  // This needs to be updated if the PC connects to a different Wi-Fi network
  // or if the router assigns a new dynamic IP.
  static const String localIpAddress = '10.165.12.116';

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    } else {
      // Use the actual local IP address so physical phones can connect
      return 'http://$localIpAddress:8000';
    }
  }
}
