import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/number_picker_dialog.dart';
import '../providers/data_provider.dart';
import '../controllers/forms_controller.dart';

class FormsScreen extends StatefulWidget {
  final String modelName;
  const FormsScreen({super.key, required this.modelName});

  @override
  State<FormsScreen> createState() => _FormsScreenState();
}

class _FormsScreenState extends State<FormsScreen>
    with SingleTickerProviderStateMixin {
  late final FormsController controller;
  final _formKey = GlobalKey<FormState>();
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    controller = FormsController(widget.modelName);
    _tabController = TabController(length: 2, vsync: this);
    WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().loadData(widget.modelName);
    });
    if (widget.modelName == 'orders') {
      // Preload related data when orders screen is initialized
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<DataProvider>().ensureRelatedDataLoaded();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload data when dependencies change (e.g., tab switch)
    context.read<DataProvider>().loadData(widget.modelName);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildTemporaryEntriesTab() {
    return Consumer<DataProvider>(
      builder: (context, provider, child) {
        final entries = provider.getTemporaryEntries(widget.modelName);
        return entries.isEmpty
            ? const Center(child: Text('No temporary entries'))
            : ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(entries[index].values.join(' - ')),
                  leading: const Icon(Icons.pending_outlined),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => controller.editTemporaryEntry(
                            context, entries[index], index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => provider.deleteTemporaryEntry(
                            widget.modelName, index),
                      ),
                    ],
                  ),
                  subtitle: widget.modelName == 'orders'
                      ? FutureBuilder<String>(
                          future:
                              provider.validateOrderReferences(entries[index]),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text(snapshot.data!,
                                  style: TextStyle(
                                    color: snapshot.data!.contains('Invalid')
                                        ? Colors.red
                                        : Colors.green,
                                  ));
                            }
                            return const SizedBox();
                          },
                        )
                      : null,
                ),
              );
      },
    );
  }

  Widget _buildDebugButton() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.bug_report),
      onSelected: (value) => _handleDebugOption(value),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'check', child: Text('Check Connection')),
        const PopupMenuItem(value: 'clear', child: Text('Clear Database')),
        const PopupMenuItem(
            value: 'populate', child: Text('Populate with Random Data')),
      ],
    );
  }

  Future<void> _handleDebugOption(String option) async {
    final provider = context.read<DataProvider>();
    switch (option) {
      case 'check':
        final result = await provider.checkDatabaseConnection();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result)),
        );
        break;
      case 'clear':
        await provider.clearDatabase();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Database cleared')),
        );
        break;
      case 'populate':
        if (widget.modelName != 'orders') {
          await _showPopulateDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cannot populate orders directly')),
          );
        }
        break;
    }
  }

  Future<void> _showPopulateDialog() async {
    final count = await showDialog<int>(
      context: context,
      builder: (context) => const NumberPickerDialog(
        minValue: 1,
        maxValue: 10,
        title: 'Select number of entries',
      ),
    );
    if (count != null && mounted) {
      await context
          .read<DataProvider>()
          .populateWithRandomData(widget.modelName, count);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.modelName} Form'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          _buildDebugButton(),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              context
                  .read<DataProvider>()
                  .persistTemporaryEntries(widget.modelName);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Entries saved to database')),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Temporary'),
            Tab(text: 'Saved Entries'),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Forms', style: TextStyle(color: Colors.white)),
            ),
            for (final model in ['users', 'products', 'orders'])
              ListTile(
                title: Text(model.toUpperCase()),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  if (model != widget.modelName) {
                    Navigator.pushReplacementNamed(context, '/$model');
                  }
                },
              ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: controller.buildForm(context),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => controller.clearForm(),
                  child: const Text('Clear'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      controller.saveForm(context);
                      _tabController.animateTo(0); // Switch to temporary tab
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Added to temporary entries')),
                      );
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTemporaryEntriesTab(),
                  // Saved Entries Tab
                  Consumer<DataProvider>(
                    builder: (context, provider, child) {
                      final entries =
                          provider.getPersistedEntries(widget.modelName);
                      return entries.isEmpty
                          ? const Center(child: Text('No saved entries'))
                          : ListView.builder(
                              itemCount: entries.length,
                              itemBuilder: (context, index) => ListTile(
                                title: Text(entries[index].values.join(' - ')),
                                subtitle: widget.modelName == 'orders'
                                    ? Text(provider
                                        .getOrderDetails(entries[index]))
                                    : null,
                                leading: const Icon(Icons.save_outlined),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    provider.deleteEntry(
                                        widget.modelName, index);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Entry deleted')),
                                    );
                                  },
                                ),
                              ),
                            );
                    },
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
