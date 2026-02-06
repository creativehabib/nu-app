import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'archive_results_screen.dart';
import 'college_list_screen.dart';
import 'department_list_screen.dart';
import 'office_order_screen.dart';
import 'recent_results_screen.dart';
import '../navigation/app_bottom_nav_items.dart';
import '../providers/theme_provider.dart';
import '../widgets/app_bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final brightness = Theme.of(context).brightness;
    // স্ট্যাটাস বার কনফিগারেশন: ব্যাকগ্রাউন্ড নীল (প্রাইমারি কালার) এবং আইকন সাদা
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // ট্রান্সপারেন্ট যাতে হেডারের কালার দেখা যায়
        statusBarIconBrightness: Brightness.light, // সাদা আইকন
        statusBarBrightness: brightness == Brightness.dark ? Brightness.light : Brightness.dark,    // iOS এর জন্য
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appBarTheme = Theme.of(context).appBarTheme;
    final appBarColor = appBarTheme.backgroundColor ?? colorScheme.primary;
    final appBarForegroundColor =
        appBarTheme.foregroundColor ?? colorScheme.onPrimary;
    final themeProvider = context.watch<ThemeProvider>();
    final isDarkMode = themeProvider.isDarkMode;

    final tasks = [
      _TaskItem(icon: Icons.menu_book, label: 'Daily Task'),
      _TaskItem(icon: Icons.how_to_reg, label: 'Attendance'),
      _TaskItem(icon: Icons.edit_document, label: 'Exam Atten.'),
      _TaskItem(
        icon: Icons.assignment_turned_in,
        label: 'Recent Results',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const RecentResultsScreen(),
            ),
          );
        },
      ),
      _TaskItem(
        icon: Icons.receipt_long,
        label: 'Office Order',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const OfficeOrderScreen(),
            ),
          );
        },
      ),
      _TaskItem(
        icon: Icons.rate_review,
        label: 'Archive Results',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const ArchiveResultsScreen(),
            ),
          );
        },
      ),
      _TaskItem(icon: Icons.assignment, label: 'Assignment'),
      _TaskItem(
        icon: Icons.account_tree,
        label: 'Office Dept.',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const DepartmentListScreen(),
            ),
          );
        },
      ),
      _TaskItem(
        icon: Icons.insert_chart_outlined,
        label: 'Affiliated College',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const CollegeListScreen(),
            ),
          );
        },
      ),
      _TaskItem(icon: Icons.photo_library, label: 'Gallery'),
      _TaskItem(icon: Icons.quiz, label: 'Res. Query'),
      _TaskItem(icon: Icons.celebration, label: 'Holiday'),
    ];

    final bottomNavItems = buildAppBottomNavItems(context);
    const currentIndex = 2;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        // --- সাইডবার ড্রয়ার মেনু ---
        drawer: Drawer(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: appBarColor),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: colorScheme.surface,
                  child: Icon(Icons.person, size: 45, color: colorScheme.primary),
                ),
                accountName: const Text('Habibur Rahaman',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                accountEmail: const Text('habibur@example.com'),
              ),
              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: const Text('Home'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Profile'),
                onTap: () {},
              ),
              SwitchListTile(
                secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
                title: const Text('Dark mode'),
                value: isDarkMode,
                onChanged: themeProvider.toggleTheme,
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () {},
              ),
            ],
          ),
        ),

        body: Column(
          children: [
            // --- ফ্ল্যাট ফুল-উইডথ হেডার (Flat Full-width Header) ---
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: appBarColor,
                // নিচে হালকা শ্যাডো দেওয়ার জন্য
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false, // হেডারের নিচে সেফ এরিয়া দরকার নেই
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Row(
                    children: [
                      // ড্রয়ার বাটন
                      Builder(
                        builder: (context) => IconButton(
                          icon: Icon(
                            Icons.menu,
                            color: appBarForegroundColor,
                            size: 28,
                          ),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // লোগো
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Image.asset(
                          'assets/nu-logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'National University',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: appBarForegroundColor,
                              ),
                            ),
                            Text(
                              'Bangladesh',
                              style: TextStyle(
                                fontSize: 13,
                                color: appBarForegroundColor.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // নোটিফিকেশন আইকন
                      IconButton(
                        icon: Icon(
                          Icons.notifications_none_outlined,
                          color: appBarForegroundColor,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // নিচের কন্টেন্টগুলো স্ক্রল করার জন্য Expanded ব্যবহার করা হয়েছে
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- স্লাইডার সেকশন ---
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Container(
                        height: 160,
                        width: double.infinity,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Image.asset(
                          'assets/img.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // --- সার্ভিসেস টাইটেল ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Our Services',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Everything you need in one place',
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- গ্রিড ভিউ ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        shrinkWrap: true, // সিঙ্গেল চাইল্ড স্ক্রল ভিউর ভেতরে দরকার
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: tasks.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.95,
                        ),
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          final baseColor = _TaskItem.palette[index % _TaskItem.palette.length];
                          return _TaskTile(
                            icon: task.icon,
                            label: task.label,
                            color: baseColor,
                            onTap: task.onTap,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: AppBottomNavBar(
          items: bottomNavItems,
          currentIndex: currentIndex,
        ),
      ),
    );
  }
}

// --- হেল্পার ক্লাস (বদলানোর প্রয়োজন নেই) ---
class _TaskItem {
  const _TaskItem({required this.icon, required this.label, this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  static const palette = [Color(0xFF7E57C2), Color(0xFF26A69A), Color(0xFFFFA726), Color(0xFF42A5F5), Color(0xFFEF5350), Color(0xFF8D6E63)];
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.icon, required this.label, required this.color, this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = Color.lerp(color, Colors.black, 0.2) ?? color;
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                color: Theme.of(context).shadowColor.withOpacity(0.15),
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 42, width: 42,
                decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
