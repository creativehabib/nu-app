import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../navigation/app_bottom_nav_items.dart';
import '../widgets/app_bottom_nav.dart';

class OfficeOrderScreen extends StatefulWidget {
  const OfficeOrderScreen({super.key});

  @override
  State<OfficeOrderScreen> createState() => _OfficeOrderScreenState();
}

class _OfficeOrderScreenState extends State<OfficeOrderScreen> {
  // পেজিনেশন এবং ডাটা ম্যানেজমেন্টের জন্য ভেরিয়েবল
  List<dynamic> _allNotices = [];
  List<dynamic> _displayedNotices = [];

  bool _isLoading = true;
  bool _hasError = false;
  bool _isLoadingMore = false;

  final int _perPage = 15; // প্রতি পেজে কয়টি করে ডাটা দেখাবে
  int _currentPage = 1;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchNotices();

    // স্ক্রল করে লিস্টের নিচে পৌঁছালে আরও ডাটা লোড করার লিসেনার
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 50 && !_isLoadingMore) {
        _loadMoreData();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // API থেকে ডাটা ফেচ করা
  Future<void> _fetchNotices() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final url = Uri.parse('https://nu-scraper.shamolrahaman.workers.dev/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decodedData = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _allNotices = decodedData;
          _displayedNotices = _allNotices.take(_perPage).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  // পেজিনেশন: নিচে স্ক্রল করলে আরও ডাটা লোড করা
  void _loadMoreData() {
    if (_displayedNotices.length < _allNotices.length) {
      setState(() {
        _isLoadingMore = true;
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _currentPage++;
          _displayedNotices = _allNotices.take(_currentPage * _perPage).toList();
          _isLoadingMore = false;
        });
      });
    }
  }

  // ক্রোম কাস্টম ট্যাব (In-App Browser) দিয়ে পিডিএফ/লিংক ওপেন করা
  Future<void> _openNoticeInternally(String link) async {
    final Uri url = Uri.parse(link);

    // LaunchMode.inAppBrowserView অ্যাপের ভেতরেই ক্রোম বা সাফারি ওপেন করবে
    if (!await launchUrl(url, mode: LaunchMode.inAppBrowserView)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('লিংকটি ওপেন করা যাচ্ছে না')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomNavItems = buildAppBottomNavItems(
      context,
      onHomeTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Office Order'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              _currentPage = 1;
              _fetchNotices();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload',
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: AppBottomNavBar(
        items: bottomNavItems,
        currentIndex: 2,
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text('ডাটা লোড করতে সমস্যা হয়েছে', style: TextStyle(color: Colors.grey[700])),
            TextButton(
              onPressed: _fetchNotices,
              child: const Text('আবার চেষ্টা করুন'),
            )
          ],
        ),
      );
    }
    if (_displayedNotices.isEmpty) {
      return const Center(child: Text('কোনো নোটিশ পাওয়া যায়নি।'));
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12.0),
      itemCount: _displayedNotices.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _displayedNotices.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final notice = _displayedNotices[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: Colors.blue.withOpacity(0.1),
              child: const Icon(Icons.picture_as_pdf, color: Colors.blue),
            ),
            title: Text(
              notice['title'] ?? 'No Title',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    notice['date'] ?? 'No Date',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onTap: () {
              if (notice['link'] != null) {
                _openNoticeInternally(notice['link']);
              }
            },
          ),
        );
      },
    );
  }
}