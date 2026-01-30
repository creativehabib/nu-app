import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/employee.dart';

class EmployeeCard extends StatefulWidget {
  const EmployeeCard({super.key, required this.employee});

  final Employee employee;

  @override
  State<EmployeeCard> createState() => _EmployeeCardState();
}

class _EmployeeCardState extends State<EmployeeCard> {
  Future<void> _launchDialer(String phone) async {
    final phoneUri = Uri(scheme: 'tel', path: phone);
    if (!await launchUrl(phoneUri)) {
      throw 'Could not launch $phone';
    }
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose an app to call',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.phone_in_talk),
                  title: const Text('Phone'),
                  subtitle: Text(phone),
                  onTap: () {
                    Navigator.of(context).pop();
                    _launchDialer(phone);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.chat_bubble),
                  title: const Text('WhatsApp'),
                  subtitle: Text(canOpenWhatsApp
                      ? 'Call via WhatsApp'
                      : 'WhatsApp not available'),
                  enabled: canOpenWhatsApp,
                  onTap: canOpenWhatsApp
                      ? () {
                          Navigator.of(context).pop();
                          _launchWhatsApp(phone);
                        }
                      : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _launchWhatsApp(String phone) async {
    final sanitizedPhone = phone.replaceAll(RegExp(r'\s+'), '');
    final whatsappUri =
        Uri(scheme: 'https', host: 'wa.me', path: sanitizedPhone);
    if (!await launchUrl(whatsappUri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch WhatsApp for $phone';
    }
  }

  Future<void> _showCallOptions(String phone) async {
    final sanitizedPhone = phone.replaceAll(RegExp(r'\s+'), '');
    final whatsappUri =
        Uri(scheme: 'https', host: 'wa.me', path: sanitizedPhone);
    final canOpenWhatsApp = await canLaunchUrl(whatsappUri);
    if (!mounted) {
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose an app to call',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.phone_in_talk),
                  title: const Text('Phone'),
                  subtitle: Text(phone),
                  onTap: () {
                    Navigator.of(context).pop();
                    _launchDialer(phone);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.chat_bubble),
                  title: const Text('WhatsApp'),
                  subtitle: Text(canOpenWhatsApp
                      ? 'Call via WhatsApp'
                      : 'WhatsApp link not available'),
                  enabled: canOpenWhatsApp,
                  onTap: canOpenWhatsApp
                      ? () {
                          Navigator.of(context).pop();
                          _launchWhatsApp(phone);
                        }
                      : null,
                ),
              ],
            ),
          ),
        );
      },
    );
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(top: 4),
          leading: CircleAvatar(
            radius: 22,
            backgroundColor: colorScheme.primaryContainer,
            child: Text(
              _initials(widget.employee.name),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
            ),
          ),
          title: Text(
            widget.employee.name,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          subtitle: Text(
            widget.employee.designation,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 12),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 56, right: 4, bottom: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _CompactInfoChip(
                          label: 'রক্ত: ${widget.employee.bloodGroup}'),
                      _CompactInfoChip(
                          label: 'জেলা: ${widget.employee.homeDistrict}'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.call,
                            size: 16, color: colorScheme.onPrimaryContainer),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.employee.phoneNumber,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontSize: 12,
                                  height: 1.1,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Call',
                          onPressed: () =>
                              _showCallOptions(widget.employee.phoneNumber),
                          icon: const Icon(Icons.phone_in_talk, size: 18),
                          color: colorScheme.onPrimaryContainer,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.email,
                            size: 16, color: colorScheme.onSecondaryContainer),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.employee.email,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontSize: 12,
                                  height: 1.1,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSecondaryContainer,
                                ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Email',
                          onPressed: () =>
                              _launchEmail(widget.employee.email),
                          icon: const Icon(Icons.mark_email_read, size: 18),
                          color: colorScheme.onSecondaryContainer,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.facebook,
                          color: colorScheme.onSurfaceVariant, size: 18),
                      const SizedBox(width: 6),
                      Icon(Icons.link,
                          color: colorScheme.onSurfaceVariant, size: 18),
                      const SizedBox(width: 6),
                      Icon(Icons.public,
                          color: colorScheme.onSurfaceVariant, size: 18),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 11),
      ),
    );
  }
}
