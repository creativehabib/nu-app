import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TrainSearchScreen extends StatefulWidget {
  const TrainSearchScreen({super.key});

  @override
  State<TrainSearchScreen> createState() => _TrainSearchScreenState();
}

class _TrainSearchScreenState extends State<TrainSearchScreen> {
  static final Uri _railwayTicketUrl = Uri.parse('https://eticket.railway.gov.bd/');

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
      ..loadRequest(_railwayTicketUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('বাংলাদেশ রেলওয়ে ই-টিকিট'),
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
