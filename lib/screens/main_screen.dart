import 'package:flutter/material.dart';
import '../controllers/main_controller.dart';

class MainScreen extends StatelessWidget {
  final MainController _controller = MainController();

  MainScreen({super.key});

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
            StreamBuilder<bool>(
              stream: _controller.connectionStream,
              builder: (context, snapshot) {
                return Text(
                  'Database connection Status: ${snapshot.data == true ? 'Connected' : 'Not Connected'}',
                  style: TextStyle(
                    color: snapshot.data == true ? Colors.green : Colors.red,
                  ),
                );
              },
            ),
            ElevatedButton(
              onPressed: _controller.checkConnection,
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
