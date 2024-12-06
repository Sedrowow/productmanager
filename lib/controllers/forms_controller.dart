import 'dart:async';
import '../models/base.dart';

class FormsController {
  final BaseTable model;
  final _formFieldsController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _entriesController =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  final List<Map<String, dynamic>> _entries = [];
  Map<String, dynamic> _currentEntry = {};

  Stream<Map<String, dynamic>> get formFieldsStream =>
      _formFieldsController.stream;
  Stream<List<Map<String, dynamic>>> get entriesStream =>
      _entriesController.stream;

  FormsController(this.model) {
    _initializeFields();
  }

  void _initializeFields() {
    _currentEntry = Map.from(model.toMap())..remove('id');
    _formFieldsController.add(_currentEntry);
    _entriesController.add(_entries);
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
    _entries.add(Map.from(_currentEntry));
    clearForm(); // Clear form after submission
    _entriesController.add(_entries);
  }

  void editEntry(int index) {
    _currentEntry = Map.from(_entries[index]);
    _entries.removeAt(index);
    _formFieldsController.add(_currentEntry);
    _entriesController.add(_entries);
  }

  void deleteEntry(int index) {
    _entries.removeAt(index);
    _entriesController.add(_entries);
  }

  void dispose() {
    _formFieldsController.close();
    _entriesController.close();
  }
}
