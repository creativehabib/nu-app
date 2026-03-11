import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

// =====================================
// 1. Data Model for Parsed Result
// =====================================
class NuResultData {
  final Map<String, String> studentInfo;
  final List<Map<String, String>> grades;

  NuResultData({required this.studentInfo, required this.grades});
}

// =====================================
// 2. Main Screen
// =====================================
class NativeResultScreen extends StatefulWidget {
  final String title;
  final String formUrl;

  const NativeResultScreen({super.key, required this.title, required this.formUrl});

  @override
  State<NativeResultScreen> createState() => _NativeResultScreenState();
}

class _NativeResultScreenState extends State<NativeResultScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController rollController = TextEditingController();
  final TextEditingController regController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController captchaController = TextEditingController();

  String sessionCookie = "";
  final Map<String, String> _hiddenFields = {};
  String rollFieldName = 'roll_number';
  String regFieldName = 'reg_no';
  String yearFieldName = 'exam_year';
  String captchaFieldName = 'letters_code';
  Uint8List? captchaBytes;
  bool isLoading = false;
  late String targetPostUrl;


  @override
  void dispose() {
    rollController.dispose();
    regController.dispose();
    yearController.dispose();
    captchaController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    targetPostUrl = widget.formUrl;
    _fetchCaptchaAndSession();
  }

  // =====================================
  // 3. Fetch Session & Captcha
  // =====================================
  Future<void> _fetchCaptchaAndSession() async {
    setState(() => isLoading = true);
    try {
      final formResponse = await http.get(
        Uri.parse(widget.formUrl),
        headers: {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'},
      );

      if (formResponse.statusCode == 200) {
        sessionCookie = _extractCookieHeader(formResponse.headers);

        var document = parser.parse(formResponse.body);

        final form = document.querySelector('form');
        if (form != null) {
          final action = form.attributes['action']?.trim();
          if (action != null && action.isNotEmpty) {
            targetPostUrl = Uri.parse(widget.formUrl).resolve(action).toString();
          }

          final inputElements = form.querySelectorAll('input');
          _hiddenFields.clear();
          for (final input in inputElements) {
            final name = input.attributes['name']?.trim();
            if (name == null || name.isEmpty) continue;

            final type = (input.attributes['type'] ?? '').toLowerCase();
            final lowered = name.toLowerCase();

            if (type == 'hidden') {
              _hiddenFields[name] = input.attributes['value'] ?? '';
              continue;
            }

            if (_looksLikeRollField(lowered)) {
              rollFieldName = name;
            } else if (_looksLikeRegField(lowered)) {
              regFieldName = name;
            } else if (_looksLikeYearField(lowered)) {
              yearFieldName = name;
            } else if (_looksLikeCaptchaField(lowered)) {
              captchaFieldName = name;
            }
          }
        }

        // কিছু পুরোনো পেইজে বাটনের onclick এ আলাদা submit URL থাকে
        final btn = document.querySelector('input[onclick*="php"]');
        final onClick = btn?.attributes['onclick'];
        if (onClick != null) {
          final match = RegExp(r"'([^']+\.php[^']*)'").firstMatch(onClick);
          if (match != null) {
            targetPostUrl = Uri.parse(widget.formUrl).resolve(match.group(1)!).toString();
          }
        }
      }

      // ক্যাপচা লোড
      final String captchaUrl = "http://103.113.200.7/captcha_code_file.php?rand=${DateTime.now().millisecondsSinceEpoch}";
      final captchaResponse = await http.get(
        Uri.parse(captchaUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Cookie': sessionCookie,
        },
      );

      if (captchaResponse.statusCode == 200) {
        setState(() => captchaBytes = captchaResponse.bodyBytes);
      }
    } catch (e) {
      _showErrorDialog("ইন্টারনেট সংযোগ চেক করুন!");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // =====================================
  // 4. Form Submit Logic (Strict POST Request)
  // =====================================
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    try {
      Map<String, String> body = {
        ..._hiddenFields,
        rollFieldName: rollController.text.trim(),
        regFieldName: regController.text.trim(),
        yearFieldName: yearController.text.trim(),
        captchaFieldName: captchaController.text.trim(),
      };

      print("🚀 Requesting EXACT POST Body: $body");
      print("🔗 Target URL: $targetPostUrl");

      final response = await http
          .post(
            Uri.parse(targetPostUrl),
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
              'Cookie': sessionCookie,
              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
              'Referer': widget.formUrl,
              'X-Requested-With': 'XMLHttpRequest',
              'Origin': 'http://103.113.200.7',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 25));

      final responseBody = response.body;

      if (_containsCaptchaError(responseBody)) {
        _showErrorDialog("আপনার দেওয়া ক্যাপচাটি ভুল হয়েছে। দয়া করে আবার চেষ্টা করুন।");
        _fetchCaptchaAndSession();
        return;
      }

      if (response.statusCode != 200) {
        final serverMessage = _extractResponseMessage(responseBody);
        _showErrorDialog(
          serverMessage ?? "সার্ভার থেকে ডেটা আনা যায়নি (HTTP ${response.statusCode})। কিছুক্ষণ পর আবার চেষ্টা করুন।",
        );
        return;
      }

      NuResultData? parsedData = _parseHtmlContent(responseBody);
      if (parsedData != null) {
        _showResultBottomSheet(parsedData);
        return;
      }

      final serverMessage = _extractResponseMessage(responseBody);
      if (serverMessage != null) {
        _showErrorDialog(serverMessage);
      } else {
        _showErrorDialog("রেজাল্ট খুঁজে পাওয়া যায়নি। রোল, রেজিস্ট্রেশন নম্বর বা সাল ভুল হতে পারে।");
      }

      print("\n❌ ==== SERVER RESPONSE HTML ==== \n${responseBody.length > 800 ? responseBody.substring(0, 800) : responseBody}\n=========================\n");
    } on TimeoutException {
      _showErrorDialog("সার্ভার রেসপন্স দিতে দেরি করছে। অনুগ্রহ করে আবার চেষ্টা করুন।");
    } on SocketException {
      _showErrorDialog("ইন্টারনেট সংযোগে সমস্যা। নেটওয়ার্ক চেক করে আবার চেষ্টা করুন।");
    } catch (e) {
      _showErrorDialog("অপ্রত্যাশিত ত্রুটি হয়েছে। আবার চেষ্টা করুন।");
      print("❌ Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  bool _containsCaptchaError(String responseBody) {
    final normalized = responseBody.toLowerCase();
    return normalized.contains('দয়া করে আবার চেষ্টা করুন') ||
        normalized.contains('wrong code') ||
        normalized.contains('invalid captcha') ||
        normalized.contains('letters code') ||
        normalized.contains('security code');
  }

  String? _extractResponseMessage(String htmlString) {
    final document = parser.parse(htmlString);
    final selectors = [
      '.error',
      '.alert',
      '.alert-danger',
      '.message',
      '#message',
      'font[color="red"]',
      'span[style*="color:red"]',
      'div[style*="color:red"]',
    ];

    for (final selector in selectors) {
      final element = document.querySelector(selector);
      final text = element?.text.trim();
      if (text != null && text.isNotEmpty && text.length < 220) {
        return text;
      }
    }

    final bodyText = document.body?.text.replaceAll(RegExp(r'\s+'), ' ').trim() ?? '';
    for (final hint in _knownFailureTexts) {
      if (bodyText.toLowerCase().contains(hint.toLowerCase())) {
        return hint;
      }
    }

    return null;
  }

  static const List<String> _knownFailureTexts = [
    'No Result Found',
    'Result Not Found',
    'রেজাল্ট পাওয়া যায়নি',
    'দয়া করে সঠিক তথ্য দিন',
    'Invalid Registration',
    'Invalid Roll',
  ];

  // =====================================
  // 5. HTML Parsing
  // =====================================
  NuResultData? _parseHtmlContent(String htmlString) {
    dom.Document document = parser.parse(htmlString);
    List<dom.Element> tables = document.querySelectorAll('table#customers, table.customers, table');

    if (tables.length < 2) return null;

    Map<String, String> studentInfo = {};
    for (final table in tables.take(2)) {
      final infoRows = table.querySelectorAll('tr');
      for (var row in infoRows) {
        var tds = row.querySelectorAll('td');
        if (tds.length >= 2) {
          String key = tds[0].text.trim().replaceAll(':', '');
          String value = tds.last.text.trim();
          if (key.isNotEmpty && value.isNotEmpty && !key.contains('Result')) {
            studentInfo[key] = value;
          } else if (key.contains('Result')) {
            studentInfo['Result Status'] = value;
          }
        }
      }
    }

    final gradeTable = tables.firstWhere(
      (table) {
        final headerText = table.text.toLowerCase();
        return headerText.contains('course') &&
            headerText.contains('grade') &&
            (headerText.contains('code') || headerText.contains('subject'));
      },
      orElse: () => tables.length > 1 ? tables[1] : tables.first,
    );

    List<Map<String, String>> grades = [];
    var gradeRows = gradeTable.querySelectorAll('tr');
    for (int i = 1; i < gradeRows.length; i++) {
      var tds = gradeRows[i].querySelectorAll('td');
      if (tds.length >= 4) {
        grades.add({
          'code': tds[0].text.trim(),
          'title': tds[1].text.trim(),
          'credit': tds[2].text.trim(),
          'grade': tds[3].text.trim(),
        });
      }
    }

    if (studentInfo.isEmpty || grades.isEmpty) return null;

    return NuResultData(studentInfo: studentInfo, grades: grades);
  }

  bool _looksLikeRollField(String name) =>
      name.contains('roll') && !name.contains('enroll');

  bool _looksLikeRegField(String name) =>
      name.contains('reg') || name.contains('registration');

  bool _looksLikeYearField(String name) =>
      name.contains('year') || name.contains('exam_year') || name.contains('examyear');

  bool _looksLikeCaptchaField(String name) =>
      name.contains('captcha') || name.contains('letter') || name.contains('code');

  String _extractCookieHeader(Map<String, String> headers) {
    final rawCookie = headers['set-cookie'] ?? headers['Set-Cookie'];
    if (rawCookie == null || rawCookie.isEmpty) return '';

    final matches = RegExp(r'([A-Za-z0-9_\-]+)=([^;,\s]+)').allMatches(rawCookie);
    final map = <String, String>{};
    for (final m in matches) {
      final key = m.group(1);
      final value = m.group(2);
      if (key == null || value == null) continue;
      if (_ignoredCookieAttributes.contains(key.toLowerCase())) continue;
      map[key] = value;
    }
    return map.entries.map((e) => '${e.key}=${e.value}').join('; ');
  }

  static const Set<String> _ignoredCookieAttributes = {
    'path',
    'expires',
    'max-age',
    'domain',
    'secure',
    'httponly',
    'samesite',
  };

  // =====================================
  // 6. UI: Bottom Sheet Result
  // =====================================
  void _showResultBottomSheet(NuResultData resultData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false, initialChildSize: 0.9, maxChildSize: 0.95, minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(child: Container(width: 50, height: 5, margin: const EdgeInsets.only(bottom: 15), decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10)))),
                  const Text("National University", textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo)),
                  Text(widget.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  const Divider(thickness: 1.5, height: 30),

                  Card(
                    elevation: 3, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: resultData.studentInfo.entries.map((e) {
                          bool isHighlight = e.key == 'Result Status' || e.key == 'Name';
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 2, child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey))),
                                const Text(" :  "),
                                Expanded(flex: 5, child: Text(e.value, style: TextStyle(fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal, color: isHighlight ? Colors.indigo : Colors.black))),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text("Course-wise Grade", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Card(
                    elevation: 2,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(Colors.indigo.shade50),
                        columnSpacing: 20,
                        columns: const [
                          DataColumn(label: Text('Code', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Course', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Credit', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Grade', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: resultData.grades.map((grade) {
                          return DataRow(cells: [
                            DataCell(Text(grade['code'] ?? '')),
                            DataCell(SizedBox(width: 150, child: Text(grade['title'] ?? '', overflow: TextOverflow.visible))),
                            DataCell(Center(child: Text(grade['credit'] ?? ''))),
                            DataCell(Center(child: Text(grade['grade'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)))),
                          ]);
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("বন্ধ করুন"))
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('মেসেজ'),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('ওকে'))],
      ),
    );
  }

  // =====================================
  // 7. Input Form UI
  // =====================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), centerTitle: true),
      body: isLoading && captchaBytes == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: rollController, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Exam Roll', border: OutlineInputBorder(), prefixIcon: Icon(Icons.pin_outlined)),
                validator: (value) => value!.isEmpty ? 'রোল নম্বর দিন' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: regController, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Registration Number', border: OutlineInputBorder(), prefixIcon: Icon(Icons.numbers)),
                validator: (value) => value!.isEmpty ? 'রেজিস্ট্রেশন নম্বর দিন' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: yearController, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Exam Year (যেমন: 2022)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.calendar_month)),
                validator: (value) => value!.isEmpty ? 'বছর দিন' : null,
              ),
              const SizedBox(height: 20),
              const Text("ক্যাপচা পূরণ করুন:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    height: 50, width: 140,
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                    child: captchaBytes != null ? Image.memory(captchaBytes!, fit: BoxFit.fill) : const Center(child: CircularProgressIndicator()),
                  ),
                  IconButton(onPressed: _fetchCaptchaAndSession, icon: const Icon(Icons.refresh, color: Colors.blue)),
                  Expanded(
                    child: TextFormField(
                      controller: captchaController,
                      decoration: const InputDecoration(hintText: 'Enter code', border: OutlineInputBorder()),
                      validator: (value) => value!.isEmpty ? 'ক্যাপচা দিন' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: Colors.indigo),
                onPressed: isLoading ? null : _submitForm,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Search Result', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
