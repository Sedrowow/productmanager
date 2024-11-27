import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'sqlmanage.dart';
import 'database_viewer.dart';

void main() async {
  // Make main async
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database factory based on platform
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else {
    // Initialize FFI for other platforms
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

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
  bool _isChecking = false;
  int _retryCount = 0;
  bool _showCreateOption = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _checkConnectionWithRetry() async {
    if (_isChecking) return;

    setState(() {
      _isChecking = true;
      _showCreateOption = false;
      _retryCount = 0; // Reset counter at start
    });

    for (int i = 0; i < 3; i++) {
      setState(() {
        _retryCount = i + 1; // Update counter in setState
      });

      final bool result = await _dbManager.checkDatabaseConnection();
      if (result) {
        setState(() {
          _isConnected = true;
          _isChecking = false;
          _showCreateOption = false;
        });
        return;
      }
      await Future.delayed(const Duration(seconds: 1));
    }

    setState(() {
      _isConnected = false;
      _isChecking = false;
      _showCreateOption = true;
    });
  }

  Future<void> _createDatabase() async {
    setState(() {
      _isChecking = true;
      _showCreateOption = false;
    });

    final bool result = await _dbManager.forceCreateDatabase();

    setState(() {
      _isConnected = result;
      _isChecking = false;
      _showCreateOption = !result;
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
            if (_isChecking) Text('Retrying... Attempt $_retryCount of 3'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isChecking ? null : _checkConnectionWithRetry,
              child: const Text('Check Connection'),
            ),
            if (_showCreateOption) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _createDatabase,
                child: const Text('Create Database'),
              ),
            ],
            if (_isConnected) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DatabaseViewerScreen(),
                    ),
                  );
                },
                child: const Text('View Database'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
