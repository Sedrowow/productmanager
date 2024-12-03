import 'package:flutter/material.dart';
import '../controllers/main_controller.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final MainController _controller = MainController();

  @override
  void initState() {
    super.initState();
    _updateConnectionStatus();
  }

  Future<void> _updateConnectionStatus() async {
    await _controller.checkConnection();
    setState(() {});
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
              'Database connection Status: ${_controller.isConnected ? 'Connected' : 'Not Connected'}',
              style: TextStyle(
                color: _controller.isConnected ? Colors.green : Colors.red,
              ),
            ),
            ElevatedButton(
              onPressed: _updateConnectionStatus,
              child: const Text('Check Connection'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _controller.navigateToTables(context),
              child: const Text('View Tables'),
            ),
          ],
        ),
      ),
    );
  }
}
