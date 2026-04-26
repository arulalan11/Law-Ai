import 'package:flutter/foundation.dart';

class ApiConstants {
  // Set the current Wi-Fi IP Address of the Windows PC here.
  // This needs to be updated if the PC connects to a different Wi-Fi network
  // or if the router assigns a new dynamic IP.
  static const String localIpAddress = '10.165.12.116';

  static String get baseUrl {
    // Return production Render API URL
    return 'https://law-ai-vsa3.onrender.com';
  }
}
