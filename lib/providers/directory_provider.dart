import 'package:flutter/material.dart';

import '../models/department.dart';
import '../models/employee.dart';
import '../services/api_service.dart';

class DirectoryProvider extends ChangeNotifier {
  DirectoryProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;
  final List<Department> _departments = [];
  bool _isLoading = false;
  String _query = '';

  List<Department> get departments => List.unmodifiable(_departments);
  bool get isLoading => _isLoading;
  String get query => _query;

  Future<void> loadDepartments() async {
    _isLoading = true;
    notifyListeners();

    final items = await _apiService.fetchDepartments();
    _departments
      ..clear()
      ..addAll(items);

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

  List<Employee> filteredEmployees(List<Employee> employees) {
    if (_query.isEmpty) {
      return employees;
    }
    final terms = _query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((term) => term.isNotEmpty)
        .toList();
    if (terms.isEmpty) {
      return employees;
    }
    return employees.where((employee) {
      final searchable = [
        employee.name,
        employee.designation,
        employee.bloodGroup,
        employee.homeDistrict,
      ].join(' ').toLowerCase();
      return terms.every(searchable.contains);
    }).toList();
  }
}
