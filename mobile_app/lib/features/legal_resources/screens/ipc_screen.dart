import 'package:flutter/material.dart';
import 'package:mobile_app/core/widgets/main_drawer.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/core/constants/api_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/providers/language_provider.dart';

class IPCScreen extends ConsumerStatefulWidget {
  const IPCScreen({super.key});

  @override
  ConsumerState<IPCScreen> createState() => _IPCScreenState();
}

class _IPCScreenState extends ConsumerState<IPCScreen> {
  final _searchController = TextEditingController();
  List<Map<String, String>> _results = [];
  bool _isLoading = false;

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final baseUrl = ApiConstants.baseUrl;
      final language = ref.read(languageProvider);
      final uri = Uri.parse(
        '$baseUrl/api/legal/ipc-search?query=${Uri.encodeComponent(query)}&language=${Uri.encodeComponent(language)}',
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final resultsList = List<Map<String, dynamic>>.from(
          data['results'] ?? [],
        );

        setState(() {
          _results = resultsList
              .map(
                (e) => {
                  'section': e['section']?.toString() ?? 'Unknown Section',
                  'title': e['title']?.toString() ?? 'No Title',
                  'detail': e['detail']?.toString() ?? 'No Details',
                  'simplified_explanation':
                      e['simplified_explanation']?.toString() ??
                      'No simplified explanation available.',
                },
              )
              .toList();
        });
      }
    } catch (e) {
      // Handle error gracefully or silently
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('IPC Section Finder')),
        drawer: const MainDrawer(),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search by keyword (e.g. "theft")',
                  prefixIcon: Icon(Icons.search),
                ),
                onSubmitted: (val) {
                  _performSearch(val);
                },
                onChanged: (val) {
                  if (val.isEmpty) {
                    setState(() {
                      _results = [];
                    });
                  }
                },
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isLoading
                    ? const Center(
                        key: ValueKey('loading'),
                        child: CircularProgressIndicator(),
                      )
                    : _results.isEmpty &&
                          _searchController.text.trim().isNotEmpty &&
                          !_isLoading
                    ? const Center(
                        key: ValueKey('no_results'),
                        child: Text(
                          'No matching sections found.',
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : _results.isEmpty
                    ? Center(
                        key: const ValueKey('empty_state'),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.menu_book,
                              size: 64,
                              color: Colors.white24,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Search for Indian Penal Code sections\nby number (e.g., "302") or keyword',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        key: const ValueKey('results_list'),
                        padding: const EdgeInsets.all(16),
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final item = _results[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ExpansionTile(
                              title: Text(
                                item['section']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              subtitle: Text(
                                item['title']!,
                                style: const TextStyle(color: Colors.white70),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.blueAccent.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.blueAccent.withValues(
                                              alpha: 0.3,
                                            ),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Row(
                                              children: [
                                                Icon(
                                                  Icons.lightbulb_outline,
                                                  color: Colors.blueAccent,
                                                  size: 18,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  "Simplified Meaning",
                                                  style: TextStyle(
                                                    color: Colors.blueAccent,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              item['simplified_explanation']!,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                height: 1.4,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        "Legal Definition:",
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item['detail']!,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Divider(color: Colors.white12),
                                      const Text(
                                        "Reference: Indian Penal Code / BNS",
                                        style: TextStyle(
                                          color: Colors.white38,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
    );
  }
}
