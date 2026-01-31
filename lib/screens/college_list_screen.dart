import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/college.dart';
import '../navigation/app_bottom_nav_items.dart';
import '../providers/college_provider.dart';
import '../widgets/app_bottom_nav.dart';

class CollegeListScreen extends StatefulWidget {
  const CollegeListScreen({super.key});

  @override
  State<CollegeListScreen> createState() => _CollegeListScreenState();
}

class _CollegeListScreenState extends State<CollegeListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CollegeProvider>().loadColleges();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CollegeProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final bottomNavItems = buildAppBottomNavItems(
      context,
      onHomeTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Affiliated Colleges'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: provider.updateQuery,
              decoration: InputDecoration(
                hintText: 'কলেজের নাম/জেলা/কোড সার্চ করুন',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: provider.query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          provider.resetQuery();
                        },
                      ),
                filled: true,
                fillColor: colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outlineVariant),
                ),
              ),
            ),
          ),
          Expanded(
            child: _CollegeListBody(provider: provider),
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

class _CollegeListBody extends StatelessWidget {
  const _CollegeListBody({required this.provider});

  final CollegeProvider provider;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final colleges = provider.filteredColleges;
    if (colleges.isEmpty) {
      return Center(
        child: Text(
          'কোনো কলেজ পাওয়া যায়নি।',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      itemCount: colleges.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final college = colleges[index];
        return _CollegeCard(college: college);
      },
    );
  }
}

class _CollegeCard extends StatelessWidget {
  const _CollegeCard({required this.college});

  final College college;

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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              college.name,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                if ((college.district ?? '').isNotEmpty)
                  _MetaChip(icon: Icons.location_city, label: college.district!),
                if ((college.thana ?? '').isNotEmpty)
                  _MetaChip(icon: Icons.map, label: college.thana!),
                if ((college.code ?? '').isNotEmpty)
                  _MetaChip(icon: Icons.confirmation_number, label: 'Code: ${college.code}'),
                if ((college.eiin ?? '').isNotEmpty)
                  _MetaChip(icon: Icons.badge_outlined, label: 'EIIN: ${college.eiin}'),
                if ((college.email ?? '').isNotEmpty)
                  _MetaChip(icon: Icons.email_outlined, label: college.email!),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
          ),
        ],
      ),
    );
  }
}
