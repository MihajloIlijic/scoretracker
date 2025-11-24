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
  bool _isLoadingPlayers = true;
  bool _isLoadingAllPlayers = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
    _loadAllPlayers();
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

  Future<void> _addPlayerToChampionship(Player player) async {
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
        title: Text(widget.championship.name),
        actions: [
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
                            child: Text(
                              widget.championship.name,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      if (widget.championship.description != null &&
                          widget.championship.description!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          widget.championship.description!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Players Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Players (${_assignedPlayers.length})',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
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
                        subtitle: player.championships != null && player.championships!.length > 1
                            ? Text(
                                'Also in: ${player.championships!.where((c) => c.id != widget.championship.id).map((c) => c.name).join(", ")}',
                              )
                            : null,
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: () => _removePlayerFromChampionship(player),
                          tooltip: 'Remove from Championship',
                        ),
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
