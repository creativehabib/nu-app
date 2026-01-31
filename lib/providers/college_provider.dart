import 'package:flutter/material.dart';

import '../models/college.dart';
import '../services/api_service.dart';

class CollegeProvider extends ChangeNotifier {
  CollegeProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;
  final List<College> _colleges = [];
  bool _isLoading = false;
  String _query = '';

  List<College> get colleges => List.unmodifiable(_colleges);
  bool get isLoading => _isLoading;
  String get query => _query;

  Future<void> loadColleges() async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    notifyListeners();

    final items = await _apiService.fetchColleges();
    _colleges
      ..clear()
      ..addAll(items.where((college) => college.name.isNotEmpty));

    _isLoading = false;
    notifyListeners();
  }

  void updateQuery(String value) {
    _query = value.trim();
    notifyListeners();
  }

  void resetQuery() {
    if (_query.isEmpty) {
      return;
    }
    _query = '';
    notifyListeners();
  }

  List<College> get filteredColleges {
    if (_query.isEmpty) {
      return colleges;
    }
    final lower = _query.toLowerCase();
    return _colleges.where((college) {
      final searchable = [
        college.name,
        college.code ?? '',
        college.district ?? '',
        college.thana ?? '',
        college.eiin ?? '',
      ].join(' ').toLowerCase();
      return searchable.contains(lower);
    }).toList();
  }
}
