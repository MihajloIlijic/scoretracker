import 'package:flutter/foundation.dart';
import '../models/championship.dart';
import '../models/player.dart';
import '../models/match.dart';
import '../services/api_service.dart';

class ChampionshipViewModel extends ChangeNotifier {
  List<Championship> _championships = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Championship> get championships => _championships;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadChampionships() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _championships = await ApiService.getAllChampionships();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error loading championships: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Championship?> createChampionship(Championship championship) async {
    try {
      final created = await ApiService.createChampionship(championship);
      await loadChampionships();
      return created;
    } catch (e) {
      _errorMessage = 'Error creating championship: $e';
      notifyListeners();
      return null;
    }
  }

  Future<bool> deleteChampionship(int id) async {
    try {
      await ApiService.deleteChampionship(id);
      await loadChampionships();
      return true;
    } catch (e) {
      _errorMessage = 'Error deleting championship: $e';
      notifyListeners();
      return false;
    }
  }
}

class ChampionshipDetailViewModel extends ChangeNotifier {
  Championship _championship;
  List<Player> _assignedPlayers = [];
  List<Player> _allPlayers = [];
  List<Match> _matches = [];
  List<Map<String, dynamic>> _standings = [];
  
  bool _isLoadingPlayers = false;
  bool _isLoadingAllPlayers = false;
  bool _isLoadingMatches = false;
  bool _isLoadingStandings = false;
  bool _isFinalizing = false;
  bool _isGeneratingMatches = false;
  String? _errorMessage;

  ChampionshipDetailViewModel(this._championship);

  Championship get championship => _championship;
  List<Player> get assignedPlayers => _assignedPlayers;
  List<Player> get allPlayers => _allPlayers;
  List<Match> get matches => _matches;
  List<Map<String, dynamic>> get standings => _standings;
  
  bool get isLoadingPlayers => _isLoadingPlayers;
  bool get isLoadingAllPlayers => _isLoadingAllPlayers;
  bool get isLoadingMatches => _isLoadingMatches;
  bool get isLoadingStandings => _isLoadingStandings;
  bool get isFinalizing => _isFinalizing;
  bool get isGeneratingMatches => _isGeneratingMatches;
  String? get errorMessage => _errorMessage;

  Future<void> loadPlayers() async {
    if (_championship.id == null) return;
    
    _isLoadingPlayers = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _assignedPlayers = await ApiService.getAllPlayers(championshipId: _championship.id);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error loading players: $e';
    } finally {
      _isLoadingPlayers = false;
      notifyListeners();
    }
  }

  Future<void> loadAllPlayers() async {
    _isLoadingAllPlayers = true;
    notifyListeners();

    try {
      _allPlayers = await ApiService.getAllPlayers();
    } catch (e) {
      // Ignore errors for all players
    } finally {
      _isLoadingAllPlayers = false;
      notifyListeners();
    }
  }

  Future<void> loadMatches() async {
    if (_championship.id == null) return;
    
    _isLoadingMatches = true;
    notifyListeners();

    try {
      _matches = await ApiService.getAllMatches(championshipId: _championship.id);
    } catch (e) {
      // Ignore errors
    } finally {
      _isLoadingMatches = false;
      notifyListeners();
    }
  }

  Future<void> loadStandings() async {
    if (_championship.id == null) return;
    
    _isLoadingStandings = true;
    notifyListeners();

    try {
      _standings = await ApiService.getStandings(_championship.id!);
    } catch (e) {
      // Ignore errors
    } finally {
      _isLoadingStandings = false;
      notifyListeners();
    }
  }

  Future<void> refreshChampionship() async {
    if (_championship.id == null) return;
    
    try {
      final updated = await ApiService.getChampionship(_championship.id!);
      _championship = updated;
      notifyListeners();
      
      if (updated.status == ChampionshipStatus.finalized) {
        await loadStandings();
      }
    } catch (e) {
      // Ignore errors
    }
  }

  Future<bool> finalizeChampionship() async {
    if (_championship.id == null) return false;

    _isFinalizing = true;
    notifyListeners();

    try {
      final finalized = await ApiService.finalizeChampionship(_championship.id!);
      _championship = finalized;
      _isFinalizing = false;
      
      if (finalized.status == ChampionshipStatus.finalized) {
        await loadStandings();
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error finalizing championship: $e';
      _isFinalizing = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> generateMatches() async {
    if (_championship.id == null) return false;

    _isGeneratingMatches = true;
    notifyListeners();

    try {
      await ApiService.generateRoundRobinMatches(_championship.id!);
      _isGeneratingMatches = false;
      await loadMatches();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error generating matches: $e';
      _isGeneratingMatches = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addPlayerToChampionship(Player player) async {
    if (_championship.status == ChampionshipStatus.finalized) {
      _errorMessage = 'Cannot add players to a finalized championship';
      notifyListeners();
      return false;
    }

    try {
      final currentChampionships = player.championships ?? [];
      if (currentChampionships.any((c) => c.id == _championship.id)) {
        _errorMessage = 'Player is already in this championship';
        notifyListeners();
        return false;
      }

      final updatedChampionships = [...currentChampionships, _championship];
      final updatedPlayer = Player(
        id: player.id,
        name: player.name,
        championships: updatedChampionships,
      );

      await ApiService.updatePlayer(updatedPlayer);
      await loadPlayers();
      await loadAllPlayers();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error adding player: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> removePlayerFromChampionship(Player player) async {
    if (_championship.status == ChampionshipStatus.finalized) {
      _errorMessage = 'Cannot remove players from a finalized championship';
      notifyListeners();
      return false;
    }

    if (player.id == null) {
      _errorMessage = 'Error: Player ID is missing';
      notifyListeners();
      return false;
    }

    try {
      final currentChampionships = player.championships ?? [];
      final updatedChampionships = currentChampionships
          .where((c) => c.id != _championship.id)
          .toList();

      final updatedPlayer = Player(
        id: player.id,
        name: player.name,
        championships: updatedChampionships.isEmpty ? null : updatedChampionships,
      );

      await ApiService.updatePlayer(updatedPlayer);
      await loadPlayers();
      await loadAllPlayers();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error removing player: $e';
      notifyListeners();
      return false;
    }
  }
}

