import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../navigation/app_bottom_nav_items.dart';
import '../widgets/app_bottom_nav.dart';

class RecentResultsScreen extends StatefulWidget {
  const RecentResultsScreen({super.key});

  @override
  State<RecentResultsScreen> createState() => _RecentResultsScreenState();
}

class _RecentResultsScreenState extends State<RecentResultsScreen> {
  final TextEditingController _rollController = TextEditingController();
  final TextEditingController _regController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _captchaController = TextEditingController(); // 🟢 ক্যাপচা কন্ট্রোলার

  String _selectedExmCode = '1101';
  bool _isLoading = false;

  // 🟢 ক্যাপচা ও সেশনের জন্য ভেরিয়েবল
  Uint8List? _captchaBytes;
  String _sessionCookie = "";

  Map<String, dynamic>? _resultData;
  List<dynamic>? _resultGrades;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchCaptchaAndSession(); // 🟢 পেজ লোড হলেই ক্যাপচা আনবে
  }

  @override
  void dispose() {
    _rollController.dispose();
    _regController.dispose();
    _yearController.dispose();
    _captchaController.dispose();
    super.dispose();
  }

  // =====================================
  // 🟢 ক্যাপচা এবং সেশন ফেচ করার লজিক
  // =====================================
  Future<void> _fetchCaptchaAndSession() async {
    try {
      final String captchaUrl = "http://103.113.200.7/captcha_code_file.php?rand=${DateTime.now().millisecondsSinceEpoch}";
      final response = await http.get(
        Uri.parse(captchaUrl),
        headers: {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'},
      );

      if (response.statusCode == 200) {
        String? rawCookie = response.headers['set-cookie'] ?? response.headers['Set-Cookie'];
        if (rawCookie != null) {
          RegExp regExp = RegExp(r'PHPSESSID=[^;]+');
          Match? match = regExp.firstMatch(rawCookie);
          _sessionCookie = match != null ? match.group(0)! : rawCookie.split(';')[0];
        }
        setState(() {
          _captchaBytes = response.bodyBytes;
        });
      }
    } catch (e) {
      _showErrorSnackBar('ক্যাপচা লোড করতে সমস্যা হচ্ছে!');
    }
  }

  // =====================================
  // রেজাল্ট ফেচ করার লজিক
  // =====================================
  Future<void> _fetchNuResult() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _resultData = null;
      _resultGrades = null;
    });

    final apiUrl = Uri.parse('https://nu-result-scraper.shamolrahaman.workers.dev/');

    // 🟢 আপনার পেলোডে ক্যাপচা এবং সেশন যুক্ত করা হলো (ওয়ার্কারের প্রয়োজন অনুযায়ী)
    final payload = {
      "exm_code": _selectedExmCode,
      "roll": _rollController.text.trim(),
      "reg": _regController.text.trim(),
      "exm_year": _yearController.text.trim(),
      "captcha": _captchaController.text.trim(), // ক্যাপচা কোড
      "cookie": _sessionCookie // সেশন কুকি
    };

    try {
      final response = await http.post(
        apiUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        if (data['success'] == true) {
          setState(() {
            _resultData = data['data'];
            _resultGrades = data['grades'];
          });
        } else {
          _showErrorSnackBar(data['message'] ?? 'রেজাল্ট পাওয়া যায়নি।');
          _fetchCaptchaAndSession(); // ভুল হলে নতুন ক্যাপচা লোড
        }
      } else {
        _showErrorSnackBar('সার্ভার এরর: HTTP ${response.statusCode}');
      }
    } catch (e) {
      _showErrorSnackBar('ইন্টারনেট সংযোগ চেক করুন অথবা আবার চেষ্টা করুন।');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade600, behavior: SnackBarBehavior.floating),
    );
  }

  Widget _buildResultView() {
    if (_resultData == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Result Sheet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildInfoRow('Name', _resultData!['name'], isBold: true, fontSize: 16),
                const Divider(height: 24),
                _buildInfoRow('Roll', _resultData!['roll']),
                const Divider(height: 24),
                _buildInfoRow('Registration', _resultData!['reg']),
                const Divider(height: 24),
                _buildInfoRow('Exam Year', _resultData!['year']),
                const Divider(height: 24),
                _buildInfoRow('GPA', _resultData!['gpa'], color: Colors.blue.shade800, isBold: true, fontSize: 16),
                const Divider(height: 24),
                _buildInfoRow('Result', _resultData!['result'], color: Colors.green.shade700, isBold: true, fontSize: 16),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        if (_resultGrades != null && _resultGrades!.isNotEmpty) ...[
          const Text('Grade/Mark Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 6, spreadRadius: 1, offset: const Offset(0, 2))
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Table(
                border: TableBorder.symmetric(inside: BorderSide(color: Colors.grey.shade200, width: 1)),
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(1.5),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.blue.shade50),
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
                        child: Text('Course Code', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF173B5F))),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
                        child: Text('Grade', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF173B5F))),
                      ),
                    ],
                  ),
                  ..._resultGrades!.map((grade) {
                    return TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                          child: Text(grade['code'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                          child: Text(grade['grade'] ?? '', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (_resultData!['publishedDate'] != null && _resultData!['publishedDate'].toString().isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Published Date: ${_resultData!['publishedDate']}',
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
              ),
            ),
        ]
      ],
    );
  }

  Widget _buildInfoRow(String title, String value, {bool isBold = false, Color? color, double fontSize = 15}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
                fontSize: fontSize,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: color ?? Colors.black87
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomNavItems = buildAppBottomNavItems(context, onHomeTap: () => Navigator.of(context).popUntil((route) => route.isFirst));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text('Recent Results'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('রেজাল্ট অনুসন্ধান করুন', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedExmCode,
                        decoration: InputDecoration(labelText: 'Examination', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14)),
                        items: const [DropdownMenuItem(value: '1101', child: Text('Bachelor Degree (Pass) 1st Year'))],
                        onChanged: (value) => setState(() => _selectedExmCode = value!),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _rollController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(7)],
                        decoration: InputDecoration(labelText: 'Exam Roll', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14)),
                        validator: (value) => value!.isEmpty ? 'রোল নম্বর দিন' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _regController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
                        decoration: InputDecoration(labelText: 'Registration No.', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14)),
                        validator: (value) => value!.isEmpty ? 'রেজিস্ট্রেশন নম্বর দিন' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _yearController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                        decoration: InputDecoration(labelText: 'Exam Year', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14)),
                        validator: (value) => value!.length != 4 ? 'সঠিক পরীক্ষার সাল দিন (যেমন: 2024)' : null,
                      ),
                      const SizedBox(height: 24),

                      // =====================================
                      // 🟢 ক্যাপচা সেকশন (নতুন যোগ করা হলো)
                      // =====================================
                      Row(
                        children: [
                          Container(
                            height: 50,
                            width: 120,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _captchaBytes != null
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(_captchaBytes!, fit: BoxFit.fill),
                            )
                                : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          ),
                          IconButton(
                            onPressed: _fetchCaptchaAndSession,
                            icon: const Icon(Icons.refresh, color: Colors.blue),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _captchaController,
                              decoration: InputDecoration(
                                labelText: 'Captcha Code',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              ),
                              validator: (value) => value!.isEmpty ? 'ক্যাপচা দিন' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _fetchNuResult,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Search Result', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            _buildResultView(),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(items: bottomNavItems, currentIndex: 2),
    );
  }
}