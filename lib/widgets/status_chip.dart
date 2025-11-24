import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/championship.dart';
import '../models/match.dart';

class StatusChip extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const StatusChip({
    super.key,
    required this.label,
    required this.backgroundColor,
    this.textColor = Colors.white,
  });

  factory StatusChip.championship(ChampionshipStatus status) {
    switch (status) {
      case ChampionshipStatus.finalized:
        return const StatusChip(
          label: 'Finalized',
          backgroundColor: AppTheme.finalizedColor,
        );
      case ChampionshipStatus.draft:
        return const StatusChip(
          label: 'Draft',
          backgroundColor: AppTheme.draftColor,
        );
    }
  }

  factory StatusChip.match(MatchStatus status) {
    switch (status) {
      case MatchStatus.pending:
        return const StatusChip(
          label: 'Pending',
          backgroundColor: AppTheme.pendingColor,
        );
      case MatchStatus.started:
        return const StatusChip(
          label: 'Live',
          backgroundColor: AppTheme.liveColor,
        );
      case MatchStatus.finished:
        return const StatusChip(
          label: 'Finished',
          backgroundColor: AppTheme.finishedColor,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingS,
        vertical: AppTheme.spacingXS,
      ),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
        border: Border.all(
          color: backgroundColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppTheme.spacingXS),
          Text(
            label,
            style: TextStyle(
              color: backgroundColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

