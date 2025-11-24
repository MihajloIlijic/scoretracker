import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/championship_viewmodel.dart';
import '../models/championship.dart';
import 'championship_detail_view.dart';
import '../widgets/add_championship_dialog.dart';

class ChampionshipListView extends StatelessWidget {
  const ChampionshipListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChampionshipViewModel>(
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
                  onPressed: () => viewModel.loadChampionships(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (viewModel.championships.isEmpty) {
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
                  onPressed: () => _showAddDialog(context, viewModel),
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
                onPressed: () => _showAddDialog(context, viewModel),
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
                onRefresh: () => viewModel.loadChampionships(),
                child: ListView.builder(
                  itemCount: viewModel.championships.length,
                  itemBuilder: (context, index) {
                    final championship = viewModel.championships[index];
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
                          onPressed: () => _deleteChampionship(context, viewModel, championship),
                          tooltip: 'Delete',
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChampionshipDetailView(championship: championship),
                            ),
                          ).then((_) => viewModel.loadChampionships());
                        },
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

