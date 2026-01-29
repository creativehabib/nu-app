import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/department.dart';

class ApiService {
  Future<List<Department>> fetchDepartments({String? endpoint}) async {
    final uri = Uri.parse(
      endpoint ?? 'https://example.com/api/nu-directory/departments',
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

const List<Map<String, dynamic>> _fallbackDepartments = [
  {
    'id': 'registrar',
    'name': 'Registrar Office',
    'employees': [
      {
        'id': 'reg-001',
        'name': 'Mr. Abdul Karim',
        'designation': 'Registrar',
        'department_name': 'Registrar Office',
        'blood_group': 'A+',
        'phone_number': '+8801711000001',
        'email': 'registrar@nu.edu.bd',
        'home_district': 'Dhaka',
      },
      {
        'id': 'reg-002',
        'name': 'Ms. Shahana Ali',
        'designation': 'Assistant Registrar',
        'department_name': 'Registrar Office',
        'blood_group': 'B+',
        'phone_number': '+8801711000002',
        'email': 'assistant.registrar@nu.edu.bd',
        'home_district': 'Cumilla',
      },
    ],
  },
  {
    'id': 'exam-controller',
    'name': 'Exam Controller',
    'employees': [
      {
        'id': 'exam-001',
        'name': 'Dr. Fatema Ahmed',
        'designation': 'Controller of Examinations',
        'department_name': 'Exam Controller',
        'blood_group': 'O+',
        'phone_number': '+8801711000003',
        'email': 'exam.controller@nu.edu.bd',
        'home_district': 'Rajshahi',
      },
      {
        'id': 'exam-002',
        'name': 'Mr. Nazmul Hasan',
        'designation': 'Deputy Controller',
        'department_name': 'Exam Controller',
        'blood_group': 'AB+',
        'phone_number': '+8801711000004',
        'email': 'deputy.exam@nu.edu.bd',
        'home_district': 'Khulna',
      },
    ],
  },
  {
    'id': 'finance',
    'name': 'Finance & Accounts',
    'employees': [
      {
        'id': 'fin-001',
        'name': 'Ms. Nusrat Jahan',
        'designation': 'Chief Accounts Officer',
        'department_name': 'Finance & Accounts',
        'blood_group': 'B-',
        'phone_number': '+8801711000005',
        'email': 'accounts@nu.edu.bd',
        'home_district': 'Sylhet',
      },
    ],
  },
  {
    'id': 'ict',
    'name': 'ICT Cell',
    'employees': [
      {
        'id': 'ict-001',
        'name': 'Mr. Imran Hossain',
        'designation': 'Director, ICT',
        'department_name': 'ICT Cell',
        'blood_group': 'A-',
        'phone_number': '+8801711000006',
        'email': 'ict.director@nu.edu.bd',
        'home_district': 'Rangpur',
      },
      {
        'id': 'ict-002',
        'name': 'Ms. Rokia Sultana',
        'designation': 'System Analyst',
        'department_name': 'ICT Cell',
        'blood_group': 'O-',
        'phone_number': '+8801711000007',
        'email': 'system.analyst@nu.edu.bd',
        'home_district': 'Mymensingh',
      },
    ],
  },
];
