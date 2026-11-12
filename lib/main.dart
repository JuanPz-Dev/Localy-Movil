import 'package:flutter/material.dart';
import 'screens/auth/login_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Localy',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F4ED),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF075E59),
        ),
      ),
      home: const LoginView(),
    );
  }
}
