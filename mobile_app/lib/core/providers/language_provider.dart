import 'package:flutter_riverpod/flutter_riverpod.dart';

class LanguageNotifier extends Notifier<String> {
  @override
  String build() => 'English';

  void setLanguage(String lang) {
    state = lang;
  }
}

final languageProvider = NotifierProvider<LanguageNotifier, String>(() {
  return LanguageNotifier();
});
