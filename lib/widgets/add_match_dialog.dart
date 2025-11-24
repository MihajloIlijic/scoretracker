import 'package:flutter/material.dart';
import '../models/match.dart';
import '../models/championship.dart';
import '../models/player.dart';
import '../services/api_service.dart';

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
  
  List<Championship> _championships = [];
  List<Player> _players = [];
  int? _selectedChampionshipId;
  String? _selectedPlayer1;
  String? _selectedPlayer2;
  String? _selectedWinner;
  bool _isLoadingChampionships = true;
  bool _isLoadingPlayers = false;

  @override
  void initState() {
    super.initState();
    _loadChampionships();
  }

  @override
  void dispose() {
    _gameController.dispose();
    _player1ScoreController.dispose();
    _player2ScoreController.dispose();
    super.dispose();
  }

  Future<void> _loadChampionships() async {
    try {
      final championships = await ApiService.getAllChampionships();
      setState(() {
        _championships = championships;
        _isLoadingChampionships = false;
        if (championships.isNotEmpty) {
          _selectedChampionshipId = championships.first.id;
          _loadPlayers();
        }
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

  Future<void> _loadPlayers() async {
    if (_selectedChampionshipId == null) return;
    
    setState(() {
      _isLoadingPlayers = true;
      _players = [];
      _selectedPlayer1 = null;
      _selectedPlayer2 = null;
      _selectedWinner = null;
    });

    try {
      final players = await ApiService.getAllPlayers(championshipId: _selectedChampionshipId);
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
        child: _isLoadingChampionships
            ? const Center(child: CircularProgressIndicator())
            : _championships.isEmpty
                ? const Text('No championships available. Please create a championship first.')
                : Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButtonFormField<int>(
                            value: _selectedChampionshipId,
                            decoration: const InputDecoration(
                              labelText: 'Championship',
                              border: OutlineInputBorder(),
                            ),
                            items: _championships
                                .map((champ) => DropdownMenuItem(
                                      value: champ.id,
                                      child: Text(champ.name),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedChampionshipId = value;
                              });
                              _loadPlayers();
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a championship';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _isLoadingPlayers
                              ? const Center(child: CircularProgressIndicator())
                              : _players.isEmpty
                                  ? const Text('No players available in this championship. Please add players first.')
                                  : Column(
                                      children: [
                                        DropdownButtonFormField<String>(
                                          value: _selectedPlayer1,
                                          decoration: const InputDecoration(
                                            labelText: 'Player 1',
                                            border: OutlineInputBorder(),
                                          ),
                                          items: _players
                                              .where((p) => p.name != _selectedPlayer2)
                                              .map((player) => DropdownMenuItem(
                                                    value: player.name,
                                                    child: Text(player.name),
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
                                              .where((p) => p.name != _selectedPlayer1)
                                              .map((player) => DropdownMenuItem(
                                                    value: player.name,
                                                    child: Text(player.name),
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
                                            labelText: 'Winner (Optional)',
                                            border: OutlineInputBorder(),
                                          ),
                                          items: [
                                            const DropdownMenuItem(
                                              value: null,
                                              child: Text('None (Draw)'),
                                            ),
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
                                        ),
                                      ],
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
          onPressed: _championships.isEmpty || _isLoadingChampionships || _players.isEmpty || _isLoadingPlayers
              ? null
              : () {
                  if (_formKey.currentState!.validate()) {
                    final match = Match(
                      championshipId: _selectedChampionshipId!,
                      player1: _selectedPlayer1!,
                      player2: _selectedPlayer2!,
                      game: _gameController.text,
                      status: MatchStatus.pending,
                      winner: _selectedWinner,
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

