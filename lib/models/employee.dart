class Employee {
  const Employee({
    required this.id,
    required this.name,
    required this.designation,
    required this.departmentName,
    required this.bloodGroup,
    required this.phoneNumber,
    required this.email,
    required this.homeDistrict,
  });

  final String id;
  final String name;
  final String designation;
  final String departmentName;
  final String bloodGroup;
  final String phoneNumber;
  final String email;
  final String homeDistrict;

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as String,
      name: json['name'] as String,
      designation: json['designation'] as String,
      departmentName: json['department_name'] as String,
      bloodGroup: json['blood_group'] as String,
      phoneNumber: json['phone_number'] as String,
      email: json['email'] as String,
      homeDistrict: json['home_district'] as String,
    );
  }
}
