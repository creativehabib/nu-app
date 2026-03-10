import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'providers/college_provider.dart';
import 'providers/directory_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/office_order_screen.dart';

// ১. Create a GlobalKey
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // --- OneSignal Start ---
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("56bc5737-f29b-409c-a8de-74cc32c98a83");
  OneSignal.Notifications.requestPermission(true);

  // ২. Notification click
  OneSignal.Notifications.addClickListener((event) {
    print("নোটিফিকেশনে ক্লিক করা হয়েছে: ${event.notification.title}");

    // GlobalKey for navigate OfficeOrderScreen
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => const OfficeOrderScreen(),
      ),
    );
  });
  // --- OneSignal End ---

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  runApp(const UniversityDirectoryApp());
}

class UniversityDirectoryApp extends StatelessWidget {
  const UniversityDirectoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    final lightColorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF173B5F),
      brightness: Brightness.light,
    );
    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF173B5F),
      brightness: Brightness.dark,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DirectoryProvider()..loadDepartments()),
        ChangeNotifierProvider(create: (_) => CollegeProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            // ৩. এখানে navigatorKey টি যুক্ত করা হলো
            navigatorKey: navigatorKey,

            debugShowCheckedModeBanner: false,
            title: 'National University Directory',
            theme: ThemeData(
              appBarTheme: AppBarTheme(
                backgroundColor: lightColorScheme.primary,
                foregroundColor: lightColorScheme.onPrimary,
                systemOverlayStyle: const SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.light,
                  statusBarBrightness: Brightness.dark,
                ),
              ),
              colorScheme: lightColorScheme,
              scaffoldBackgroundColor: const Color(0xFFF7F9FC),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              appBarTheme: AppBarTheme(
                backgroundColor: const Color(0xFF1B2735),
                foregroundColor: darkColorScheme.onSurface,
                systemOverlayStyle: const SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.light,
                  statusBarBrightness: Brightness.dark,
                ),
              ),
              colorScheme: darkColorScheme,
              scaffoldBackgroundColor: const Color(0xFF0F141B),
              useMaterial3: true,
            ),
            themeMode: themeProvider.themeMode,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}