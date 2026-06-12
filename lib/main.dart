import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/config_loader.dart';
import 'db/db_service.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load bundled config instantly (no network required)
  await ConfigLoader.loadBundled();
  
  // Init database
  await DbService.init();

  runApp(const ProviderScope(child: StridebornApp()));
  
  // Fetch PB config overrides in background after UI is visible
  ConfigLoader.fetchOverrides();
}

class StridebornApp extends StatelessWidget {
  const StridebornApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Strideborn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFD4A84B),
          secondary: const Color(0xFF8B6914),
          surface: const Color(0xFF1A1A2E),
          onSurface: const Color(0xFFE8DCC8),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}
