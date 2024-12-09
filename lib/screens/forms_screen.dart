import 'package:flutter/material.dart';
import '../controllers/forms_controller.dart';
import '../services/sqlmanage.dart';

class FormsScreen extends StatefulWidget {
  // Change to StatefulWidget
  final String modelName;

  const FormsScreen({
    super.key,
    required this.modelName,
  });

  @override
  State<FormsScreen> createState() => _FormsScreenState();
}

class _FormsScreenState extends State<FormsScreen> {
  late final FormsController controller;

  @override
  void initState() {
    super.initState();
    final model = DatabaseManager().createModel(widget.modelName);
    if (model == null) {
      throw Exception('Invalid model type: ${widget.modelName}');
    }
    controller = FormsController(model);

    // Load saved data after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadSavedData(context);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        controller.navigateToScreen(context, '/orders');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.modelName} Form'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => controller.navigateToScreen(context, '/orders'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () => controller.saveEntries(context),
            ),
            PopupMenuButton<String>(
              onSelected: (route) =>
                  controller.navigateToScreen(context, route),
              itemBuilder: (context) =>
                  controller.getNavigationItems(widget.modelName),
            ),
          ],
        ),
        body: Column(
          children: [
            // Form Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder<Map<String, dynamic>>(
                stream: controller.formFieldsStream,
                initialData:
                    controller.getInitialFields(), // Add initial fields
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

            // Temporary Entries Section
            Expanded(
              child: Column(
                children: [
                  const Divider(thickness: 2),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Unsaved ${widget.modelName.toUpperCase()}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.orange,
                          ),
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: controller.temporaryEntriesStream,
                      initialData: const [],
                      builder: (context, snapshot) {
                        final entries = snapshot.data ?? [];
                        return ListView.builder(
                          itemCount: entries.length,
                          itemBuilder: (context, index) {
                            final entry = entries[index];
                            return ListTile(
                              title: Text(
                                entry.values.join(' - '),
                                style: const TextStyle(color: Colors.orange),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () =>
                                        controller.editEntry(index),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () =>
                                        controller.deleteTemporaryEntry(index),
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
            ),

            // Saved Entries Section
            Expanded(
              child: Column(
                children: [
                  const Divider(thickness: 2),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Saved ${widget.modelName.toUpperCase()}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<List<Map<String, dynamic>>>(
                      stream: controller.savedEntriesStream,
                      initialData: const [],
                      builder: (context, snapshot) {
                        final entries = snapshot.data ?? [];
                        return ListView.builder(
                          itemCount: entries.length,
                          itemBuilder: (context, index) {
                            final entry = entries[index];
                            return ListTile(
                              title: Text(entry.values.join(' - ')),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () =>
                                    controller.deleteSavedEntry(context, index),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
