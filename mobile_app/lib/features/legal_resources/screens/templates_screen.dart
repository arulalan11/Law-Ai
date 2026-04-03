import 'package:flutter/material.dart';
import 'package:mobile_app/core/widgets/main_drawer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobile_app/core/constants/api_constants.dart';
import 'package:mobile_app/features/legal_resources/screens/dashboard_screen.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/providers/language_provider.dart';
import 'package:mobile_app/core/constants/app_strings.dart';

class TemplatesScreen extends ConsumerStatefulWidget {
  const TemplatesScreen({super.key});

  @override
  ConsumerState<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends ConsumerState<TemplatesScreen> {
  final _formKey = GlobalKey<FormState>();
  // Block A - Sender (1, 2)
  final _senderNameController = TextEditingController();
  final _senderFathersNameController = TextEditingController();
  final _senderAddressController = TextEditingController();
  final _senderContactController = TextEditingController();
  final _senderEmailController = TextEditingController();

  // Block B - Opponent
  final _opponentNameController = TextEditingController();
  final _opponentFathersNameController = TextEditingController();
  final _opponentAddressController = TextEditingController();
  String _businessType = 'Individual';
  final List<String> _businessTypes = [
    'Individual',
    'Company',
    'Landlord',
    'Employer',
    'Other',
  ];

  // Block C - Relationship Context
  String _relationship = 'Business Partner';
  final List<String> _relationships = [
    'Tenant',
    'Employer',
    'Borrower',
    'Seller',
    'Service Provider',
    'Husband/Wife',
    'Business Partner',
    'Other',
  ];

  // Block D - Timeline Facts
  final _dateOfAgreementController = TextEditingController();
  String _natureOfAgreement = 'Written';
  final List<String> _agreementNatures = ['Written', 'Oral', 'None'];
  final _keyEventDateController = TextEditingController();
  final _reminderDateController = TextEditingController();
  final _breachDateController = TextEditingController();

  // Block E - Claim Details
  final _amountInvolvedController = TextEditingController();
  String _modeOfTransaction = 'Bank Transfer';
  final List<String> _transactionModes = [
    'Cash',
    'Bank Transfer',
    'UPI',
    'Cheque',
    'N/A',
  ];
  bool _proofAvailable = true;
  String _reliefSought = 'Payment';
  final List<String> _reliefs = [
    'Payment',
    'Refund',
    'Replacement',
    'Apology',
    'Vacate Property',
    'Stop Harassment',
  ];

  // Block F - Legal Ground Selection
  String _legalGround = 'Money Recovery';
  final List<String> _legalGrounds = [
    'Money Recovery',
    'Consumer Dispute',
    'Employment Dues',
    'Rent Default',
    'Breach of Contract',
    'Defamation',
    'Divorce / Matrimonial',
    'Property Dispute',
  ];

  String _selectedLanguage = 'English';
  final List<String> _languages = ['English', 'Tamil', 'Hindi', 'Telugu'];

  bool _isGenerating = false;
  String? _generatedNotice;

  @override
  void dispose() {
    _senderNameController.dispose();
    _senderFathersNameController.dispose();
    _senderAddressController.dispose();
    _senderContactController.dispose();
    _senderEmailController.dispose();

    _opponentNameController.dispose();
    _opponentFathersNameController.dispose();
    _opponentAddressController.dispose();

    _dateOfAgreementController.dispose();
    _keyEventDateController.dispose();
    _reminderDateController.dispose();
    _breachDateController.dispose();

    _amountInvolvedController.dispose();
    super.dispose();
  }

  Future<void> _generateNotice() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isGenerating = true;
      _generatedNotice = null;
    });

    try {
      final baseUrl = ApiConstants.baseUrl;
      final response = await http.post(
        Uri.parse('$baseUrl/api/legal/generate-notice'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'senderName': _senderNameController.text.trim(),
          'senderFathersName': _senderFathersNameController.text.trim(),
          'senderAddress': _senderAddressController.text.trim(),
          'senderContact': _senderContactController.text.trim(),
          'senderEmail': _senderEmailController.text.trim(),

          'opponentName': _opponentNameController.text.trim(),
          'opponentFathersName': _opponentFathersNameController.text.trim(),
          'opponentAddress': _opponentAddressController.text.trim(),
          'businessType': _businessType,

          'relationship': _relationship,

          'dateOfAgreement': _dateOfAgreementController.text.trim(),
          'natureOfAgreement': _natureOfAgreement,
          'keyEventDate': _keyEventDateController.text.trim(),
          'reminderDate': _reminderDateController.text.trim(),
          'breachDate': _breachDateController.text.trim(),

          'amountInvolved': _amountInvolvedController.text.trim(),
          'modeOfTransaction': _modeOfTransaction,
          'proofAvailable': _proofAvailable,
          'reliefSought': _reliefSought,

          'legalGround': _legalGround,
          'language': _selectedLanguage,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _generatedNotice = data['draft'];
        });
      } else {
        _showError('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Failed to connect to the backend server.');
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _exportPdf() async {
    if (_generatedNotice == null) return;

    final pdf = pw.Document();

    final font = await PdfGoogleFonts.tinosRegular();
    final boldFont = await PdfGoogleFonts.tinosBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(72), // 1 inch = 72 pt
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  "LEGAL NOTICE",
                  style: pw.TextStyle(
                    font: boldFont,
                    fontSize: 14, // Slightly larger for header
                    decoration: pw.TextDecoration.underline,
                  ),
                ),
              ),
              pw.SizedBox(height: 24),
              pw.Text(
                _generatedNotice!,
                style: pw.TextStyle(
                  font: font,
                  fontSize: 12, // 12pt font required
                  lineSpacing: 1.5, // 1.5 line spacing required
                ),
                textAlign: pw.TextAlign.justify, // Justified alignment required
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name:
          'Legal_Notice_${_senderNameController.text.replaceAll(' ', '_')}.pdf',
    );
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
        appBar: AppBar(title: Text(AppStrings.get(currentLanguage, 'documentation_templates'))),
        drawer: const MainDrawer(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Draft a highly professional, court-ready legal notice by filling out the details below.",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _selectedLanguage,
                      decoration: const InputDecoration(
                        labelText: 'Drafting Language',
                        prefixIcon: Icon(Icons.language),
                      ),
                      items: _languages.map((lang) {
                        return DropdownMenuItem(
                          value: lang,
                          child: Text(
                            lang,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedLanguage = val!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "BLOCK A — Sender Details",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _senderNameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _senderFathersNameController,
                      decoration: const InputDecoration(
                        labelText: 'Father\'s Name (Optional)',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _senderAddressController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Full Address',
                        prefixIcon: Icon(Icons.home),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _senderContactController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Contact Number (Optional)',
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _senderEmailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email (Optional)',
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),

                    const SizedBox(height: 32),
                    const Text(
                      "BLOCK B — Opposite Party Details",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _opponentNameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name / Company Name',
                        prefixIcon: Icon(Icons.business),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _opponentFathersNameController,
                      decoration: const InputDecoration(
                        labelText: 'Father\'s Name (If individual)',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _opponentAddressController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Registered Office / Full Address',
                        prefixIcon: Icon(Icons.location_city),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _businessType,
                      decoration: const InputDecoration(
                        labelText: 'Business Type',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _businessTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(
                            type,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _businessType = val!;
                        });
                      },
                    ),

                    const SizedBox(height: 32),
                    const Text(
                      "BLOCK C — Relationship Context (CRITICAL)",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orangeAccent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _relationship,
                      decoration: const InputDecoration(
                        labelText: 'What is the relationship?',
                        prefixIcon: Icon(Icons.handshake),
                      ),
                      items: _relationships.map((rel) {
                        return DropdownMenuItem(
                          value: rel,
                          child: Text(
                            rel,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _relationship = val!;
                        });
                      },
                    ),

                    const SizedBox(height: 32),
                    const Text(
                      "BLOCK D — Timeline Facts",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _dateOfAgreementController,
                      decoration: const InputDecoration(
                        labelText: 'Date of Agreement (if any)',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _natureOfAgreement,
                      decoration: const InputDecoration(
                        labelText: 'Nature of Agreement',
                        prefixIcon: Icon(Icons.article),
                      ),
                      items: _agreementNatures.map((nature) {
                        return DropdownMenuItem(
                          value: nature,
                          child: Text(
                            nature,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _natureOfAgreement = val!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _keyEventDateController,
                      decoration: const InputDecoration(
                        labelText: 'Key Event Date',
                        prefixIcon: Icon(Icons.event),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _reminderDateController,
                      decoration: const InputDecoration(
                        labelText: 'Reminder Date(s) (if any)',
                        prefixIcon: Icon(Icons.notifications_active),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _breachDateController,
                      decoration: const InputDecoration(
                        labelText: 'Breach Date',
                        prefixIcon: Icon(Icons.broken_image),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),

                    const SizedBox(height: 32),
                    const Text(
                      "BLOCK E — Claim Details",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _amountInvolvedController,
                      decoration: const InputDecoration(
                        labelText: 'Amount Involved (e.g. ₹50,000)',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _modeOfTransaction,
                      decoration: const InputDecoration(
                        labelText: 'Mode of Transaction',
                        prefixIcon: Icon(Icons.payment),
                      ),
                      items: _transactionModes.map((mode) {
                        return DropdownMenuItem(
                          value: mode,
                          child: Text(
                            mode,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _modeOfTransaction = val!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text(
                        'Proof Available (Yes/No)',
                        style: TextStyle(color: Colors.white),
                      ),
                      value: _proofAvailable,
                      activeThumbColor: Colors.blueAccent,
                      onChanged: (bool value) {
                        setState(() {
                          _proofAvailable = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _reliefSought,
                      decoration: const InputDecoration(
                        labelText: 'Relief Sought',
                        prefixIcon: Icon(Icons.balance),
                      ),
                      items: _reliefs.map((relief) {
                        return DropdownMenuItem(
                          value: relief,
                          child: Text(
                            relief,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _reliefSought = val!;
                        });
                      },
                    ),

                    const SizedBox(height: 32),
                    const Text(
                      "BLOCK F — Legal Ground Selection",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _legalGround,
                      decoration: const InputDecoration(
                        labelText: 'Select Legal Ground',
                        prefixIcon: Icon(Icons.gavel),
                      ),
                      items: _legalGrounds.map((ground) {
                        return DropdownMenuItem(
                          value: ground,
                          child: Text(
                            ground,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _legalGround = val!;
                        });
                      },
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isGenerating ? null : _generateNotice,
                        icon: _isGenerating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.auto_awesome),
                        label: Text(
                          _isGenerating
                              ? 'Drafting Notice...'
                              : 'Generate Legal Notice',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_generatedNotice != null) ...[
                const SizedBox(height: 32),
                const Divider(color: Colors.white24),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Generated Notice",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _exportPdf,
                      icon: const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Export PDF",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF252525),
                    border: Border.all(color: Colors.white24),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    _generatedNotice!,
                    style: const TextStyle(
                      color: Colors.white,
                      height: 1.5,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
