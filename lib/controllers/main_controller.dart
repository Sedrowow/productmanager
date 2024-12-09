import 'dart:async';
import 'package:flutter/material.dart';
import '../services/sqlmanage.dart';

class MainController {
  final DatabaseManager _dbManager = DatabaseManager();
  final _connectionController = StreamController<bool>.broadcast();
  final _debugModeController = StreamController<bool>.broadcast();
  final _modelsController = StreamController<List<String>>.broadcast();
  bool _isDebugMode = false;

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
