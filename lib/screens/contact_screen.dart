import 'package:flutter/material.dart';

import '../navigation/app_bottom_nav_items.dart';
import '../widgets/app_bottom_nav.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomNavItems = buildAppBottomNavItems(
      context,
      onHomeTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Get in touch',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Our service team is available Sunday to Thursday to help with '
            'admissions, exams, and student records.',
          ),
          const SizedBox(height: 16),
          _ContactCard(
            title: 'Main Helpline',
            subtitle: '+880 2 1234 5678',
            icon: Icons.phone_in_talk_outlined,
          ),
          const SizedBox(height: 12),
          _ContactCard(
            title: 'Email',
            subtitle: 'support@nu.ac.bd',
            icon: Icons.email_outlined,
          ),
          const SizedBox(height: 12),
          _ContactCard(
            title: 'Office Hours',
            subtitle: '9:00 AM — 5:00 PM (Sun-Thu)',
            icon: Icons.schedule_outlined,
          ),
          const SizedBox(height: 12),
          _ContactCard(
            title: 'Student Support Desk',
            subtitle: 'studenthelp@nu.ac.bd',
            icon: Icons.support_agent_outlined,
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        items: bottomNavItems,
        currentIndex: 1,
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: ListTile(
        leading: Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: colorScheme.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}
