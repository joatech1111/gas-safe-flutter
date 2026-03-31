import 'package:flutter/material.dart';
import 'utils/prefs_util.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PrefsUtil.init();
  runApp(const GasSafeApp());
}

class GasSafeApp extends StatelessWidget {
  const GasSafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '가스안전관리',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A90D9)),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 1,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
