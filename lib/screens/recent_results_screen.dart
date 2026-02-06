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
          onPageFinished: (_) => _showResultsForm(),
        ),
      )
      ..loadRequest(_recentResultsUri);
  }

  Future<void> _showResultsForm() async {
    const script = '''
(() => {
  const form =
    document.querySelector('form') ||
    document.querySelector('form[name]') ||
    document.querySelector('form[action]');
  if (!form) return;
  document.body.innerHTML = '';
  const viewport = document.createElement('meta');
  viewport.name = 'viewport';
  viewport.content = 'width=device-width, initial-scale=1, maximum-scale=1';
  document.head.appendChild(viewport);
  const style = document.createElement('style');
  style.textContent = `
    * { box-sizing: border-box; }
    html, body {
      height: 100%;
    }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
      margin: 0;
      overflow-x: hidden;
      font-size: 14px;
    }
    form { display: flex; flex-direction: column; gap: 8px; width: 100%; }
    label { font-weight: 600; color: #1f2937; font-size: 12px; }
    input, select {
      width: 100%;
      max-width: 100%;
      padding: 10px 12px;
      border-radius: 10px;
      border: 1px solid #d1d5db;
      background: #f9fafb;
      font-size: 14px;
      transition: border-color 150ms ease, box-shadow 150ms ease;
    }
    input:focus, select:focus {
      outline: none;
      border-color: #2563eb;
      box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.2);
      background: #ffffff;
    }
    button, input[type="submit"] {
      width: 100%;
      padding: 10px 14px;
      border-radius: 10px;
      border: none;
      background: #2563eb;
      color: #ffffff;
      font-weight: 600;
      font-size: 14px;
      cursor: pointer;
    }
  `;
  document.head.appendChild(style);
  const container = document.createElement('div');
  container.style.padding = '16px 14px 18px';
  container.style.maxWidth = '520px';
  container.style.width = '100%';
  container.style.margin = '0 auto';
  container.appendChild(form.cloneNode(true));
  document.body.appendChild(container);
  document.body.style.backgroundColor = '#ffffff';
  document.body.style.margin = '0';
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
