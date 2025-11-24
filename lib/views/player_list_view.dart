import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/player_viewmodel.dart';
import '../models/player.dart';
import '../theme/app_theme.dart';
import '../widgets/add_player_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/player_card.dart';

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
          return ErrorState(
            message: viewModel.errorMessage!,
            onRetry: () => viewModel.loadPlayers(),
          );
        }

        if (viewModel.players.isEmpty) {
          return EmptyState(
            icon: Icons.people,
            title: 'No players yet',
            subtitle: 'Add players to participate in championships!',
            actionLabel: 'Add Player',
            onAction: () => _showAddDialog(context, viewModel),
          );
        }

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: ElevatedButton.icon(
                onPressed: () => _showAddDialog(context, viewModel),
                icon: const Icon(Icons.add),
                label: const Text('Add New Player'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => viewModel.loadPlayers(),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
                  itemCount: viewModel.players.length,
                  itemBuilder: (context, index) {
                    final player = viewModel.players[index];
                    return PlayerCard(
                      player: player,
                      onDelete: () => _deletePlayer(context, viewModel, player),
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

