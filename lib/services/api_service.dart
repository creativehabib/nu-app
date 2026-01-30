import 'dart:convert';

import 'package:http/http.dart' as http;

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
}

const List<Map<String, dynamic>> _fallbackDepartments = [];
