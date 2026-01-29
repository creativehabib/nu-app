import 'employee.dart';

class Department {
  const Department({
    required this.id,
    required this.name,
    required this.employees,
  });

  final String id;
  final String name;
  final List<Employee> employees;

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'] as String,
      name: json['name'] as String,
      employees: (json['employees'] as List<dynamic>)
          .map((employee) =>
              Employee.fromJson(employee as Map<String, dynamic>))
          .toList(),
    );
  }
}
