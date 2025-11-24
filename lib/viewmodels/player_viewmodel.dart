import 'package:flutter/foundation.dart';
import '../models/player.dart';
import '../services/api_service.dart';

class PlayerViewModel extends ChangeNotifier {
  List<Player> _players = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Player> get players => _players;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadPlayers({int? championshipId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _players = await ApiService.getAllPlayers(championshipId: championshipId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error loading players: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Player?> createPlayer(Player player) async {
    try {
      final created = await ApiService.createPlayer(player);
      await loadPlayers();
      return created;
    } catch (e) {
      _errorMessage = 'Error creating player: $e';
      notifyListeners();
      return null;
    }
  }

  Future<bool> deletePlayer(int id) async {
    try {
      await ApiService.deletePlayer(id);
      await loadPlayers();
      return true;
    } catch (e) {
      _errorMessage = 'Error deleting player: $e';
      notifyListeners();
      return false;
    }
  }
}

