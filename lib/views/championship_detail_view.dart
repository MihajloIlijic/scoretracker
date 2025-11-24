import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/championship_viewmodel.dart';
import '../models/championship.dart';
import '../models/player.dart';
import '../models/match.dart';
import '../theme/app_theme.dart';
import '../widgets/status_chip.dart';
import '../widgets/player_card.dart';
import '../widgets/match_card.dart';
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
                      margin: const EdgeInsets.all(AppTheme.spacingM),
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.spacingM),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFFD700),
                                        Color(0xFFFFA500),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                                  ),
                                  child: const Icon(
                                    Icons.emoji_events,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: AppTheme.spacingM),
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
                                      const SizedBox(height: AppTheme.spacingXS),
                                      StatusChip.championship(viewModel.championship.status),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (viewModel.championship.description != null &&
                                viewModel.championship.description!.isNotEmpty) ...[
                              const SizedBox(height: AppTheme.spacingM),
                              Text(
                                viewModel.championship.description!,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                              ),
                            ],
                            const SizedBox(height: AppTheme.spacingL),
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
                                  minimumSize: const Size(double.infinity, 56),
                                ),
                              ),
                              if (viewModel.assignedPlayers.length < 2)
                                Padding(
                                  padding: const EdgeInsets.only(top: AppTheme.spacingS),
                                  child: Text(
                                    'At least 2 players required to finalize',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppTheme.warningColor,
                                        ),
                                  ),
                                ),
                            ] else ...[
                              ElevatedButton.icon(
                                onPressed: viewModel.isGeneratingMatches ? null : () => _generateMatches(context, viewModel),
                                icon: viewModel.isGeneratingMatches
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.shuffle),
                                label: const Text('Generate Matches'),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 56),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Standings Section (if finalized)
                    if (viewModel.championship.status == ChampionshipStatus.finalized) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingM,
                          vertical: AppTheme.spacingS,
                        ),
                        child: Text(
                          'Standings',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      if (viewModel.isLoadingStandings)
                        const Padding(
                          padding: EdgeInsets.all(AppTheme.spacingM),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (viewModel.standings.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(AppTheme.spacingM),
                          child: Center(
                            child: Text(
                              'No matches finished yet',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                            ),
                          ),
                        )
                      else
                        Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingM,
                            vertical: AppTheme.spacingS,
                          ),
                          child: Column(
                            children: [
                              for (int i = 0; i < viewModel.standings.length; i++)
                                ListTile(
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      gradient: i == 0
                                          ? const LinearGradient(
                                              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                                            )
                                          : i == 1
                                              ? LinearGradient(
                                                  colors: [Colors.grey.shade400, Colors.grey.shade600],
                                                )
                                              : i == 2
                                                  ? LinearGradient(
                                                      colors: [Colors.brown.shade300, Colors.brown.shade500],
                                                    )
                                                  : LinearGradient(
                                                      colors: [AppTheme.primaryLight, AppTheme.primaryColor],
                                                    ),
                                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${i + 1}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: i < 3 ? Colors.white : Colors.black,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    viewModel.standings[i]['player_name'] ?? '',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppTheme.spacingM,
                                      vertical: AppTheme.spacingXS,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                                    ),
                                    child: Text(
                                      '${viewModel.standings[i]['points'] ?? 0} pts',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primaryColor,
                                          ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingM,
                          vertical: AppTheme.spacingS,
                        ),
                        child: Text(
                          'Matches (${viewModel.matches.length})',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      if (viewModel.isLoadingMatches)
                        const Padding(
                          padding: EdgeInsets.all(AppTheme.spacingM),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (viewModel.matches.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(AppTheme.spacingM),
                          child: Center(
                            child: Text(
                              'No matches yet. Generate matches to start.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                            ),
                          ),
                        )
                      else
                        ...viewModel.matches.map((match) {
                          return MatchCard(
                            match: match,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MatchDetailView(match: match),
                                ),
                              ).then((_) {
                                viewModel.loadMatches();
                                viewModel.loadStandings();
                              });
                            },
                          );
                        }),
                    ],

                    // Players Section
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingM,
                        vertical: AppTheme.spacingS,
                      ),
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
                        padding: EdgeInsets.all(AppTheme.spacingXXL),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (viewModel.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.all(AppTheme.spacingM),
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                viewModel.errorMessage!,
                                style: TextStyle(color: AppTheme.errorColor),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppTheme.spacingM),
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
                        padding: const EdgeInsets.all(AppTheme.spacingXXL),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(height: AppTheme.spacingM),
                              Text(
                                'No players assigned yet',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                              ),
                              const SizedBox(height: AppTheme.spacingM),
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
                      ...viewModel.assignedPlayers.map((player) {
                        return PlayerCard(
                          player: player,
                          showDelete: viewModel.championship.status == ChampionshipStatus.draft,
                          onDelete: viewModel.championship.status == ChampionshipStatus.draft
                              ? () => _removePlayer(context, viewModel, player)
                              : null,
                        );
                      }),
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

