import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/sqlmanage.dart';
import '../providers/data_provider.dart';

class MainController {
  final DatabaseManager _dbManager = DatabaseManager();
  final _connectionController = StreamController<bool>.broadcast();
  final _debugModeController = StreamController<bool>.broadcast();
  final _modelsController = StreamController<List<String>>.broadcast();
  final _debugOptionsVisible = StreamController<bool>.broadcast();
  bool _isDebugMode = false;
  static const String _debugPin = '24682468';

  Stream<bool> get connectionStream => _connectionController.stream;
  Stream<bool> get debugModeStream => _debugModeController.stream;
  Stream<List<String>> get modelsStream => _modelsController.stream;
  Stream<bool> get debugOptionsVisible => _debugOptionsVisible.stream;

  MainController() {
    final models = _dbManager.getAvailableModels();
    _modelsController.add(models);
    _debugModeController.add(_isDebugMode);
    checkConnection();
  }

  Future<void> checkConnection() async {
    final isConnected = await _dbManager.checkConnection();
    _connectionController.add(isConnected);
  }

  Future<void> showDebugPinDialog(BuildContext context) async {
    final TextEditingController pinController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Debug PIN'),
        content: TextField(
          controller: pinController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Enter PIN',
            hintStyle: TextStyle(color: Colors.grey),
          ),
          keyboardType: TextInputType.number,
          maxLength: 8,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (pinController.text == _debugPin) {
                Navigator.pop(context);
                toggleDebugMode();
              } else {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invalid PIN'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    ).then((_) => pinController.dispose());
  }

  void toggleDebugMode() {
    _isDebugMode = !_isDebugMode;
    _debugModeController.add(_isDebugMode);
  }

  void openModelForm(BuildContext context, String modelType) {
    Navigator.pushNamed(context, '/$modelType');
  }

  void showDebugMenu(BuildContext context) async {
    if (!_isDebugMode) {
      await showDebugPinDialog(context);
      return;
    }

    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Check Connection'),
            onTap: () async {
              final result = await dataProvider.checkDatabaseConnection();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result)),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.data_array),
            title: const Text('Populate All Tables'),
            onTap: () async {
              try {
                await dataProvider.populateAllTables();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Tables populated successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('Clear Database'),
            onTap: () async {
              await dataProvider.clearDatabase();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Database cleared')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void dispose() {
    _connectionController.close();
    _debugModeController.close();
    _modelsController.close();
    _debugOptionsVisible.close();
  }
}
