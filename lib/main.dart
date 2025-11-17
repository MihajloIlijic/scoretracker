import 'package:flutter/material.dart';
import 'services/api_service.dart';

void main() {
  runApp(const ScoreTrackerApp());
}

class ScoreTrackerApp extends StatelessWidget {
  const ScoreTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Score Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ScoreTrackerHome(),
    );
  }
}

class ScoreTrackerHome extends StatefulWidget {
  const ScoreTrackerHome({super.key});

  @override
  State<ScoreTrackerHome> createState() => _ScoreTrackerHomeState();
}

class _ScoreTrackerHomeState extends State<ScoreTrackerHome> {
  List<Score> _scores = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final scores = await ApiService.getAllScores();
      setState(() {
        _scores = scores;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading scores: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _addScore() async {
    final result = await showDialog<Score>(
      context: context,
      builder: (context) => const AddScoreDialog(),
    );

    if (result != null) {
      try {
        await ApiService.createScore(result);
        _loadScores();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Score added successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding score: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteScore(Score score) async {
    if (score.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Score'),
        content: Text('Are you sure you want to delete ${score.player}\'s score?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ApiService.deleteScore(score.id!);
        _loadScores();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Score deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting score: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Score Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadScores,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadScores,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _scores.isEmpty
                  ? const Center(
                      child: Text(
                        'No scores yet.\nTap the + button to add one!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadScores,
                      child: ListView.builder(
                        itemCount: _scores.length,
                        itemBuilder: (context, index) {
                          final score = _scores[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(
                                  score.player.isNotEmpty
                                      ? score.player[0].toUpperCase()
                                      : '?',
                                ),
                              ),
                              title: Text(score.player),
                              subtitle: Text('Game: ${score.game}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Chip(
                                    label: Text(
                                      '${score.points}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteScore(score),
                                    tooltip: 'Delete',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addScore,
        tooltip: 'Add Score',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddScoreDialog extends StatefulWidget {
  const AddScoreDialog({super.key});

  @override
  State<AddScoreDialog> createState() => _AddScoreDialogState();
}

class _AddScoreDialogState extends State<AddScoreDialog> {
  final _formKey = GlobalKey<FormState>();
  final _playerController = TextEditingController();
  final _gameController = TextEditingController();
  final _pointsController = TextEditingController();

  @override
  void dispose() {
    _playerController.dispose();
    _gameController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Score'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _playerController,
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
            TextFormField(
              controller: _gameController,
              decoration: const InputDecoration(
                labelText: 'Game',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a game name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pointsController,
              decoration: const InputDecoration(
                labelText: 'Points',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter points';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
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
              final score = Score(
                player: _playerController.text,
                game: _gameController.text,
                points: int.parse(_pointsController.text),
              );
              Navigator.pop(context, score);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
