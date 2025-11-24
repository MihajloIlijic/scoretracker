import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/player_viewmodel.dart';
import '../models/player.dart';
import '../widgets/add_player_dialog.dart';

class PlayerListView extends StatelessWidget {
  const PlayerListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
          );
        }

        if (viewModel.players.isEmpty) {
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
                  'Add players to participate in championships!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _showAddDialog(context, viewModel),
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
                onPressed: () => _showAddDialog(context, viewModel),
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
                onRefresh: () => viewModel.loadPlayers(),
                child: ListView.builder(
                  itemCount: viewModel.players.length,
                  itemBuilder: (context, index) {
                    final player = viewModel.players[index];
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
                        subtitle: player.championships != null && player.championships!.isNotEmpty
                            ? Text('In ${player.championships!.length} championship(s)')
                            : const Text('Not in any championship'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deletePlayer(context, viewModel, player),
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
      },
    );
  }

  Future<void> _showAddDialog(BuildContext context, PlayerViewModel viewModel) async {
    final result = await showDialog<Player>(
      context: context,
      builder: (context) => const AddPlayerDialog(),
    );

    if (result != null) {
      final created = await viewModel.createPlayer(result);
      if (created != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Player created successfully')),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${viewModel.errorMessage ?? "Unknown error"}')),
        );
      }
    }
  }

  Future<void> _deletePlayer(BuildContext context, PlayerViewModel viewModel, Player player) async {
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
      final success = await viewModel.deletePlayer(player.id!);
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Player deleted successfully')),
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

