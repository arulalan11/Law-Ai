import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/auth/screens/login_screen.dart';
import 'package:mobile_app/features/chat/screens/chat_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:supabase_flutter/supabase_flutter.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://niyviwluojivnnepaoyr.supabase.co',
    anonKey: 'sb_publishable_SQKw-uJ1Pw2V_NddJM0hmQ_Ug_S-wnf',
  );

  runApp(
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Legal AI Assistant',
      theme: AppTheme.darkTheme,
      home: Supabase.instance.client.auth.currentSession != null
          ? const ChatScreen()
          : const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
