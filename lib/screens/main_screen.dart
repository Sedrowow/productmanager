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
          initialData: const [
            'users',
            'products',
            'orders'
          ], // Add initial data
          builder: (context, snapshot) {
            final models = snapshot.data ?? []; // Handle null data
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
                            _controller.openModelForm(context, modelType),
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
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isDebug)
                FloatingActionButton(
                  heroTag: 'tables_button', // Add unique hero tag
                  onPressed: () => _controller.navigateToTables(context),
                  child: const Icon(Icons.table_chart),
                ),
              const SizedBox(height: 10),
              FloatingActionButton(
                heroTag: 'debug_button', // Add unique hero tag
                onPressed: _controller.toggleDebugMode,
                child: Icon(
                    isDebug ? Icons.bug_report : Icons.bug_report_outlined),
              ),
            ],
          );
        },
      ),
    );
  }
}
