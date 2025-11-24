import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/match_viewmodel.dart';
import '../models/match.dart';
import '../theme/app_theme.dart';
import 'match_detail_view.dart';
import '../widgets/add_match_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/match_card.dart';

class MatchListView extends StatelessWidget {
  const MatchListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MatchViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.errorMessage != null) {
          return ErrorState(
            message: viewModel.errorMessage!,
            onRetry: () => viewModel.loadMatches(),
          );
        }

        if (viewModel.matches.isEmpty) {
          return EmptyState(
            icon: Icons.sports_esports,
            title: 'No matches yet',
            subtitle: 'Create a match between players!',
            actionLabel: 'Create Match',
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
                label: const Text('Create New Match'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => viewModel.loadMatches(),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
                  itemCount: viewModel.matches.length,
                  itemBuilder: (context, index) {
                    final match = viewModel.matches[index];
                    return MatchCard(
                      match: match,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MatchDetailView(match: match),
                          ),
                        ).then((_) => viewModel.loadMatches());
                      },
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

  Future<void> _showAddDialog(BuildContext context, MatchViewModel viewModel) async {
    final result = await showDialog<Match>(
      context: context,
      builder: (context) => const AddMatchDialog(),
    );

    if (result != null) {
      final created = await viewModel.createMatch(result);
      if (created != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Match created successfully')),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${viewModel.errorMessage ?? "Unknown error"}')),
        );
      }
    }
  }
}

