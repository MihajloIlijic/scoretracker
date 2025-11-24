import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/match_viewmodel.dart';
import '../models/match.dart';
import 'match_detail_view.dart';
import '../widgets/add_match_dialog.dart';

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
                  onPressed: () => viewModel.loadMatches(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (viewModel.matches.isEmpty) {
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
                  onPressed: () => _showAddDialog(context, viewModel),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Match'),
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
                label: const Text('Create New Match'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => viewModel.loadMatches(),
                child: ListView.builder(
                  itemCount: viewModel.matches.length,
                  itemBuilder: (context, index) {
                    final match = viewModel.matches[index];
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
                              builder: (context) => MatchDetailView(match: match),
                            ),
                          ).then((_) => viewModel.loadMatches());
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
                                                fontWeight: isPlayer1Winner && !isDraw
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

