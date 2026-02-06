import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ArchiveResultsScreen extends StatefulWidget {
  const ArchiveResultsScreen({super.key});

  @override
  State<ArchiveResultsScreen> createState() => _ArchiveResultsScreenState();
}

class _ArchiveResultsScreenState extends State<ArchiveResultsScreen> {
  static final Uri _archiveResultsUri = Uri.parse('http://103.113.200.7/');
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
        ),
      )
      ..loadRequest(_archiveResultsUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Archive Results'),
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
