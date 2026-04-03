import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/auth/screens/login_screen.dart';
import 'package:mobile_app/features/chat/screens/chat_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter/foundation.dart';
import 'package:device_preview/device_preview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://niyviwluojivnnepaoyr.supabase.co',
    anonKey: 'sb_publishable_SQKw-uJ1Pw2V_NddJM0hmQ_Ug_S-wnf',
  );

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const ProviderScope(child: MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: 'Legal AI Assistant',
      theme: AppTheme.darkTheme,
      home: Supabase.instance.client.auth.currentSession != null
          ? const ChatScreen()
          : const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
