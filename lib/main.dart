import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'screens/forms_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
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
      initialRoute: '/orders',
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
