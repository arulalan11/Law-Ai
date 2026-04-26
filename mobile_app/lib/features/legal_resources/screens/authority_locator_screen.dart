import 'package:flutter/material.dart';
import 'package:mobile_app/core/widgets/main_drawer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/providers/language_provider.dart';
import 'package:mobile_app/core/constants/app_strings.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthorityLocatorScreen extends ConsumerWidget {
  const AuthorityLocatorScreen({super.key});

  Future<void> _launchMaps(BuildContext context, String query) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
    );
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open map app.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLanguage = ref.watch(languageProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get(currentLanguage, 'authority_locator')),
      ),
      drawer: const MainDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0, top: 16.0),
              child: Text(
                AppStrings.get(currentLanguage, 'find_legal_authorities'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            _buildAuthorityCard(
              context,
              AppStrings.get(currentLanguage, 'police_stations'),
              Icons.local_police,
              Colors.blueAccent,
              'police stations near me',
            ),
            _buildAuthorityCard(
              context,
              AppStrings.get(currentLanguage, 'courts'),
              Icons.gavel,
              Colors.orangeAccent,
              'courts near me',
            ),
            _buildAuthorityCard(
              context,
              AppStrings.get(currentLanguage, 'lawyers_advocates'),
              Icons.person,
              Colors.greenAccent,
              'lawyers near me',
            ),
            _buildAuthorityCard(
              context,
              AppStrings.get(currentLanguage, 'legal_aid_clinics'),
              Icons.healing,
              Colors.redAccent,
              'free legal aid clinics near me',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorityCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String query,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _launchMaps(context, query),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white54,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
