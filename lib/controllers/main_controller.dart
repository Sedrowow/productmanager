import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/sqlmanage.dart';
import '../providers/debug_settings_provider.dart';
import '../services/github_service.dart';

class MainController {
  final DatabaseManager _dbManager = DatabaseManager();
  final _connectionController = StreamController<bool>.broadcast();
  final _debugModeController = StreamController<bool>.broadcast();
  final _modelsController = StreamController<List<String>>.broadcast();
  final _debugOptionsVisible = StreamController<bool>.broadcast();
  final GitHubService _gitHubService = GitHubService();
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

  Future<void> showDebugMenu(BuildContext context) async {
    final debugSettings =
        Provider.of<DebugSettingsProvider>(context, listen: false);

    // If not in development mode, show only bug report
    if (!debugSettings.isDevelopmentMode) {
      _showBugReportDialog(context);
      return;
    }

    // Show full debug menu in development mode
    await showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Debug Mode'),
                value: debugSettings.isDebugUnlocked,
                onChanged: (value) {
                  debugSettings.setDebugUnlocked(value);
                  setState(() {});
                  _debugModeController.add(value);
                },
              ),
              if (debugSettings.isDebugUnlocked) ...[
                SwitchListTile(
                  title: const Text('Show Debug Logs'),
                  value: debugSettings.showDebugLogs,
                  onChanged: (value) => setState(() {
                    debugSettings.setShowDebugLogs(value);
                  }),
                ),
                ListTile(
                  title: const Text('Report Bug'),
                  leading: const Icon(Icons.bug_report),
                  onTap: () => _showBugReportDialog(context),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showBugReportDialog(BuildContext context) async {
    // Create controllers
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Report Bug'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Brief description of the bug',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Detailed description of the bug',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Submit'),
            ),
          ],
        ),
      );

      if (result == true &&
          titleController.text.isNotEmpty &&
          context.mounted) {
        final success = await _gitHubService.createIssue(
          titleController.text,
          descriptionController.text,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success
                    ? 'Bug report submitted successfully'
                    : 'Failed to submit bug report',
              ),
            ),
          );
        }
      }
    } finally {
      // Ensure controllers are disposed
      titleController.dispose();
      descriptionController.dispose();
    }
  }

  void dispose() {
    _connectionController.close();
    _debugModeController.close();
    _modelsController.close();
    _debugOptionsVisible.close();
  }
}
