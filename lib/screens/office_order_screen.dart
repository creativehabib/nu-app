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
  List<dynamic> _allNotices = [];
  List<dynamic> _filteredNotices = [];
  List<dynamic> _displayedNotices = [];

  bool _isLoading = true;
  bool _hasError = false;
  bool _isLoadingMore = false;

  final int _perPage = 15;
  int _currentPage = 1;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchNotices();

    // Scroll below to load more data
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 50 && !_isLoadingMore) {
        _loadMoreData();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Data fetch from API
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
          _filteredNotices = List.from(_allNotices);
          _displayedNotices = _filteredNotices.take(_perPage).toList();
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

  // Pagination: Load more data
  void _loadMoreData() {
    if (_displayedNotices.length < _filteredNotices.length) {
      setState(() {
        _isLoadingMore = true;
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _currentPage++;
          _displayedNotices = _filteredNotices.take(_currentPage * _perPage).toList();
          _isLoadingMore = false;
        });
      });
    }
  }

  // Search function
  void _filterNotices(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredNotices = List.from(_allNotices);
      } else {
        _filteredNotices = _allNotices.where((notice) {
          final title = (notice['title'] ?? '').toString().toLowerCase();
          return title.contains(query.toLowerCase());
        }).toList();
      }
      // Search result pagination
      _currentPage = 1;
      _displayedNotices = _filteredNotices.take(_perPage).toList();
    });
  }

  // Open PDF chrome custom
  Future<void> _openNoticeInternally(String link) async {
    final Uri url = Uri.parse(link);
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
              _searchController.clear();
              _searchQuery = '';
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
            Text('ডাটা লোড করতে সমস্যা হয়েছে', style: TextStyle(color: Colors.grey[700])),
            TextButton(
              onPressed: _fetchNotices,
              child: const Text('আবার চেষ্টা করুন'),
            )
          ],
        ),
      );
    }

    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: _searchController,
            onChanged: _filterNotices,
            decoration: InputDecoration(
              hintText: 'নোটিশ খুঁজুন...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.grey),
                onPressed: () {
                  _searchController.clear();
                  _filterNotices('');
                },
              )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),

        // List View
        Expanded(
          child: _displayedNotices.isEmpty
              ? const Center(child: Text('কোনো নোটিশ পাওয়া যায়নি।'))
              : ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            itemCount: _displayedNotices.length + (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _displayedNotices.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final notice = _displayedNotices[index];
              final titleText = notice['title'] ?? 'No Title';

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      child: const Icon(Icons.picture_as_pdf, color: Colors.blue),
                    ),
                    title: Text(
                      titleText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              titleText,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade800,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 45,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  if (notice['link'] != null) {
                                    _openNoticeInternally(notice['link']);
                                  }
                                },
                                icon: const Icon(Icons.remove_red_eye),
                                label: const Text(
                                  'ভিউ নোটিশ (পিডিএফ)',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade50,
                                  foregroundColor: Colors.blue.shade700,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}