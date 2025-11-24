import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/championship.dart';
import '../services/api_service.dart';

class AddPlayerDialog extends StatefulWidget {
  const AddPlayerDialog({super.key});

  @override
  State<AddPlayerDialog> createState() => _AddPlayerDialogState();
}

class _AddPlayerDialogState extends State<AddPlayerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  List<Championship> _championships = [];
  Set<int> _selectedChampionshipIds = {};
  bool _isLoadingChampionships = true;

  @override
  void initState() {
    super.initState();
    _loadChampionships();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadChampionships() async {
    try {
      final championships = await ApiService.getAllChampionships();
      setState(() {
        _championships = championships;
        _isLoadingChampionships = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingChampionships = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading championships: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Player'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: _isLoadingChampionships
              ? const Center(child: CircularProgressIndicator())
              : _championships.isEmpty
                  ? const Text('No championships available. Please create a championship first.')
                  : SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Player Name',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a player name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Select Championships:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ..._championships.map((champ) {
                            return CheckboxListTile(
                              title: Text(champ.name),
                              value: _selectedChampionshipIds.contains(champ.id),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedChampionshipIds.add(champ.id!);
                                  } else {
                                    _selectedChampionshipIds.remove(champ.id);
                                  }
                                });
                              },
                            );
                          }),
                        ],
                      ),
                    ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoadingChampionships
              ? null
              : () {
                  if (_formKey.currentState!.validate()) {
                    final selectedChampionships = _championships
                        .where((c) => _selectedChampionshipIds.contains(c.id))
                        .toList();
                    final player = Player(
                      name: _nameController.text,
                      championships: selectedChampionships.isEmpty ? null : selectedChampionships,
                    );
                    Navigator.pop(context, player);
                  }
                },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

