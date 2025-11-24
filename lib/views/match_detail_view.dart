import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/match_viewmodel.dart';
import '../models/match.dart';

class MatchDetailView extends StatelessWidget {
  final Match match;

  const MatchDetailView({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MatchDetailViewModel(match)..loadMatch(),
      child: Consumer<MatchDetailViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(viewModel.match.game),
            ),
            body: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => viewModel.loadMatch(),
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
                                  viewModel.match.status == MatchStatus.pending
                                      ? 'Pending'
                                      : viewModel.match.status == MatchStatus.started
                                          ? 'Live'
                                          : 'Finished',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                backgroundColor: viewModel.match.status == MatchStatus.pending
                                    ? Colors.grey.withOpacity(0.2)
                                    : viewModel.match.status == MatchStatus.started
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
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                viewModel.match.player1,
                                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                '${viewModel.match.player1Score}',
                                                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                      color: viewModel.match.status == MatchStatus.started
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
                                                viewModel.match.player2,
                                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                textAlign: TextAlign.end,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                '${viewModel.match.player2Score}',
                                                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                      color: viewModel.match.status == MatchStatus.started
                                                          ? Colors.blue
                                                          : Colors.black,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (viewModel.match.status == MatchStatus.finished && viewModel.match.winner != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 16.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.emoji_events, color: Colors.amber),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Winner: ${viewModel.match.winner}',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.amber,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    else if (viewModel.match.status == MatchStatus.finished && viewModel.match.winner == null)
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
                            if (viewModel.match.status == MatchStatus.pending)
                              ElevatedButton.icon(
                                onPressed: viewModel.isUpdating ? null : () => _startMatch(context, viewModel),
                                icon: viewModel.isUpdating
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
                            else if (viewModel.match.status == MatchStatus.started) ...[
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
                                                Text(viewModel.match.player1),
                                                const SizedBox(height: 8),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(Icons.remove),
                                                      onPressed: viewModel.isUpdating || viewModel.match.player1Score <= 0
                                                          ? null
                                                          : () => _updateScore(
                                                                context,
                                                                viewModel,
                                                                viewModel.match.player1Score - 1,
                                                                viewModel.match.player2Score,
                                                              ),
                                                    ),
                                                    Text(
                                                      '${viewModel.match.player1Score}',
                                                      style: const TextStyle(
                                                        fontSize: 24,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(Icons.add),
                                                      onPressed: viewModel.isUpdating
                                                          ? null
                                                          : () => _updateScore(
                                                                context,
                                                                viewModel,
                                                                viewModel.match.player1Score + 1,
                                                                viewModel.match.player2Score,
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
                                                Text(viewModel.match.player2),
                                                const SizedBox(height: 8),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(Icons.remove),
                                                      onPressed: viewModel.isUpdating || viewModel.match.player2Score <= 0
                                                          ? null
                                                          : () => _updateScore(
                                                                context,
                                                                viewModel,
                                                                viewModel.match.player1Score,
                                                                viewModel.match.player2Score - 1,
                                                              ),
                                                    ),
                                                    Text(
                                                      '${viewModel.match.player2Score}',
                                                      style: const TextStyle(
                                                        fontSize: 24,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(Icons.add),
                                                      onPressed: viewModel.isUpdating
                                                          ? null
                                                          : () => _updateScore(
                                                                context,
                                                                viewModel,
                                                                viewModel.match.player1Score,
                                                                viewModel.match.player2Score + 1,
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
                                onPressed: viewModel.isUpdating ? null : () => _finishMatch(context, viewModel),
                                icon: viewModel.isUpdating
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
        },
      ),
    );
  }

  Future<void> _startMatch(BuildContext context, MatchDetailViewModel viewModel) async {
    final success = await viewModel.startMatch();
    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Match started')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${viewModel.errorMessage ?? "Unknown error"}')),
        );
      }
    }
  }

  Future<void> _updateScore(BuildContext context, MatchDetailViewModel viewModel, int player1Score, int player2Score) async {
    final success = await viewModel.updateScore(player1Score, player2Score);
    if (context.mounted && !success && viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${viewModel.errorMessage}')),
      );
    }
  }

  Future<void> _finishMatch(BuildContext context, MatchDetailViewModel viewModel) async {
    final success = await viewModel.finishMatch();
    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Match finished')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${viewModel.errorMessage ?? "Unknown error"}')),
        );
      }
    }
  }
}

