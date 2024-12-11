import 'dart:async';
import 'package:flutter/material.dart';
import '../services/sqlmanage.dart';

class MainController {
  final DatabaseManager _dbManager = DatabaseManager();
  final _connectionController = StreamController<bool>.broadcast();
  final _debugModeController = StreamController<bool>.broadcast();
  final _modelsController = StreamController<List<String>>.broadcast();
  bool _isDebugMode = false;
  static const String _debugPin = '24682468';

  Stream<bool> get connectionStream => _connectionController.stream;
  Stream<bool> get debugModeStream => _debugModeController.stream;
  Stream<List<String>> get modelsStream => _modelsController.stream;

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

  void dispose() {
    _connectionController.close();
    _debugModeController.close();
    _modelsController.close();
  }
}
