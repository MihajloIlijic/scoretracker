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
  List<Championship> _championships = [];
  List<Player> _players = [];
  List<Match> _matches = [];
  bool _isLoadingChampionships = true;
  bool _isLoadingPlayers = true;
  bool _isLoadingMatches = true;
  String? _errorMessageChampionships;
  String? _errorMessagePlayers;
  String? _errorMessageMatches;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild when tab changes to update FAB
    });
    _loadChampionships();
    _loadPlayers();
    _loadMatches();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadChampionships() async {
    setState(() {
      _isLoadingChampionships = true;
      _errorMessageChampionships = null;
    });

    try {
      final championships = await ApiService.getAllChampionships();
      setState(() {
        _championships = championships;
        _isLoadingChampionships = false;
      });
    } catch (e) {
      setState(() {
        _errorMessageChampionships = 'Error loading championships: $e';
        _isLoadingChampionships = false;
      });
    }
  }

  Future<void> _addChampionship() async {
    final result = await showDialog<Championship>(
      context: context,
      builder: (context) => const AddChampionshipDialog(),
    );

    if (result != null) {
      try {
        await ApiService.createChampionship(result);
        _loadChampionships();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Championship created successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating championship: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteChampionship(Championship championship) async {
    if (championship.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Championship'),
        content: Text('Are you sure you want to delete "${championship.name}"? This will also delete all associated players, matches, and scores.'),
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
        await ApiService.deleteChampionship(championship.id!);
        _loadChampionships();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Championship deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting championship: $e')),
          );
        }
      }
    }
  }

  Future<void> _loadPlayers() async {
    setState(() {
      _isLoadingPlayers = true;
      _errorMessagePlayers = null;
    });

    try {
      final players = await ApiService.getAllPlayers();
      setState(() {
        _players = players;
        _isLoadingPlayers = false;
      });
    } catch (e) {
      setState(() {
        _errorMessagePlayers = 'Error loading players: $e';
        _isLoadingPlayers = false;
      });
    }
  }

  Future<void> _addPlayer() async {
    final result = await showDialog<Player>(
      context: context,
      builder: (context) => const AddPlayerDialog(),
    );

    if (result != null) {
      try {
        await ApiService.createPlayer(result);
        _loadPlayers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Player added successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding player: $e')),
          );
        }
      }
    }
  }

  Future<void> _deletePlayer(Player player) async {
    if (player.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Player'),
        content: Text('Are you sure you want to delete ${player.name}?'),
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
        await ApiService.deletePlayer(player.id!);
        _loadPlayers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Player deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting player: $e')),
          );
        }
      }
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Score Tracker'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.emoji_events), text: 'Championships'),
            Tab(icon: Icon(Icons.people), text: 'Players'),
            Tab(icon: Icon(Icons.sports_esports), text: 'Matches'),
          ],
        ),
        actions: [
          if (_tabController.index == 0)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addChampionship,
              tooltip: 'Create Championship',
            ),
          if (_tabController.index == 1)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addPlayer,
              tooltip: 'Add Player',
            ),
          if (_tabController.index == 2)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addMatch,
              tooltip: 'Create Match',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadChampionships();
              _loadPlayers();
              _loadMatches();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChampionshipsTab(),
          _buildPlayersTab(),
          _buildMatchesTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: _addChampionship,
              tooltip: 'Create Championship',
              child: const Icon(Icons.add),
            )
          : _tabController.index == 1
              ? FloatingActionButton(
                  onPressed: _addPlayer,
                  tooltip: 'Add Player',
                  child: const Icon(Icons.add),
                )
              : _tabController.index == 2
                  ? FloatingActionButton(
                      onPressed: _addMatch,
                      tooltip: 'Create Match',
                      child: const Icon(Icons.add),
                    )
                  : null,
    );
  }

  Widget _buildChampionshipsTab() {
    if (_isLoadingChampionships) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessageChampionships != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessageChampionships!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadChampionships,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_championships.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.emoji_events,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No championships yet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create a championship to organize players and matches!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addChampionship,
              icon: const Icon(Icons.add),
              label: const Text('Create Championship'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
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
            onPressed: _addChampionship,
            icon: const Icon(Icons.add),
            label: const Text('Create New Championship'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadChampionships,
            child: ListView.builder(
              itemCount: _championships.length,
              itemBuilder: (context, index) {
                final championship = _championships[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.emoji_events),
                    ),
                    title: Text(
                      championship.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: championship.description != null && championship.description!.isNotEmpty
                        ? Text(championship.description!)
                        : const Text('No description'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteChampionship(championship),
                      tooltip: 'Delete',
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChampionshipDetailPage(championship: championship),
                        ),
                      ).then((_) => _loadChampionships());
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayersTab() {
    if (_isLoadingPlayers) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessagePlayers != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessagePlayers!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPlayers,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_players.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.people,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No players yet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add players to championships!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addPlayer,
              icon: const Icon(Icons.add),
              label: const Text('Add Player'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
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
            onPressed: _addPlayer,
            icon: const Icon(Icons.add),
            label: const Text('Add New Player'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadPlayers,
            child: ListView.builder(
              itemCount: _players.length,
              itemBuilder: (context, index) {
                final player = _players[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        player.name.isNotEmpty
                            ? player.name[0].toUpperCase()
                            : '?',
                      ),
                    ),
                    title: Text(player.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deletePlayer(player),
                      tooltip: 'Delete',
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
          final isDraw = match.winner == null && match.status == MatchStatus.finished;
          
          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MatchDetailPage(match: match),
                  ),
                ).then((_) => _loadMatches());
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                match.game,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Chip(
                                label: Text(
                                  match.status == MatchStatus.pending
                                      ? 'Pending'
                                      : match.status == MatchStatus.started
                                          ? 'Live'
                                          : 'Finished',
                                  style: const TextStyle(fontSize: 11),
                                ),
                                backgroundColor: match.status == MatchStatus.pending
                                    ? Colors.grey.withOpacity(0.2)
                                    : match.status == MatchStatus.started
                                        ? Colors.green.withOpacity(0.2)
                                        : Colors.blue.withOpacity(0.2),
                              ),
                            ],
                          ),
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
                                  if (isPlayer1Winner && !isDraw) ...[
                                    const SizedBox(width: 8),
                                    const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Score: ${match.player1Score}',
                                style: TextStyle(
                                  color: isPlayer1Winner && !isDraw ? Colors.green : Colors.grey,
                                  fontWeight: isPlayer1Winner && !isDraw ? FontWeight.bold : FontWeight.normal,
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
                                  if (!isPlayer1Winner && !isDraw && match.winner != null) ...[
                                    const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                                    const SizedBox(width: 8),
                                  ],
                                  Text(
                                    match.player2,
                                    style: TextStyle(
                                      fontWeight: !isPlayer1Winner && !isDraw && match.winner != null
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
                                  color: !isPlayer1Winner && !isDraw && match.winner != null ? Colors.green : Colors.grey,
                                  fontWeight: !isPlayer1Winner && !isDraw && match.winner != null ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (isDraw && match.status == MatchStatus.finished)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Draw',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                  ],
                ),
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

class ChampionshipDetailPage extends StatefulWidget {
  final Championship championship;

  const ChampionshipDetailPage({super.key, required this.championship});

  @override
  State<ChampionshipDetailPage> createState() => _ChampionshipDetailPageState();
}

class _ChampionshipDetailPageState extends State<ChampionshipDetailPage> {
  List<Player> _assignedPlayers = [];
  List<Player> _allPlayers = [];
  List<Map<String, dynamic>> _standings = [];
  List<Match> _matches = [];
  Championship? _championship;
  bool _isLoadingPlayers = true;
  bool _isLoadingAllPlayers = false;
  bool _isLoadingStandings = false;
  bool _isLoadingMatches = false;
  bool _isFinalizing = false;
  bool _isGeneratingMatches = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _championship = widget.championship;
    _loadPlayers();
    _loadAllPlayers();
    _loadMatches();
    if (_championship!.status == ChampionshipStatus.finalized) {
      _loadStandings();
    }
  }

  Future<void> _loadPlayers() async {
    setState(() {
      _isLoadingPlayers = true;
      _errorMessage = null;
    });

    try {
      final players = await ApiService.getAllPlayers(championshipId: widget.championship.id);
      setState(() {
        _assignedPlayers = players;
        _isLoadingPlayers = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading players: $e';
        _isLoadingPlayers = false;
      });
    }
  }

  Future<void> _refreshChampionship() async {
    if (_championship?.id == null) return;
    
    try {
      final updated = await ApiService.getChampionship(_championship!.id!);
      setState(() {
        _championship = updated;
      });
      if (updated.status == ChampionshipStatus.finalized) {
        _loadStandings();
      }
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> _loadAllPlayers() async {
    setState(() {
      _isLoadingAllPlayers = true;
    });

    try {
      final players = await ApiService.getAllPlayers();
      setState(() {
        _allPlayers = players;
        _isLoadingAllPlayers = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingAllPlayers = false;
      });
    }
  }

  Future<void> _loadStandings() async {
    if (_championship?.id == null) return;
    
    setState(() {
      _isLoadingStandings = true;
    });

    try {
      final standings = await ApiService.getStandings(_championship!.id!);
      setState(() {
        _standings = standings;
        _isLoadingStandings = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingStandings = false;
      });
    }
  }

  Future<void> _loadMatches() async {
    if (_championship?.id == null) return;
    
    setState(() {
      _isLoadingMatches = true;
    });

    try {
      final matches = await ApiService.getAllMatches(championshipId: _championship!.id);
      setState(() {
        _matches = matches;
        _isLoadingMatches = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMatches = false;
      });
    }
  }

  Future<void> _finalizeChampionship() async {
    if (_championship?.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalize Championship'),
        content: const Text(
          'Are you sure you want to finalize this championship? '
          'After finalizing, you cannot add or remove players anymore.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Finalize'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isFinalizing = true;
    });

    try {
      final finalized = await ApiService.finalizeChampionship(_championship!.id!);
      setState(() {
        _championship = finalized;
        _isFinalizing = false;
      });
      
      // Reload standings after finalizing
      if (finalized.status == ChampionshipStatus.finalized) {
        _loadStandings();
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Championship finalized successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _isFinalizing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error finalizing championship: $e')),
        );
      }
    }
  }

  Future<void> _generateMatches() async {
    if (_championship?.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Matches'),
        content: Text(
          'This will generate all round-robin matches (each player plays against every other player once). '
          'Total matches: ${_assignedPlayers.length * (_assignedPlayers.length - 1) ~/ 2}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Generate'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isGeneratingMatches = true;
    });

    try {
      await ApiService.generateRoundRobinMatches(_championship!.id!);
      setState(() {
        _isGeneratingMatches = false;
      });
      
      // Reload matches after generating
      _loadMatches();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Matches generated successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _isGeneratingMatches = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating matches: $e')),
        );
      }
    }
  }

  Future<void> _addPlayerToChampionship(Player player) async {
    if (_championship?.status == ChampionshipStatus.finalized) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot add players to a finalized championship')),
        );
      }
      return;
    }

    try {
      // Get current championships of the player
      final currentChampionships = player.championships ?? [];
      
      // Check if player is already in this championship
      if (currentChampionships.any((c) => c.id == widget.championship.id)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Player is already in this championship')),
          );
        }
        return;
      }

      // Add this championship to the player's championships
      final updatedChampionships = [...currentChampionships, widget.championship];
      final updatedPlayer = Player(
        id: player.id,
        name: player.name,
        championships: updatedChampionships,
      );

      await ApiService.updatePlayer(updatedPlayer);
      _loadPlayers();
      _loadAllPlayers();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Player added to championship')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding player: $e')),
        );
      }
    }
  }

  Future<void> _removePlayerFromChampionship(Player player) async {
    if (_championship?.status == ChampionshipStatus.finalized) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot remove players from a finalized championship')),
        );
      }
      return;
    }

    try {
      if (player.id == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Player ID is missing')),
          );
        }
        return;
      }
      
      // Get current championships of the player
      final currentChampionships = player.championships ?? [];
      
      // Remove this championship from the player's championships
      final updatedChampionships = currentChampionships
          .where((c) => c.id != widget.championship.id)
          .toList();

      final updatedPlayer = Player(
        id: player.id,
        name: player.name,
        championships: updatedChampionships.isEmpty ? null : updatedChampionships,
      );

      await ApiService.updatePlayer(updatedPlayer);
      
      // Reload data after update
      await _loadPlayers();
      await _loadAllPlayers();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Player removed from championship')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error removing player: $e')),
        );
      }
    }
  }

  Future<void> _showAddPlayerDialog() async {
    // Filter out players that are already in this championship
    final availablePlayers = _allPlayers
        .where((p) => !(p.championships?.any((c) => c.id == widget.championship.id) ?? false))
        .toList();

    if (availablePlayers.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All players are already in this championship')),
        );
      }
      return;
    }

    final selectedPlayer = await showDialog<Player>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Player to Championship'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availablePlayers.length,
            itemBuilder: (context, index) {
              final player = availablePlayers[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(
                    player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
                  ),
                ),
                title: Text(player.name),
                subtitle: player.championships != null && player.championships!.isNotEmpty
                    ? Text('In: ${player.championships!.map((c) => c.name).join(", ")}')
                    : const Text('No other championships'),
                onTap: () => Navigator.pop(context, player),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selectedPlayer != null) {
      await _addPlayerToChampionship(selectedPlayer);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_championship?.name ?? widget.championship.name),
        actions: [
          if (_championship?.status == ChampionshipStatus.draft)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showAddPlayerDialog,
              tooltip: 'Add Player',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadPlayers();
          await _loadAllPlayers();
          await _loadMatches();
          await _refreshChampionship();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Championship Info Card
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.emoji_events, size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _championship?.name ?? widget.championship.name,
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Chip(
                                  label: Text(
                                    _championship?.status == ChampionshipStatus.finalized
                                        ? 'Finalized'
                                        : 'Draft',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  backgroundColor: _championship?.status == ChampionshipStatus.finalized
                                      ? Colors.green.withOpacity(0.2)
                                      : Colors.orange.withOpacity(0.2),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if ((_championship?.description ?? widget.championship.description) != null &&
                          (_championship?.description ?? widget.championship.description)!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          _championship?.description ?? widget.championship.description!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                      const SizedBox(height: 16),
                      // Action buttons
                      if (_championship?.status == ChampionshipStatus.draft) ...[
                        ElevatedButton.icon(
                          onPressed: _assignedPlayers.length < 2
                              ? null
                              : _isFinalizing
                                  ? null
                                  : _finalizeChampionship,
                          icon: _isFinalizing
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.lock),
                          label: const Text('Finalize Championship'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                        if (_assignedPlayers.length < 2)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Text(
                              'At least 2 players required to finalize',
                              style: TextStyle(color: Colors.orange, fontSize: 12),
                            ),
                          ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isGeneratingMatches ? null : _generateMatches,
                                icon: _isGeneratingMatches
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.shuffle),
                                label: const Text('Generate Matches'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Standings Section (if finalized)
              if (_championship?.status == ChampionshipStatus.finalized) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Standings',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (_isLoadingStandings)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_standings.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'No matches finished yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        for (int i = 0; i < _standings.length; i++)
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: i == 0
                                  ? Colors.amber
                                  : i == 1
                                      ? Colors.grey.shade400
                                      : i == 2
                                          ? Colors.brown.shade300
                                          : Colors.blue.shade100,
                              child: Text(
                                '${i + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: i < 3 ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                            title: Text(_standings[i]['player_name'] ?? ''),
                            trailing: Text(
                              '${_standings[i]['points'] ?? 0} pts',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],

              // Matches Section (if finalized)
              if (_championship?.status == ChampionshipStatus.finalized) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Matches (${_matches.length})',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (_isLoadingMatches)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_matches.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'No matches yet. Generate matches to start.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ..._matches.map((match) {
                    final isPlayer1Winner = match.winner == match.player1;
                    final isDraw = match.winner == null && match.status == MatchStatus.finished;
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MatchDetailPage(match: match),
                            ),
                          ).then((_) => _loadMatches());
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              // Status indicator
                              Container(
                                width: 4,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: match.status == MatchStatus.pending
                                      ? Colors.grey
                                      : match.status == MatchStatus.started
                                          ? Colors.green
                                          : Colors.blue,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(2),
                                    bottomLeft: Radius.circular(2),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            match.player1,
                                            style: TextStyle(
                                              fontWeight: isPlayer1Winner && !isDraw
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${match.player1Score}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: match.status == MatchStatus.started
                                                ? Colors.blue
                                                : Colors.black,
                                          ),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Text('vs'),
                                        ),
                                        Text(
                                          '${match.player2Score}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: match.status == MatchStatus.started
                                                ? Colors.blue
                                                : Colors.black,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            match.player2,
                                            textAlign: TextAlign.end,
                                            style: TextStyle(
                                              fontWeight: !isPlayer1Winner && !isDraw && match.winner != null
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Chip(
                                          label: Text(
                                            match.status == MatchStatus.pending
                                                ? 'Pending'
                                                : match.status == MatchStatus.started
                                                    ? 'Live'
                                                    : 'Finished',
                                            style: const TextStyle(fontSize: 10),
                                          ),
                                          backgroundColor: match.status == MatchStatus.pending
                                              ? Colors.grey.withOpacity(0.2)
                                              : match.status == MatchStatus.started
                                                  ? Colors.green.withOpacity(0.2)
                                                  : Colors.blue.withOpacity(0.2),
                                        ),
                                        if (match.status == MatchStatus.finished && match.winner != null)
                                          Padding(
                                            padding: const EdgeInsets.only(left: 8.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.emoji_events, size: 16, color: Colors.amber),
                                                const SizedBox(width: 4),
                                                Text(
                                                  match.winner!,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        else if (match.status == MatchStatus.finished && match.winner == null)
                                          const Padding(
                                            padding: EdgeInsets.only(left: 8.0),
                                            child: Text(
                                              'Draw',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontStyle: FontStyle.italic,
                                                color: Colors.orange,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
              ],

              // Players Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Players (${_assignedPlayers.length})',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (_championship?.status == ChampionshipStatus.draft)
                      TextButton.icon(
                        onPressed: _showAddPlayerDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Player'),
                      ),
                  ],
                ),
              ),

              // Players List
              if (_isLoadingPlayers)
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadPlayers,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_assignedPlayers.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'No players assigned yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _showAddPlayerDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Add First Player'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _assignedPlayers.length,
                  itemBuilder: (context, index) {
                    final player = _assignedPlayers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            player.name.isNotEmpty
                                ? player.name[0].toUpperCase()
                                : '?',
                          ),
                        ),
                        title: Text(player.name),
                        trailing: _championship?.status == ChampionshipStatus.draft
                            ? IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                onPressed: () => _removePlayerFromChampionship(player),
                                tooltip: 'Remove from Championship',
                              )
                            : null,
                      ),
                    );
                  },
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class MatchDetailPage extends StatefulWidget {
  final Match match;

  const MatchDetailPage({super.key, required this.match});

  @override
  State<MatchDetailPage> createState() => _MatchDetailPageState();
}

class _MatchDetailPageState extends State<MatchDetailPage> {
  late Match _match;
  bool _isLoading = false;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _match = widget.match;
    _loadMatch();
  }

  Future<void> _loadMatch() async {
    if (_match.id == null) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final match = await ApiService.getMatch(_match.id!);
      setState(() {
        _match = match;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading match: $e')),
        );
      }
    }
  }

  Future<void> _startMatch() async {
    if (_match.id == null) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      final match = await ApiService.startMatch(_match.id!);
      setState(() {
        _match = match;
        _isUpdating = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Match started')),
        );
      }
    } catch (e) {
      setState(() {
        _isUpdating = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting match: $e')),
        );
      }
    }
  }

  Future<void> _updateScore(int player1Score, int player2Score) async {
    if (_match.id == null) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      final match = await ApiService.updateMatchScore(_match.id!, player1Score, player2Score);
      setState(() {
        _match = match;
        _isUpdating = false;
      });
    } catch (e) {
      setState(() {
        _isUpdating = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating score: $e')),
        );
      }
    }
  }

  Future<void> _finishMatch() async {
    if (_match.id == null) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      final match = await ApiService.finishMatch(_match.id!);
      setState(() {
        _match = match;
        _isUpdating = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Match finished')),
        );
      }
    } catch (e) {
      setState(() {
        _isUpdating = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error finishing match: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_match.game),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadMatch,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Status Chip
                      Center(
                        child: Chip(
                          label: Text(
                            _match.status == MatchStatus.pending
                                ? 'Pending'
                                : _match.status == MatchStatus.started
                                    ? 'Live'
                                    : 'Finished',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: _match.status == MatchStatus.pending
                              ? Colors.grey.withOpacity(0.2)
                              : _match.status == MatchStatus.started
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.blue.withOpacity(0.2),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Score Display
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              // Player 1
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _match.player1,
                                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '${_match.player1Score}',
                                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: _match.status == MatchStatus.started
                                                    ? Colors.blue
                                                    : Colors.black,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Text(
                                    'vs',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          _match.player2,
                                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                          textAlign: TextAlign.end,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '${_match.player2Score}',
                                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: _match.status == MatchStatus.started
                                                    ? Colors.blue
                                                    : Colors.black,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (_match.status == MatchStatus.finished && _match.winner != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.emoji_events, color: Colors.amber),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Winner: ${_match.winner}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else if (_match.status == MatchStatus.finished && _match.winner == null)
                                const Padding(
                                  padding: EdgeInsets.only(top: 16.0),
                                  child: Text(
                                    'Draw',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Action Buttons
                      if (_match.status == MatchStatus.pending)
                        ElevatedButton.icon(
                          onPressed: _isUpdating ? null : _startMatch,
                          icon: _isUpdating
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.play_arrow),
                          label: const Text('Start Match'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size(double.infinity, 56),
                          ),
                        )
                      else if (_match.status == MatchStatus.started) ...[
                        // Score Update Controls
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Update Score',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(_match.player1),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.remove),
                                                onPressed: _isUpdating || _match.player1Score <= 0
                                                    ? null
                                                    : () => _updateScore(
                                                          _match.player1Score - 1,
                                                          _match.player2Score,
                                                        ),
                                              ),
                                              Text(
                                                '${_match.player1Score}',
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.add),
                                                onPressed: _isUpdating
                                                    ? null
                                                    : () => _updateScore(
                                                          _match.player1Score + 1,
                                                          _match.player2Score,
                                                        ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Text('vs', style: TextStyle(fontSize: 18)),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(_match.player2),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.remove),
                                                onPressed: _isUpdating || _match.player2Score <= 0
                                                    ? null
                                                    : () => _updateScore(
                                                          _match.player1Score,
                                                          _match.player2Score - 1,
                                                        ),
                                              ),
                                              Text(
                                                '${_match.player2Score}',
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.add),
                                                onPressed: _isUpdating
                                                    ? null
                                                    : () => _updateScore(
                                                          _match.player1Score,
                                                          _match.player2Score + 1,
                                                        ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _isUpdating ? null : _finishMatch,
                          icon: _isUpdating
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.stop),
                          label: const Text('Finish Match'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size(double.infinity, 56),
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
