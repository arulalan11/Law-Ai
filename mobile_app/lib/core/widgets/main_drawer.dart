import 'package:flutter/material.dart';
import 'package:mobile_app/features/chat/screens/chat_screen.dart';
import 'package:mobile_app/features/legal_resources/screens/ipc_screen.dart';
import 'package:mobile_app/features/legal_resources/screens/templates_screen.dart';
import 'package:mobile_app/features/legal_resources/screens/dashboard_screen.dart';
import 'package:mobile_app/features/legal_resources/screens/emergency_screen.dart';
import 'package:mobile_app/features/legal_resources/screens/authority_locator_screen.dart';
import 'package:mobile_app/features/auth/screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/providers/language_provider.dart';
import 'package:mobile_app/core/constants/app_strings.dart';

class MainDrawer extends ConsumerStatefulWidget {
  const MainDrawer({super.key});

  @override
  ConsumerState<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends ConsumerState<MainDrawer> {
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchConversations();
  }

  Future<void> _fetchConversations() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final data = await Supabase.instance.client
          .from('conversations')
          .select()
          .eq('user_id', user.id)
          .order('updated_at', ascending: false);

      if (mounted) {
        setState(() {
          _conversations = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching conversations: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguage = ref.watch(languageProvider);
    final user = Supabase.instance.client.auth.currentUser;
    final guestStr = AppStrings.get(currentLanguage, 'guest_user');
    final userEmail = user?.email ?? guestStr;

    return Drawer(
      backgroundColor: const Color(0xFF1A1A1A),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    // Profile Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 36,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              color: Colors.black,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            userEmail.split('@')[0], // Username only
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Actions
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF252525),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blueAccent.withValues(alpha: 0.3),
                          ),
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.blueAccent,
                          ),
                          title: Text(
                            AppStrings.get(currentLanguage, 'new_chat'),
                            style: const TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).pop(); Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const ChatScreen(),
                                transitionsBuilder:
                                    (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                      child,
                                    ) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green[900]?.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.greenAccent.withValues(alpha: 0.5),
                          ),
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.location_on,
                            color: Colors.greenAccent,
                          ),
                          title: Text(
                            AppStrings.get(
                              currentLanguage,
                              'authority_locator',
                            ),
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).pop(); Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const AuthorityLocatorScreen(),
                                transitionsBuilder:
                                    (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                      child,
                                    ) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red[900]?.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.redAccent.withValues(alpha: 0.5),
                          ),
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.redAccent,
                          ),
                          title: Text(
                            AppStrings.get(currentLanguage, 'emergency_sos'),
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).pop(); Navigator.of(context).push(
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const EmergencyScreen(),
                                transitionsBuilder:
                                    (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                      child,
                                    ) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                      ),
                      leading: const Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.white70,
                      ),
                      title: Text(
                        AppStrings.get(
                          currentLanguage,
                          'daily_update_dashboard',
                        ),
                        style: const TextStyle(color: Colors.white70),
                      ),
                      onTap: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                      ),
                      leading: const Icon(
                        Icons.description_outlined,
                        color: Colors.white70,
                      ),
                      title: Text(
                        AppStrings.get(
                          currentLanguage,
                          'documentation_templates',
                        ),
                        style: const TextStyle(color: Colors.white70),
                      ),
                      onTap: () {
                        Navigator.of(context).pop(); Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const TemplatesScreen(),
                            transitionsBuilder:
                                (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                          ),
                        );
                      },
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                      ),
                      leading: const Icon(
                        Icons.menu_book_outlined,
                        color: Colors.white70,
                      ),
                      title: Text(
                        AppStrings.get(currentLanguage, 'ipc_section_finder'),
                        style: const TextStyle(color: Colors.white70),
                      ),
                      onTap: () {
                        Navigator.of(context).pop(); Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const IPCScreen(),
                            transitionsBuilder:
                                (
                                  context,
                                  animation,
                                  secondaryAnimation,
                                  child,
                                ) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                          ),
                        );
                      },
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Divider(color: Colors.white12, height: 32),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          AppStrings.get(currentLanguage, 'chat_history'),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Chat History Items
                    _isLoading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : _conversations.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                AppStrings.get(
                                  currentLanguage,
                                  'no_chat_history',
                                ),
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          )
                        : Column(
                            children: _conversations.map((conv) {
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 24.0,
                                ),
                                title: Text(
                                  conv['title'] ??
                                      AppStrings.get(
                                        currentLanguage,
                                        'new_chat',
                                      ),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () {
                                  Navigator.of(context).pop(); Navigator.of(context).push(
                                    PageRouteBuilder(
                                      pageBuilder:
                                          (
                                            context,
                                            animation,
                                            secondaryAnimation,
                                          ) => ChatScreen(
                                            conversationId: conv['id'],
                                          ),
                                      transitionsBuilder:
                                          (
                                            context,
                                            animation,
                                            secondaryAnimation,
                                            child,
                                          ) {
                                            return FadeTransition(
                                              opacity: animation,
                                              child: child,
                                            );
                                          },
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                  ],
                ),
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24.0),
              leading: const Icon(
                Icons.power_settings_new,
                color: Colors.redAccent,
              ),
              title: Text(
                AppStrings.get(currentLanguage, 'logout'),
                style: const TextStyle(color: Colors.white70),
              ),
              onTap: () async {
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
