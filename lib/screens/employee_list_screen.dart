import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/department.dart';
import '../navigation/app_bottom_nav_items.dart';
import '../providers/directory_provider.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/employee_card.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key, required this.department});

  final Department department;

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DirectoryProvider>();
      provider.resetQuery();
      _searchController.text = provider.query;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DirectoryProvider>();
    final filteredEmployees =
        provider.filteredEmployees(widget.department.employees);
    final bottomNavItems = buildAppBottomNavItems(
      context,
      onHomeTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.department.name),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText:
                    'Search by name, designation, blood group, or district',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: provider.query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          provider.updateQuery('');
                        },
                      ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: provider.updateQuery,
            ),
          ),
          Expanded(
            child: filteredEmployees.isEmpty
                ? const Center(
                    child: Text('No employees match this filter.'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: filteredEmployees.length,
                    itemBuilder: (context, index) {
                      final employee = filteredEmployees[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: EmployeeCard(employee: employee),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        items: bottomNavItems,
        currentIndex: 2,
      ),
    );
  }
}
