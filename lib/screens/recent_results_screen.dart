import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../navigation/app_bottom_nav_items.dart';
import '../widgets/app_bottom_nav.dart';

class RecentResultsScreen extends StatefulWidget {
  const RecentResultsScreen({super.key});

  @override
  State<RecentResultsScreen> createState() => _RecentResultsScreenState();
}

class _RecentResultsScreenState extends State<RecentResultsScreen> {
  static final Uri _recentResultsUri = Uri.parse('http://103.113.200.8/');
  late final WebViewController _controller;
  int _loadingProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            setState(() {
              _loadingProgress = progress;
            });
          },
          onPageFinished: (_) => _showResultsTable(),
        ),
      )
      ..loadRequest(_recentResultsUri);
  }

  Future<void> _showResultsTable() async {
    const script = '''
(() => {
  const tables = Array.from(document.querySelectorAll('table'));
  if (!tables.length) return;
  let target = null;
  for (const table of tables) {
    const text = (table.innerText || '').toLowerCase();
    if (text.includes('result') || text.includes('recent')) {
      target = table;
      break;
    }
  }
  if (!target) {
    target = tables.reduce((best, table) => {
      const rows = table.querySelectorAll('tr').length;
      const bestRows = best.querySelectorAll('tr').length;
      return rows > bestRows ? table : best;
    }, tables[0]);
  }
  document.body.innerHTML = '';
  const container = document.createElement('div');
  container.style.padding = '16px';
  container.appendChild(target.cloneNode(true));
  document.body.appendChild(container);
  document.body.style.backgroundColor = '#ffffff';
})();
''';
    await _controller.runJavaScript(script);
  }

  @override
  Widget build(BuildContext context) {
    final bottomNavItems = buildAppBottomNavItems(
      context,
      onHomeTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
    );
    const currentIndex = 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Results'),
        actions: [
          IconButton(
            onPressed: () => _controller.reload(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_loadingProgress < 100)
            LinearProgressIndicator(value: _loadingProgress / 100),
          Expanded(
            child: WebViewWidget(controller: _controller),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        items: bottomNavItems,
        currentIndex: currentIndex,
      ),
    );
  }
}
