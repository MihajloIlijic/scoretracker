import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'views/home_view.dart';
import 'theme/app_theme.dart';
import 'viewmodels/championship_viewmodel.dart';
import 'viewmodels/player_viewmodel.dart';
import 'viewmodels/match_viewmodel.dart';

void main() {
  runApp(const ScoreTrackerApp());
}

class ScoreTrackerApp extends StatelessWidget {
  const ScoreTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChampionshipViewModel()..loadChampionships()),
        ChangeNotifierProvider(create: (_) => PlayerViewModel()..loadPlayers()),
        ChangeNotifierProvider(create: (_) => MatchViewModel()..loadMatches()),
      ],
      child: MaterialApp(
        title: 'Score Tracker',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const HomeView(),
      ),
    );
  }
}

