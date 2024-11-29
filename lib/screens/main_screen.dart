import 'package:flutter/material.dart';
import '../controllers/main_controller.dart';
import 'tables_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final MainController _controller = MainController();
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    final bool result = await _controller.checkDatabaseConnection();
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TablesScreen(),
                  ),
                );
              },
              child: const Text('View Tables'),
            ),
          ],
        ),
      ),
    );
  }
}
