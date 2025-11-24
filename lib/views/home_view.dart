import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/championship_viewmodel.dart';
import '../viewmodels/player_viewmodel.dart';
import '../viewmodels/match_viewmodel.dart';
import 'championship_list_view.dart';
import 'player_list_view.dart';
import 'match_list_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChampionshipViewModel()..loadChampionships()),
        ChangeNotifierProvider(create: (_) => PlayerViewModel()..loadPlayers()),
        ChangeNotifierProvider(create: (_) => MatchViewModel()..loadMatches()),
      ],
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Score Tracker'),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(icon: Icon(Icons.emoji_events), text: 'Championships'),
              Tab(icon: Icon(Icons.people), text: 'Players'),
              Tab(icon: Icon(Icons.sports_esports), text: 'Matches'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<ChampionshipViewModel>().loadChampionships();
                context.read<PlayerViewModel>().loadPlayers();
                context.read<MatchViewModel>().loadMatches();
              },
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            const ChampionshipListView(),
            const PlayerListView(),
            const MatchListView(),
          ],
        ),
      ),
    );
  }
}

