import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/employee.dart';

class EmployeeCard extends StatelessWidget {
  const EmployeeCard({super.key, required this.employee});

  final Employee employee;

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

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) {
      return '';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: colorScheme.primary.withOpacity(0.15),
            child: Text(
              _initials(employee.name),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  employee.designation,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 10),
                Text(
                  'রক্তের গ্রুপ: ${employee.bloodGroup}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'নিজ জেলা: ${employee.homeDistrict}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.call, size: 18, color: colorScheme.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        employee.phoneNumber,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Call',
                      onPressed: () => _launchPhone(employee.phoneNumber),
                      icon: const Icon(Icons.phone_in_talk),
                      color: colorScheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.email, size: 18, color: colorScheme.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        employee.email,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Email',
                      onPressed: () => _launchEmail(employee.email),
                      icon: const Icon(Icons.mark_email_read),
                      color: colorScheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.facebook, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Icon(Icons.link, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Icon(Icons.public, color: colorScheme.primary),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
