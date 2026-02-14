import 'package:flutter/material.dart';

import '../navigation/app_bottom_nav_items.dart';
import '../widgets/app_bottom_nav.dart';

class DeveloperScreen extends StatelessWidget {
  const DeveloperScreen({super.key});

  void _goToHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bottomNavItems = buildAppBottomNavItems(
      context,
      onHomeTap: () => _goToHome(context),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _goToHome(context),
        ),
        title: const Text('About Developer'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage('assets/habib_nu.png'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Habibur Rahaman',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const _InfoRow(
                    icon: Icons.phone_android,
                    label: 'Mobile',
                    value: '+8801914120688',
                  ),
                  const SizedBox(height: 10),
                  const _InfoRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: 'iamhabibnu@gmail.com',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        items: bottomNavItems,
        currentIndex: 4,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, color: colorScheme.primary),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
