import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../navigation/app_bottom_nav_items.dart';
import '../widgets/app_bottom_nav.dart';

// ==========================================
// 1. Data Models & Category List
// ==========================================
class SubCategory {
  final String name;
  final String url;
  SubCategory({required this.name, required this.url});
}

class ResultCategory {
  final String title;
  final List<SubCategory> subs;
  ResultCategory({required this.title, required this.subs});
}

final List<ResultCategory> nuCategories = [
  ResultCategory(title: "Degree", subs: [
    SubCategory(name: "First Year", url: "http://103.113.200.7/degree/Form.php?year=1"),
    SubCategory(name: "Second Year", url: "http://103.113.200.7/degree/Form.php?year=2"),
    SubCategory(name: "Third Year", url: "http://103.113.200.7/degree/Form.php?year=3"),
    SubCategory(name: "Consolidated", url: "http://103.113.200.7/degree/ConsolidatedForm.php"),
    SubCategory(name: "Two Year Course", url: "http://103.113.200.7/degree/Form.php?year=0"),
    SubCategory(name: "Degree (Subs.)", url: "http://103.113.200.7/degree/Form.php?year=4"),
  ]),
  ResultCategory(title: "Honours", subs: [
    SubCategory(name: "First Year", url: "http://103.113.200.7/honours/1stForm.php?exam_year=1"),
    SubCategory(name: "Second Year", url: "http://103.113.200.7/honours/2ndForm.php"),
    SubCategory(name: "Third Year", url: "http://103.113.200.7/honours/3rdForm.php"),
    SubCategory(name: "Fourth Year", url: "http://103.113.200.7/honours/4thForm.php"),
    SubCategory(name: "Consolidated", url: "http://103.113.200.7/honours/FinalForm.php"),
  ]),
  ResultCategory(title: "Masters", subs: [
    SubCategory(name: "Masters Preli", url: "http://103.113.200.7/mp/getMPForm.php"),
    SubCategory(name: "Masters Final", url: "http://103.113.200.7/masters/getMasterseForm.php"),
    SubCategory(name: "ICT Course", url: "http://103.113.200.7/masters/getICTForm.php"),
    SubCategory(name: "Rescrutiny (Masters)", url: "http://103.113.200.7/masters/getRescrutinyForm.php"),
  ]),
  ResultCategory(title: "Professional", subs: [
    SubCategory(name: "Aeronautical", url: "http://103.113.200.7/aeronautical/getAERForm.php"),
    SubCategory(name: "Aviation Mgmt", url: "http://103.113.200.7/aviation/getAVIForm.php"),
    SubCategory(name: "AMT/KMT/FDT", url: "http://103.113.200.7/bgmea/getBGMEAForm.php"),
    SubCategory(name: "BBA (Prof)", url: "http://103.113.200.7/bba/getForm_bba.php"),
    SubCategory(name: "BEd (Prof)", url: "http://103.113.200.7/med/getBedForm.php"),
    SubCategory(name: "BEd (Hon) / MED", url: "http://103.113.200.7/bedHon/getBedHonForm.php"),
    SubCategory(name: "BFA", url: "http://103.113.200.7/bfa/getBFAForm.php"),
    SubCategory(name: "BPED / MPED", url: "http://103.113.200.7/bped/getbpedForm.php"),
    SubCategory(name: "BSED / MSED", url: "http://103.113.200.7/sed/getForm.php"),
    SubCategory(name: "CSE / MCSE", url: "http://103.113.200.7/cse/getCSEForm.php"),
    SubCategory(name: "ECE", url: "http://103.113.200.7/ece/getECEForm.php"),
    SubCategory(name: "Journalism", url: "http://103.113.200.7/jrnl/getJRNLForm.php"),
    SubCategory(name: "LL.B Part-1", url: "http://103.113.200.7/llb/getLLB1stForm.php"),
    SubCategory(name: "LL.B Final", url: "http://103.113.200.7/llb/getLLBFinalForm.php"),
    SubCategory(name: "LIS (Library Science)", url: "http://103.113.200.7/lib/getLiBForm.php"),
    SubCategory(name: "MACPM", url: "http://103.113.200.7/macpm/getMACPMForm.php"),
    SubCategory(name: "MBA", url: "http://103.113.200.7/mba/getMBAForm.php"),
    SubCategory(name: "PGD Courses", url: "http://103.113.200.7/pgd/getPGDPForm.php"),
    SubCategory(name: "THM (Tourism)", url: "http://103.113.200.7/thm/getTouForm.php"),
    SubCategory(name: "TMS (Theatre)", url: "http://103.113.200.7/tms/getTMSForm.php"),
    SubCategory(name: "TST (Textile)", url: "http://103.113.200.7/tst/getTSTForm.php"),
  ]),
  ResultCategory(title: "On Campus", subs: [
    SubCategory(name: "LIS: Batch-1", url: "http://103.113.200.7/lis/getLISForm.php"),
    SubCategory(name: "Advanced MBA", url: "http://103.113.200.7/amba/getAMBAForm.php"),
    SubCategory(name: "MAS", url: "http://103.113.200.7/mas/getMASForm.php"),
    SubCategory(name: "M.Phil", url: "http://103.113.200.7/mphil/getMPHILForm.php"),
    SubCategory(name: "Ph.D", url: "http://103.113.200.7/phd/getPHDForm.php"),
  ]),
  ResultCategory(title: "Other", subs: [
    SubCategory(name: "Revaluation Result", url: "http://103.113.200.7/rescrutiny/getForm.php"),
  ]),
];

// ==========================================
// 2. Main Screen (Category List)
// ==========================================
class ArchiveResultsScreen extends StatelessWidget {
  const ArchiveResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomNavItems = buildAppBottomNavItems(
      context,
      onHomeTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
    );
    const currentIndex = 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Archive Results'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: nuCategories.length,
        itemBuilder: (context, index) {
          final category = nuCategories[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 10),
            child: ExpansionTile(
              leading: const Icon(Icons.school, color: Colors.blue),
              title: Text(
                category.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              children: category.subs.map((sub) {
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 40.0),
                  title: Text(sub.name, style: const TextStyle(fontSize: 15)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResultViewScreen(
                          title: sub.name,
                          url: sub.url,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          );
        },
      ),
      bottomNavigationBar: AppBottomNavBar(
        items: bottomNavItems,
        currentIndex: currentIndex,
      ),
    );
  }
}

// ==========================================
// 3. Detail Screen (WebView to show Form)
// ==========================================
class ResultViewScreen extends StatefulWidget {
  final String title;
  final String url;

  const ResultViewScreen({super.key, required this.title, required this.url});

  @override
  State<ResultViewScreen> createState() => _ResultViewScreenState();
}

class _ResultViewScreenState extends State<ResultViewScreen> {
  late final WebViewController _controller;
  int _loadingProgress = 0;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36')
      ..clearCache()
      ..clearLocalStorage()
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) {
              setState(() {
                _loadingProgress = progress;
              });
            }
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _hasError = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              setState(() {
                _hasError = true;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _hasError = false;
                _loadingProgress = 0;
              });
              _controller.reload();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload',
          ),
        ],
      ),
      body: _hasError
          ? _buildErrorScreen()
          : Column(
        children: [
          if (_loadingProgress < 100)
            LinearProgressIndicator(value: _loadingProgress / 100),
          Expanded(
            child: WebViewWidget(controller: _controller),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 80, color: Colors.redAccent),
            const SizedBox(height: 20),
            const Text(
              'সার্ভার সংযোগে ত্রুটি',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'ন্যাশনাল ইউনিভার্সিটির সার্ভার এই মুহূর্তে ডাউন থাকতে পারে অথবা ইন্টারনেট সংযোগে সমস্যা হচ্ছে।',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _loadingProgress = 0;
                });
                _controller.reload();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('আবার চেষ্টা করুন'),
            )
          ],
        ),
      ),
    );
  }
}