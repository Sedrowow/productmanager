import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/base.dart';
import '../providers/app_state.dart';

class FormsController {
  final BaseTable model;
  final String modelName;
  final _formFieldsController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _entriesController =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  final _temporaryEntriesController =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  final _savedEntriesController =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  final List<Map<String, dynamic>> _temporaryEntries = [];
  final List<Map<String, dynamic>> _savedEntries = [];
  Map<String, dynamic> _currentEntry = {};

  List<Map<String, dynamic>> get currentEntries => _temporaryEntries;
  List<Map<String, dynamic>> get savedEntries => _savedEntries;

  Stream<Map<String, dynamic>> get formFieldsStream =>
      _formFieldsController.stream;
  Stream<List<Map<String, dynamic>>> get entriesStream =>
      _entriesController.stream;
  Stream<List<Map<String, dynamic>>> get temporaryEntriesStream =>
      _temporaryEntriesController.stream;
  Stream<List<Map<String, dynamic>>> get savedEntriesStream =>
      _savedEntriesController.stream;

  FormsController(this.model) : modelName = model.tableName {
    _initializeFields();
  }

  void _initializeFields() {
    _currentEntry = Map.from(model.toMap())..remove('id');
    _formFieldsController.add(_currentEntry);
    _entriesController.add([..._temporaryEntries, ..._savedEntries]);
  }

  Map<String, dynamic> getInitialFields() {
    return Map.from(model.toMap())..remove('id');
  }

  void updateField(String field, String value) {
    if (_currentEntry.containsKey(field)) {
      dynamic convertedValue = value;
      if (_currentEntry[field] is int) {
        convertedValue = int.tryParse(value) ?? 0;
      } else if (_currentEntry[field] is double) {
        convertedValue = double.tryParse(value) ?? 0.0;
      }
      _currentEntry[field] = convertedValue;
    }
  }

  void clearForm() {
    _currentEntry = Map.from(model.toMap())..remove('id');
    _formFieldsController.add(_currentEntry);
  }

  void submitForm() {
    _temporaryEntries.add(Map.from(_currentEntry));
    clearForm();
    _updateStreams();
  }

  void saveTemporaryEntries() {
    _savedEntries.addAll(_temporaryEntries);
    _temporaryEntries.clear();
    _updateStreams();
  }

  void editEntry(int index) {
    final allEntries = [..._temporaryEntries, ..._savedEntries];
    _currentEntry = Map.from(allEntries[index]);
    if (index < _temporaryEntries.length) {
      _temporaryEntries.removeAt(index);
    } else {
      _savedEntries.removeAt(index - _temporaryEntries.length);
    }
    _formFieldsController.add(_currentEntry);
    _entriesController.add([..._temporaryEntries, ..._savedEntries]);
  }

  void deleteTemporaryEntry(int index) {
    _temporaryEntries.removeAt(index);
    _updateStreams();
  }

  void deleteSavedEntry(BuildContext context, int index) {
    _savedEntries.removeAt(index);
    _updateStreams();

    // Update persisted data
    final appState = context.read<AppState>();
    appState.saveEntriesForModel(modelName, _savedEntries);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Entry deleted')),
    );
  }

  void initializeWithPersistedData(List<Map<String, dynamic>> persistedData) {
    _savedEntries.clear();
    _savedEntries.addAll(persistedData);
    _updateStreams();
  }

  void _updateStreams() {
    _temporaryEntriesController.add(_temporaryEntries);
    _savedEntriesController.add(_savedEntries);
  }

  void dispose() {
    _formFieldsController.close();
    _temporaryEntriesController.close();
    _savedEntriesController.close();
  }

  void navigateToScreen(BuildContext context, String route) {
    Navigator.pushReplacementNamed(context, route);
  }

  void saveEntries(BuildContext context) {
    saveTemporaryEntries();
    final appState = context.read<AppState>();
    appState.saveEntriesForModel(modelName, savedEntries);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data saved!')),
    );
  }

  List<PopupMenuEntry<String>> getNavigationItems(String currentModel) {
    return [
      if (currentModel != 'orders')
        const PopupMenuItem<String>(value: '/orders', child: Text('Orders')),
      if (currentModel != 'products')
        const PopupMenuItem<String>(
            value: '/products', child: Text('Products')),
      if (currentModel != 'users')
        const PopupMenuItem<String>(value: '/users', child: Text('Users')),
    ];
  }

  void loadSavedData(BuildContext context) {
    final appState = context.read<AppState>();
    final savedEntries = appState.getEntriesForModel(modelName);
    initializeWithPersistedData(savedEntries);
  }
}
