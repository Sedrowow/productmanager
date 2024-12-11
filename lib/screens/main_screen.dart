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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Manager')),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Forms', style: TextStyle(color: Colors.white)),
            ),
            for (final model in ['users', 'products', 'orders'])
              ListTile(
                title: Text(model.toUpperCase()),
                onTap: () => _controller.openModelForm(context, model),
              ),
          ],
        ),
      ),
      body: StreamBuilder<List<String>>(
        stream: _controller.modelsStream,
        builder: (context, snapshot) {
          return const Center(
            child: Text('Select a form from the menu'),
          );
        },
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: _controller.debugModeStream,
        builder: (context, snapshot) {
          final isDebug = snapshot.data ?? false;
          return FloatingActionButton(
            onPressed: () => _controller.showDebugPinDialog(context),
            child: Icon(isDebug ? Icons.bug_report : Icons.bug_report_outlined),
          );
        },
      ),
    );
  }
}
