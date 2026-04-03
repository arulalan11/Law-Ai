import 'package:flutter/material.dart';
import 'package:mobile_app/core/widgets/main_drawer.dart';
import 'package:mobile_app/core/providers/language_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:mobile_app/core/constants/api_constants.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:mobile_app/features/legal_resources/screens/dashboard_screen.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String? conversationId;
  const ChatScreen({super.key, this.conversationId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  bool _speechEnabled = false;
  bool _isTyping = false;
  bool _isSpeaking = false;
  String? _currentlySpeakingText;

  String? _documentBase64;
  String? _documentFileName;
  String? _documentMimeType;

  String _currentConversationId = '';
  final _uuid = const Uuid();

  final List<Map<String, dynamic>> _messages = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    _currentConversationId = widget.conversationId ?? _uuid.v4();
    _initSpeech();
    _initTts();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    if (widget.conversationId == null) {
      final initialMessage = {
        "role": "assistant",
        "content":
            "Hello! I am your AI Legal Assistant. How can I help you regarding Indian law today?",
        "suggestions": <String>[],
      };
      setState(() {
        _messages.add(initialMessage);
      });
      return;
    }

    try {
      final data = await Supabase.instance.client
          .from('messages')
          .select()
          .eq('conversation_id', widget.conversationId!)
          .order('created_at', ascending: true);

      setState(() {
        for (var i = 0; i < data.length; i++) {
          final m = data[i];
          _messages.add({
            "role": m['role'],
            "content": m['content'],
            "suggestions": <String>[],
          });
          // For initial load, we animate them in sequentially
          _listKey.currentState?.insertItem(i);
        }
      });
    } catch (e) {
      debugPrint('Error fetching messages: $e');
    }
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _initTts() async {
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setPitch(1.0);
    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _currentlySpeakingText = null;
        });
      }
    });
    _flutterTts.setErrorHandler((message) {
      debugPrint('TTS Error: $message');
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _currentlySpeakingText = null;
        });
      }
    });
  }

  /// Strips markdown formatting so TTS reads clean text.
  String _stripMarkdown(String text) {
    // Remove bold/italic markers
    String clean = text
        .replaceAll(RegExp(r'\*\*\*(.+?)\*\*\*'), r'$1')
        .replaceAll(RegExp(r'\*\*(.+?)\*\*'), r'$1')
        .replaceAll(RegExp(r'\*(.+?)\*'), r'$1')
        .replaceAll(RegExp(r'_(.+?)_'), r'$1');
    // Remove headings
    clean = clean.replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '');
    // Remove inline code
    clean = clean.replaceAll(RegExp(r'`(.+?)`'), r'$1');
    // Remove code blocks
    clean = clean.replaceAll(RegExp(r'```[\s\S]*?```'), '');
    // Remove markdown links [text](url) → text
    clean = clean.replaceAll(RegExp(r'\[(.+?)\]\(.*?\)'), r'$1');
    // Remove horizontal rules
    clean = clean.replaceAll(RegExp(r'^[-*_]{3,}\s*$', multiLine: true), '');
    // Remove blockquote markers
    clean = clean.replaceAll(RegExp(r'^>\s?', multiLine: true), '');
    // Clean up extra whitespace
    clean = clean.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
    return clean;
  }

  /// Returns the locale code string for a given language name.
  String _langCode(String language) {
    switch (language) {
      case 'Hindi':     return 'hi-IN';
      case 'Tamil':     return 'ta-IN';
      case 'Telugu':    return 'te-IN';
      case 'Kannada':   return 'kn-IN';
      case 'Malayalam': return 'ml-IN';
      default:          return 'en-IN';
    }
  }

  void _startListening() async {
    final language = ref.read(languageProvider);
    String localeId = 'en-IN';
    switch (language) {
      case 'Hindi': localeId = 'hi-IN'; break;
      case 'Tamil': localeId = 'ta-IN'; break;
      case 'Telugu': localeId = 'te-IN'; break;
      case 'Kannada': localeId = 'kn-IN'; break;
      case 'Malayalam': localeId = 'ml-IN'; break;
    }

    await _speechToText.listen(
      localeId: localeId,
      onResult: (result) {
        setState(() {
          _messageController.text = result.recognizedWords;
        });
      },
    );
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  Future<void> _speak(String text, String language) async {
    // Toggle off if already speaking the same message
    if (_isSpeaking && _currentlySpeakingText == text) {
      await _flutterTts.stop();
      setState(() {
        _isSpeaking = false;
        _currentlySpeakingText = null;
      });
      return;
    }
    if (_isSpeaking) {
      await _flutterTts.stop();
    }

    // Strip markdown so symbols aren't read aloud
    final cleanText = _stripMarkdown(text);

    // Determine the desired locale
    String langCode = _langCode(language);

    // Check available TTS voices and fall back gracefully
    bool voiceAvailable = false;
    try {
      final availableLanguages = await _flutterTts.getLanguages;
      if (availableLanguages != null) {
        final langList = List<String>.from(availableLanguages);
        if (langList.contains(langCode)) {
          voiceAvailable = true;
        } else if (langList.contains(langCode.split('-').first)) {
          // Use base language code (e.g. 'hi' instead of 'hi-IN')
          langCode = langCode.split('-').first;
          voiceAvailable = true;
        } else {
          // Voice not installed — warn the user and fall back to English
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '$language TTS voice is not installed on this device. '
                  'Playing in English. Please install the $language voice '
                  'in your device Settings → Accessibility → TTS.',
                ),
                duration: const Duration(seconds: 5),
                backgroundColor: Colors.orange[800],
              ),
            );
          }
          langCode = 'en-IN';
          voiceAvailable = true;
        }
      } else {
        voiceAvailable = true; // Can't check — try anyway
      }
    } catch (_) {
      voiceAvailable = true; // Can't check — try anyway
    }

    if (!voiceAvailable) return;

    await _flutterTts.setLanguage(langCode);

    setState(() {
      _isSpeaking = true;
      _currentlySpeakingText = text;
    });
    await _flutterTts.speak(cleanText);
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty && _documentBase64 == null) {
      return;
    }

    final userText = _messageController.text.trim();
    String formattedContent = userText;
    if (_documentFileName != null) {
      formattedContent += "\n[Attached file: $_documentFileName]";
    }

    final newMessageIndex = _messages.length;
    setState(() {
      _messages.add({
        "role": "user",
        "content": formattedContent,
        "suggestions": <String>[],
      });
      _messageController.clear();
      _isTyping = true;
    });
    _listKey.currentState?.insertItem(
      newMessageIndex,
      duration: const Duration(milliseconds: 300),
    );

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        if (_messages.length == 2 || widget.conversationId == null) {
          // It's the first user message, create/upsert the conversation
          await Supabase.instance.client.from('conversations').upsert({
            'id': _currentConversationId,
            'user_id': user.id,
            'title': 'New Legal Chat',
          });
        }
        await Supabase.instance.client.from('messages').insert({
          'id': _uuid.v4(),
          'conversation_id': _currentConversationId,
          'role': 'user',
          'content': formattedContent,
        });
      }
    } catch (e) {
      debugPrint('Error saving user message: $e');
    }

    try {
      final selectedLanguage = ref.read(languageProvider);
      final baseUrl = ApiConstants.baseUrl;
      final uri = Uri.parse('$baseUrl/api/chat/');

      final bodyData = {
        "conversation_id": _currentConversationId,
        "messages": _messages
            .map((m) => {"role": m["role"], "content": m["content"]})
            .toList(),
        "language": selectedLanguage,
      };

      if (_documentBase64 != null) {
        bodyData["document_base64"] = _documentBase64!;
        bodyData["document_mime_type"] = _documentMimeType!;
      }

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(bodyData),
      );

      setState(() {
        _documentBase64 = null;
        _documentFileName = null;
        _documentMimeType = null;
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        String assistantText = "";
        List<String> suggestions = [];

        try {
          final parsedResponse = jsonDecode(data["response"]);
          assistantText = parsedResponse["response"] ?? data["response"];
          if (parsedResponse["suggestions"] != null) {
            suggestions = List<String>.from(parsedResponse["suggestions"]);
          }
        } catch (e) {
          assistantText = data["response"];
        }

        final newMessageIndex = _messages.length;
        setState(() {
          _messages.add({
            "role": "assistant",
            "content": assistantText,
            "suggestions": suggestions,
          });
          _isTyping = false;
        });
        _listKey.currentState?.insertItem(
          newMessageIndex,
          duration: const Duration(milliseconds: 300),
        );

        try {
          final user = Supabase.instance.client.auth.currentUser;
          if (user != null) {
            await Supabase.instance.client.from('messages').insert({
              'id': _uuid.v4(),
              'conversation_id': _currentConversationId,
              'role': 'assistant',
              'content': assistantText,
            });

            // Trigger backend title generation asynchronously
            if (_messages.length == 3 || widget.conversationId == null) {
              http
                  .post(
                    Uri.parse('$baseUrl/api/chat/generate-title'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({
                      "conversation_id": _currentConversationId,
                      "messages": _messages
                          .map(
                            (m) => {"role": m["role"], "content": m["content"]},
                          )
                          .toList(),
                    }),
                  )
                  .then((titleRes) async {
                    if (titleRes.statusCode == 200) {
                      final titleData = jsonDecode(titleRes.body);
                      await Supabase.instance.client
                          .from('conversations')
                          .update({'title': titleData['title']})
                          .eq('id', _currentConversationId);
                    }
                  })
                  .catchError((e) {
                    debugPrint("Title generation error: $e");
                    return Future.value(null);
                  });
            }
          }
        } catch (e) {
          debugPrint('Error saving assistant message: $e');
        }
      } else {
        final errIndex = _messages.length;
        setState(() {
          _messages.add({
            "role": "assistant",
            "content":
                "Error communicating with server: ${response.statusCode}",
            "suggestions": <String>[],
          });
          _isTyping = false;
        });
        _listKey.currentState?.insertItem(errIndex);
      }
    } catch (e) {
      final errIndex = _messages.length;
      setState(() {
        _messages.add({
          "role": "assistant",
          "content": "Network error: $e",
          "suggestions": <String>[],
        });
        _isTyping = false;
        _documentBase64 = null;
        _documentFileName = null;
        _documentMimeType = null;
      });
      _listKey.currentState?.insertItem(errIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguage = ref.watch(languageProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D0D),
        appBar: AppBar(
          title: const Text(
            'Law.Ai',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF0D0D0D),
          actions: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: DropdownButton<String>(
                value: currentLanguage,
                dropdownColor: const Color(0xFF1A1A1A),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                underline: const SizedBox(),
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white70,
                  size: 20,
                ),
                items:
                    [
                          'English',
                          'Tamil',
                          'Hindi',
                          'Telugu',
                          'Kannada',
                          'Malayalam',
                        ]
                        .map(
                          (lang) =>
                              DropdownMenuItem(value: lang, child: Text(lang)),
                        )
                        .toList(),
                onChanged: (val) {
                  if (val != null) {
                    ref.read(languageProvider.notifier).setLanguage(val);
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
        drawer: const MainDrawer(),
        body: Column(
          children: [
            Expanded(
              child: AnimatedList(
                key: _listKey,
                padding: const EdgeInsets.all(16),
                initialItemCount: _messages.length,
                itemBuilder: (context, index, animation) {
                  final msg = _messages[index];
                  final isUser = msg["role"] == "user";
                  final List<String> suggestions =
                      msg["suggestions"] ?? <String>[];

                  return SizeTransition(
                    sizeFactor: animation,
                    child: FadeTransition(
                      opacity: animation,
                      child: Column(
                        crossAxisAlignment: isUser
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? const Color(0xFF2C2C2E)
                                    : Colors.transparent,
                                border: isUser
                                    ? null
                                    : Border.all(color: Colors.white12),
                                borderRadius: BorderRadius.circular(20)
                                    .copyWith(
                                      bottomRight: isUser
                                          ? const Radius.circular(4)
                                          : const Radius.circular(20),
                                      bottomLeft: !isUser
                                          ? const Radius.circular(4)
                                          : const Radius.circular(20),
                                    ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  MarkdownBody(
                                    data: msg["content"] ?? "",
                                    styleSheet: MarkdownStyleSheet(
                                      p: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        height: 1.4,
                                      ),
                                      listBullet: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      strong: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      em: const TextStyle(
                                        color: Colors.white,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                  if (!isUser)
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: IconButton(
                                        padding: const EdgeInsets.only(
                                          top: 8.0,
                                        ),
                                        constraints: const BoxConstraints(),
                                        icon: Icon(
                                          (_isSpeaking && _currentlySpeakingText == (msg["content"] ?? ""))
                                              ? Icons.stop_circle_outlined
                                              : Icons.volume_up,
                                          color: Colors.white54,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          _speak(
                                            msg["content"] ?? "",
                                            currentLanguage,
                                          );
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          if (suggestions.isNotEmpty && !isUser)
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 8.0,
                                bottom: 16.0,
                              ),
                              child: Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: suggestions
                                    .map(
                                      (s) => ActionChip(
                                        label: Text(
                                          s,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                        backgroundColor: const Color(
                                          0xFF1E1E1E,
                                        ),
                                        side: const BorderSide(
                                          color: Colors.white12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        onPressed: () {
                                          _messageController.text = s;
                                        },
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: _isTyping
                  ? const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 8.0,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Law.Ai is typing...',
                          style: TextStyle(
                            color: Colors.white54,
                            fontStyle: FontStyle.italic,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ).copyWith(bottom: MediaQuery.of(context).padding.bottom + 12.0),
              decoration: BoxDecoration(
                color: const Color(0xFF0D0D0D),
                border: Border(
                  top: BorderSide(
                    color: Colors.white12.withValues(alpha: 0.05),
                  ),
                ),
              ),
              child: Column(
                children: [
                  if (_documentFileName != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.attach_file,
                            color: Colors.blueAccent,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _documentFileName!,
                              style: const TextStyle(
                                color: Colors.blueAccent,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white54,
                              size: 16,
                            ),
                            onPressed: () => setState(() {
                              _documentFileName = null;
                              _documentBase64 = null;
                              _documentMimeType = null;
                            }),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C1C1E),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.white54,
                                ),
                                onPressed: () async {
                                  FilePickerResult? result = await FilePicker
                                      .platform
                                      .pickFiles(
                                        type: FileType.custom,
                                        allowedExtensions: [
                                          'pdf',
                                          'png',
                                          'jpg',
                                          'jpeg',
                                        ],
                                        withData: true,
                                      );
                                  if (result != null &&
                                      result.files.single.bytes != null) {
                                    final bytes = result.files.single.bytes!;
                                    final ext = result.files.single.extension
                                        ?.toLowerCase();
                                    String mime = 'application/octet-stream';
                                    if (ext == 'pdf') {
                                      mime = 'application/pdf';
                                    } else if (ext == 'jpg' || ext == 'jpeg') {
                                      mime = 'image/jpeg';
                                    } else if (ext == 'png') {
                                      mime = 'image/png';
                                    }

                                    setState(() {
                                      _documentBase64 = base64Encode(bytes);
                                      _documentMimeType = mime;
                                      _documentFileName =
                                          result.files.single.name;
                                    });
                                  }
                                },
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _messageController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    hintText: 'Ask Law.Ai...',
                                    hintStyle: TextStyle(color: Colors.white38),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                ),
                              ),
                              AvatarGlow(
                                animate: _speechToText.isListening,
                                glowColor: Colors.red,
                                duration: const Duration(milliseconds: 2000),
                                repeat: true,
                                child: IconButton(
                                  icon: Icon(
                                    _speechToText.isListening
                                        ? Icons.mic
                                        : Icons.mic_none,
                                    color: _speechToText.isListening
                                        ? Colors.red
                                        : Colors.white54,
                                  ),
                                  onPressed: () {
                                    if (_speechEnabled) {
                                      _speechToText.isListening
                                          ? _stopListening()
                                          : _startListening();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_upward,
                            color: Colors.white,
                          ),
                          onPressed: _sendMessage,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Law.Ai can make mistakes. Check important info.',
                    style: TextStyle(color: Colors.white38, fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
