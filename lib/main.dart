import 'package:flutter/material.dart';
import 'sqlmanage.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final DatabaseManager _dbManager = DatabaseManager();
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    final bool result = await _dbManager.checkDatabaseConnection();
    setState(() {
      _isConnected = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQL Management'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Database connection Status: ${_isConnected ? 'Connected' : 'Not Connected'}',
              style: TextStyle(
                color: _isConnected ? Colors.green : Colors.red,
              ),
            ),
            ElevatedButton(
              onPressed: _checkConnection,
              child: const Text('Check Connection'),
            ),
          ],
        ),
      ),
    );
  }
}
