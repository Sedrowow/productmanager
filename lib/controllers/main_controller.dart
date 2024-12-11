import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/sqlmanage.dart';
import '../providers/data_provider.dart';
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

  void showDebugMenu(BuildContext context) async {
    final debugSettings =
        Provider.of<DebugSettingsProvider>(context, listen: false);

    if (!debugSettings.isDebugUnlocked && debugSettings.isDevelopmentMode) {
      await showDebugPinDialog(context);
      return;
    }

    if (!debugSettings.isDevelopmentMode) {
      _showBugReportDialog(context);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Consumer<DebugSettingsProvider>(
              builder: (context, settings, _) => SwitchListTile(
                title: const Text('Show Debug Logs'),
                value: settings.showDebugLogs,
                onChanged: settings.setShowDebugLogs,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Check Connection'),
              onTap: () async {
                final result =
                    await Provider.of<DataProvider>(context, listen: false)
                        .checkDatabaseConnection();
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(result)));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.data_array),
              title: const Text('Populate Table'),
              onTap: () => _showPopulateDialog(context),
            ),
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: const Text('Submit Bug Report'),
              onTap: () => _showBugReportDialog(context),
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever),
              title: const Text('Clear Database'),
              onTap: () async {
                await Provider.of<DataProvider>(context, listen: false)
                    .clearDatabase();
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
      ),
    );
  }

  Future<void> _showPopulateDialog(BuildContext context) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    String selectedTable = 'users';
    int entryCount = 1;
    int maxEntries = 100;

    if (selectedTable == 'orders') {
      final usersCount = (dataProvider.getPersistedEntries('users')).length;
      final productsCount =
          (dataProvider.getPersistedEntries('products')).length;
      if (usersCount < 3 || productsCount < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Need at least 3 users and products')),
        );
        return;
      }
      maxEntries = usersCount * productsCount;
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Populate Table'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedTable,
                items: ['users', 'products', 'orders']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedTable = value!;
                    if (value == 'orders') {
                      entryCount = maxEntries.clamp(1, maxEntries);
                    }
                  });
                },
              ),
              TextFormField(
                initialValue: '1',
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Number of entries',
                  helperText: selectedTable == 'orders'
                      ? 'Max: $maxEntries'
                      : 'Max: 100',
                ),
                onChanged: (value) {
                  entryCount = int.tryParse(value) ?? 1;
                  if (selectedTable == 'orders') {
                    entryCount = entryCount.clamp(1, maxEntries);
                  } else {
                    entryCount = entryCount.clamp(1, 100);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await dataProvider.populateWithRandomData(
                    selectedTable,
                    entryCount,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Table populated')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                }
              },
              child: const Text('Populate'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showBugReportDialog(BuildContext context) async {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    bool isSubmitting = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Submit Bug Report'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Brief description of the issue',
                ),
                enabled: !isSubmitting,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Please provide detailed steps to reproduce...',
                ),
                maxLines: 5,
                enabled: !isSubmitting,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (titleController.text.isEmpty ||
                          descriptionController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill in all fields'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      setState(() => isSubmitting = true);

                      final success = await _gitHubService.createIssue(
                        titleController.text,
                        descriptionController.text,
                      );

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success
                                  ? 'Bug report submitted successfully'
                                  : 'Failed to submit bug report',
                            ),
                            backgroundColor:
                                success ? Colors.green : Colors.red,
                          ),
                        );
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit'),
            ),
          ],
        ),
      ),
    );

    titleController.dispose();
    descriptionController.dispose();
  }

  void dispose() {
    _connectionController.close();
    _debugModeController.close();
    _modelsController.close();
    _debugOptionsVisible.close();
  }
}
