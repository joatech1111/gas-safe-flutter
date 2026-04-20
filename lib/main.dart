import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
      locale: const Locale('ko', 'KR'),
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        platform: TargetPlatform.android,
        scaffoldBackgroundColor: const Color(0xFFEDEAE7),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFDAD8D1),
          surface: const Color(0xFFEDEAE7),
        ),
        useMaterial3: true,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF4D4A47)),
          bodyLarge: TextStyle(color: Color(0xFF4D4A47)),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Color(0xFFDAD8D1),
          foregroundColor: Colors.black,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
