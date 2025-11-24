import 'package:flutter/material.dart';
import '../models/championship.dart';

class AddChampionshipDialog extends StatefulWidget {
  const AddChampionshipDialog({super.key});

  @override
  State<AddChampionshipDialog> createState() => _AddChampionshipDialogState();
}

class _AddChampionshipDialogState extends State<AddChampionshipDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Championship'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Championship Name',
                border: OutlineInputBorder(),
                hintText: 'e.g., Summer Tournament 2024',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a championship name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                border: OutlineInputBorder(),
                hintText: 'Add a description for this championship',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final championship = Championship(
                name: _nameController.text,
                description: _descriptionController.text.isEmpty
                    ? null
                    : _descriptionController.text,
              );
              Navigator.pop(context, championship);
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}

