import 'package:flutter/material.dart';
import 'package:mobile_app/core/widgets/main_drawer.dart';
import 'package:mobile_app/core/providers/language_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobile_app/core/constants/api_constants.dart';
import 'package:mobile_app/core/constants/app_strings.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _dailyTip = 'Loading...';
  bool _isLoadingTip = true;

  @override
  void initState() {
    super.initState();
    _fetchDailyTip();
  }

  Future<void> _fetchDailyTip() async {
    try {
      final language = ref.read(languageProvider);
      final baseUrl = ApiConstants.baseUrl;
      final response = await http.get(
        Uri.parse('$baseUrl/api/legal/daily-legal-tip?language=$language'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _dailyTip = data['tip'] ?? 'No tip available.';
          _isLoadingTip = false;
        });
      } else {
        setState(() {
          _dailyTip =
              'Failed to load daily tip. (Status: ${response.statusCode})';
          _isLoadingTip = false;
        });
      }
    } catch (e) {
      setState(() {
        _dailyTip =
            'Error connecting to server. Make sure the backend is running.';
        _isLoadingTip = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguage = ref.watch(languageProvider);
    ref.listen(languageProvider, (previous, next) {
      if (previous != next) {
        setState(() {
          _isLoadingTip = true;
        });
        _fetchDailyTip();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get(currentLanguage, 'legal_awareness')),
      ),
      drawer: const MainDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionHeader(
              AppStrings.get(currentLanguage, 'daily_legal_tip'),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb, color: Colors.yellow),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.get(currentLanguage, 'did_you_know'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _isLoadingTip
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : Text(
                            _dailyTip,
                            style: const TextStyle(color: Colors.white70),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
