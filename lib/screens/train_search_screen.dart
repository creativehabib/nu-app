import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../navigation/app_bottom_nav_items.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/offline_notice.dart';

class TrainSearchScreen extends StatefulWidget {
  const TrainSearchScreen({super.key});

  @override
  State<TrainSearchScreen> createState() => _TrainSearchScreenState();
}

class _TrainSearchScreenState extends State<TrainSearchScreen> {
  static final Uri _railwayTicketUrl = Uri.parse('https://eticket.railway.gov.bd/');

  late final WebViewController _controller;
  int _loadingProgress = 0;
  bool _hasConnectionError = false;

  Future<void> _openInExternalBrowser(Uri uri) async {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('লিংক খোলা যায়নি। অনুগ্রহ করে ফোনে ব্রাউজার চেক করুন।'),
        ),
      );
    }
  }

  void _retryRailwayTicket() {
    setState(() {
      _hasConnectionError = false;
      _loadingProgress = 0;
    });
    _controller.loadRequest(_railwayTicketUrl);
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (!mounted) return;
            setState(() {
              _loadingProgress = progress;
            });
          },
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _hasConnectionError = false;
            });
          },
          onWebResourceError: (_) {
            if (!mounted) return;
            setState(() {
              _hasConnectionError = true;
              _loadingProgress = 0;
            });
          },
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri == null) {
              return NavigationDecision.navigate;
            }

            final isLoginRoute = uri.host.contains('railway.gov.bd') &&
                uri.path.toLowerCase().contains('login');

            if (isLoginRoute) {
              _openInExternalBrowser(uri);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(_railwayTicketUrl);
  }

  @override
  Widget build(BuildContext context) {
    final bottomNavItems = buildAppBottomNavItems(
      context,
      trailingItem: AppBottomNavItem(
        icon: Icons.directions_railway,
        label: 'Railway',
        onTap: () {},
      ),
    );
    const currentIndex = 4;

    return Scaffold(
      appBar: AppBar(
        title: const Text('বাংলাদেশ রেলওয়ে ই-টিকিট'),
        actions: [
          IconButton(
            tooltip: 'ব্রাউজারে খুলুন',
            onPressed: () => _openInExternalBrowser(_railwayTicketUrl),
            icon: const Icon(Icons.open_in_browser),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_hasConnectionError && _loadingProgress < 100)
            LinearProgressIndicator(value: _loadingProgress / 100),
          Expanded(
            child: _hasConnectionError
                ? OfflineNotice(
                    message: "Your mobile internet or WI-FI isn't connected",
                    onRetry: _retryRailwayTicket,
                  )
                : WebViewWidget(controller: _controller),
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
