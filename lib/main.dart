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

class _ScoreTrackerHomeState extends State<ScoreTrackerHome> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Score> _scores = [];
  List<Match> _matches = [];
  bool _isLoadingScores = true;
  bool _isLoadingMatches = true;
  String? _errorMessageScores;
  String? _errorMessageMatches;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild when tab changes to update FAB
    });
    _loadScores();
    _loadMatches();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadScores() async {
    setState(() {
      _isLoadingScores = true;
      _errorMessageScores = null;
    });

    try {
      final scores = await ApiService.getAllScores();
      setState(() {
        _scores = scores;
        _isLoadingScores = false;
      });
    } catch (e) {
      setState(() {
        _errorMessageScores = 'Error loading scores: $e';
        _isLoadingScores = false;
      });
    }
  }

  Future<void> _loadMatches() async {
    setState(() {
      _isLoadingMatches = true;
      _errorMessageMatches = null;
    });

    try {
      final matches = await ApiService.getAllMatches();
      setState(() {
        _matches = matches;
        _isLoadingMatches = false;
      });
    } catch (e) {
      setState(() {
        _errorMessageMatches = 'Error loading matches: $e';
        _isLoadingMatches = false;
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

  Future<void> _addMatch() async {
    final result = await showDialog<Match>(
      context: context,
      builder: (context) => const AddMatchDialog(),
    );

    if (result != null) {
      try {
        await ApiService.createMatch(result);
        _loadMatches();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Match created successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating match: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteMatch(Match match) async {
    if (match.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Match'),
        content: Text('Are you sure you want to delete the match between ${match.player1} and ${match.player2}?'),
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
        await ApiService.deleteMatch(match.id!);
        _loadMatches();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Match deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting match: $e')),
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.score), text: 'Scores'),
            Tab(icon: Icon(Icons.sports_esports), text: 'Matches'),
          ],
        ),
        actions: [
          if (_tabController.index == 1)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addMatch,
              tooltip: 'Create Match',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadScores();
              _loadMatches();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildScoresTab(),
          _buildMatchesTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: _addScore,
              tooltip: 'Add Score',
              child: const Icon(Icons.add),
            )
          : FloatingActionButton(
              onPressed: _addMatch,
              tooltip: 'Create Match',
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _buildScoresTab() {
    if (_isLoadingScores) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessageScores != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessageScores!,
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
      );
    }

    if (_scores.isEmpty) {
      return const Center(
        child: Text(
          'No scores yet.\nTap the + button to add one!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return RefreshIndicator(
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
    );
  }

  Widget _buildMatchesTab() {
    if (_isLoadingMatches) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessageMatches != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessageMatches!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMatches,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.sports_esports,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No matches yet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create a match between players!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addMatch,
              icon: const Icon(Icons.add),
              label: const Text('Create Match'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Or use the + button below',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _addMatch,
            icon: const Icon(Icons.add),
            label: const Text('Create New Match'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadMatches,
            child: ListView.builder(
              itemCount: _matches.length,
              itemBuilder: (context, index) {
          final match = _matches[index];
          final isPlayer1Winner = match.winner == match.player1;
          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        match.game,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteMatch(match),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  match.player1,
                                  style: TextStyle(
                                    fontWeight: isPlayer1Winner
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: 16,
                                  ),
                                ),
                                if (isPlayer1Winner) ...[
                                  const SizedBox(width: 8),
                                  const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Score: ${match.player1Score}',
                              style: TextStyle(
                                color: isPlayer1Winner ? Colors.green : Colors.grey,
                                fontWeight: isPlayer1Winner ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        'vs',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (!isPlayer1Winner) ...[
                                  const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                                  const SizedBox(width: 8),
                                ],
                                Text(
                                  match.player2,
                                  style: TextStyle(
                                    fontWeight: !isPlayer1Winner
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Score: ${match.player2Score}',
                              style: TextStyle(
                                color: !isPlayer1Winner ? Colors.green : Colors.grey,
                                fontWeight: !isPlayer1Winner ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
            ),
          ),
        ),
      ],
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

class AddMatchDialog extends StatefulWidget {
  const AddMatchDialog({super.key});

  @override
  State<AddMatchDialog> createState() => _AddMatchDialogState();
}

class _AddMatchDialogState extends State<AddMatchDialog> {
  final _formKey = GlobalKey<FormState>();
  final _gameController = TextEditingController();
  final _player1ScoreController = TextEditingController();
  final _player2ScoreController = TextEditingController();
  
  List<String> _players = [];
  String? _selectedPlayer1;
  String? _selectedPlayer2;
  String? _selectedWinner;
  bool _isLoadingPlayers = true;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  @override
  void dispose() {
    _gameController.dispose();
    _player1ScoreController.dispose();
    _player2ScoreController.dispose();
    super.dispose();
  }

  Future<void> _loadPlayers() async {
    try {
      final players = await ApiService.getPlayers();
      setState(() {
        _players = players;
        _isLoadingPlayers = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPlayers = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading players: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Match'),
      content: SizedBox(
        width: double.maxFinite,
        child: _isLoadingPlayers
            ? const Center(child: CircularProgressIndicator())
            : _players.isEmpty
                ? const Text('No players available. Please add scores first to create players.')
                : Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButtonFormField<String>(
                            value: _selectedPlayer1,
                            decoration: const InputDecoration(
                              labelText: 'Player 1',
                              border: OutlineInputBorder(),
                            ),
                            items: _players
                                .where((p) => p != _selectedPlayer2)
                                .map((player) => DropdownMenuItem(
                                      value: player,
                                      child: Text(player),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedPlayer1 = value;
                                if (_selectedWinner == _selectedPlayer2 && value != null) {
                                  _selectedWinner = null;
                                }
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select player 1';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedPlayer2,
                            decoration: const InputDecoration(
                              labelText: 'Player 2',
                              border: OutlineInputBorder(),
                            ),
                            items: _players
                                .where((p) => p != _selectedPlayer1)
                                .map((player) => DropdownMenuItem(
                                      value: player,
                                      child: Text(player),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedPlayer2 = value;
                                if (_selectedWinner == _selectedPlayer1 && value != null) {
                                  _selectedWinner = null;
                                }
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select player 2';
                              }
                              if (value == _selectedPlayer1) {
                                return 'Player 2 must be different from Player 1';
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
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _player1ScoreController,
                                  decoration: InputDecoration(
                                    labelText: _selectedPlayer1 ?? 'Player 1 Score',
                                    border: const OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  enabled: _selectedPlayer1 != null,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    if (int.tryParse(value) == null) {
                                      return 'Invalid';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _player2ScoreController,
                                  decoration: InputDecoration(
                                    labelText: _selectedPlayer2 ?? 'Player 2 Score',
                                    border: const OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  enabled: _selectedPlayer2 != null,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    if (int.tryParse(value) == null) {
                                      return 'Invalid';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedWinner,
                            decoration: const InputDecoration(
                              labelText: 'Winner',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              if (_selectedPlayer1 != null)
                                DropdownMenuItem(
                                  value: _selectedPlayer1,
                                  child: Text(_selectedPlayer1!),
                                ),
                              if (_selectedPlayer2 != null)
                                DropdownMenuItem(
                                  value: _selectedPlayer2,
                                  child: Text(_selectedPlayer2!),
                                ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedWinner = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a winner';
                              }
                              return null;
                            },
                          ),
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
          onPressed: _players.isEmpty || _isLoadingPlayers
              ? null
              : () {
                  if (_formKey.currentState!.validate()) {
                    final match = Match(
                      player1: _selectedPlayer1!,
                      player2: _selectedPlayer2!,
                      game: _gameController.text,
                      winner: _selectedWinner!,
                      player1Score: int.parse(_player1ScoreController.text),
                      player2Score: int.parse(_player2ScoreController.text),
                    );
                    Navigator.pop(context, match);
                  }
                },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
