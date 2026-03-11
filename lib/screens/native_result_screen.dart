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
  String csrfToken = "";
  String dynamicCsrfName = "csrfHon"; // ডিফল্ট নাম
  Uint8List? captchaBytes;
  bool isLoading = false;
  late String targetPostUrl;

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
        String? rawCookie = formResponse.headers['set-cookie'] ?? formResponse.headers['Set-Cookie'];
        if (rawCookie != null) {
          RegExp regExp = RegExp(r'PHPSESSID=[^;]+');
          Match? match = regExp.firstMatch(rawCookie);
          sessionCookie = match != null ? match.group(0)! : rawCookie.split(';')[0];
        }

        var document = parser.parse(formResponse.body);

        // 🟢 ডাইনামিক হিডেন CSRF টোকেন বের করা
        var hiddenInputs = document.querySelectorAll('input[type="hidden"]');
        for (var input in hiddenInputs) {
          String name = input.attributes['name'] ?? '';
          if (name.toLowerCase().contains('csrf')) {
            dynamicCsrfName = name;
            csrfToken = input.attributes['value'] ?? '';
          }
        }

        // 🟢 সঠিক URL বের করা
        var btn = document.querySelector('input[type="button"][value="Search Result"]');
        if (btn != null) {
          String? onClick = btn.attributes['onclick'];
          if (onClick != null) {
            var match = RegExp(r"'([^']+)'").firstMatch(onClick);
            if (match != null) {
              String path = match.group(1)!;
              targetPostUrl = path.startsWith('http') ? path : 'http://103.113.200.7/$path';
            }
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
      // 🟢 আপনার বের করা একদম নিখুঁত নামগুলো ব্যবহার করা হলো
      Map<String, String> body = {
        'roll_number': rollController.text,
        'reg_no': regController.text,
        'exam_year': yearController.text,
        'letters_code': captchaController.text, // ক্যাপচার অরিজিনাল নাম
        dynamicCsrfName: csrfToken, // ডাইনামিক CSRF (যেমন: csrfHon)
      };

      print("🚀 Requesting EXACT POST Body: $body");
      print("🔗 Target URL: $targetPostUrl");

      // ⚠️ সার্ভারকে বোঝানোর জন্য স্পেশাল হেডার (AJAX Request)
      final response = await http.post(
        Uri.parse(targetPostUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8', // ফর্ম ডেটা টাইপ
          'Cookie': sessionCookie, // আমাদের মাস্টার কুকি
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Referer': widget.formUrl, // কোথা থেকে রিকোয়েস্ট যাচ্ছে
          'X-Requested-With': 'XMLHttpRequest', // 🟢 সবচেয়ে জরুরি: এটি ছাড়া NU সার্ভার ডেটা দিবে না!
          'Origin': 'http://103.113.200.7',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        String responseBody = response.body;

        // ক্যাপচা ভুল কিনা চেক
        if (responseBody.contains("দয়া করে আবার চেষ্টা করুন") || responseBody.contains("wrong code") || responseBody.contains("Wrong")) {
          _showErrorDialog("আপনার দেওয়া ক্যাপচাটি ভুল হয়েছে। দয়া করে আবার চেষ্টা করুন।");
          _fetchCaptchaAndSession();
          return;
        }

        NuResultData? parsedData = _parseHtmlContent(responseBody);

        if (parsedData != null) {
          _showResultBottomSheet(parsedData); // 🎉 সফল হলে রেজাল্ট দেখাবে
        } else {
          // ডিবাগিং এর জন্য কনসোলে প্রিন্ট (যদি রেজাল্ট না আসে)
          print("\n❌ ==== SERVER RESPONSE HTML ==== \n${responseBody.length > 800 ? responseBody.substring(0, 800) : responseBody}\n=========================\n");

          _showErrorDialog("রেজাল্ট খুঁজে পাওয়া যায়নি। রোল, রেজিস্ট্রেশন নম্বর বা সাল ভুল হতে পারে।");
        }
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      _showErrorDialog("সার্ভার ডাউন। আবার চেষ্টা করুন।");
      print("❌ Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // =====================================
  // 5. HTML Parsing
  // =====================================
  NuResultData? _parseHtmlContent(String htmlString) {
    dom.Document document = parser.parse(htmlString);
    List<dom.Element> tables = document.querySelectorAll('table#customers');

    if (tables.length < 2) return null;

    Map<String, String> studentInfo = {};
    var infoRows = tables[0].querySelectorAll('tr');
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

    List<Map<String, String>> grades = [];
    var gradeRows = tables[1].querySelectorAll('tr');
    for (int i = 2; i < gradeRows.length; i++) {
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

    return NuResultData(studentInfo: studentInfo, grades: grades);
  }

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