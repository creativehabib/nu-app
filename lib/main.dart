import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const UniversityDirectoryApp());
}

class UniversityDirectoryApp extends StatelessWidget {
  const UniversityDirectoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DirectoryProvider()..loadDepartments(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'University Directory',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
          useMaterial3: true,
        ),
        home: const DashboardScreen(),
      ),
    );
  }
}

class Department {
  Department({
    required this.id,
    required this.name,
    required this.members,
  });

  final String id;
  final String name;
  final List<Member> members;

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'] as String,
      name: json['name'] as String,
      members: (json['members'] as List<dynamic>)
          .map((member) => Member.fromJson(member as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Member {
  Member({
    required this.id,
    required this.name,
    required this.designation,
    required this.district,
    required this.bloodGroup,
    required this.phone,
    required this.email,
  });

  final String id;
  final String name;
  final String designation;
  final String district;
  final String bloodGroup;
  final String phone;
  final String email;

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] as String,
      name: json['name'] as String,
      designation: json['designation'] as String,
      district: json['district'] as String,
      bloodGroup: json['bloodGroup'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
    );
  }
}

class DirectoryProvider extends ChangeNotifier {
  final List<Department> _departments = [];
  bool _isLoading = false;
  String _filterText = '';

  List<Department> get departments => List.unmodifiable(_departments);
  bool get isLoading => _isLoading;
  String get filterText => _filterText;

  Future<void> loadDepartments() async {
    _isLoading = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 900));
    final data = _dummyJson;
    _departments
      ..clear()
      ..addAll(
        data
            .map((department) => Department.fromJson(department))
            .toList(),
      );

    _isLoading = false;
    notifyListeners();
  }

  void updateFilter(String value) {
    _filterText = value.trim();
    notifyListeners();
  }

  List<Member> filteredMembers(List<Member> members) {
    if (_filterText.isEmpty) {
      return members;
    }
    final query = _filterText.toLowerCase();
    return members.where((member) {
      return member.district.toLowerCase().contains(query) ||
          member.bloodGroup.toLowerCase().contains(query) ||
          member.name.toLowerCase().contains(query);
    }).toList();
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DirectoryProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('University Directory'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: provider.isLoading
            ? const DepartmentGridShimmer()
            : GridView.builder(
                itemCount: provider.departments.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.05,
                ),
                itemBuilder: (context, index) {
                  final department = provider.departments[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => DepartmentDetailScreen(
                            department: department,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 12,
                            color: Colors.black.withOpacity(0.08),
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 36,
                            width: 36,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.apartment,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            department.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${department.members.length} Members',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class DepartmentDetailScreen extends StatelessWidget {
  const DepartmentDetailScreen({super.key, required this.department});

  final Department department;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DirectoryProvider>();
    final filteredMembers = provider.filteredMembers(department.members);
    return Scaffold(
      appBar: AppBar(
        title: Text(department.name),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by district or blood group',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: provider.updateFilter,
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const MemberListShimmer()
                : filteredMembers.isEmpty
                    ? const Center(
                        child: Text('No members found for this filter.'),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredMembers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final member = filteredMembers[index];
                          return MemberCard(member: member);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class MemberCard extends StatelessWidget {
  const MemberCard({super.key, required this.member});

  final Member member;

  Future<void> _launchPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $phone';
    }
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $email';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            member.name,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            member.designation,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _InfoChip(label: 'District: ${member.district}'),
              _InfoChip(label: 'Blood: ${member.bloodGroup}'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _launchPhone(member.phone),
                  icon: const Icon(Icons.call),
                  label: const Text('Call Now'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _launchEmail(member.email),
                  icon: const Icon(Icons.email),
                  label: const Text('Send Email'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}

class DepartmentGridShimmer extends StatelessWidget {
  const DepartmentGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: 4,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }
}

class MemberListShimmer extends StatelessWidget {
  const MemberListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }
}

final List<Map<String, dynamic>> _dummyJson = [
  {
    'id': 'cse',
    'name': 'Computer Science & Engineering',
    'members': [
      {
        'id': 'cse-1',
        'name': 'Dr. Farhana Akter',
        'designation': 'Professor',
        'district': 'Dhaka',
        'bloodGroup': 'A+',
        'phone': '+8801710000001',
        'email': 'farhana.akter@university.edu',
      },
      {
        'id': 'cse-2',
        'name': 'Mr. Rahim Chowdhury',
        'designation': 'Assistant Professor',
        'district': 'Chattogram',
        'bloodGroup': 'B+',
        'phone': '+8801710000002',
        'email': 'rahim.chowdhury@university.edu',
      },
      {
        'id': 'cse-3',
        'name': 'Ms. Nusrat Jahan',
        'designation': 'Lecturer',
        'district': 'Rajshahi',
        'bloodGroup': 'O+',
        'phone': '+8801710000003',
        'email': 'nusrat.jahan@university.edu',
      },
    ],
  },
  {
    'id': 'eee',
    'name': 'Electrical & Electronic Engineering',
    'members': [
      {
        'id': 'eee-1',
        'name': 'Dr. Mahmud Hasan',
        'designation': 'Professor',
        'district': 'Khulna',
        'bloodGroup': 'AB+',
        'phone': '+8801710000004',
        'email': 'mahmud.hasan@university.edu',
      },
      {
        'id': 'eee-2',
        'name': 'Ms. Sumaiya Karim',
        'designation': 'Senior Lecturer',
        'district': 'Sylhet',
        'bloodGroup': 'B-',
        'phone': '+8801710000005',
        'email': 'sumaiya.karim@university.edu',
      },
    ],
  },
  {
    'id': 'bba',
    'name': 'Business Administration',
    'members': [
      {
        'id': 'bba-1',
        'name': 'Mr. Tanvir Hossain',
        'designation': 'Department Head',
        'district': 'Barishal',
        'bloodGroup': 'A-',
        'phone': '+8801710000006',
        'email': 'tanvir.hossain@university.edu',
      },
      {
        'id': 'bba-2',
        'name': 'Ms. Ruma Akter',
        'designation': 'Lecturer',
        'district': 'Rangpur',
        'bloodGroup': 'O-',
        'phone': '+8801710000007',
        'email': 'ruma.akter@university.edu',
      },
    ],
  },
  {
    'id': 'arch',
    'name': 'Architecture',
    'members': [
      {
        'id': 'arch-1',
        'name': 'Dr. Omar Faruk',
        'designation': 'Associate Professor',
        'district': 'Mymensingh',
        'bloodGroup': 'AB-',
        'phone': '+8801710000008',
        'email': 'omar.faruk@university.edu',
      },
    ],
  },
];
