import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/directory_provider.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const UniversityDirectoryApp());
}

class UniversityDirectoryApp extends StatelessWidget {
  const UniversityDirectoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    final lightTheme = ThemeData(
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF173B5F),
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF173B5F),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF7F9FC),
      useMaterial3: true,
    );

    final darkTheme = ThemeData(
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0F2238),
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF8BB6FF),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF0B141F),
      useMaterial3: true,
    );

    return ChangeNotifierProvider(
      create: (_) => DirectoryProvider()..loadDepartments(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'National University Directory',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
