import 'package:flutter/material.dart';

import '../navigation/app_bottom_nav_items.dart';
import '../widgets/app_bottom_nav.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomNavItems = buildAppBottomNavItems(
      context,
      onHomeTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'National University',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Founded to expand access to higher education, the National '
            'University network connects colleges across the country and '
            'supports millions of learners each year.',
          ),
          const SizedBox(height: 16),
          _InfoCard(
            title: 'Mission',
            description:
                'Deliver inclusive, technology-enabled education and services '
                'for students, faculty, and staff.',
            icon: Icons.flag_outlined,
          ),
          const SizedBox(height: 12),
          _InfoCard(
            title: 'Vision',
            description:
                'Empower communities through innovative learning, research, '
                'and national collaboration.',
            icon: Icons.visibility_outlined,
          ),
          const SizedBox(height: 12),
          _InfoCard(
            title: 'Core Values',
            description:
                'Integrity • Student-first service • Collaboration • '
                'Excellence • Lifelong learning',
            icon: Icons.workspace_premium_outlined,
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        items: bottomNavItems,
        currentIndex: 0,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
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
