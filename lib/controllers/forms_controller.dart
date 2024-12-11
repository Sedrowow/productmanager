import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../providers/data_provider.dart';
import '../services/sqlmanage.dart';

class FormsController {
  final String modelName;
  final _formData = <String, dynamic>{};
  final _formControllers = <String, TextEditingController>{};

  FormsController(this.modelName);

  void updateField(String field, String value) {
    _formData[field] = value;
  }

  void clearForm() {
    _formData.clear();
    for (final controller in _formControllers.values) {
      controller.clear();
    }
  }

  void editTemporaryEntry(
      BuildContext context, Map<String, dynamic> entry, int index) {
    _formData.clear();
    entry.forEach((key, value) {
      if (key != 'id') {
        _formControllers[key]?.text = value.toString();
        _formData[key] = value;
      }
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Entry'),
        content: SingleChildScrollView(
          child: Form(
            child: buildForm(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context
                  .read<DataProvider>()
                  .updateTemporaryEntry(modelName, index, Map.from(_formData));
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget buildForm(BuildContext context) {
    final model = DatabaseManager().createModel(modelName);
    if (model == null) return const SizedBox();

    final fields = model.toMap()..remove('id');
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          children: fields.entries.map((field) {
            _formControllers[field.key] ??= TextEditingController();
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _formControllers[field.key],
                    decoration: InputDecoration(labelText: field.key),
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'Field required' : null,
                    keyboardType: _getKeyboardType(field.key),
                    inputFormatters: _getInputFormatters(field.key),
                    onChanged: (value) {
                      _handleFieldChange(context, field.key, value);
                      // Force rebuild suggestions when these fields change
                      if (field.key == 'user_id' || field.key == 'product_id') {
                        setState(() {}); // Trigger rebuild for suggestions
                      }
                    },
                  ),
                  if (modelName == 'orders' &&
                      (field.key == 'user_id' || field.key == 'product_id'))
                    Consumer<DataProvider>(
                      builder: (context, provider, child) {
                        return FutureBuilder<String>(
                          future: provider.getEntitySuggestions(
                            field.key == 'user_id' ? 'users' : 'products',
                            _formControllers[field.key]!.text,
                          ),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData ||
                                snapshot.data!.isEmpty ||
                                snapshot.data == 'No matches found') {
                              return const SizedBox();
                            }
                            return Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              constraints: const BoxConstraints(
                                maxHeight: 100, // Limit height of suggestions
                              ),
                              child: SingleChildScrollView(
                                child: Text(
                                  snapshot.data!,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  TextInputType _getKeyboardType(String fieldKey) {
    if (fieldKey.contains('price')) {
      return const TextInputType.numberWithOptions(decimal: true);
    } else if (fieldKey.contains('quantity')) {
      return const TextInputType.numberWithOptions(decimal: false);
    }
    return TextInputType.text;
  }

  List<TextInputFormatter>? _getInputFormatters(String fieldKey) {
    if (fieldKey.contains('price')) {
      return [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))];
    } else if (fieldKey.contains('quantity')) {
      return [FilteringTextInputFormatter.digitsOnly];
    }
    return null;
  }

  void _handleFieldChange(BuildContext context, String field, String value) {
    if (field.contains('price')) {
      _formData[field] = double.tryParse(value) ?? 0.0;
    } else {
      _formData[field] = value;
    }
  }

  void saveForm(BuildContext context) async {
    if (_formData.isEmpty) return;

    final provider = context.read<DataProvider>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (modelName == 'orders') {
      // Load related data first
      await provider.loadData('users');
      await provider.loadData('products');

      final isValid = await provider.validateOrderEntry(Map.from(_formData));
      if (!isValid && context.mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Invalid user or product reference')),
        );
        return;
      }
    }

    provider.addTemporaryEntry(modelName, Map.from(_formData));
    clearForm();
  }

  void dispose() {
    for (var controller in _formControllers.values) {
      controller.dispose();
    }
  }
}
