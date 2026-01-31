import 'package:flutter/material.dart';

import 'department_list_screen.dart';
import '../navigation/app_bottom_nav_items.dart';
import '../widgets/app_bottom_nav.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = [
      _TaskItem(icon: Icons.menu_book, label: 'Daily Task'),
      _TaskItem(icon: Icons.how_to_reg, label: 'Attendance'),
      _TaskItem(icon: Icons.edit_document, label: 'Exam Atten.'),
      _TaskItem(icon: Icons.assignment_turned_in, label: 'Exam Marks'),
      _TaskItem(icon: Icons.receipt_long, label: 'Office Order'),
      _TaskItem(icon: Icons.rate_review, label: 'Exam Remark'),
      _TaskItem(icon: Icons.assignment, label: 'Assignment'),
      _TaskItem(icon: Icons.account_tree,
        label: 'Office Dept.',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const DepartmentListScreen(),
            ),
          );
        },
      ),
      _TaskItem(icon: Icons.insert_chart_outlined, label: 'Indicator'),
      _TaskItem(icon: Icons.photo_library, label: 'Gallery'),
      _TaskItem(icon: Icons.quiz, label: 'Res. Query'),
      _TaskItem(icon: Icons.celebration, label: 'Holiday'),
    ];
    final bottomNavItems = buildAppBottomNavItems(context);
    const currentIndex = 2;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 16,
                      color: Colors.black.withOpacity(0.06),
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F4FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: Image.network(
                        'https://www.nu.ac.bd/assets/images/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'National University',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F1F1F),
                            ),
                          ),
                          SizedBox(height: 1),
                          Text(
                            'Bangladesh',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6C6C6C),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 38,
                      width: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F7FB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.notifications_none_outlined,
                        color: Color(0xFF3E3E3E),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  'https://www.nu.ac.bd/slide_images/slider_image_01.png',
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'Our Services',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F1F1F),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  itemCount: tasks.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.95,
                  ),
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final baseColor = _TaskItem.palette[
                        index % _TaskItem.palette.length];
                    return _TaskTile(
                      icon: task.icon,
                      label: task.label,
                      color: baseColor,
                      onTap: task.onTap,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        items: bottomNavItems,
        currentIndex: currentIndex,
      ),
    );
  }
}

class _TaskItem {
  const _TaskItem({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  static const palette = [
    Color(0xFF7E57C2),
    Color(0xFF26A69A),
    Color(0xFFFFA726),
    Color(0xFF42A5F5),
    Color(0xFFEF5350),
    Color(0xFF8D6E63),
  ];
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = Color.lerp(color, Colors.black, 0.2) ?? color;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                blurRadius: 12,
                color: Colors.black.withOpacity(0.06),
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E2E2E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
