import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_avicast/providers/auth_provider.dart';
import 'package:mobile_avicast/providers/sync_provider.dart';
import 'package:mobile_avicast/providers/network_provider.dart';
import 'package:mobile_avicast/screens/splash_screen.dart';
import 'package:mobile_avicast/utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SyncProvider()),
        ChangeNotifierProvider(create: (_) => NetworkProvider()),
      ],
      child: const AvicastApp(),
    ),
  );
}

class AvicastApp extends StatelessWidget {
  const AvicastApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Avicast Mobile',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
} 