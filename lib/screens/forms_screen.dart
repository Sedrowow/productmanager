import 'package:flutter/material.dart';
import '../controllers/forms_controller.dart';

class FormsScreen extends StatelessWidget {
  final String modelName;
  final FormsController controller;

  const FormsScreen({
    super.key,
    required this.modelName,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$modelName Form'),
      ),
      body: Column(
        children: [
          // Form Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: StreamBuilder<Map<String, dynamic>>(
              stream: controller.formFieldsStream,
              initialData: controller.getInitialFields(), // Add initial fields
              builder: (context, snapshot) {
                final fields = snapshot.data ?? {};

                return Form(
                  child: Column(
                    children: fields.entries.map((field) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: field.key,
                            border: const OutlineInputBorder(),
                          ),
                          controller: TextEditingController(
                              text: field.value.toString()),
                          onChanged: (value) =>
                              controller.updateField(field.key, value),
                        ),
                      );
                    }).toList()
                      ..add(
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: controller.submitForm,
                                child: const Text('Submit'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: controller.clearForm,
                                child: const Text('Clear'),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ),
                );
              },
            ),
          ),

          // List Section
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: controller.entriesStream,
              initialData: const [], // Add initial empty list
              builder: (context, snapshot) {
                final entries = snapshot.data ?? [];

                return ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return ListTile(
                      title: Text(entry.values.join(' - ')),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => controller.editEntry(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => controller.deleteEntry(index),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
