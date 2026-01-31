import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/college.dart';
import '../models/department.dart';

class ApiService {
  Future<List<Department>> fetchDepartments({String? endpoint}) async {
    final uri = Uri.parse(
      endpoint ?? 'https://raw.githubusercontent.com/creativehabib/nu-data/main/departments.json',
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        throw Exception('Unexpected status: ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map(
            (department) =>
                Department.fromJson(department as Map<String, dynamic>),
          )
          .toList();
    } catch (_) {
      return _fallbackDepartments
          .map((department) => Department.fromJson(department))
          .toList();
    }
  }

  Future<List<College>> fetchColleges({String? endpoint}) async {
    final uri = Uri.parse(
      endpoint ?? 'https://collegeportal.nu.ac.bd/college-list-data',
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        throw Exception('Unexpected status: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      final items = _extractList(data);
      return items
          .whereType<Map<String, dynamic>>()
          .map(College.fromJson)
          .toList();
    } catch (_) {
      return _fallbackColleges
          .map((college) => College.fromJson(college))
          .toList();
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
