import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OfficeOrderScreen extends StatefulWidget {
  const OfficeOrderScreen({super.key});

  @override
  State<OfficeOrderScreen> createState() => _OfficeOrderScreenState();
}

class _OfficeOrderScreenState extends State<OfficeOrderScreen> {
  static final Uri _recentNewsUri =
      Uri.parse('https://www.nu.ac.bd/recent-news-notice.php');
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
          onPageFinished: (_) => _showRecentNewsTable(),
        ),
      )
      ..loadRequest(_recentNewsUri);
  }

  Future<void> _showRecentNewsTable() async {
    const script = '''
(() => {
  const wrapper = document.querySelector('#myTable_wrapper');
  if (!wrapper) return;
  const footer = document.querySelector('footer')
    || document.querySelector('#footer')
    || document.querySelector('.footer')
    || document.querySelector('#bottom')
    || document.querySelector('.bottom');
  document.body.innerHTML = '';
  const container = document.createElement('div');
  container.style.padding = '16px';
  container.appendChild(wrapper.cloneNode(true));
  if (footer) {
    const footerClone = footer.cloneNode(true);
    footerClone.style.marginTop = '24px';
    container.appendChild(footerClone);
  }
  document.body.appendChild(container);
  document.body.style.backgroundColor = '#ffffff';
})();
''';
    await _controller.runJavaScript(script);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Office Order'),
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
    );
  }
}
