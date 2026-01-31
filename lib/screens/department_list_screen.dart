import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../navigation/app_bottom_nav_items.dart';
import '../providers/directory_provider.dart';
import '../widgets/app_bottom_nav.dart';
import 'employee_list_screen.dart';

class DepartmentListScreen extends StatelessWidget {
  const DepartmentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DirectoryProvider>();
    final departments = provider.departments;
    final bottomNavItems = buildAppBottomNavItems(
      context,
      onHomeTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Office Departments'),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : departments.isEmpty
              ? const Center(child: Text('No departments available.'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  itemCount: departments.length,
                  itemBuilder: (context, index) {
                    final department = departments[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Card(
                        elevation: 0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          leading: CircleAvatar(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            child: Icon(
                              Icons.apartment_outlined,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          title: Text(
                            department.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Text(
                            '${department.employees.length} জন কর্মকর্তা/কর্মচারী',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    EmployeeListScreen(department: department),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: AppBottomNavBar(
        items: bottomNavItems,
        currentIndex: 2,
      ),
    );
  }
}
