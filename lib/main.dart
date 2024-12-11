import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/data_provider.dart';
import 'screens/forms_screen.dart';
import 'services/platform_service.dart';
import 'screens/main_screen.dart';
import 'providers/debug_settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PlatformService.initializePlatform();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DataProvider()),
        ChangeNotifierProvider(create: (_) => DebugSettingsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Manager',
      home: const MainScreen(),
      routes: {
        '/users': (context) => const FormsScreen(modelName: 'users'),
        '/products': (context) => const FormsScreen(modelName: 'products'),
        '/orders': (context) => const FormsScreen(modelName: 'orders'),
      },
      onGenerateRoute: (settings) {
        // Fallback to orders page if route not found
        return MaterialPageRoute(
          builder: (context) => const FormsScreen(modelName: 'orders'),
        );
      },
    );
  }
}
