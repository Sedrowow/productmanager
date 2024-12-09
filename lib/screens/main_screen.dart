import 'package:flutter/material.dart';
import '../controllers/main_controller.dart';

class MainScreen extends StatelessWidget {
  final MainController _controller = MainController();

  MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Manager'),
      ),
      body: Center(
        child: StreamBuilder<List<String>>(
          stream: _controller.modelsStream,
          initialData: const ['users', 'products', 'orders'],
          builder: (context, snapshot) {
            final models = snapshot.data ?? [];
            if (models.isEmpty) {
              return const Text('No models available');
            }

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: models
                  .map(
                    (modelType) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/$modelType'),
                        child: Text('Manage ${modelType.toUpperCase()}'),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: StreamBuilder<bool>(
        stream: _controller.debugModeStream,
        builder: (context, snapshot) {
          final isDebug = snapshot.data ?? false;
          return FloatingActionButton(
            heroTag: 'debug_button',
            onPressed: _controller.toggleDebugMode,
            child: Icon(isDebug ? Icons.bug_report : Icons.bug_report_outlined),
          );
        },
      ),
    );
  }
}
