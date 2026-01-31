import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/college.dart';
import '../models/department.dart';

class ApiResult<T> {
  const ApiResult({required this.items, required this.usedFallback});

  final List<T> items;
  final bool usedFallback;
}

class ApiService {
  Future<ApiResult<Department>> fetchDepartments({String? endpoint}) async {
    final uri = Uri.parse(
      endpoint ?? 'https://raw.githubusercontent.com/creativehabib/nu-data/main/departments.json',
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        throw Exception('Unexpected status: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as List<dynamic>;
      final items = data
          .map(
            (department) =>
                Department.fromJson(department as Map<String, dynamic>),
          )
          .toList();
      return ApiResult(items: items, usedFallback: false);
    } catch (_) {
      final fallback = _fallbackDepartments
          .map((department) => Department.fromJson(department))
          .toList();
      return ApiResult(items: fallback, usedFallback: true);
    }
  }

  Future<ApiResult<College>> fetchColleges({String? endpoint}) async {
    final uri = Uri.parse(
      endpoint ?? 'https://raw.githubusercontent.com/creativehabib/nu-data/refs/heads/main/affiliated_college.json',
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        throw Exception('Unexpected status: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      final items = _extractList(data);
      final colleges = items
          .whereType<Map<String, dynamic>>()
          .map(College.fromJson)
          .toList();
      return ApiResult(items: colleges, usedFallback: false);
    } catch (_) {
      final fallback = _fallbackColleges
          .map((college) => College.fromJson(college))
          .toList();
      return ApiResult(items: fallback, usedFallback: true);
    }
  }
}

const List<Map<String, dynamic>> _fallbackDepartments = [];
const List<Map<String, dynamic>> _fallbackColleges = [];

List<dynamic> _extractList(dynamic data) {
  if (data is List) {
    return data;
  }
  if (data is Map<String, dynamic>) {
    for (final key in ['data', 'colleges', 'collegeList', 'items']) {
      final value = data[key];
      if (value is List) {
        return value;
      }
    }
  }
  return const [];
}
