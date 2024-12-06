import 'dart:async';
import 'package:flutter/material.dart';
import '../services/sqlmanage.dart';
import '../screens/tables_screen.dart';
import '../screens/forms_screen.dart';
import '../controllers/forms_controller.dart';

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

  void navigateToTables(BuildContext context) {
    if (!_isDebugMode) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: 'tables_screen'),
        builder: (context) => const TablesScreen(),
      ),
    );
  }

  void openModelForm(BuildContext context, String modelType) {
    final model = _dbManager.createModel(modelType);
    if (model == null) return;

    final controller = FormsController(model);
    Navigator.of(context).push(
      MaterialPageRoute(
        settings: RouteSettings(name: '${modelType}_form'),
        builder: (context) => FormsScreen(
          modelName: modelType,
          controller: controller,
        ),
      ),
    );
  }

  void dispose() {
    _connectionController.close();
    _debugModeController.close();
    _modelsController.close();
  }
}
