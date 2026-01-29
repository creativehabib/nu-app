import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/department.dart';
import '../providers/directory_provider.dart';
import '../widgets/employee_card.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key, required this.department});

  final Department department;

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DirectoryProvider>().resetQuery();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DirectoryProvider>();
    final filteredEmployees =
        provider.filteredEmployees(widget.department.employees);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.department.name),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Filter by blood group or home district',
                prefixIcon: const Icon(Icons.search),
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
    );
  }
}
