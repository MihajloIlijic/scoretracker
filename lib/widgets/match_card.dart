import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/match.dart';
import 'status_chip.dart';

class MatchCard extends StatelessWidget {
  final Match match;
  final VoidCallback? onTap;

  const MatchCard({
    super.key,
    required this.match,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPlayer1Winner = match.winner == match.player1;
    final isDraw = match.winner == null && match.status == MatchStatus.finished;
    final statusColor = match.status == MatchStatus.pending
        ? AppTheme.pendingColor
        : match.status == MatchStatus.started
            ? AppTheme.liveColor
            : AppTheme.finishedColor;
    
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border(
          left: BorderSide(
            color: statusColor,
            width: 5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        match.game,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                      ),
                    ),
                    StatusChip.match(match.status),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingM),
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildPlayerScore(
                          context,
                          match.player1,
                          match.player1Score,
                          isPlayer1Winner && !isDraw,
                          match.status == MatchStatus.started,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingS,
                            vertical: AppTheme.spacingXS,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.textSecondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radiusS),
                          ),
                          child: Text(
                            'VS',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textSecondary,
                                  letterSpacing: 1,
                                ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: _buildPlayerScore(
                          context,
                          match.player2,
                          match.player2Score,
                          !isPlayer1Winner && !isDraw && match.winner != null,
                          match.status == MatchStatus.started,
                          isRight: true,
                        ),
                      ),
                    ],
                  ),
                ),
                if (match.status == MatchStatus.finished) ...[
                  const SizedBox(height: AppTheme.spacingS),
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingS),
                    decoration: BoxDecoration(
                      gradient: match.winner != null
                          ? LinearGradient(
                              colors: [
                                Colors.amber.withOpacity(0.1),
                                Colors.orange.withOpacity(0.1),
                              ],
                            )
                          : null,
                      color: match.winner == null ? AppTheme.warningColor.withOpacity(0.1) : null,
                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (match.winner != null) ...[
                          const Icon(Icons.emoji_events_rounded, size: 20, color: Colors.amber),
                          const SizedBox(width: AppTheme.spacingXS),
                          Text(
                            'Winner: ${match.winner}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.amber.shade700,
                                ),
                          ),
                        ] else
                          Text(
                            'Draw',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: AppTheme.warningColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerScore(
    BuildContext context,
    String playerName,
    int score,
    bool isWinner,
    bool isLive, {
    bool isRight = false,
  }) {
    return Column(
      crossAxisAlignment: isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: isRight ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (isWinner && !isRight) ...[
              const Icon(Icons.emoji_events, size: 18, color: Colors.amber),
              const SizedBox(width: AppTheme.spacingXS),
            ],
            Flexible(
              child: Text(
                playerName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: isWinner ? FontWeight.bold : FontWeight.w500,
                      color: isWinner ? AppTheme.successColor : AppTheme.textPrimary,
                    ),
                textAlign: isRight ? TextAlign.end : TextAlign.start,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isWinner && isRight) ...[
              const SizedBox(width: AppTheme.spacingXS),
              const Icon(Icons.emoji_events, size: 18, color: Colors.amber),
            ],
          ],
        ),
        const SizedBox(height: AppTheme.spacingXS),
        Text(
          '$score',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isLive ? AppTheme.liveColor : AppTheme.textPrimary,
              ),
        ),
      ],
    );
  }
}

