import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/championship_viewmodel.dart';
import '../models/championship.dart';
import '../models/player.dart';
import '../models/match.dart';
import 'match_detail_view.dart';

class ChampionshipDetailView extends StatelessWidget {
  final Championship championship;

  const ChampionshipDetailView({super.key, required this.championship});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChampionshipDetailViewModel(championship)
        ..loadPlayers()
        ..loadAllPlayers()
        ..loadMatches()
        ..loadStandings(),
      child: Consumer<ChampionshipDetailViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(viewModel.championship.name),
              actions: [
                if (viewModel.championship.status == ChampionshipStatus.draft)
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _showAddPlayerDialog(context, viewModel),
                    tooltip: 'Add Player',
                  ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                await viewModel.loadPlayers();
                await viewModel.loadAllPlayers();
                await viewModel.loadMatches();
                await viewModel.refreshChampionship();
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
                                        viewModel.championship.name,
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Chip(
                                        label: Text(
                                          viewModel.championship.status == ChampionshipStatus.finalized
                                              ? 'Finalized'
                                              : 'Draft',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        backgroundColor: viewModel.championship.status == ChampionshipStatus.finalized
                                            ? Colors.green.withOpacity(0.2)
                                            : Colors.orange.withOpacity(0.2),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (viewModel.championship.description != null &&
                                viewModel.championship.description!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(
                                viewModel.championship.description!,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                            const SizedBox(height: 16),
                            // Action buttons
                            if (viewModel.championship.status == ChampionshipStatus.draft) ...[
                              ElevatedButton.icon(
                                onPressed: viewModel.assignedPlayers.length < 2
                                    ? null
                                    : viewModel.isFinalizing
                                        ? null
                                        : () => _finalizeChampionship(context, viewModel),
                                icon: viewModel.isFinalizing
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
                              if (viewModel.assignedPlayers.length < 2)
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
                                      onPressed: viewModel.isGeneratingMatches ? null : () => _generateMatches(context, viewModel),
                                      icon: viewModel.isGeneratingMatches
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
                    if (viewModel.championship.status == ChampionshipStatus.finalized) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          'Standings',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      if (viewModel.isLoadingStandings)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (viewModel.standings.isEmpty)
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
                              for (int i = 0; i < viewModel.standings.length; i++)
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
                                  title: Text(viewModel.standings[i]['player_name'] ?? ''),
                                  trailing: Text(
                                    '${viewModel.standings[i]['points'] ?? 0} pts',
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
                    if (viewModel.championship.status == ChampionshipStatus.finalized) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          'Matches (${viewModel.matches.length})',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      if (viewModel.isLoadingMatches)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (viewModel.matches.isEmpty)
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
                        ...viewModel.matches.map((match) {
                          final isPlayer1Winner = match.winner == match.player1;
                          final isDraw = match.winner == null && match.status == MatchStatus.finished;
                          
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MatchDetailView(match: match),
                                  ),
                                ).then((_) => viewModel.loadMatches());
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
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
                            'Players (${viewModel.assignedPlayers.length})',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          if (viewModel.championship.status == ChampionshipStatus.draft)
                            TextButton.icon(
                              onPressed: () => _showAddPlayerDialog(context, viewModel),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Player'),
                            ),
                        ],
                      ),
                    ),

                    // Players List
                    if (viewModel.isLoadingPlayers)
                      const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (viewModel.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                viewModel.errorMessage!,
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => viewModel.loadPlayers(),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (viewModel.assignedPlayers.isEmpty)
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
                                onPressed: () => _showAddPlayerDialog(context, viewModel),
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
                        itemCount: viewModel.assignedPlayers.length,
                        itemBuilder: (context, index) {
                          final player = viewModel.assignedPlayers[index];
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
                              trailing: viewModel.championship.status == ChampionshipStatus.draft
                                  ? IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                      onPressed: () => _removePlayer(context, viewModel, player),
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
        },
      ),
    );
  }

  Future<void> _showAddPlayerDialog(BuildContext context, ChampionshipDetailViewModel viewModel) async {
    final selectedPlayer = await showDialog<Player>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Player to Championship'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: viewModel.allPlayers.length,
            itemBuilder: (context, index) {
              final player = viewModel.allPlayers[index];
              final isAlreadyInChampionship = viewModel.assignedPlayers.any((p) => p.id == player.id);
              
              return ListTile(
                title: Text(player.name),
                trailing: isAlreadyInChampionship
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: isAlreadyInChampionship
                    ? null
                    : () => Navigator.pop(context, player),
              );
            },
          ),
        ),
      ),
    );

    if (selectedPlayer != null) {
      final success = await viewModel.addPlayerToChampionship(selectedPlayer);
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Player added to championship')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${viewModel.errorMessage ?? "Unknown error"}')),
          );
        }
      }
    }
  }

  Future<void> _removePlayer(BuildContext context, ChampionshipDetailViewModel viewModel, Player player) async {
    final success = await viewModel.removePlayerFromChampionship(player);
    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Player removed from championship')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${viewModel.errorMessage ?? "Unknown error"}')),
        );
      }
    }
  }

  Future<void> _finalizeChampionship(BuildContext context, ChampionshipDetailViewModel viewModel) async {
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

    if (confirmed == true) {
      final success = await viewModel.finalizeChampionship();
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Championship finalized successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${viewModel.errorMessage ?? "Unknown error"}')),
          );
        }
      }
    }
  }

  Future<void> _generateMatches(BuildContext context, ChampionshipDetailViewModel viewModel) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Matches'),
        content: Text(
          'This will generate all round-robin matches (each player plays against every other player once). '
          'Total matches: ${viewModel.assignedPlayers.length * (viewModel.assignedPlayers.length - 1) ~/ 2}',
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

    if (confirmed == true) {
      final success = await viewModel.generateMatches();
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Matches generated successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${viewModel.errorMessage ?? "Unknown error"}')),
          );
        }
      }
    }
  }
}

