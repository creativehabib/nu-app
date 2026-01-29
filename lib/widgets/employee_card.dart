import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/employee.dart';

class EmployeeCard extends StatelessWidget {
  const EmployeeCard({super.key, required this.employee});

  final Employee employee;

  Future<void> _launchPhone(String phone) async {
    final whatsappUri = Uri(
      scheme: 'whatsapp',
      host: 'send',
      queryParameters: {'phone': phone},
    );
    if (await canLaunchUrl(whatsappUri)) {
      if (!await launchUrl(whatsappUri)) {
        throw 'Could not launch WhatsApp for $phone';
      }
      return;
    }
    final phoneUri = Uri(scheme: 'tel', path: phone);
    if (!await launchUrl(phoneUri)) {
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
      padding: const EdgeInsets.all(12),
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
            radius: 22,
            backgroundColor: colorScheme.primary.withOpacity(0.15),
            child: Text(
              _initials(employee.name),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  employee.designation,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.grey.shade700, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _CompactInfoChip(label: 'রক্ত: ${employee.bloodGroup}'),
                    _CompactInfoChip(label: 'জেলা: ${employee.homeDistrict}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.call, size: 16, color: colorScheme.primary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        employee.phoneNumber,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontSize: 12),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Call',
                      onPressed: () => _launchPhone(employee.phoneNumber),
                      icon: const Icon(Icons.phone_in_talk, size: 18),
                      color: colorScheme.primary,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.email, size: 16, color: colorScheme.primary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        employee.email,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontSize: 12),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Email',
                      onPressed: () => _launchEmail(employee.email),
                      icon: const Icon(Icons.mark_email_read, size: 18),
                      color: colorScheme.primary,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.facebook,
                        color: colorScheme.primary, size: 18),
                    const SizedBox(width: 6),
                    Icon(Icons.link, color: colorScheme.primary, size: 18),
                    const SizedBox(width: 6),
                    Icon(Icons.public, color: colorScheme.primary, size: 18),
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

class _CompactInfoChip extends StatelessWidget {
  const _CompactInfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: colorScheme.primary, fontSize: 11),
      ),
    );
  }
}
