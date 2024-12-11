import 'package:flutter/material.dart';

class NumberPickerDialog extends StatefulWidget {
  final int minValue;
  final int maxValue;
  final String title;
  final int initialValue;

  const NumberPickerDialog({
    super.key,
    required this.minValue,
    required this.maxValue,
    required this.title,
    this.initialValue = 1,
  });

  @override
  State<NumberPickerDialog> createState() => _NumberPickerDialogState();
}

class _NumberPickerDialogState extends State<NumberPickerDialog> {
  late int _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue.clamp(widget.minValue, widget.maxValue);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: _currentValue > widget.minValue
                ? () => setState(() => _currentValue--)
                : null,
          ),
          Text(
            _currentValue.toString(),
            style: const TextStyle(fontSize: 20),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _currentValue < widget.maxValue
                ? () => setState(() => _currentValue++)
                : null,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _currentValue),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
