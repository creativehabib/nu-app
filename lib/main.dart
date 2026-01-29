import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/directory_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const UniversityDirectoryApp());
}

class UniversityDirectoryApp extends StatelessWidget {
  const UniversityDirectoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DirectoryProvider()..loadDepartments(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'National University Directory',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0D47A1),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF7F9FC),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
