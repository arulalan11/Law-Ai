import 'package:flutter/material.dart';
import 'package:mobile_app/core/widgets/main_drawer.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/providers/language_provider.dart';
import 'package:mobile_app/core/constants/app_strings.dart';

class EmergencyScreen extends ConsumerWidget {
  const EmergencyScreen({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      debugPrint("Cannot launch $launchUri");
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLanguage = ref.watch(languageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get(currentLanguage, 'emergency_assistance')),
        backgroundColor: Colors.red[900],
      ),
      drawer: const MainDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                border: Border.all(color: Colors.redAccent),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.redAccent,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppStrings.get(currentLanguage, 'immediate_danger'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildEmergencyCard(
              title: AppStrings.get(currentLanguage, 'domestic_violence'),
              icon: Icons.family_restroom,
              color: Colors.purpleAccent,
              helplineTitle: "Women's Helpline",
              helplineNumber: "1091",
              steps: [
                "1. Move to a safe location if possible.",
                "2. Call the Women's Helpline (1091) or Police (112).",
                "3. Do not destroy any evidence (messages, photos of injuries).",
                "4. You have the right to request a female officer for your statement.",
              ],
              onCall: () => _makePhoneCall("1091"),
            ),
            const SizedBox(height: 16),
            _buildEmergencyCard(
              title: AppStrings.get(currentLanguage, 'cyber_fraud'),
              icon: Icons.security,
              color: Colors.blueAccent,
              helplineTitle: "Nat. Cyber Crime Reporting",
              helplineNumber: "1930",
              steps: [
                "1. Immediately block your bank cards/accounts.",
                "2. Do not delete the fraudulent emails, messages, or call logs.",
                "3. Take screenshots of all transactions and profiles.",
                "4. Call the 1930 Helpline or report on cybercrime.gov.in.",
              ],
              onCall: () => _makePhoneCall("1930"),
            ),
            const SizedBox(height: 16),
            _buildEmergencyCard(
              title: AppStrings.get(currentLanguage, 'police_arrest'),
              icon: Icons.local_police,
              color: Colors.orangeAccent,
              helplineTitle: "National Legal Aid",
              helplineNumber: "15100",
              steps: [
                "1. Ask the officer for their ID and the reason for arrest.",
                "2. You have the right to inform one relative or friend.",
                "3. Do not sign any document you do not understand or cannot read.",
                "4. You must be presented before a magistrate within 24 hours.",
                "5. Ask for free legal aid if you cannot afford a lawyer.",
              ],
              onCall: () => _makePhoneCall("15100"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyCard({
    required String title,
    required IconData icon,
    required Color color,
    required String helplineTitle,
    required String helplineNumber,
    required List<String> steps,
    required VoidCallback onCall,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        childrenPadding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    helplineTitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    helplineNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: onCall,
                icon: const Icon(Icons.call, color: Colors.white),
                label: const Text(
                  "CALL NOW",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Immediate Steps:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...steps.map(
            (step) => Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("• ", style: TextStyle(color: Colors.white54)),
                  Expanded(
                    child: Text(
                      step,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
