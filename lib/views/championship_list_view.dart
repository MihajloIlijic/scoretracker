import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/championship_viewmodel.dart';
import '../models/championship.dart';
import '../theme/app_theme.dart';
import 'championship_detail_view.dart';
import '../widgets/add_championship_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/championship_card.dart';

class ChampionshipListView extends StatelessWidget {
  const ChampionshipListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChampionshipViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (viewModel.errorMessage != null) {
          return ErrorState(
            message: viewModel.errorMessage!,
            onRetry: () => viewModel.loadChampionships(),
          );
        }

        if (viewModel.championships.isEmpty) {
          return EmptyState(
            icon: Icons.emoji_events,
            title: 'No championships yet',
            subtitle: 'Create a championship to organize players and matches!',
            actionLabel: 'Create Championship',
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
                label: const Text('Create New Championship'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => viewModel.loadChampionships(),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
                  itemCount: viewModel.championships.length,
                  itemBuilder: (context, index) {
                    final championship = viewModel.championships[index];
                    return ChampionshipCard(
                      championship: championship,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChampionshipDetailView(championship: championship),
                          ),
                        ).then((_) => viewModel.loadChampionships());
                      },
                      onDelete: () => _deleteChampionship(context, viewModel, championship),
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

  Future<void> _showAddDialog(BuildContext context, ChampionshipViewModel viewModel) async {
    final result = await showDialog<Championship>(
      context: context,
      builder: (context) => const AddChampionshipDialog(),
    );

    if (result != null) {
      final created = await viewModel.createChampionship(result);
      if (created != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Championship created successfully')),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${viewModel.errorMessage ?? "Unknown error"}')),
        );
      }
    }
  }

  Future<void> _deleteChampionship(BuildContext context, ChampionshipViewModel viewModel, Championship championship) async {
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
      final success = await viewModel.deleteChampionship(championship.id!);
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Championship deleted successfully')),
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

